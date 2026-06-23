import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localDatabaseBackupServiceProvider = Provider<LocalDatabaseBackupService>(
  (ref) => LocalDatabaseBackupService(
    db: ref.read(appDatabaseProvider),
    syncCursorStore: ref.read(syncCursorStoreProvider),
    preferences: ref.read(sharedPreferencesProvider),
  ),
);

class LocalDatabaseBackupService {
  const LocalDatabaseBackupService({
    required AppDatabase db,
    required SyncCursorStore syncCursorStore,
    required SharedPreferences? preferences,
  }) : _db = db,
       _syncCursorStore = syncCursorStore,
       _preferences = preferences;

  final AppDatabase _db;
  final SyncCursorStore _syncCursorStore;
  final SharedPreferences? _preferences;

  Future<LocalDatabaseBackupFile> exportDatabase() async {
    final directory = await getTemporaryDirectory();
    final fileName = 'luotopia-db-${_timestamp(DateTime.now())}.sqlite';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    if (await file.exists()) {
      await file.delete();
    }

    await _db.customStatement('VACUUM INTO ${_sqlString(file.path)}');
    await _prepareExportedBackup(file.path);
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
      await _validateBackup(alias, metadata);
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        await _db.transaction(() async {
          await _deleteCurrentNonCourseRows();
          await _copyRows(alias);
          await _validateImportedRows();
        });
        _notifyImportedTablesUpdated();
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON');
      }
      await _restoreBackupPreferences(alias);
      await _syncCursorStore.reset();
    } finally {
      await _db.customStatement('DETACH DATABASE $alias');
    }
  }

  Future<void> _prepareExportedBackup(String path) async {
    const alias = 'exported_backup';
    await _db.customStatement('ATTACH DATABASE ${_sqlString(path)} AS $alias');
    try {
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        await _db.customStatement(
          'PRAGMA $alias.user_version = ${_db.schemaVersion}',
        );
        await _sanitizeBackupRows(alias);
        await _writeBackupPreferences(alias);
        await _writeBackupMetadata(alias);
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON');
      }
    } finally {
      await _db.customStatement('DETACH DATABASE $alias');
    }
  }

  Future<void> _writeBackupMetadata(String alias) async {
    await _db.customStatement('DROP TABLE IF EXISTS $alias.$_metadataTable');
    await _db.customStatement('''
      CREATE TABLE $alias.$_metadataTable (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    final metadata = {
      'format_version': '3',
      'schema_version': _db.schemaVersion.toString(),
      'backup_scope': _backupScope,
      'created_at': DateTime.now().toIso8601String(),
    };
    for (final entry in metadata.entries) {
      await _db.customStatement('''
        INSERT INTO $alias.$_metadataTable (key, value)
        VALUES (${_sqlString(entry.key)}, ${_sqlString(entry.value)})
      ''');
    }
  }

  Future<Map<String, String>> _readBackupMetadata(String alias) async {
    final table = await _db.customSelect('''
      SELECT name
      FROM $alias.sqlite_master
      WHERE type = 'table' AND name = ${_sqlString(_metadataTable)}
    ''').getSingleOrNull();
    if (table == null) {
      return const {};
    }
    final rows = await _db
        .customSelect('SELECT key, value FROM $alias.$_metadataTable')
        .get();
    return {
      for (final row in rows)
        row.data['key'] as String? ?? '': row.data['value'] as String? ?? '',
    };
  }

  Future<void> _validateBackup(
    String alias,
    Map<String, String> metadata,
  ) async {
    final userVersion = await _db
        .customSelect('PRAGMA $alias.user_version')
        .getSingleOrNull();
    final version = (userVersion?.data['user_version'] as int?) ?? 0;
    if (version != _db.schemaVersion) {
      throw LocalDatabaseBackupException(
        '数据库导入失败：备份版本 $version 与当前版本 ${_db.schemaVersion} 不兼容',
      );
    }
    if (metadata['format_version'] != '3' ||
        metadata['schema_version'] != _db.schemaVersion.toString() ||
        metadata['backup_scope'] != _backupScope) {
      throw const LocalDatabaseBackupException('数据库导入失败：备份格式不兼容');
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

    final courseRow = await _db.customSelect('''
      SELECT id
      FROM $alias.agenda_item_rows
      WHERE deleted_at IS NULL AND type = 'course'
      LIMIT 1
    ''').getSingleOrNull();
    if (courseRow != null) {
      throw const LocalDatabaseBackupException('数据库导入失败：备份包含课程事项');
    }

    final preferencesTable = await _db.customSelect('''
      SELECT name
      FROM $alias.sqlite_master
      WHERE type = 'table' AND name = ${_sqlString(_preferencesTable)}
    ''').getSingleOrNull();
    if (preferencesTable == null) {
      throw const LocalDatabaseBackupException('数据库导入失败：缺少个人配置表');
    }
  }

  Future<void> _deleteCurrentNonCourseRows() async {
    await _db.customStatement('''
      DELETE FROM schedule_item_detail_rows
      WHERE item_id IN (
        SELECT id FROM agenda_item_rows
        WHERE type = 'schedule'
      )
    ''');
    await _db.customStatement('''
      DELETE FROM task_item_detail_rows
      WHERE item_id IN (
        SELECT id FROM agenda_item_rows
        WHERE type = 'task'
      )
    ''');
    await _db.customStatement('''
      DELETE FROM agenda_item_rows
      WHERE type IN ('schedule', 'task', 'memo')
    ''');
    await _db.customStatement('''
      DELETE FROM sync_tombstone_rows
      WHERE entity_type = 'agenda_item'
    ''');
  }

  Future<void> _copyRows(String alias) async {
    await _copyAgendaRows(alias);
    await _copyDetailRows(alias, 'schedule_item_detail_rows');
    await _copyDetailRows(alias, 'task_item_detail_rows');
  }

  Future<void> _copyAgendaRows(String alias) async {
    await _db.customStatement('''
      INSERT INTO agenda_item_rows (
        id, type, title, notes, location, color, reminder, repeat_rule,
        is_completed, completed_at, sort_order, source_kind, source_ref,
        remote_id, revision, dirty, deleted_at, last_synced_at,
        created_at, updated_at
      )
      SELECT
        id, type, title, notes, location, color, reminder, repeat_rule,
        is_completed, completed_at, sort_order, source_kind, source_ref,
        NULL, 0, TRUE, NULL, NULL, created_at, updated_at
      FROM $alias.agenda_item_rows
      WHERE type IN ('schedule', 'task', 'memo') AND deleted_at IS NULL
    ''');
  }

  Future<void> _copyDetailRows(String alias, String table) async {
    final columns = _columnsByTable[table]!;
    final columnList = columns.map(_sqlIdentifier).join(', ');
    final tableName = _sqlIdentifier(table);
    await _db.customStatement('''
      INSERT INTO $tableName ($columnList)
      SELECT $columnList
      FROM $alias.$tableName
      WHERE item_id IN (
        SELECT id
        FROM $alias.agenda_item_rows
        WHERE deleted_at IS NULL
          AND type = ${_sqlString(table == 'task_item_detail_rows' ? 'task' : 'schedule')}
      )
    ''');
  }

  Future<void> _sanitizeBackupRows(String alias) async {
    await _db.customStatement('''
      DELETE FROM $alias.schedule_item_detail_rows
      WHERE item_id NOT IN (
        SELECT id FROM $alias.agenda_item_rows
        WHERE type = 'schedule' AND deleted_at IS NULL
      )
    ''');
    await _db.customStatement('''
      DELETE FROM $alias.task_item_detail_rows
      WHERE item_id NOT IN (
        SELECT id FROM $alias.agenda_item_rows
        WHERE type = 'task' AND deleted_at IS NULL
      )
    ''');
    await _db.customStatement('''
      DELETE FROM $alias.agenda_item_rows
      WHERE type NOT IN ('schedule', 'task', 'memo') OR deleted_at IS NOT NULL
    ''');
    await _db.customStatement('''
      UPDATE $alias.agenda_item_rows
      SET remote_id = NULL,
          revision = 0,
          dirty = TRUE,
          deleted_at = NULL,
          last_synced_at = NULL
    ''');
    for (final table in _excludedTables) {
      if (await _tableExists(alias, table)) {
        await _db.customStatement(
          'DELETE FROM $alias.${_sqlIdentifier(table)}',
        );
      }
    }
  }

  Future<void> _writeBackupPreferences(String alias) async {
    await _db.customStatement('DROP TABLE IF EXISTS $alias.$_preferencesTable');
    await _db.customStatement('''
      CREATE TABLE $alias.$_preferencesTable (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    for (final key in _preferenceBackupKeys) {
      final value = preferences.getString(key);
      if (value == null) {
        continue;
      }
      await _db.customStatement('''
        INSERT INTO $alias.$_preferencesTable (key, value)
        VALUES (${_sqlString(key)}, ${_sqlString(value)})
      ''');
    }
  }

  Future<void> _restoreBackupPreferences(String alias) async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    for (final key in _preferenceBackupKeys) {
      await preferences.remove(key);
    }
    final rows = await _db
        .customSelect('SELECT key, value FROM $alias.$_preferencesTable')
        .get();
    for (final row in rows) {
      final key = row.data['key'] as String? ?? '';
      if (!_preferenceBackupKeys.contains(key)) {
        continue;
      }
      await preferences.setString(key, row.data['value'] as String? ?? '');
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
        )
      LIMIT 1
    ''').getSingleOrNull();
    if (missingDetails != null) {
      throw LocalDatabaseBackupException(
        '数据库导入失败：${missingDetails.data['id']} 缺少事项详情',
      );
    }
  }

  void _notifyImportedTablesUpdated() {
    _db.markTablesUpdated([
      _db.agendaItemRows,
      _db.scheduleItemDetailRows,
      _db.taskItemDetailRows,
      _db.syncTombstoneRows,
    ]);
  }

  Future<bool> _tableExists(String alias, String table) async {
    final row = await _db.customSelect('''
      SELECT name
      FROM $alias.sqlite_master
      WHERE type = 'table' AND name = ${_sqlString(table)}
    ''').getSingleOrNull();
    return row != null;
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

const _metadataTable = '_luotopia_backup_metadata';
const _preferencesTable = '_luotopia_backup_preferences';
const _backupScope = 'user_data_non_course';

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
];

final _columnsByTable = {
  for (final table in _backupTables) table.name: table.columns,
};

const _excludedTables = [
  'course_meeting_rule_week_rows',
  'course_instance_week_rows',
  'course_instance_rows',
  'course_occurrence_rows',
  'course_meeting_rule_rows',
  'course_source_rows',
  'course_audience_rows',
  'course_offering_rows',
  'course_instructor_course_rows',
  'course_term_course_rows',
  'course_catalog_rows',
  'school_timetable_term_rows',
  'course_item_detail_rows',
  'selected_course_timetable_rows',
  'course_timetable_rows',
  'sync_tombstone_rows',
];

const _preferenceBackupKeys = {
  AppBootstrapStorageKeys.locale,
  AppBootstrapStorageKeys.themeMode,
  AppBootstrapStorageKeys.homeSettings,
  AppBootstrapStorageKeys.aiSettings,
  AppBootstrapStorageKeys.widgetSettings,
  AppBootstrapStorageKeys.navigationSettings,
  AppBootstrapStorageKeys.aiSessions,
  AppBootstrapStorageKeys.activeAiSessionId,
  'empty_classroom_filter_snapshot',
};
