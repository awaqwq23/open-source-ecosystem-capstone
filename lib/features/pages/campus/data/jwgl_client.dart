import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 教务系统 HTTP 客户端。
///
/// 自愈式 cookie 管理：
/// 1. 所有请求携带 `_cookieHeader`（CAS cookie + JWGL session cookie 合并串）
/// 2. 响应含登录页标记（authserver/login、var dlktsxx=）→ 自动 _ssoRefresh
/// 3. _ssoRefresh 从 `set-cookie` 提取新 cookie 合并到 _cookieHeader
/// 4. 合并后续期 → 重试原请求（用户/业务层无感）
class JwglClient {
  JwglClient({
    required String cookieHeader,
    this.onCookiesUpdated,
  }) : _cookieHeader = cookieHeader;

  String _cookieHeader;
  final ValueChanged<String>? onCookiesUpdated;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  static const _requestTimeout = Duration(seconds: 20);

  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';

  static const _casLoginUrl =
      'https://cas.whu.edu.cn/authserver/login'
      '?service=https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin';

  Map<String, String> _buildHeaders() => {
        'User-Agent': _userAgent,
        'Cookie': _cookieHeader,
      };

  // ── 公开 API ──

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? body,
    Map<String, String>? extraHeaders,
  }) async {
    final req = () => http
        .post(
          url,
          headers: {
            ..._buildHeaders(),
            'Content-Type': 'application/x-www-form-urlencoded',
            if (extraHeaders != null) ...extraHeaders,
          },
          body: body,
        )
        .timeout(_requestTimeout);
    return _executeWithRetry(req);
  }

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? extraHeaders,
  }) async {
    final req = () => http
        .get(
          url,
          headers: {
            ..._buildHeaders(),
            if (extraHeaders != null) ...extraHeaders,
          },
        )
        .timeout(_requestTimeout);
    return _executeWithRetry(req);
  }

  // ── 自愈核心 ──

  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();
    if (!_looksLikeLoginRedirect(response.body)) return response;

    await _ssoRefresh();
    return request();
  }

  /// SSO 重新握手：用已有 cookie 访问 CAS 完成静默认证。
  /// 从最终响应的 set-cookie 中提取新 cookie 合并到 _cookieHeader。
  Future<void> _ssoRefresh() async {
    if (_isRefreshing) {
      await _refreshCompleter!.future;
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final response = await http
          .get(Uri.parse(_casLoginUrl), headers: _buildHeaders())
          .timeout(_requestTimeout);

      if (response.body.contains('教学管理信息服务平台')) {
        _extractAndUpdateCookies(response);

        // 部分 JWGL 实现不会在最终页面响应中重发 JSESSIONID，
        // 显式请求 JWGL 首页强制获取 session cookie
        if (!_cookieHeader.contains('JSESSIONID=')) {
          try {
            final warmup = await http
                .get(
                  Uri.parse('https://jwgl.whu.edu.cn/'),
                  headers: _buildHeaders(),
                )
                .timeout(_requestTimeout);
            _extractAndUpdateCookies(warmup);
          } catch (_) {}
        }

        if (_cookieHeader.contains('JSESSIONID=')) {
          onCookiesUpdated?.call(_cookieHeader);
          _refreshCompleter!.complete();
          return;
        }
      }

      final errorMatch = RegExp(r'var dlktsxx="(.*?)";').firstMatch(response.body);
      final errorMsg = errorMatch?.group(1);
      if (errorMsg != null && errorMsg.isNotEmpty) {
        throw Exception('教务系统登录失败：$errorMsg');
      }

      throw Exception('教务系统登录失败，请检查账户状态。');
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  // ── cookie 提取合并 ──

  void _extractAndUpdateCookies(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) return;

    for (final part in setCookie.split(',')) {
      final match = RegExp(r'([^=]+=[^;]*)').firstMatch(part.trim());
      if (match == null) continue;

      final newPair = match.group(1)!;
      // 跳过空值 cookie（如 CASTGC=; 是 cookie 清除指令）
      if (newPair.endsWith('=')) continue;

      final key = newPair.split('=')[0];

      final entries =
          _cookieHeader.split('; ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      entries.removeWhere((e) => e.startsWith('$key='));
      entries.add(newPair);
      _cookieHeader = entries.join('; ');
    }
  }

  // ── 工具 ──

  static bool _looksLikeLoginRedirect(String body) {
    final lower = body.toLowerCase();
    return lower.contains('authserver/login') ||
        (lower.contains('cas.whu.edu.cn') && lower.contains('login')) ||
        lower.contains('var dlktsxx=');
  }

  static String generateValidate() {
    final random = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return 'sl$random';
  }
}
