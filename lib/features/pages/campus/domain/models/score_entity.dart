class ScoreEntity {
  const ScoreEntity({
    required this.year,
    required this.semester,
    required this.name,
    required this.instructor,
    required this.courseId,
    required this.credit,
    required this.courseType,
    required this.score,
    required this.courseCollege,
  });

  final int year;
  final int semester;
  final String name;
  final String instructor;
  final String courseId;
  final double credit;
  final String courseType;
  final int score;
  final String courseCollege;
}

class ScoreListResult {
  const ScoreListResult({
    required this.scores,
  });

  final List<ScoreEntity> scores;
}
