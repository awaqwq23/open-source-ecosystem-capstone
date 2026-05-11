import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/data/whu_authorized_client.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_account.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_cas_service_request.dart';
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';

class WhuCasService {
  const WhuCasService();

  static final educationService = WhuCasServiceRequest(
    serviceUrl: Uri.parse('https://jwgl.whu.edu.cn/sso/jznewsixlogin'),
    isSuccess: _isEducationLoginSuccess,
    parseFailure: _parseEducationLoginFailure,
  );

  Future<WhuServiceSession> authorizeService({
    required String casCookieHeader,
    required WhuCasServiceRequest request,
  }) async {
    if (casCookieHeader.trim().isEmpty) {
      throw const WhuAuthException(
        WhuAuthExceptionCode.loginRequired,
        '请先登录武大统一认证。',
      );
    }
    final client = WhuAuthorizedClient(initialCookieHeader: casCookieHeader);
    try {
      final loginUri = Uri.parse(
        'https://cas.whu.edu.cn/authserver/login?service=${Uri.encodeComponent(request.serviceUrl.toString())}',
      );
      final response = await client.get(loginUri);
      if (!request.isSuccess(response)) {
        final reason = request.parseFailure?.call(response);
        throw WhuAuthException(
          WhuAuthExceptionCode.serviceLoginFailed,
          reason == null || reason.trim().isEmpty
              ? '服务授权失败，请重新登录武大统一认证。'
              : reason,
        );
      }
      return client;
    } on WhuAuthException {
      client.close();
      rethrow;
    } catch (error) {
      client.close();
      throw WhuAuthException(
        WhuAuthExceptionCode.networkFailure,
        '服务授权请求失败：$error',
      );
    }
  }

  Future<WhuAccount> loadEducationAccount(WhuServiceSession client) async {
    final response = await client.get(
      Uri.parse(
        'https://jwgl.whu.edu.cn/xtgl/index_cxYhxxIndex.html?xt=jw&localeKey=zh_CN&gnmkdm=index',
      ),
      headers: const {'Host': 'jwgl.whu.edu.cn'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WhuAuthException(
        WhuAuthExceptionCode.invalidResponse,
        '获取教务账户信息失败（HTTP ${response.statusCode}）。',
      );
    }
    return _parseAccount(response.body);
  }

  WhuAccount _parseAccount(String html) {
    final studentId = RegExp(r'xh_id=([^"&]+)')
            .firstMatch(html)
            ?.group(1)
            ?.trim() ??
        '';
    final nameRaw = RegExp(r'<h4[^>]*class="[^"]*media-heading[^"]*"[^>]*>(.*?)</h4>',
            dotAll: true)
        .firstMatch(html)
        ?.group(1);
    final name = _stripHtml(nameRaw ?? '')
        .replaceAll(RegExp(r'\s*学生.*'), '')
        .trim();
    final bodyText = RegExp(r'<div[^>]*class="[^"]*media-body[^"]*"[^>]*>.*?<p[^>]*>(.*?)</p>',
            dotAll: true)
        .firstMatch(html)
        ?.group(1);
    final collegeText = _stripHtml(bodyText ?? '').trim();
    final college = collegeText.replaceAll(RegExp(r'\s+\d{4}.*'), '').trim();
    return WhuAccount(
      studentId: Uri.decodeComponent(studentId),
      name: name,
      college: college,
      major: '',
    );
  }

  String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\u00a0', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

bool _isEducationLoginSuccess(http.Response response) {
  return response.body.contains('教学管理信息服务平台');
}

String? _parseEducationLoginFailure(http.Response response) {
  final match = RegExp(r'var dlktsxx="(.*?)";').firstMatch(response.body);
  final reason = match?.group(1)?.trim();
  if (reason != null && reason.isNotEmpty) {
    return '教务系统登录失败：$reason';
  }
  return '教务系统登录失败，请重新登录武大统一认证。';
}
