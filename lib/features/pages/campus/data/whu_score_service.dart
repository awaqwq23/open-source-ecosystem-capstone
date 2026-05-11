import 'dart:convert';
import 'dart:math';

import 'package:luotopia/features/pages/campus/domain/models/score_entity.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';

class WhuScoreService {
  const WhuScoreService({required this.client});

  final WhuServiceSession client;

  static final Uri _scoreApiUri = Uri.parse(
    'https://jwgl.whu.edu.cn/cjcx/cjcx_cxXsgrcj.html?doType=query&gnmkdm=N305005',
  );

  Future<ScoreListResult> getScoreList({
    int year = -1,
    int semester = -1,
  }) async {
    final response = await client.post(
      _scoreApiUri,
      headers: const {
        'Host': 'jwgl.whu.edu.cn',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'validate': _generateValidate(),
        'xnm': year == -1 ? '' : '$year',
        'xqm': semester == -1 ? '' : '${_mapSemester(semester)}',
        'queryModel.showCount': '150',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('成绩接口请求失败（HTTP ${response.statusCode}）。');
    }
    final normalizedBody = response.body.replaceAll('\u00a0', '');
    final decoded = jsonDecode(normalizedBody);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('成绩接口返回格式异常。');
    }
    final items = decoded['items'];
    if (items is! List) {
      throw Exception('成绩接口返回格式异常：未找到 items。');
    }

    final scores = <ScoreEntity>[];
    for (final raw in items) {
      if (raw is! Map) {
        continue;
      }
      final item = Map<String, dynamic>.from(raw);
      final entity = _parseScore(item);
      if (entity != null) {
        scores.add(entity);
      }
    }
    return ScoreListResult(scores: scores);
  }

  ScoreEntity? _parseScore(Map<String, dynamic> item) {
    final parsedYear = int.tryParse('${item['xnm'] ?? ''}') ?? -1;
    final parsedCredit = double.tryParse('${item['xf'] ?? ''}') ?? double.nan;
    final parsedScore = int.tryParse('${item['bfzcj'] ?? ''}') ?? -1;
    if (parsedYear <= 0 || parsedCredit.isNaN || parsedScore < 0) {
      return null;
    }
    return ScoreEntity(
      year: parsedYear,
      semester: _unmapSemester(int.tryParse('${item['xqm'] ?? ''}') ?? 3),
      name: '${item['kcmc'] ?? ''}',
      instructor: '${item['jsxm'] ?? ''}',
      courseId: '${item['jxbmc'] ?? ''}',
      credit: parsedCredit,
      courseType: '${item['kcxzmc'] ?? ''}',
      score: parsedScore,
      courseCollege: '${item['kkbmmc'] ?? ''}',
    );
  }

  int _mapSemester(int semester) {
    return switch (semester) {
      1 => 3,
      2 => 12,
      3 => 16,
      _ => 3,
    };
  }

  int _unmapSemester(int semester) {
    return switch (semester) {
      3 => 1,
      12 => 2,
      16 => 3,
      _ => 1,
    };
  }

  String _generateValidate() {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    final randomPart = List.generate(
      7,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'sl$randomPart${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }
}
