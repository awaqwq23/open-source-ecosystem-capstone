import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_data.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/pages/sports_reservation_checkout_webview_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/viewmodels/sports_reservation_view_model.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/presentation/widgets/app_web_view_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_cookie_manager_flutter/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SportsReservationSessionWebViewPage extends ConsumerStatefulWidget {
  const SportsReservationSessionWebViewPage({super.key});

  @override
  ConsumerState<SportsReservationSessionWebViewPage> createState() =>
      _SportsReservationSessionWebViewPageState();
}

class _SportsReservationSessionWebViewPageState
    extends ConsumerState<SportsReservationSessionWebViewPage> {
  final WebviewCookieManager _cookieManager = WebviewCookieManager();
  var _needsLogin = false;
  var _waitingForToken = false;
  var _readingToken = false;
  var _completed = false;
  String? _errorMessage;

  Future<AppWebViewRequest?> _prepareInitialRequest(
    WebViewController controller,
  ) async {
    setState(() {
      _needsLogin = false;
      _waitingForToken = false;
      _errorMessage = null;
    });

    final authState = ref.read(whuAuthProvider);
    if (!authState.isAuthenticated || authState.isExpired) {
      setState(() {
        _needsLogin = true;
      });
      return null;
    }

    try {
      await ref
          .read(sportsReservationAuthServiceProvider)
          .primeCasCookiesForWebView();
      await controller.setUserAgent(SportsReservationWebSession.userAgent);
      return AppWebViewRequest(
        uri: SportsReservationAuthService.webAuthorizationUri,
      );
    } on WhuAuthException catch (error) {
      if (!mounted) {
        return null;
      }
      setState(() {
        _needsLogin = true;
        _errorMessage = error.message;
      });
      return null;
    } catch (error) {
      if (!mounted) {
        return null;
      }
      setState(() {
        _errorMessage = '场馆系统授权准备失败：$error';
      });
      return null;
    }
  }

  AppWebViewNavigationAction _handleNavigationRequest(
    NavigationRequest request,
  ) {
    final uri = Uri.tryParse(request.url);
    if (uri == null || !_isWebUri(uri)) {
      setState(() {
        _errorMessage = '当前链接需要在浏览器或学校应用中打开。';
      });
      return const AppWebViewNavigationAction.prevent();
    }
    debugPrint(
      '[SportsReservationSessionWebView] ${sanitizeSportsReservationWebUrl(uri)}',
    );
    return const AppWebViewNavigationAction.navigate();
  }

  Future<void> _handlePageFinished(
    String url,
    WebViewController controller,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    debugPrint(
      '[SportsReservationSessionWebView] finished ${sanitizeSportsReservationWebUrl(uri)}',
    );
    if (_isCasLoginUri(uri)) {
      if (!mounted || _completed) {
        return;
      }
      setState(() {
        _needsLogin = true;
        _waitingForToken = false;
        _errorMessage = '武大统一认证登录状态已失效，请重新登录后再授权场馆系统。';
      });
      return;
    }
    if (_isGymUri(uri)) {
      await _tryCompleteFromWebStorage(controller, uri);
    }
  }

  Future<void> _tryCompleteFromWebStorage(
    WebViewController controller,
    Uri referer,
  ) async {
    if (_readingToken || _completed) {
      return;
    }
    _readingToken = true;
    if (mounted) {
      setState(() {
        _waitingForToken = true;
        _errorMessage = null;
      });
    }
    try {
      for (var attempt = 0; attempt < 20; attempt++) {
        final token = await _readWebStorageValue(controller, const [
          'wxtoken',
          'jwttoken',
          'jwtToken',
        ]);
        if (token.isNotEmpty) {
          final cookieHeader = await _readGymCookieHeader();
          if (!_hasSafeLineCookie(cookieHeader) && attempt < 19) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
            continue;
          }
          final userId = await _readWebStorageValue(controller, const [
            'wdUid',
            'userId',
            'uid',
          ]);
          final session = ref
              .read(sportsReservationAuthServiceProvider)
              .createSessionFromWebToken(
                jwt: token,
                referer: referer,
                userId: userId,
                cookieHeader: cookieHeader,
              );
          ref
              .read(sportsReservationViewModelProvider.notifier)
              .useSession(session);
          _completed = true;
          if (mounted) {
            context.pop(session);
          }
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (!mounted || _completed) {
          return;
        }
      }
      if (!mounted || _completed) {
        return;
      }
      setState(() {
        _waitingForToken = false;
        _errorMessage = '场馆页面已打开，但未读取到登录凭证。请刷新或重新授权。';
      });
    } catch (error) {
      if (!mounted || _completed) {
        return;
      }
      setState(() {
        _waitingForToken = false;
        _errorMessage = '读取场馆登录凭证失败：$error';
      });
    } finally {
      _readingToken = false;
    }
  }

  Future<String> _readWebStorageValue(
    WebViewController controller,
    List<String> keys,
  ) async {
    final encodedKeys = jsonEncode(keys);
    final value = await controller.runJavaScriptReturningResult('''
(function () {
  var keys = $encodedKeys;
  function readFrom(storageName) {
    try {
      var storage = window[storageName];
      if (!storage) {
        return '';
      }
      for (var index = 0; index < keys.length; index++) {
        var value = storage.getItem(keys[index]);
        if (value) {
          return value;
        }
      }
    } catch (error) {
      return '';
    }
    return '';
  }
  return readFrom('localStorage') || readFrom('sessionStorage') || '';
})()
''');
    return normalizeSportsReservationWebStorageValue(value);
  }

  Future<String> _readGymCookieHeader() async {
    final cookies = await _cookieManager.getCookies(
      SportsReservationAuthService.serviceUrl.toString(),
    );
    final gymCookies = [
      for (final cookie in cookies)
        if ((cookie.domain == null ||
                cookie.domain!.contains('gym.whu.edu.cn')) &&
            cookie.name.trim().isNotEmpty &&
            cookie.value.trim().isNotEmpty)
          cookie,
    ];
    final header = gymCookies
        .map((cookie) => '${cookie.name}=${cookie.value}')
        .join('; ');
    if (header.isNotEmpty) {
      final names = gymCookies.map((cookie) => cookie.name).toList()..sort();
      debugPrint(
        '[SportsReservationSessionWebView] gym cookies=${names.join(',')}',
      );
    }
    return header;
  }

  bool _hasSafeLineCookie(String cookieHeader) {
    return cookieHeader.contains('safeline_bot_token=') ||
        cookieHeader.contains('safeline_bot_challenge=');
  }

  Future<void> _openLoginGuide(WebViewController controller) async {
    await context.push(AppRoutePaths.whuAccount);
    if (!mounted) {
      return;
    }
    final request = await _prepareInitialRequest(controller);
    if (request != null) {
      await controller.loadRequest(request.uri, headers: request.headers);
    }
  }

  Future<void> _refresh(
    WebViewController controller,
    Future<void> Function() loadInitialRequest,
  ) async {
    if (_needsLogin || _errorMessage != null) {
      await loadInitialRequest();
      return;
    }
    await controller.reload();
  }

  void _exit() {
    if (!_completed) {
      context.pop<SportsReservationSession>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppWebViewPage(
      title: '授权场馆系统',
      initialRequest: _prepareInitialRequest,
      preparingMessage: '正在准备场馆系统授权...',
      loadingMessage: '正在打开场馆系统...',
      errorTitle: '场馆系统暂时无法打开',
      onNavigationRequest: (request, _) => _handleNavigationRequest(request),
      onPageStarted: (url, _) {
        final uri = Uri.tryParse(url);
        if (uri != null) {
          debugPrint(
            '[SportsReservationSessionWebView] started ${sanitizeSportsReservationWebUrl(uri)}',
          );
        }
      },
      onPageFinished: _handlePageFinished,
      onRefresh: _refresh,
      onExit: _exit,
      overlayBuilder: (context, state, controller) {
        if (_needsLogin) {
          return _SessionStateOverlay(
            icon: Icons.account_circle_outlined,
            title: '需要登录武大统一认证',
            message: _errorMessage ?? '登录后可继续授权运动场馆系统。',
            primaryText: '去登录',
            onPrimary: () => _openLoginGuide(controller),
            secondaryText: '返回',
            onSecondary: _exit,
          );
        }
        final errorMessage = _errorMessage;
        if (errorMessage != null) {
          return _SessionStateOverlay(
            icon: Icons.error_outline,
            title: '无法完成场馆授权',
            message: errorMessage,
            primaryText: '重试',
            onPrimary: () => _refresh(controller, () async {
              final request = await _prepareInitialRequest(controller);
              if (request != null) {
                await controller.loadRequest(
                  request.uri,
                  headers: request.headers,
                );
              }
            }),
            secondaryText: '返回',
            onSecondary: _exit,
          );
        }
        if (_waitingForToken) {
          return ColoredBox(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.72),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('正在建立场馆系统会话...'),
                ],
              ),
            ),
          );
        }
        return null;
      },
    );
  }

  bool _isWebUri(Uri uri) {
    return uri.scheme == 'https' || uri.scheme == 'http';
  }

  bool _isCasLoginUri(Uri uri) {
    return uri.host == 'cas.whu.edu.cn' && uri.path.contains('/login');
  }

  bool _isGymUri(Uri uri) {
    final serviceUrl = SportsReservationAuthService.serviceUrl;
    return uri.host == serviceUrl.host &&
        uri.path.startsWith(trimSportsReservationBasePath(serviceUrl.path));
  }
}

String normalizeSportsReservationWebStorageValue(Object? value) {
  if (value == null) {
    return '';
  }
  final text = '$value'.trim();
  if (text.isEmpty || text == 'null' || text == 'undefined') {
    return '';
  }
  if (text.length >= 2 && text.startsWith('"') && text.endsWith('"')) {
    try {
      final decoded = jsonDecode(text);
      return decoded is String ? decoded.trim() : '$decoded'.trim();
    } on FormatException {
      return text;
    }
  }
  return text;
}

class _SessionStateOverlay extends StatelessWidget {
  const _SessionStateOverlay({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.onPrimary,
    required this.secondaryText,
    required this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryText;
  final VoidCallback onPrimary;
  final String secondaryText;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return ColoredBox(
      color: colors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: colors.primary),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ui.OutlineButton(
                      onPressed: onSecondary,
                      child: Text(secondaryText),
                    ),
                    const SizedBox(width: 12),
                    ui.PrimaryButton(
                      onPressed: onPrimary,
                      child: Text(primaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
