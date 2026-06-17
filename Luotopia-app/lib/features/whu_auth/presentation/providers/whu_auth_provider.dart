import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/whu_auth/data/whu_auth_storage.dart';
import 'package:luotopia/features/whu_auth/data/whu_cas_service.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_account.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_snapshot.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_cas_service_request.dart';
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_cookie_manager_flutter/webview_cookie_manager.dart';

final whuAuthProvider = NotifierProvider<WhuAuthNotifier, WhuAuthState>(
  WhuAuthNotifier.new,
);

final whuCasServiceProvider = Provider<WhuCasService>((ref) {
  return const WhuCasService();
});

final whuAuthGatewayProvider = Provider<WhuAuthGateway>((ref) {
  return ref.watch(whuAuthProvider.notifier);
});

class WhuAuthNotifier extends Notifier<WhuAuthState> implements WhuAuthGateway {
  final WhuAuthStorage _storage = const WhuAuthStorage();
  final _WebViewCookieStore _cookieStore = _WebViewCookieStore();

  String _casCookieHeader = '';
  String _educationCookieHeader = '';

  @override
  WhuAuthState build() {
    final snapshot = _storage.readSnapshot(ref.read(sharedPreferencesProvider));
    if (snapshot == null) {
      return const WhuAuthState();
    }
    _casCookieHeader = snapshot.casCookieHeader;
    _educationCookieHeader = snapshot.educationCookieHeader;
    return WhuAuthState(
      status: WhuAuthStatus.authenticated,
      account: snapshot.account,
      lastAuthenticatedAt: snapshot.lastAuthenticatedAt,
      lastVerifiedAt: snapshot.lastVerifiedAt,
    );
  }

