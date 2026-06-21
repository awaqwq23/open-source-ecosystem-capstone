import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';
import 'package:path_provider/path_provider.dart';

final localDatabaseBackupServiceProvider = Provider<LocalDatabaseBackupService>(
  (ref) => LocalDatabaseBackupService(
    db: ref.read(appDatabaseProvider),
    syncCursorStore: ref.read(syncCursorStoreProvider),
  ),
);

class LocalDatabaseBackupService {
  const LocalDatabaseBackupService({
    required AppDatabase db,
    required SyncCursorStore syncCursorStore,
  }) : _db = db,
       _syncCursorStore = syncCursorStore;

  final AppDatabase _db;
  final SyncCursorStore _syncCursorStore;

  Future<LocalDatabaseBackupFile> exportDatabase() async {
    final directory = await getTemporaryDirectory();
    final fileName = 'luotopia-db-${_timestamp(DateTime.now())}.sqlite';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    if (await file.exists()) {
      await file.delete();
    }

    await _db.customStatement('VACUUM INTO ${_sqlString(file.path)}');
    await _writeBackupMetadata(file.path);
    if (!await file.exists() || await file.length() == 0) {
      throw const LocalDatabaseBackupException('数据库导出失败：未生成备份文件');
    }
    return LocalDatabaseBackupFile(path: file.path, fileName: fileName);
  }

  Future<void> importDatabase(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw const LocalDatabaseBackupException('数据库导入失败：文件不存在');
    }

