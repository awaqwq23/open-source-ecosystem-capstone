/// A single teaching class record from the course schedule.
///
/// Used in both Level-2 (list page) and Level-3 (detail page).
class TeachingClass {
  const TeachingClass({
    required this.id,
    required this.academicYear,
    required this.semester,
    required this.courseCode,
    required this.courseName,
    required this.teachingClassName,
    required this.school,
    required this.planSchool,
    required this.credits,
    required this.courseNature,
    required this.courseCategory,
    required this.courseType,
    required this.grade,
    required this.major,
    required this.teacher,
    required this.teacherTitle,
    required this.studentCount,
    this.theoryHours,
    this.computerHours,
    this.experimentHours,
    this.practiceHours,
    this.scheduleSun,
    this.scheduleMon,
    this.scheduleTue,
    this.scheduleWed,
    this.scheduleThu,
    this.scheduleFri,
    this.scheduleSat,
    this.notes,
    this.otherTeachers,
    this.textbook,
    this.publisher,
  });

  final int id;
  final String academicYear;
  final int semester;
  final String courseCode;
  final String courseName;
  final String teachingClassName;
  final String school;
  final String planSchool;
  final double credits;
  final String courseNature;
  final String courseCategory;
  final String courseType;
  final String grade;
  final String major;
  final String teacher;
  final String teacherTitle;
  final String studentCount;
  final int? theoryHours;
  final int? computerHours;
  final int? experimentHours;
  final int? practiceHours;
  final String? scheduleSun;
  final String? scheduleMon;
  final String? scheduleTue;
  final String? scheduleWed;
  final String? scheduleThu;
  final String? scheduleFri;
  final String? scheduleSat;
  final String? notes;
  final String? otherTeachers;
  final String? textbook;
  final String? publisher;

  /// All non-null schedule strings.
  List<String> get allSchedules => [
    ?scheduleSun,
    ?scheduleMon,
    ?scheduleTue,
    ?scheduleWed,
    ?scheduleThu,
    ?scheduleFri,
    ?scheduleSat,
  ];

  /// Total teaching hours.
  int get totalHours =>
      (theoryHours ?? 0) +
      (computerHours ?? 0) +
      (experimentHours ?? 0) +
      (practiceHours ?? 0);

  /// Short time-location summary for list display.
  String get scheduleSummary {
    if (allSchedules.isEmpty) return '';
    // Pick the first non-empty schedule entry as a summary
    return allSchedules.first;
  }

  factory TeachingClass.fromDbRow(Map<String, Object?> row) {
    return TeachingClass(
      id: row['id'] as int? ?? 0,
      academicYear: (row['academic_year'] as String?) ?? '',
      semester: (row['semester'] as int?) ?? 0,
      courseCode: (row['course_code'] as String?) ?? '',
      courseName: (row['course_name'] as String?) ?? '',
      teachingClassName: (row['teaching_class_name'] as String?) ?? '',
      school: (row['school'] as String?) ?? '',
      planSchool: (row['plan_school'] as String?) ?? '',
      credits: (row['credits'] as num?)?.toDouble() ?? 0.0,
      courseNature: (row['course_nature'] as String?) ?? '',
      courseCategory: (row['course_category'] as String?) ?? '',
      courseType: (row['course_type'] as String?) ?? '',
      grade: (row['grade'] as String?) ?? '',
      major: (row['major'] as String?) ?? '',
      teacher: (row['teacher'] as String?) ?? '',
      teacherTitle: (row['teacher_title'] as String?) ?? '',
      studentCount: (row['student_count'] as String?) ?? '',
      theoryHours: row['theory_hours'] as int?,
      computerHours: row['computer_hours'] as int?,
      experimentHours: row['experiment_hours'] as int?,
      practiceHours: row['practice_hours'] as int?,
      scheduleSun: row['schedule_sun'] as String?,
      scheduleMon: row['schedule_mon'] as String?,
      scheduleTue: row['schedule_tue'] as String?,
      scheduleWed: row['schedule_wed'] as String?,
      scheduleThu: row['schedule_thu'] as String?,
      scheduleFri: row['schedule_fri'] as String?,
      scheduleSat: row['schedule_sat'] as String?,
      notes: row['notes'] as String?,
      otherTeachers: row['other_teachers'] as String?,
      textbook: row['textbook'] as String?,
      publisher: row['publisher'] as String?,
    );
  }
}
