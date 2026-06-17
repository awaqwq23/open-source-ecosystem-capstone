import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/whu_auth.dart';

class SeatReservationWebSession {
  const SeatReservationWebSession({
    required this.launchUri,
    required this.cookieHeader,
  });

  final Uri launchUri;
  final String cookieHeader;
}

class SeatReservationAuthService {
  const SeatReservationAuthService({required this.gateway});

  final WhuAuthGateway gateway;

  static final Uri _seatConfigUri = Uri.parse(
    'https://seat.lib.whu.edu.cn/jsq/static/public/cg/getSysSet/MOBILE',
  );
  Future<SeatReservationWebSession> createWebSession() async {
    final serviceRequest = await _loadSeatServiceRequest();
    final client = await gateway.authorizeService(serviceRequest);
    try {
      final launchUri = client.lastResponseUri ?? serviceRequest.entryUrl!;
      return SeatReservationWebSession(
        launchUri: launchUri,
        cookieHeader: client.cookieHeaderFor(serviceRequest.entryUrl!),
      );
    } finally {
      client.close();
    }
  }

  static bool _isSeatLoginSuccess(http.Response response) {
    final uri = response.request?.url;
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return false;
    }
    if (_looksLikeCasLoginPage(response.body)) {
      return false;
    }
    return uri != null && uri.host == 'seat.lib.whu.edu.cn';
  }

  static Future<WhuCasServiceRequest> _loadSeatServiceRequest() async {
    final config = await _loadSeatConfig();
    final casService = _readConfigUri(config, 'CASSSERVICE');
    final vueService = _readConfigUri(config, 'VUESERVICE');
    final entryUri = _appendPath(
      casService,
      'static/sso/login',
    ).replace(queryParameters: {'redirectUrl': vueService.toString()});
    debugPrint('[SeatReservationAuth] use SSO entry ${_sanitizeUri(entryUri)}');
    return WhuCasServiceRequest(
      serviceUrl: entryUri,
      entryUrl: entryUri,
      isSuccess: _isSeatLoginSuccess,
      parseFailure: _parseSeatFailure,
    );
  }

  static Future<Map<String, Object?>> _loadSeatConfig() async {
    final client = http.Client();
    try {
      final response = await client.post(
        _seatConfigUri,
        headers: const {'Content-Type': 'application/json;charset=UTF-8'},
        body: '{}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final diagnostic = _diagnosticFromResponse(response);
        debugPrint('[SeatReservationAuth] config failed: $diagnostic');
        throw Exception('获取座位预约系统配置失败。\n$diagnostic');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        throw Exception('获取座位预约系统配置失败：响应格式异常。');
      }
      final data = decoded['data'];
      if (data is! Map<String, Object?>) {
        throw Exception('获取座位预约系统配置失败：缺少 data。');
      }
      final vueConfig = data['vueConfig'];
      if (vueConfig is! Map<String, Object?>) {
        throw Exception('获取座位预约系统配置失败：缺少 vueConfig。');
      }
      return vueConfig;
    } finally {
      client.close();
    }
  }

  static Uri _readConfigUri(Map<String, Object?> config, String key) {
    final value = config[key];
    if (value is! String || value.trim().isEmpty) {
      throw Exception('获取座位预约系统配置失败：$key 为空。');
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw Exception('获取座位预约系统配置失败：$key 不是有效地址。');
    }
    return uri;
  }

  static Uri _appendPath(Uri base, String path) {
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final nextPath = path.startsWith('/') ? path.substring(1) : path;
    return base.replace(path: '$basePath/$nextPath');
  }

  static String? _parseSeatFailure(http.Response response) {
    final diagnostic = _diagnosticFromResponse(response);
    debugPrint('[SeatReservationAuth] authorize failed: $diagnostic');
    if (_looksLikeCasLoginPage(response.body)) {
      return '座位预约系统授权失败，请重新登录武大统一认证。\n$diagnostic';
    }
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return '座位预约系统授权失败（HTTP ${response.statusCode}）。\n$diagnostic';
    }
    return '座位预约系统授权失败：未进入座位预约系统。\n$diagnostic';
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

  static String _diagnosticFromResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? 'unknown';
    final bodyKind = _bodyKind(response.body);
    final excerpt = _bodyExcerpt(response.body);
    return '诊断：status=${response.statusCode}; '
        'url=${_sanitizeUri(response.request?.url)}; '
        'contentType=$contentType; '
        'bodyKind=$bodyKind; '
        'bodyExcerpt=$excerpt';
  }

  static String _sanitizeUri(Uri? uri) {
    if (uri == null) {
      return 'unknown';
    }
    final queryKeys =
        uri.queryParameters.keys
            .where((key) => key.toLowerCase() != 'token')
            .toList(growable: false)
          ..sort();
    final queryText = queryKeys.isEmpty ? '' : '?${queryKeys.join(',')}';
    final fragmentText = uri.fragment.isEmpty ? '' : '#<fragment>';
    return '${uri.scheme}://${uri.host}${uri.path}$queryText$fragmentText';
  }

  static String _bodyKind(String body) {
    if (_extractToken(Uri.tryParse(body)) != null) {
      return 'token-like';
    }
    if (_looksLikeCasLoginPage(body)) {
      return 'cas-login-page';
    }
    if (body.contains('static/sso/login')) {
      return 'seat-sso-page';
    }
    if (body.contains('<html') || body.contains('<!DOCTYPE html')) {
      return 'html';
    }
    if (body.trimLeft().startsWith('{')) {
      return 'json';
    }
    return 'unknown';
  }

  static String _bodyExcerpt(String body) {
    final text = body
        .replaceAll(
          RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style[\s\S]*?</style>', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'token=[^&\s]+'), 'token=<redacted>')
        .trim();
    if (text.isEmpty) {
      return '<empty>';
    }
    return text.length <= 120 ? text : '${text.substring(0, 120)}...';
  }
}