  Future<void> completeCasLogin({
    String? casCookieHeader,
    String? educationCookieHeader,
    String? educationAccountHtml,
  }) async {
    state = state.copyWith(status: WhuAuthStatus.loading, clearError: true);
    try {
      final latestCasCookieHeader = _coalesceCookieHeader(
        casCookieHeader,
        await _readCasCookieHeader(),
      );
      final latestEducationCookieHeader = _coalesceCookieHeader(
        educationCookieHeader,
        await _readEducationCookieHeader(),
      );
      if (!_hasCasSession(latestCasCookieHeader) &&
          latestEducationCookieHeader.trim().isEmpty) {
        throw const WhuAuthException(
          WhuAuthExceptionCode.loginRequired,
          '没有检测到有效的武大统一认证 Cookie。',
        );
      }

      _casCookieHeader = latestCasCookieHeader;
      _educationCookieHeader = latestEducationCookieHeader;
      final accountHtml = educationAccountHtml?.trim();
      if (accountHtml != null && accountHtml.isNotEmpty) {
        final account = ref
            .read(whuCasServiceProvider)
            .parseEducationAccountHtml(accountHtml);
        await _persistAuthenticated(account);
        return;
      }
      final client = await authorizeEducation();
      try {
        final account = await ref.read(whuCasServiceProvider).loadEducationAccount(client);
        await _persistAuthenticated(account);
      } finally {
        client.close();
      }
    } catch (error) {
      state = WhuAuthState(
        status: WhuAuthStatus.unauthenticated,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<void> ensureCasSessionFresh() async {
    await _refreshCasCookieHeader();
    if (_casCookieHeader.trim().isEmpty) {
      throw const WhuAuthException(
        WhuAuthExceptionCode.loginRequired,
        '请先登录武大统一认证。',
      );
    }
  }

  @override
  Future<WhuServiceSession> authorizeService(WhuCasServiceRequest request) async {
    await _refreshCasCookieHeader();
    if (_casCookieHeader.trim().isEmpty) {
      throw const WhuAuthException(
        WhuAuthExceptionCode.loginRequired,
        '请先登录武大统一认证。',
      );
    }
    return ref.read(whuCasServiceProvider).authorizeService(
          casCookieHeader: _casCookieHeader,
          request: request,
        );
  }

  Future<void> _refreshCasCookieHeader() async {
    final latestCookieHeader = await _readCasCookieHeader();
    if (_hasCasSession(latestCookieHeader)) {
      _casCookieHeader = latestCookieHeader;
      debugPrint('[WhuAuth] refreshed CAS cookies before service authorization');
    } else {
      debugPrint('[WhuAuth] no fresh CAS cookies found before service authorization');
    }
  }

  @override
  Future<WhuServiceSession> authorizeEducation() async {
    await _refreshWebViewCookieHeaders();
    if (_educationCookieHeader.trim().isNotEmpty) {
      try {
        return ref.read(whuCasServiceProvider).authorizeEducationWithCookies(
              educationCookieHeader: _educationCookieHeader,
            );
      } on WhuAuthException catch (error) {
        debugPrint('[WhuAuth] education cookie authorization failed: $error');
      }
    }
    return authorizeService(WhuCasService.educationService);
  }

  @override
  Future<void> primeCasCookiesForWebView() async {
    if (!_hasCasSession(_casCookieHeader)) {
      throw const WhuAuthException(
        WhuAuthExceptionCode.loginRequired,
        '请先登录武大统一认证。',
      );
    }
    final cookies = buildWhuCasWebViewCookies(_casCookieHeader);
    if (cookies.isEmpty) {
      throw const WhuAuthException(
        WhuAuthExceptionCode.loginRequired,
        '请先登录武大统一认证。',
      );
    }
    await _cookieStore.setCookies(
      cookies,
      origin: 'https://cas.whu.edu.cn',
    );
  }

  Future<void> logout() async {
    _casCookieHeader = '';
    _educationCookieHeader = '';
    await _storage.clear(ref.read(sharedPreferencesProvider));
    await _cookieStore.clearCookies();
    state = const WhuAuthState();
  }

  Future<void> _persistAuthenticated(WhuAccount account) async {
    final now = DateTime.now();
    final nextAccount = account.hasProfile
        ? account
        : state.account ??
            const WhuAccount(
              studentId: '',
              name: '',
              college: '',
              major: '',
            );
    final snapshot = WhuAuthSnapshot(
      casCookieHeader: _casCookieHeader,
      educationCookieHeader: _educationCookieHeader,
      account: nextAccount,
      lastAuthenticatedAt: now,
      lastVerifiedAt: now,
    );
    await _storage.writeSnapshot(ref.read(sharedPreferencesProvider), snapshot);
    state = WhuAuthState(
      status: WhuAuthStatus.authenticated,
      account: nextAccount,
      lastAuthenticatedAt: now,
      lastVerifiedAt: now,
    );
  }

  Future<String> _readCasCookieHeader() async {
    final cookies = await _cookieStore.getCookies(
      Uri.parse('https://cas.whu.edu.cn/authserver/'),
    );
    final casCookies = [
      for (final cookie in cookies)
        if ((cookie.domain == null || cookie.domain!.contains('cas.whu.edu.cn')) &&
            cookie.name.trim().isNotEmpty &&
            cookie.value.trim().isNotEmpty)
          cookie,
    ];
    return casCookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  Future<String> _readEducationCookieHeader() async {
    final cookies = await _cookieStore.getCookies(
      Uri.parse('https://jwgl.whu.edu.cn/'),
    );
    final educationCookies = [
      for (final cookie in cookies)
        if ((cookie.domain == null || cookie.domain!.contains('jwgl.whu.edu.cn')) &&
            cookie.name.trim().isNotEmpty &&
            cookie.value.trim().isNotEmpty)
          cookie,
    ];
    return educationCookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
  }

  Future<void> _refreshWebViewCookieHeaders() async {
    final latestCasCookieHeader = await _readCasCookieHeader();
    final latestEducationCookieHeader = await _readEducationCookieHeader();
    if (_hasCasSession(latestCasCookieHeader)) {
      _casCookieHeader = latestCasCookieHeader;
    }
    if (latestEducationCookieHeader.trim().isNotEmpty) {
      _educationCookieHeader = latestEducationCookieHeader;
    }
  }

  bool _hasCasSession(String cookieHeader) {
    return _hasNonEmptyCookie(cookieHeader, 'CASTGC');
  }

  String _coalesceCookieHeader(String? preferred, String fallback) {
    final value = preferred?.trim();
    return value == null || value.isEmpty ? fallback : value;
  }
}

class _WebViewCookieStore {
  final WebviewCookieManager _mobileCookieManager = WebviewCookieManager();

  Future<List<Cookie>> getCookies(Uri uri) async {
    if (_usesMobileCookieManager) {
      return _mobileCookieManager.getCookies(uri.toString());
    }
    final platformCookieManager = WebViewCookieManager().platform;
    final cookies = await platformCookieManager.getCookies(uri);
    return [
      for (final cookie in cookies)
        Cookie(cookie.name, cookie.value)
          ..domain = cookie.domain
          ..path = cookie.path,
    ];
  }

  Future<void> setCookies(List<Cookie> cookies, {required String origin}) async {
    if (_usesMobileCookieManager) {
      await _mobileCookieManager.setCookies(cookies, origin: origin);
      return;
    }
    final cookieManager = WebViewCookieManager();
    for (final cookie in cookies) {
      await cookieManager.setCookie(
        WebViewCookie(
          name: cookie.name,
          value: cookie.value,
          domain: cookie.domain ?? Uri.parse(origin).host,
          path: cookie.path ?? '/',
        ),
      );
    }
  }

  Future<void> clearCookies() async {
    if (_usesMobileCookieManager) {
      await _mobileCookieManager.clearCookies();
      return;
    }
    await WebViewCookieManager().clearCookies();
  }

  bool get _usesMobileCookieManager {
    return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  }
}

bool hasWhuCasSessionCookie(String cookieHeader) {
  return _hasNonEmptyCookie(cookieHeader, 'CASTGC');
}

bool _hasNonEmptyCookie(String cookieHeader, String name) {
  for (final part in cookieHeader.split(';')) {
    final trimmed = part.trim();
    if (!trimmed.startsWith('$name=')) {
      continue;
    }
    return trimmed.substring(name.length + 1).trim().isNotEmpty;
  }
  return false;
}

List<Cookie> buildWhuCasWebViewCookies(String cookieHeader) {
  final cookies = <Cookie>[];
  for (final part in cookieHeader.split(';')) {
    final trimmed = part.trim();
    if (trimmed.isEmpty || !trimmed.contains('=')) {
      continue;
    }
    final separator = trimmed.indexOf('=');
    final name = trimmed.substring(0, separator).trim();
    final value = trimmed.substring(separator + 1).trim();
    if (name.isEmpty || value.isEmpty) {
      continue;
    }
    cookies.add(
      Cookie(name, value)
        ..domain = 'cas.whu.edu.cn'
        ..path = '/'
        ..secure = true
        ..httpOnly = true,
    );
  }
  return cookies;
}
