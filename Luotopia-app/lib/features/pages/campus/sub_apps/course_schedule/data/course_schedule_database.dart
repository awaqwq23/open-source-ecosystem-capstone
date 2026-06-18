import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final courseScheduleDbProvider = Provider<CourseScheduleDatabase>((ref) {
  final db = CourseScheduleDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Separate SQLite database for 全校课表 data.
///
/// Uses drift's QueryExecutor for platform-compatible SQLite.
/// Schema managed via raw SQL — no build_runner needed.
class CourseScheduleDatabase {
  QueryExecutor? _executor;
  bool _initialized = false;

  QueryExecutor get executor {
    _executor ??= driftDatabase(name: 'course_schedule');
    return _executor!;
  }

  /// Ensure schema is created. Must be called before any query.
  Future<void> ensureSchema() async {
    if (_initialized) return;
    _initialized = true;

    await _run('''
      CREATE TABLE IF NOT EXISTS course_schedule_classes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        academic_year TEXT NOT NULL DEFAULT '',
        semester INTEGER NOT NULL DEFAULT 0,
        course_code TEXT NOT NULL DEFAULT '',
        course_name TEXT NOT NULL DEFAULT '',
        teaching_class_name TEXT NOT NULL DEFAULT '',
        school TEXT NOT NULL DEFAULT '',
        plan_school TEXT NOT NULL DEFAULT '',
        credits REAL DEFAULT 0,
        course_nature TEXT NOT NULL DEFAULT '',
        course_category TEXT NOT NULL DEFAULT '',
        course_type TEXT NOT NULL DEFAULT '',
        grade TEXT NOT NULL DEFAULT '',
        major TEXT NOT NULL DEFAULT '',
        teacher TEXT NOT NULL DEFAULT '',
        teacher_title TEXT NOT NULL DEFAULT '',
        student_count TEXT NOT NULL DEFAULT '',
        theory_hours INTEGER,
        computer_hours INTEGER,
        experiment_hours INTEGER,
        practice_hours INTEGER,
        schedule_sun TEXT,
        schedule_mon TEXT,
        schedule_tue TEXT,
        schedule_wed TEXT,
        schedule_thu TEXT,
        schedule_fri TEXT,
        schedule_sat TEXT,
        notes TEXT,
        other_teachers TEXT,
        textbook TEXT,
        publisher TEXT
      )
    ''');
    await _run('CREATE INDEX IF NOT EXISTS idx_csc_term ON course_schedule_classes(academic_year, semester)');
    await _run('CREATE INDEX IF NOT EXISTS idx_csc_course_code ON course_schedule_classes(course_code)');
    await _run('CREATE INDEX IF NOT EXISTS idx_csc_course_name ON course_schedule_classes(course_name)');
    await _run('CREATE INDEX IF NOT EXISTS idx_csc_teacher ON course_schedule_classes(teacher)');
    await _run('CREATE INDEX IF NOT EXISTS idx_csc_school ON course_schedule_classes(school)');
    await _run('CREATE INDEX IF NOT EXISTS idx_csc_grade ON course_schedule_classes(grade)');
  }

  Future<void> _run(String sql) => executor.runCustom(sql);

  /// Execute an arbitrary SQL statement (DDL, REINDEX, etc.).
  Future<void> execute(String sql) => _run(sql);

  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?> args = const []]) {
    return executor.runSelect(sql, args);
  }

  Future<int> rawInsert(String sql, [List<Object?> args = const []]) {
    return executor.runInsert(sql, args);
  }

  Future<bool> hasData() async {
    final rows = await rawQuery('SELECT COUNT(*) AS cnt FROM course_schedule_classes');
    return (rows.firstOrNull?['cnt'] as int? ?? 0) > 0;
  }

  Future<void> close() async {
    await executor.close();
  }
}
