import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_api_response.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_session.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_web_session.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_cas_service_request.dart';
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';

class SportsReservationAuthService {
  const SportsReservationAuthService({required this.gateway});

  final WhuAuthGateway gateway;

  static final Uri serviceUrl = Uri.parse(
    'https://gym.whu.edu.cn/hsdsqhafive/',
  );

  static Uri get webAuthorizationUri => Uri.https(
    'cas.whu.edu.cn',
    '/authserver/login',
    {'service': serviceUrl.toString()},
  );

  static final Uri _loginExchangeBaseUri = Uri.https(
    'gym.whu.edu.cn',
    '/api/Login/Cookies_Wd',
  );

  Future<SportsReservationSession> createSession() async {
    await gateway.ensureCasSessionFresh();
    final casSession = await gateway.authorizeService(
      WhuCasServiceRequest(
        serviceUrl: serviceUrl,
        isSuccess: _hasGymTicket,
        parseFailure: _parseGymFailure,
      ),
    );
    try {
      final referer = casSession.lastResponseUri;
      final ticket = referer?.queryParameters['ticket']?.trim();
      if (referer == null || ticket == null || ticket.isEmpty) {
        throw const SportsReservationAuthException(
          '运动场馆系统授权失败：未获取到 CAS ticket。',
        );
      }
      return await _exchangeTicket(ticket: ticket, referer: referer);
    } finally {
      casSession.close();
    }
  }

  Future<SportsReservationWebSession> createWebSession({Uri? launchUri}) async {
    final session = await createSession();
    return SportsReservationWebSession.fromSession(
      session,
      launchUri: launchUri,
    );
  }

  Future<void> primeCasCookiesForWebView() {
    return gateway.primeCasCookiesForWebView();
  }

  SportsReservationSession createSessionFromWebToken({
    required String jwt,
    required Uri referer,
    String userId = '',
    String cookieHeader = '',
  }) {
    final token = jwt.trim();
    if (token.isEmpty) {
      throw const SportsReservationAuthException('运动场馆系统授权失败：未获取到登录凭证。');
    }
    return SportsReservationSession(
      jwt: token,
      serviceUrl: serviceUrl,
      referer: referer,
      userId: userId.trim(),
      cookieHeader: cookieHeader.trim(),
    );
  }

  Future<SportsReservationSession> _exchangeTicket({
    required String ticket,
    required Uri referer,
  }) async {
    final client = http.Client();
    try {
      final uri = _loginExchangeBaseUri.replace(
        queryParameters: {'ticket': ticket, 'service': serviceUrl.toString()},
      );
      final response = await client.get(
        uri,
        headers: {
          'Accept': 'application/json, text/plain, */*',
          'Authorization': 'Bearer',
          'Referer': referer.toString(),
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
        },
      );
      final payload = SportsReservationApiResponse.decode(
        response,
        action: '获取运动场馆登录凭证',
      );
      final data = SportsReservationJson.asMap(payload);
      final jwt = SportsReservationJson.readString(data, 'jwttoken');
      if (jwt.isEmpty) {
        throw const SportsReservationAuthException('运动场馆系统授权失败：响应中缺少 JWT。');
      }
      return SportsReservationSession(
        jwt: jwt,
        serviceUrl: serviceUrl,
        referer: referer,
        userId: SportsReservationJson.readString(data, 'wdUid'),
      );
    } on SportsReservationException {
      rethrow;
    } catch (error) {
      throw SportsReservationAuthException('运动场馆系统授权失败。', cause: error);
    } finally {
      client.close();
    }
  }

  static bool _hasGymTicket(http.Response response) {
    final uri = response.request?.url;
    final ticket = uri?.queryParameters['ticket']?.trim();
    return uri?.host == 'gym.whu.edu.cn' &&
        uri?.path.startsWith('/hsdsqhafive') == true &&
        ticket != null &&
        ticket.isNotEmpty;
  }

  static String? _parseGymFailure(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return '运动场馆系统授权失败（HTTP ${response.statusCode}）。';
    }
    return '运动场馆系统授权失败，请重新登录武大统一认证。';
  }
}
