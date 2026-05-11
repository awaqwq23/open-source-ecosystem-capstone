class ScoreEntity {
  final int year;
  final int semester;
  final String name;
  final String courseId;
  final String instructor;
  final double credit;
  final String courseType;
  final double score;
  final String courseCollege;

  const ScoreEntity({
    required this.year,
    required this.semester,
    required this.name,
    this.courseId = '',
    this.instructor = '',
    required this.credit,
    this.courseType = '',
    required this.score,
    this.courseCollege = '',
  });
}
