import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/domain/whu_session_checker.dart';
import 'package:luotopia/features/whu_auth/domain/whu_session_invalid_exception.dart';

class WhuEducationClient {
  String _cookieHeader;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';

  static const _requestTimeout = Duration(seconds: 20);

  static const _casLoginUrl =
      'https://cas.whu.edu.cn/authserver/login'
      '?service=https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin';

  WhuEducationClient({
    required String cookieHeader,
    this.onCookiesUpdated,
  }) : _cookieHeader = cookieHeader;

  String get currentCookie => _cookieHeader;
  final ValueChanged<String>? onCookiesUpdated;

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? extraHeaders,
    bool skipRetry = false,
  }) async {
    final req = () => http.get(url, headers: _buildHeaders(extraHeaders)).timeout(_requestTimeout);
    if (skipRetry) return req();
    return _executeWithRetry(req);
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? extraHeaders,
    Object? body,
    bool skipRetry = false,
  }) async {
    final req = () =>
        http.post(url, headers: _buildHeaders(extraHeaders, isForm: true), body: body).timeout(_requestTimeout);
    if (skipRetry) return req();
    return _executeWithRetry(req);
  }

  Map<String, String> _buildHeaders(Map<String, String>? extra, {bool isForm = false}) {
    final headers = <String, String>{
      'User-Agent': _userAgent,
      'Cookie': _cookieHeader,
    };
    if (isForm) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  /// 公开方法：供 Notifier 在登录/手动刷新时调用
  Future<void> refreshSession() async {
    await _ssoRefresh();
  }

  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();
    final text = response.body.replaceAll('\u00A0', ' ');

    if (!looksLikeWhuLoginRedirect(text)) {
      return response;
    }

    try {
      await _ssoRefresh();
    } catch (_) {
      throw const WhuSessionInvalidException();
    }

    return request();
  }

  /// 内部 SSO 重新握手：用已有 Cookie 访问 CAS 完成静默认证
  Future<void> _ssoRefresh() async {
    if (_isRefreshing) {
      await _refreshCompleter!.future;
      return;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final response = await http
          .get(Uri.parse(_casLoginUrl), headers: _buildHeaders(null))
          .timeout(_requestTimeout);

      final text = response.body.replaceAll('\u00A0', ' ');

      if (text.contains('教学管理信息服务平台')) {
        _extractAndUpdateCookies(response);
        onCookiesUpdated?.call(_cookieHeader);
        _refreshCompleter!.complete();
        return;
      }

      final errorMatch = RegExp(r'var dlktsxx="(.*?)";').firstMatch(text);
      final errorMsg = errorMatch?.group(1);
      if (errorMsg != null && errorMsg.isNotEmpty) {
        throw Exception('教务系统登录失败：$errorMsg');
      }

      throw const WhuSessionInvalidException();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 从 SSO 响应头提取新 Cookie 并更新本地缓存
  void _extractAndUpdateCookies(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie == null || setCookie.isEmpty) return;

    for (final part in setCookie.split(',')) {
      final match = RegExp(r'([^=]+=[^;]*)').firstMatch(part.trim());
      if (match == null) continue;
      final newPair = match.group(1)!;
      final key = newPair.split('=')[0];
      final entries =
          _cookieHeader.split('; ').map((e) => e.trim()).where((e) => e.isNotEmpty);
      final updated = entries.where((e) => !e.startsWith('$key=')).toList();
      updated.add(newPair);
      _cookieHeader = updated.join('; ');
    }
  }

  static String generateValidate() {
    final random = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return 'sl$random';
  }
}
