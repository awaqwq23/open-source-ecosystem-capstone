import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:path_provider/path_provider.dart';

final localDatabaseBackupServiceProvider = Provider<LocalDatabaseBackupService>(
  (ref) => LocalDatabaseBackupService(ref.read(appDatabaseProvider)),
);

class LocalDatabaseBackupService {
  const LocalDatabaseBackupService(this._db);

  final AppDatabase _db;

  Future<LocalDatabaseBackupFile> exportDatabase() async {
    final directory = await getTemporaryDirectory();
    final fileName = 'luotopia-db-${_timestamp(DateTime.now())}.sqlite';
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    if (await file.exists()) {
      await file.delete();
    }

    await _db.customStatement('VACUUM INTO ${_sqlString(file.path)}');
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
      await _validateBackup(alias);
      await _db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        await _db.transaction(() async {
          await _deleteCurrentRows();
          await _copyRows(alias);
        });
      } finally {
        await _db.customStatement('PRAGMA foreign_keys = ON');
      }
    } finally {
      await _db.customStatement('DETACH DATABASE $alias');
    }
  }

  Future<void> _validateBackup(String alias) async {
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
          .customSelect('PRAGMA $alias.table_info(${_sqlString(table.name)})')
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
      await _db.customStatement('DELETE FROM $table');
    }
  }

  Future<void> _copyRows(String alias) async {
    for (final table in _copyOrder) {
      final columns = _columnsByTable[table]!;
      final columnList = columns.join(', ');
      await _db.customStatement('''
        INSERT INTO $table ($columnList)
        SELECT $columnList FROM $alias.$table
      ''');
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
];

final _columnsByTable = {
  for (final table in _backupTables) table.name: table.columns,
};

const _deleteOrder = [
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
  'schedule_item_detail_rows',
  'task_item_detail_rows',
  'course_item_detail_rows',
  'selected_course_timetable_rows',
  'sync_tombstone_rows',
];
