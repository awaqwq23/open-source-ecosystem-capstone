import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/campus/domain/models/scorecalc_item.dart';

/// 成绩计算结果
class ScoreCalcResult {
  final double gpa;
  final double totalCredits;
  final double totalScore;
  final double weightedAverage;
  final Map<String, dynamic> raw;

  const ScoreCalcResult({
    required this.gpa,
    required this.totalCredits,
    required this.totalScore,
    required this.weightedAverage,
    required this.raw,
  });

  factory ScoreCalcResult.fromJson(Map<String, dynamic> json) {
    return ScoreCalcResult(
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0,
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0,
      weightedAverage: (json['weightedAverage'] as num?)?.toDouble() ?? 0,
      raw: json,
    );
  }
}

/// 单条成绩输入
class CalcScoreInput {
  final String name;
  final double credit;
  final double score;

  const CalcScoreInput({
    required this.name,
    required this.credit,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'credit': credit,
        'score': score,
      };
}

class ScoreCalcService {
  static const _githubConfigUrl =
      'https://raw.githubusercontent.com/whu-ham/ScoreCalculator/main/config.json';

  JavascriptRuntime? _runtime;

  JavascriptRuntime _getRuntime() {
    _runtime ??= getJavascriptRuntime();
    return _runtime!;
  }

  /// 执行成绩计算脚本
  ScoreCalcResult evaluate({
    required String script,
    required List<CalcScoreInput> scores,
  }) {
    final runtime = _getRuntime();
    final scoresJson = jsonEncode(scores.map((s) => s.toJson()).toList());

    final wrappedScript = '''
$script

const __scores__ = $scoresJson;
const __result__ = calculate(__scores__);
JSON.stringify(__result__);
''';

    final result = runtime.evaluate(wrappedScript);
    if (result.rawResult == null || result.rawResult!.isEmpty) {
      throw Exception('脚本执行失败：未返回结果');
    }
    final parsed = jsonDecode(result.rawResult!);
    if (parsed is! Map<String, dynamic>) {
      throw Exception('脚本执行失败：返回格式异常');
    }
    return ScoreCalcResult.fromJson(parsed);
  }

  /// 从 GitHub 拉取脚本列表
  Future<List<ScoreCalcItem>> fetchFromGithub() async {
    final response = await http.get(Uri.parse(_githubConfigUrl));
    if (response.statusCode != 200) {
      throw Exception('无法从 GitHub 拉取脚本列表：HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json.entries.map((entry) {
      final item = Map<String, dynamic>.from(entry.value as Map);
      return ScoreCalcItem.fromJson({
        ...item,
        'title': entry.key,
        'url':
            'https://raw.githubusercontent.com/whu-ham/ScoreCalculator/main/${entry.key}',
        'type': 'GITHUB',
      });
    }).toList();
  }

  /// 从 URL 拉取 JS 脚本内容
  Future<String> fetchScript(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('无法拉取脚本：HTTP ${response.statusCode}');
    }
    return response.body;
  }

  /// 验证 JS 脚本语法（尝试执行一个简单调用）
  bool validateScript(String script) {
    try {
      final runtime = _getRuntime();
      final testScript = '''
$script
typeof calculate === 'function';
''';
      final result = runtime.evaluate(testScript);
      return result.rawResult == 'true';
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _runtime?.dispose();
    _runtime = null;
  }
}
