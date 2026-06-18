import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/course_group.dart';
import '../domain/models/teaching_class.dart';
import 'course_schedule_database.dart';
import 'course_schedule_seeder.dart';

final courseScheduleRepositoryProvider = Provider<CourseScheduleRepository>((ref) {
  final db = ref.watch(courseScheduleDbProvider);
  return CourseScheduleRepository(db);
});

/// Repository for querying course schedule data.
///
/// All queries use raw SQL for performance and control over indexes.
/// The database has indexes on:
///   - (academic_year, semester): term filtering
///   - course_code: grouping for Level-1
///   - course_name, teacher, school, grade: search/filter
class CourseScheduleRepository {
  const CourseScheduleRepository(this._db);

  final CourseScheduleDatabase _db;

  /// Ensure schema exists and seed mock data if the database is empty.
  Future<void> seedIfNeeded() async {
    await _db.ensureSchema();
    await CourseScheduleSeeder(_db).seedIfNeeded();
  }

  // ── Level 1: search / filter ──

  /// Search course groups by keyword across multiple fields.
  ///
  /// Returns aggregated rows (one per unique course code).
  /// Uses LIKE on indexed columns for efficient prefix matching.
  Future<List<CourseGroup>> searchGroups({
    String? keyword,
    String? academicYear,
    int? semester,
    String? school,
    String? grade,
  }) async {
    final conditions = <String>[];
    final args = <Object?>[];

    // Apply term filter (mandatory for performance — always scope to a term)
    if (academicYear != null) {
      conditions.add('cs.academic_year = ?');
      args.add(academicYear);
    }
    if (semester != null) {
      conditions.add('cs.semester = ?');
      args.add(semester);
    }

    if (keyword != null && keyword.isNotEmpty) {
      final like = '%$keyword%';
      // Search across multiple text fields
      conditions.add('(cs.course_name LIKE ? OR cs.course_code LIKE ? OR cs.teacher LIKE ? OR cs.school LIKE ? OR cs.teaching_class_name LIKE ?)');
      args.addAll([like, like, like, like, like]);
    }
    if (school != null && school.isNotEmpty) {
      conditions.add('cs.school = ?');
      args.add(school);
    }
    if (grade != null && grade.isNotEmpty) {
      conditions.add('cs.grade = ?');
      args.add(grade);
    }

    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';

    // Aggregate: one row per course_code, with summary fields
    final sql = '''
      SELECT
        cs.course_code,
        cs.course_name,
        cs.academic_year,
        cs.semester,
        cs.credits,
        cs.school,
        cs.course_nature,
        cs.course_category,
        COUNT(*) AS teaching_class_count,
        -- Teacher summary: first few unique teachers
        (SELECT GROUP_CONCAT(DISTINCT t.teacher, '、')
         FROM (
           SELECT teacher FROM course_schedule_classes
           WHERE course_code = cs.course_code
             AND academic_year = cs.academic_year
             AND semester = cs.semester
           GROUP BY teacher
           LIMIT 5
         ) t
        ) AS teacher_summary,
        -- Grade summary
        (SELECT GROUP_CONCAT(DISTINCT grade)
         FROM course_schedule_classes
         WHERE course_code = cs.course_code
           AND academic_year = cs.academic_year
           AND semester = cs.semester
         ORDER BY grade
        ) AS grade_summary,
        -- Day-of-week summary (which days have classes)
        (SELECT GROUP_CONCAT(DISTINCT day_abbr)
         FROM (
           SELECT '周一' AS day_abbr FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_mon IS NOT NULL AND schedule_mon != ''
           UNION SELECT '周二' FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_tue IS NOT NULL AND schedule_tue != ''
           UNION SELECT '周三' FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_wed IS NOT NULL AND schedule_wed != ''
           UNION SELECT '周四' FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_thu IS NOT NULL AND schedule_thu != ''
           UNION SELECT '周五' FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_fri IS NOT NULL AND schedule_fri != ''
           UNION SELECT '周六' FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_sat IS NOT NULL AND schedule_sat != ''
           UNION SELECT '周日' FROM course_schedule_classes
           WHERE course_code = cs.course_code AND schedule_sun IS NOT NULL AND schedule_sun != ''
         )
        ) AS schedule_day_summary
      FROM course_schedule_classes cs
      $where
      GROUP BY cs.course_code, cs.academic_year, cs.semester
      ORDER BY cs.course_name
    ''';

    final rows = await _db.rawQuery(sql, args);
    return rows.map(_rowToCourseGroup).toList();
  }

