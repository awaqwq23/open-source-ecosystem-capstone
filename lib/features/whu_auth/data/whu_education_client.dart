import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/domain/whu_session_checker.dart';
import 'package:luotopia/features/whu_auth/domain/whu_session_invalid_exception.dart';

class WhuEducationClient {
  String _cookieHeader;
  final void Function()? onSessionExpired;
  final Future<bool> Function()? refreshSession;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  static const _userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36';

  static const _requestTimeout = Duration(seconds: 20);

  WhuEducationClient({
    required String cookieHeader,
    this.onSessionExpired,
    this.refreshSession,
  }) : _cookieHeader = cookieHeader;

  String get currentCookie => _cookieHeader;

  void updateCookie(String newCookie) {
    _cookieHeader = newCookie;
  }

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

  Future<http.Response> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();
    final text = response.body.replaceAll('\u00A0', ' ');

    if (!looksLikeWhuLoginRedirect(text)) {
      return response;
    }

    if (refreshSession == null) {
      onSessionExpired?.call();
      throw const WhuSessionInvalidException();
    }

    bool refreshResult;
    if (_isRefreshing) {
      refreshResult = await _refreshCompleter!.future;
    } else {
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();
      try {
        refreshResult = await refreshSession!();
      } catch (_) {
        refreshResult = false;
      }
      _refreshCompleter!.complete(refreshResult);
      _isRefreshing = false;
    }

    if (!refreshResult) {
      onSessionExpired?.call();
      throw const WhuSessionInvalidException();
    }

    return request();
  }

  static String generateValidate() {
    final random = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return 'sl$random';
  }
}
