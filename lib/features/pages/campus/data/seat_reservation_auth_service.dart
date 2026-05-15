import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/whu_auth.dart';

class SeatReservationWebSession {
  const SeatReservationWebSession({
    required this.token,
    required this.launchUri,
  });

  final String token;
  final Uri launchUri;
}

class SeatReservationAuthService {
  const SeatReservationAuthService({required this.gateway});

  final WhuAuthGateway gateway;

  static final Uri _seatRedirectUri = Uri.parse('https://seat.lib.whu.edu.cn/seat');

  static final WhuCasServiceRequest _seatServiceRequest = WhuCasServiceRequest(
    serviceUrl: Uri.parse(
      'https://seat.lib.whu.edu.cn/static/sso/login'
      '?redirectUrl=https%3A%2F%2Fseat.lib.whu.edu.cn%2Fseat',
    ),
    isSuccess: _hasSeatToken,
    parseFailure: _parseSeatFailure,
  );

  Future<SeatReservationWebSession> createWebSession() async {
    final session = await gateway.authorizeService(_seatServiceRequest);
    try {
      final token = _extractToken(session.lastResponseUri);
      if (token == null || token.isEmpty) {
        throw Exception('座位预约系统授权失败：未获取到座位系统 token。');
      }
      return SeatReservationWebSession(
        token: token,
        launchUri: _seatRedirectUri.replace(
          queryParameters: {'token': token},
          fragment: '/main/index',
        ),
      );
    } finally {
      session.close();
    }
  }

  static bool _hasSeatToken(http.Response response) {
    final token = _extractToken(response.request?.url);
    return token != null && token.isNotEmpty;
  }

  static String? _parseSeatFailure(http.Response response) {
    if (_looksLikeCasLoginPage(response.body)) {
      return '座位预约系统授权失败，请重新登录武大统一认证。';
    }
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return '座位预约系统授权失败（HTTP ${response.statusCode}）。';
    }
    return '座位预约系统授权失败：未获取到座位系统 token。';
  }

  static String? _extractToken(Uri? uri) {
    final token = uri?.queryParameters['token']?.trim();
    if (token != null && token.isNotEmpty) {
      return token;
    }
    final fragment = uri?.fragment;
    if (fragment == null || fragment.isEmpty || !fragment.contains('?')) {
      return null;
    }
    final query = fragment.substring(fragment.indexOf('?') + 1);
    return Uri.splitQueryString(query)['token']?.trim();
  }

  static bool _looksLikeCasLoginPage(String body) {
    return body.contains('authserver/login') ||
        body.contains('统一身份认证') ||
        body.contains('cas.whu.edu.cn');
  }
}
