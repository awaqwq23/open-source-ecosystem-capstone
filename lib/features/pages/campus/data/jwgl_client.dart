import 'dart:math';

import 'package:http/http.dart' as http;

/// 教务系统 HTTP 客户端。
///
/// 手动管理 cookie + 重定向链：先以 CAS cookie 做 SSO，
/// 在重定向过程中逐环保存 JWGL 下发的 session cookie，
/// 后续请求自动附带。
class JwglClient {
  JwglClient({required this.casCookie});
  final String casCookie;

  /// 域名 → cookie 键值对
  final Map<String, Map<String, String>> _cookieJar = {};

  bool _sessionEstablished = false;

  static const _casLoginUrl = 'https://cas.whu.edu.cn/authserver/login';
  static const _educationSsoUrl = 'https://jwgl.whu.edu.cn/sso/jznewsixlogin';

  /// SSO：手动跟随重定向链，沿途保存 Set-Cookie。
  Future<void> loginEducation() async {
    if (_sessionEstablished) return;

    var uri = Uri.parse(
      '$_casLoginUrl?service=${Uri.encodeComponent(_educationSsoUrl)}',
    );

    for (var hop = 0; hop < 10; hop++) {
      final request = http.Request('GET', uri);
      _attachCookies(request, uri.host);
      request.headers['Cookie'] = casCookie;

      final client = http.Client();
      try {
        final streamed = await client.send(request);
        final headers = streamed.headers;

        // 提取 Set-Cookie
        _saveCookies(uri.host, headers['set-cookie']);

        if (streamed.statusCode < 300 || streamed.statusCode >= 400) {
          final body = await streamed.stream.bytesToString();
          if (!body.contains('教学管理信息服务平台')) {
            _sessionEstablished = false;
            final reason = _parseJsError(body);
            throw Exception(
              '教务系统登录失败！${reason.isEmpty ? '请重新登录' : reason}',
            );
          }
          _sessionEstablished = true;
          return;
        }

        final location = headers['location'];
        if (location == null || location.isEmpty) break;
        uri = Uri.parse(location);
      } finally {
        client.close();
      }
    }

    throw Exception('教务系统登录失败：重定向链异常。');
  }

  /// POST 请求（自动携带 session cookie）。
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? body,
    Map<String, String>? headers,
  }) async {
    await loginEducation();

    final request = http.Request('POST', url);
    _attachCookies(request, url.host);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    request.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    if (body != null) {
      request.body =
          body.entries
              .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
              .join('&');
    }

    final client = http.Client();
    try {
      final streamed = await client.send(request);
      final headers = streamed.headers;
      _saveCookies(url.host, headers['set-cookie']);

      final bodyStr = await streamed.stream.bytesToString();
      return http.Response(bodyStr, streamed.statusCode, headers: headers);
    } finally {
      client.close();
    }
  }

  /// GET 请求（自动携带 session cookie）。
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    await loginEducation();

    final request = http.Request('GET', url);
    _attachCookies(request, url.host);
    if (headers != null) {
      request.headers.addAll(headers);
    }

    final client = http.Client();
    try {
      final streamed = await client.send(request);
      final streamedHeaders = streamed.headers;
      _saveCookies(url.host, streamedHeaders['set-cookie']);

      final bodyStr = await streamed.stream.bytesToString();
      return http.Response(bodyStr, streamed.statusCode,
          headers: streamedHeaders);
    } finally {
      client.close();
    }
  }

  // ── cookie 管理 ──

  void _saveCookies(String domain, String? setCookie) {
    if (setCookie == null || setCookie.isEmpty) return;

    for (final raw in setCookie.split(',').map((s) => s.trim())) {
      final semi = raw.indexOf(';');
      final kv = semi > 0 ? raw.substring(0, semi).trim() : raw.trim();
      final eq = kv.indexOf('=');
      if (eq <= 0) continue;

      _cookieJar.putIfAbsent(domain, () => {});
      _cookieJar[domain]![kv.substring(0, eq).trim()] = kv.substring(eq + 1);
    }
  }

  void _attachCookies(http.BaseRequest request, String domain) {
    final cookies = _cookieJar[domain];
    if (cookies == null || cookies.isEmpty) return;
    final value =
        cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    request.headers['Cookie'] = value;
  }

  // ── 工具 ──

  static String generateValidate() {
    final random = Random();
    return 'sl${random.nextInt(1000000000).toRadixString(36)}${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }

  String _parseJsError(String html) {
    final match = RegExp(r'var dlktsxx="(.*?)";').firstMatch(html);
    return match?.group(1) ?? '';
  }
}
