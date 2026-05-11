import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/campus/domain/models/score_entity.dart';
import 'package:luotopia/features/pages/campus/domain/models/score_parser.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

/// 教务系统教育服务：在 whu_auth 的 CAS 会话之上封装教育网业务逻辑。
class EducationService {
  EducationService({required this.fastLogin});

  /// fastLogin(serviceUrl) → 携带 CAS cookie 向目标服务发起 SSO 请求
  final Future<http.Response> Function(String serviceUrl) fastLogin;

  /// 教务系统 SSO 入口
  static const _educationSsoUrl =
      'https://jwgl.whu.edu.cn/sso/jznewsixlogin';

  /// 成绩查询接口
  static const _scoreApiUrl =
      'https://jwgl.whu.edu.cn/cjcx/cjcx_cxXsgrcj.html?doType=query&gnmkdm=N305005';

  /// 建立教务系统会话
  Future<void> loginEducation() async {
    final res = await fastLogin(_educationSsoUrl);
    final body = res.body;
    if (!body.contains('教学管理信息服务平台')) {
      final reason = _parseJsError(body);
      throw Exception(
        '教务系统登录失败！${reason.isEmpty ? '请重试' : reason}',
      );
    }
  }

  /// 获取所有学期成绩
  Future<List<ScoreEntity>> getScoreList() async {
    final validate = WhuSessionClient.generateValidate();
    final res = await fastLogin(_educationSsoUrl);
    final body = res.body;
    if (!body.contains('教学管理信息服务平台')) {
      throw Exception('教务会话已过期，请重新登录。');
    }

    final scoreRes = await http.post(
      Uri.parse(_scoreApiUrl),
      body: {
        'validate': validate,
        'xnm': '',
        'xqm': '',
        'queryModel.showCount': '150',
      },
    );

    if (scoreRes.statusCode < 200 || scoreRes.statusCode >= 300) {
      throw Exception('成绩查询失败（HTTP ${scoreRes.statusCode}）。');
    }

    final normalized = scoreRes.body.replaceAll('\u00A0', '');
    final result = ScoreParser.parse(normalized);
    return result.scores;
  }

  /// 从 CAS 回调 HTML 中提取错误原因
  String _parseJsError(String html) {
    final regex = RegExp(r'var dlktsxx="(.*?)";');
    final match = regex.firstMatch(html);
    return match?.group(1) ?? '';
  }
}
