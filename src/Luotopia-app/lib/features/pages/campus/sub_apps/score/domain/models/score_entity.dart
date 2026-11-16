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

  factory ScoreEntity.fromJson(Map<String, dynamic> json) {
    return ScoreEntity(
      year: json['year'] as int,
      semester: json['semester'] as int,
      name: json['name'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
      courseType: json['courseType'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      courseCollege: json['courseCollege'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'semester': semester,
      'name': name,
      'instructor': instructor,
      'courseId': courseId,
      'credit': credit,
      'courseType': courseType,
      'score': score,
      'courseCollege': courseCollege,
    };
  }
}

class ScoreListResult {
  const ScoreListResult({required this.scores});

  final List<ScoreEntity> scores;

  factory ScoreListResult.fromJson(Map<String, dynamic> json) {
    final rawScores = json['scores'];
    return ScoreListResult(
      scores: rawScores is List
          ? rawScores
                .whereType<Map<String, dynamic>>()
                .map(ScoreEntity.fromJson)
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'scores': scores.map((s) => s.toJson()).toList()};
  }
}
