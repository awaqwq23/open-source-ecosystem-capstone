import 'dart:convert';

import 'package:luotopia/features/pages/campus/domain/models/score_entity.dart';

class ScoreParseResult {
  final List<ScoreEntity> scores;
  final String studentId;
  final String studentName;
  final String college;

  const ScoreParseResult({
    required this.scores,
    this.studentId = '',
    this.studentName = '',
    this.college = '',
  });
}

class ScoreParser {
  static ScoreParseResult parse(String rawJson) {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? [];

    String studentId = '';
    String studentName = '';
    String college = '';
    final scores = <ScoreEntity>[];

    for (final raw in items) {
      if (raw is! Map) continue;
      final item = raw as Map<String, dynamic>;

      if (studentId.isEmpty) {
        studentId = _str(item['xh']);
        studentName = _str(item['xm']);
        college = _str(item['jgmc']);
      }

      final year = int.tryParse(_str(item['xnm'])) ?? 0;
      final semester = _mapSemester(int.tryParse(_str(item['xqm'])) ?? 0);
      final credit = double.tryParse(_str(item['xf'])) ?? 0;
      final score = double.tryParse(_str(item['bfzcj'])) ?? 0;

      if (year <= 0 || credit.isNaN || score.isNaN) continue;

      scores.add(ScoreEntity(
        year: year,
        semester: semester,
        name: _str(item['kcmc']),
        courseId: _str(item['jxbmc']),
        instructor: _str(item['jsxm']),
        credit: credit,
        courseType: _str(item['kcxzmc']),
        score: score,
        courseCollege: _str(item['kkbmmc']),
      ));
    }

    return ScoreParseResult(
      scores: scores,
      studentId: studentId,
      studentName: studentName,
      college: college,
    );
  }

  static String _str(dynamic v) => (v == null ? '' : '$v').trim();

  /// 教务系统学期编码 → 应用学期编号 (1/2/3)
  static int _mapSemester(int raw) {
    if (raw == 3) return 1;
    if (raw == 12) return 2;
    if (raw == 16) return 3;
    return 1;
  }
}
