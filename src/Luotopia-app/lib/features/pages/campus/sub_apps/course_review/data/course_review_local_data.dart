import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/domain/models/course_review_models.dart';
import 'package:luotopia/shared/data/database/app_database.dart';

/// 课程评价本地数据层：直接读 AppDatabase 中的全校课表缓存，
/// 提供"跨学期课程搜索"与"某课程教师列表"，供用户选择评价对象。
///
/// 不修改 all_school_timetable 子应用既有模型，避免侵入子应用边界。
class CourseReviewLocalData {
  CourseReviewLocalData(this._db);

  final AppDatabase _db;

  /// 按关键字搜索课程目录（跨学期），含授课教师数（去重）。
  Future<List<CourseReviewCourse>> searchCourses(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return const [];
    }
    final pattern = '%${_escapeLike(trimmed)}%';
    final rows = await _db.customSelect(
      '''
      SELECT cc.id AS course_id, cc.course_no, cc.course_name, cc.credits,
             (SELECT COUNT(DISTINCT ot.teacher_id)
                FROM school_timetable_offering_teachers ot
                JOIN school_timetable_offerings o ON o.id = ot.offering_id
               WHERE o.course_id = cc.id) AS teacher_count
      FROM school_timetable_courses cc
      WHERE cc.course_name LIKE ? ESCAPE char(92)
         OR cc.course_no LIKE ? ESCAPE char(92)
      ORDER BY CASE WHEN cc.course_name LIKE ? ESCAPE char(92) THEN 0 ELSE 1 END,
               cc.course_name ASC
      LIMIT 60
      ''',
      variables: [
        Variable.withString(pattern),
        Variable.withString(pattern),
        Variable('${_escapeLike(trimmed)}%'),
      ],
    ).get();
    return rows
        .map(
          (row) => CourseReviewCourse(
            courseId: _readString(row, 'course_id'),
            courseNo: _readString(row, 'course_no'),
            courseName: _readString(row, 'course_name'),
            credits: _readString(row, 'credits'),
            teacherCount: _readInt(row, 'teacher_count'),
          ),
        )
        .toList(growable: false);
  }

  /// 某课程下跨学期去重的教师列表（含授课教学班数）。
  Future<List<CourseReviewTeacher>> listTeachers(String courseId) async {
    if (courseId.isEmpty) {
      return const [];
    }
    final rows = await _db.customSelect(
      '''
      SELECT t.id AS teacher_id, t.name, ot.title,
             COUNT(DISTINCT ot.offering_id) AS class_count
      FROM school_timetable_offering_teachers ot
      JOIN school_timetable_offerings o ON o.id = ot.offering_id
      JOIN school_timetable_teachers t ON t.id = ot.teacher_id
      WHERE o.course_id = ?
      GROUP BY t.id, t.name, ot.title
      ORDER BY class_count DESC, t.name
      ''',
      variables: [Variable.withString(courseId)],
    ).get();
    return rows
        .map(
          (row) => CourseReviewTeacher(
            teacherId: _readString(row, 'teacher_id'),
            name: _readString(row, 'name'),
            title: _readString(row, 'title'),
            classCount: _readInt(row, 'class_count'),
          ),
        )
        .toList(growable: false);
  }

  String _readString(QueryRow row, String column) =>
      row.data[column]?.toString() ?? '';

  int _readInt(QueryRow row, String column) {
    final value = row.data[column];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _escapeLike(String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }
}

final courseReviewLocalDataProvider = Provider<CourseReviewLocalData>((ref) {
  return CourseReviewLocalData(ref.read(appDatabaseProvider));
});