    const alias = 'backup';
    await _db.customStatement('ATTACH DATABASE ${_sqlString(path)} AS $alias');
    try {
      final metadata = await _readBackupMetadata(alias);
      await _validateBackup(alias);
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        await _db.transaction(() async {
          await _deleteCurrentRows();
          await _copyRows(alias);
          await _validateImportedRows();
        });
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON');
      }
      await _syncCursorStore.restore(
        cursor: metadata.syncCursor,
        lastSyncedAt: metadata.syncLastSyncedAt,
      );
    } finally {
      await _db.customStatement('DETACH DATABASE $alias');
    }
  }

  Future<void> _writeBackupMetadata(String path) async {
    const alias = 'exported_backup';
    await _db.customStatement('ATTACH DATABASE ${_sqlString(path)} AS $alias');
    try {
      await _db.customStatement('DROP TABLE IF EXISTS $alias.$_metadataTable');
      await _db.customStatement('''
        CREATE TABLE $alias.$_metadataTable (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      final createdAt = DateTime.now().toIso8601String();
      final metadata = {
        'format_version': '2',
        'schema_version': _currentSchemaVersion.toString(),
        'created_at': createdAt,
        'sync_cursor': _syncCursorStore.read().toString(),
        'sync_last_synced_at':
            _syncCursorStore.readLastSyncedAt()?.toIso8601String() ?? '',
      };
      for (final entry in metadata.entries) {
        await _db.customStatement('''
          INSERT INTO $alias.$_metadataTable (key, value)
          VALUES (${_sqlString(entry.key)}, ${_sqlString(entry.value)})
        ''');
      }
    } finally {
      await _db.customStatement('DETACH DATABASE $alias');
    }
  }

  Future<_BackupMetadata> _readBackupMetadata(String alias) async {
    final table = await _db.customSelect('''
      SELECT name
      FROM $alias.sqlite_master
      WHERE type = 'table' AND name = ${_sqlString(_metadataTable)}
    ''').getSingleOrNull();
    if (table == null) {
      return const _BackupMetadata(syncCursor: 0);
    }
    final rows = await _db
        .customSelect('SELECT key, value FROM $alias.$_metadataTable')
        .get();
    final values = {
      for (final row in rows)
        row.data['key'] as String? ?? '': row.data['value'] as String? ?? '',
    };
    final cursor = int.tryParse(values['sync_cursor'] ?? '') ?? 0;
    final lastSyncedAt = DateTime.tryParse(values['sync_last_synced_at'] ?? '');
    return _BackupMetadata(syncCursor: cursor, syncLastSyncedAt: lastSyncedAt);
  }

  Future<void> _validateBackup(String alias) async {
    final userVersion = await _db
        .customSelect('PRAGMA $alias.user_version')
        .getSingleOrNull();
    final version = (userVersion?.data['user_version'] as int?) ?? 0;
    if (version != _currentSchemaVersion) {
      throw LocalDatabaseBackupException(
        '数据库导入失败：备份版本 $version 与当前版本 $_currentSchemaVersion 不兼容',
      );
    }

    for (final table in _backupTables) {
      final exists = await _db.customSelect('''
            SELECT name
            FROM $alias.sqlite_master
            WHERE type = 'table' AND name = ${_sqlString(table.name)}
            ''').getSingleOrNull();
      if (exists == null) {
        throw LocalDatabaseBackupException('数据库导入失败：缺少 ${table.name} 表');
      }

      final columns = await _db
          .customSelect(
            'PRAGMA $alias.table_info(${_sqlIdentifier(table.name)})',
          )
          .get();
      final columnNames = {
        for (final row in columns) row.data['name'] as String? ?? '',
      };
      final missing = table.columns.where(
        (name) => !columnNames.contains(name),
      );
      if (missing.isNotEmpty) {
        throw LocalDatabaseBackupException(
          '数据库导入失败：${table.name} 缺少 ${missing.first} 字段',
        );
      }
    }
  }

  Future<void> _deleteCurrentRows() async {
    for (final table in _deleteOrder) {
      await _db.customStatement('DELETE FROM ${_sqlIdentifier(table)}');
    }
  }

  Future<void> _copyRows(String alias) async {
    for (final table in _copyOrder) {
      final columns = _columnsByTable[table]!;
      final columnList = columns.map(_sqlIdentifier).join(', ');
      final tableName = _sqlIdentifier(table);
      await _db.customStatement('''
        INSERT INTO $tableName ($columnList)
        SELECT $columnList FROM $alias.$tableName
      ''');
    }
  }

  Future<void> _validateImportedRows() async {
    final foreignKeyRows = await _db
        .customSelect('PRAGMA foreign_key_check')
        .get();
    if (foreignKeyRows.isNotEmpty) {
      final row = foreignKeyRows.first.data;
      throw LocalDatabaseBackupException(
        '数据库导入失败：${row['table'] ?? '未知表'} 存在无效外键',
      );
    }

    final missingDetails = await _db.customSelect('''
      SELECT id, type
      FROM agenda_item_rows
      WHERE deleted_at IS NULL
        AND (
          (type = 'schedule' AND NOT EXISTS (
            SELECT 1 FROM schedule_item_detail_rows
            WHERE item_id = agenda_item_rows.id
          ))
          OR (type = 'task' AND NOT EXISTS (
            SELECT 1 FROM task_item_detail_rows
            WHERE item_id = agenda_item_rows.id
          ))
          OR (type = 'course' AND NOT EXISTS (
            SELECT 1 FROM course_item_detail_rows
            WHERE item_id = agenda_item_rows.id
          ))
        )
      LIMIT 1
    ''').getSingleOrNull();
    if (missingDetails != null) {
      throw LocalDatabaseBackupException(
        '数据库导入失败：${missingDetails.data['id']} 缺少事项详情',
      );
    }
  }

  String _timestamp(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.year}${two(value.month)}${two(value.day)}-'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}';
  }

  String _sqlString(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  String _sqlIdentifier(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}

class LocalDatabaseBackupFile {
  const LocalDatabaseBackupFile({required this.path, required this.fileName});

  final String path;
  final String fileName;
}

class LocalDatabaseBackupException implements Exception {
  const LocalDatabaseBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _BackupTable {
  const _BackupTable(this.name, this.columns);

  final String name;
  final List<String> columns;
}

class _BackupMetadata {
  const _BackupMetadata({required this.syncCursor, this.syncLastSyncedAt});

  final int syncCursor;
  final DateTime? syncLastSyncedAt;
}

const _currentSchemaVersion = 8;
const _metadataTable = '_luotopia_backup_metadata';

const _backupTables = [
  _BackupTable('agenda_item_rows', [
    'id',
    'type',
    'title',
    'notes',
    'location',
    'color',
    'reminder',
    'repeat_rule',
    'is_completed',
    'completed_at',
    'sort_order',
    'source_kind',
    'source_ref',
    'remote_id',
    'revision',
    'dirty',
    'deleted_at',
    'last_synced_at',
    'created_at',
    'updated_at',
  ]),
  _BackupTable('schedule_item_detail_rows', [
    'item_id',
    'start_at',
    'end_at',
    'is_all_day',
    'countdown_enabled',
    'auto_completed_once_at',
  ]),
  _BackupTable('task_item_detail_rows', ['item_id', 'deadline_at']),
  _BackupTable('course_item_detail_rows', [
    'item_id',
    'start_at',
    'end_at',
    'is_all_day',
    'timetable_id',
    'source_kind',
    'source_course_id',
    'course_nature',
    'instructor',
    'week_meta',
    'term_course_id',
    'offering_id',
    'instructor_course_id',
    'occurrence_id',
  ]),
  _BackupTable('course_timetable_rows', [
    'id',
    'name',
    'source',
    'term_label',
    'remote_id',
    'revision',
    'dirty',
    'deleted_at',
    'last_synced_at',
    'created_at',
    'updated_at',
  ]),
  _BackupTable('selected_course_timetable_rows', [
    'timetable_id',
    'sort_order',
    'revision',
    'dirty',
    'deleted_at',
    'last_synced_at',
    'updated_at',
  ]),
  _BackupTable('sync_tombstone_rows', [
    'entity_type',
    'entity_id',
    'revision',
    'dirty',
    'deleted_at',
  ]),
  _BackupTable('school_timetable_term_rows', [
    'term_key',
    'school_year',
    'term',
    'first_week_monday',
    'source_version',
    'row_count',
    'imported_at',
    'updated_at',
  ]),
  _BackupTable('course_catalog_rows', [
    'id',
    'catalog_key',
    'course_no',
    'course_name',
    'credits',
    'search_text',
  ]),
  _BackupTable('course_term_course_rows', [
    'id',
    'term_key',
    'catalog_id',
    'course_no',
    'course_name',
    'open_college',
    'credits',
    'course_nature',
    'course_category',
    'open_type',
    'teaching_class_count',
    'teacher_summary',
    'weekday_summary',
    'search_text',
  ]),
  _BackupTable('course_instructor_course_rows', [
    'id',
    'catalog_id',
    'course_no',
    'course_name',
    'credits',
    'instructor_name',
    'instructor_name_key',
    'offering_count',
    'latest_term_key',
    'latest_open_college',
    'latest_teaching_title',
    'search_text',
  ]),
  _BackupTable('course_offering_rows', [
    'id',
    'term_key',
    'term_course_id',
    'catalog_id',
    'instructor_course_id',
    'source_key',
    'package_index',
    'source_status',
    'school_year',
    'term',
    'teaching_class_name',
    'course_no',
    'course_name',
    'open_college',
    'plan_college',
    'credits',
    'course_nature',
    'course_category',
    'open_type',
    'grade',
    'major',
    'instructor',
    'title',
    'people_raw',
    'theory_hours',
    'computer_hours',
    'experiment_hours',
    'practice_hours',
    'sunday_raw',
    'monday_raw',
    'tuesday_raw',
    'wednesday_raw',
    'thursday_raw',
    'friday_raw',
    'saturday_raw',
    'remark',
    'other_teachers',
    'textbook',
    'publisher',
    'open_department_code',
    'college_code',
    'major_code',
    'grade_code',
    'school_year_code',
    'term_code',
    'course_category_code',
    'condition_code',
    'open_type_code',
    'course_nature_code',
    'note',
    'schedule_summary',
    'weekday_summary',
    'search_text',
    'original_fields_json',
  ]),
  _BackupTable('course_audience_rows', [
    'id',
    'term_key',
    'offering_id',
    'term_course_id',
    'catalog_id',
    'grade',
    'major',
    'plan_college',
    'course_nature',
    'course_nature_code',
    'course_category',
    'course_category_code',
    'open_type',
    'open_type_code',
    'condition_code',
  ]),
  _BackupTable('course_source_rows', [
    'id',
    'term_key',
    'term_course_id',
    'offering_id',
    'source_key',
    'package_index',
    'source_status',
    'original_fields_json',
  ]),
  _BackupTable('course_meeting_rule_rows', [
    'id',
    'offering_id',
    'term_key',
    'term_course_id',
    'catalog_id',
    'weekday',
    'segment_index',
    'weekday_label',
    'raw_text',
    'week_text',
    'section_text',
    'location_text',
    'building',
    'room',
  ]),
  _BackupTable('course_occurrence_rows', [
    'id',
    'rule_id',
    'offering_id',
    'term_key',
    'term_course_id',
    'catalog_id',
    'date',
    'week_index',
    'weekday',
    'section_text',
    'location_text',
    'building',
    'room',
  ]),
];

final _columnsByTable = {
  for (final table in _backupTables) table.name: table.columns,
};

const _deleteOrder = [
  'course_occurrence_rows',
  'course_meeting_rule_rows',
  'course_source_rows',
  'course_audience_rows',
  'course_offering_rows',
  'course_instructor_course_rows',
  'course_term_course_rows',
  'course_catalog_rows',
  'school_timetable_term_rows',
  'schedule_item_detail_rows',
  'task_item_detail_rows',
  'course_item_detail_rows',
  'selected_course_timetable_rows',
  'agenda_item_rows',
  'course_timetable_rows',
  'sync_tombstone_rows',
];

const _copyOrder = [
  'agenda_item_rows',
  'course_timetable_rows',
  'school_timetable_term_rows',
  'course_catalog_rows',
  'course_term_course_rows',
  'course_instructor_course_rows',
  'course_offering_rows',
  'course_audience_rows',
  'course_source_rows',
  'course_meeting_rule_rows',
  'course_occurrence_rows',
  'schedule_item_detail_rows',
  'task_item_detail_rows',
  'course_item_detail_rows',
  'selected_course_timetable_rows',
  'sync_tombstone_rows',
];
