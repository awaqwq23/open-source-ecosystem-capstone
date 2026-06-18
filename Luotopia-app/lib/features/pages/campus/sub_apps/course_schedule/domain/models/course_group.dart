/// Level-1 search result: one row per unique (course_code + term).
///
/// Aggregates all teaching classes sharing the same course code.
class CourseGroup {
  const CourseGroup({
    required this.courseCode,
    required this.courseName,
    required this.academicYear,
    required this.semester,
    required this.credits,
    required this.school,
    required this.courseNature,
    required this.courseCategory,
    required this.teachingClassCount,
    required this.teacherSummary,
    required this.gradeSummary,
    required this.scheduleDaySummary,
  });

  final String courseCode;
  final String courseName;
  final String academicYear;
  final int semester;
  final double credits;
  final String school;
  final String courseNature;
  final String courseCategory;
  final int teachingClassCount;
  final String teacherSummary;
  final String gradeSummary;
  final String scheduleDaySummary;

  String get termLabel => '$academicYear 第$semester学期';
}
