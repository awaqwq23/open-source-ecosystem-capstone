import 'package:luotopia/features/pages/campus/data/jwgl_client.dart';
import 'package:luotopia/features/pages/campus/domain/models/score_entity.dart';
import 'package:luotopia/features/pages/campus/domain/models/score_parser.dart';

/// 教务系统教育服务：在 JwglClient 之上封装成绩查询等业务逻辑。
class EducationService {
  EducationService({required this.client});
  final JwglClient client;

  static const _scoreApiUrl =
      'https://jwgl.whu.edu.cn/cjcx/cjcx_cxXsgrcj.html?doType=query&gnmkdm=N305005';

  Future<List<ScoreEntity>> getScoreList() async {
    final validate = JwglClient.generateValidate();

    final response = await client.post(
      Uri.parse(_scoreApiUrl),
      body: {
        'validate': validate,
        'xnm': '',
        'xqm': '',
        'queryModel.showCount': '150',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('成绩查询失败（HTTP ${response.statusCode}）。');
    }

    final normalized = response.body.replaceAll('\u00A0', '');
    final result = ScoreParser.parse(normalized);
    return result.scores;
  }
}