  /// Count of groups matching the given filters.
  Future<int> countGroups({
    String? keyword,
    String? academicYear,
    int? semester,
    String? school,
    String? grade,
  }) async {
    final conditions = <String>[];
    final args = <Object?>[];

    if (academicYear != null) {
      conditions.add('academic_year = ?');
      args.add(academicYear);
    }
    if (semester != null) {
      conditions.add('semester = ?');
      args.add(semester);
    }
    if (keyword != null && keyword.isNotEmpty) {
      final like = '%$keyword%';
      conditions.add('(course_name LIKE ? OR course_code LIKE ? OR teacher LIKE ?)');
      args.addAll([like, like, like]);
    }
    if (school != null) {
      conditions.add('school = ?');
      args.add(school);
    }
    if (grade != null) {
      conditions.add('grade = ?');
      args.add(grade);
    }

    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    final sql = 'SELECT COUNT(DISTINCT course_code) AS cnt FROM course_schedule_classes $where';
    final rows = await _db.rawQuery(sql, args);
    return rows.first['cnt'] as int? ?? 0;
  }

  // ── Level 2: teaching classes for a course code ──

  /// List all teaching classes sharing the same course code + term.
  Future<List<TeachingClass>> getTeachingClasses({
    required String courseCode,
    required String academicYear,
    required int semester,
  }) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM course_schedule_classes WHERE course_code = ? AND academic_year = ? AND semester = ? ORDER BY teacher, teaching_class_name',
      [courseCode, academicYear, semester],
    );
    return rows.map(TeachingClass.fromDbRow).toList();
  }

  // ── Level 3: single teaching class detail ──

  /// Get a single teaching class by its primary key.
  Future<TeachingClass?> getTeachingClassById(int id) async {
    final rows = await _db.rawQuery(
      'SELECT * FROM course_schedule_classes WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return TeachingClass.fromDbRow(rows.first);
  }

  // ── Filter dimension helpers ──

  /// List distinct schools that have courses in the given term.
  Future<List<String>> getSchools(String academicYear, int semester) async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT school FROM course_schedule_classes WHERE academic_year = ? AND semester = ? ORDER BY school',
      [academicYear, semester],
    );
    return rows.map((r) => r['school'] as String? ?? '').where((s) => s.isNotEmpty).toList();
  }

  /// List distinct grades in the given term.
  Future<List<String>> getGrades(String academicYear, int semester) async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT grade FROM course_schedule_classes WHERE academic_year = ? AND semester = ? ORDER BY grade',
      [academicYear, semester],
    );
    return rows.map((r) => r['grade'] as String? ?? '').where((s) => s.isNotEmpty).toList();
  }

  /// List all available terms.
  Future<List<({String academicYear, int semester})>> getTerms() async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT academic_year, semester FROM course_schedule_classes ORDER BY academic_year DESC, semester DESC',
    );
    return rows.map((r) => (
      academicYear: r['academic_year'] as String? ?? '',
      semester: r['semester'] as int? ?? 0,
    )).toList();
  }

  /// Re-index for maintenance.
  Future<void> reindex() async {
    await _db.execute('REINDEX idx_csc_term');
    await _db.execute('REINDEX idx_csc_course_code');
    await _db.execute('REINDEX idx_csc_course_name');
    await _db.execute('REINDEX idx_csc_teacher');
    await _db.execute('REINDEX idx_csc_school');
    await _db.execute('REINDEX idx_csc_grade');
  }

  // ── Helpers ──

  CourseGroup _rowToCourseGroup(Map<String, Object?> row) {
    return CourseGroup(
      courseCode: (row['course_code'] as String?) ?? '',
      courseName: (row['course_name'] as String?) ?? '',
      academicYear: (row['academic_year'] as String?) ?? '',
      semester: (row['semester'] as int?) ?? 0,
      credits: (row['credits'] as num?)?.toDouble() ?? 0.0,
      school: (row['school'] as String?) ?? '',
      courseNature: (row['course_nature'] as String?) ?? '',
      courseCategory: (row['course_category'] as String?) ?? '',
      teachingClassCount: (row['teaching_class_count'] as int?) ?? 0,
      teacherSummary: (row['teacher_summary'] as String?) ?? '',
      gradeSummary: (row['grade_summary'] as String?) ?? '',
      scheduleDaySummary: (row['schedule_day_summary'] as String?) ?? '',
    );
  }
}
