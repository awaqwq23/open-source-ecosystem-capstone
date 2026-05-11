class ScoreEntity {
  final int year;
  final int semester;
  final String name;
  final String courseId;
  final String instructor;
  final double credit;
  final String courseType;
  final int score;
  final String courseCollege;

  const ScoreEntity({
    required this.year,
    required this.semester,
    required this.name,
    required this.courseId,
    required this.instructor,
    required this.credit,
    required this.courseType,
    required this.score,
    required this.courseCollege,
  });
}

class ScoreUserInfo {
  final String college;
  final String major;
  final String name;
  final String studentId;

  const ScoreUserInfo({
    required this.college,
    required this.major,
    required this.name,
    required this.studentId,
  });

  bool get isComplete =>
      college.isNotEmpty && name.isNotEmpty && studentId.isNotEmpty;
}
