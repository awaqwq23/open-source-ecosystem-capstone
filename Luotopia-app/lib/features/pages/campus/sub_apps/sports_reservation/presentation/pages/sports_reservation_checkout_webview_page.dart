import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_data.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/viewmodels/sports_reservation_view_model.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/presentation/widgets/app_web_view_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_flutter/webview_flutter.dart';

class SportsReservationCheckoutWebViewPage extends ConsumerStatefulWidget {
  const SportsReservationCheckoutWebViewPage({required this.args, super.key});

  final SportsCheckoutArgs args;

  @override
  ConsumerState<SportsReservationCheckoutWebViewPage> createState() =>
      _SportsReservationCheckoutWebViewPageState();
}

class _SportsReservationCheckoutWebViewPageState
    extends ConsumerState<SportsReservationCheckoutWebViewPage> {
  SportsReservationWebSession? _session;
  SportsCheckoutResult? _result;
  Timer? _routePoller;
  var _pollingLocation = false;
  var _completedAndExiting = false;
  String? _lastObservedUrl;
  var _needsLogin = false;
  String? _errorMessage;

  @override
  void dispose() {
    _routePoller?.cancel();
    super.dispose();
  }

  Future<AppWebViewRequest?> _prepareInitialRequest(
    WebViewController controller,
  ) async {
    setState(() {
      _needsLogin = false;
      _errorMessage = null;
    });

    if (!widget.args.canStartCheckout) {
      setState(() {
        _errorMessage = '当前场地或时段不可预约，请返回重新选择。';
      });
      return null;
    }

    final authState = ref.read(whuAuthProvider);
    if (!authState.isAuthenticated || authState.isExpired) {
      setState(() {
        _needsLogin = true;
      });
      return null;
    }

    try {
      final launchUri = sportsReservationCheckoutEntryUri(widget.args);
      final session = ref
          .read(sportsReservationViewModelProvider.notifier)
          .webSessionFor(launchUri: launchUri);
      if (session == null) {
        setState(() {
          _errorMessage = '请先返回预约页完成场馆系统授权。';
        });
        return null;
      }
      if (!mounted) {
        return null;
      }
      _session = session;
      await controller.setUserAgent(SportsReservationWebSession.userAgent);
      await controller.loadHtmlString(
        session.bootstrapHtml,
        baseUrl: session.bootstrapBaseUrl,
      );
      return null;
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
        _errorMessage = '预约确认页准备失败：$error';
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

    final result = _handleObservedUri(uri);
    if (result?.outcome == SportsCheckoutOutcome.completed) {
      return const AppWebViewNavigationAction.prevent();
    }
    if (_isCasLoginUri(uri)) {
      _result = const SportsCheckoutResult.authorizationExpired(
        message: '运动场馆系统登录已失效，请重新登录后再试。',
      );
    }

    final session = _session;
    if (session != null && session.shouldLoadWithGymHeaders(uri)) {
      return AppWebViewNavigationAction.reloadWithHeaders(
        uri,
        session.documentHeadersFor(uri),
      );
    }

    return const AppWebViewNavigationAction.navigate();
  }

  SportsCheckoutResult? _handleObservedUri(Uri uri) {
    if (_completedAndExiting) {
      return _result;
    }
    final result = sportsReservationCheckoutResultForUri(uri);
    if (result != null) {
      _result = result;
      if (result.outcome == SportsCheckoutOutcome.completed) {
        _completeAndExit(result);
      }
    }
    return result;
  }

  void _handleObservedUrl(String event, String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    _handleObservedUri(uri);
    debugPrint(
      '[SportsReservationWebView] $event ${sanitizeSportsReservationWebUrl(uri)}',
    );
  }

  void _completeAndExit(SportsCheckoutResult result) {
    if (_completedAndExiting || !mounted) {
      return;
    }
    _completedAndExiting = true;
    _result = result;
    _routePoller?.cancel();
    _routePoller = null;
    Future<void>.microtask(() {
      if (mounted) {
        context.pop(result);
      }
    });
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
    context.pop(_result ?? const SportsCheckoutResult.dismissed());
  }

  void _returnToNativeReservationPage() {
    context.pop(
      _result?.withSuppressedFeedback() ??
          const SportsCheckoutResult.silentOrderChanged(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppWebViewPage(
      title: '确认预约',
      initialRequest: _prepareInitialRequest,
      onControllerCreated: _startRoutePolling,
      allowMixedContent: true,
      preparingMessage: '正在准备预约确认页...',
      loadingMessage: '正在加载预约确认页...',
      errorTitle: '预约确认页暂时无法打开',
      onNavigationRequest: (request, _) => _handleNavigationRequest(request),
      onPageStarted: (url, _) {
        _handleObservedUrl('started', url);
      },
      onPageFinished: (url, _) {
        _handleObservedUrl('finished', url);
      },
      onRefresh: _refresh,
      onExit: _exit,
      trailingActions: [
        ui.Tooltip(
          tooltip: (context) => const Text('返回原生预约页'),
          child: ui.IconButton.ghost(
            icon: const Icon(Icons.home_outlined),
            onPressed: _returnToNativeReservationPage,
          ),
        ),
      ],
      overlayBuilder: (context, state, controller) {
        if (_needsLogin) {
          return _CheckoutStateOverlay(
            icon: Icons.account_circle_outlined,
            title: '需要登录武大统一认证',
            message: _errorMessage ?? '登录后可继续确认运动场馆预约。',
            primaryText: '去登录',
            onPrimary: () => _openLoginGuide(controller),
            secondaryText: '返回',
            onSecondary: _exit,
          );
        }
        final errorMessage = _errorMessage;
        if (errorMessage != null) {
          return _CheckoutStateOverlay(
            icon: Icons.error_outline,
            title: '无法继续确认预约',
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

  void _startRoutePolling(WebViewController controller) {
    _routePoller?.cancel();
    _routePoller = Timer.periodic(const Duration(milliseconds: 500), (_) {
      unawaited(_observeCurrentLocation(controller));
    });
  }

  Future<void> _observeCurrentLocation(WebViewController controller) async {
    if (_pollingLocation || _completedAndExiting) {
      return;
    }
    _pollingLocation = true;
    try {
      final value = await controller.runJavaScriptReturningResult(
        'window.location.href',
      );
      final url = normalizeSportsReservationJavaScriptString(value);
      if (url.isEmpty || url == _lastObservedUrl) {
        return;
      }
      _lastObservedUrl = url;
      final uri = Uri.tryParse(url);
      if (uri == null) {
        return;
      }
      _handleObservedUri(uri);
      debugPrint(
        '[SportsReservationWebView] route ${sanitizeSportsReservationWebUrl(uri)}',
      );
    } catch (_) {
      // The page may be between navigations. The next poll will observe it.
    } finally {
      _pollingLocation = false;
    }
  }
}

Uri sportsReservationCheckoutEntryUri(
  SportsCheckoutArgs args, {
  Uri? serviceUrl,
}) {
  final base = serviceUrl ?? SportsReservationAuthService.serviceUrl;
  return base.replace(
    path: '${trimSportsReservationBasePath(base.path)}/pages/index/detail',
    queryParameters: {
      'areaId': '${args.stadiumsAreaId}',
      'areaNo': '${args.stadiumsAreaNo}',
      'date': _formatDate(args.dateOnly),
    },
  );
}

SportsCheckoutResult? sportsReservationCheckoutResultForUri(Uri uri) {
  if (uri.host != SportsReservationAuthService.serviceUrl.host) {
    return null;
  }

  final route = _sportsReservationWebRoute(uri);
  if (route == null || !route.path.startsWith('/pages/order/')) {
    return null;
  }

  final orderNo = route.queryParameters['orderNo'];
  if (route.path == '/pages/order/success') {
    return SportsCheckoutResult.completed(orderNo: orderNo);
  }
  if (route.path == '/pages/order/sureOrder' ||
      route.path == '/pages/order/orderDetails' ||
      route.path == '/pages/order/orderList') {
    return SportsCheckoutResult.orderChanged(orderNo: orderNo);
  }
  return null;
}

Uri? _sportsReservationWebRoute(Uri uri, {Uri? serviceUrl}) {
  final basePath = trimSportsReservationBasePath(
    (serviceUrl ?? SportsReservationAuthService.serviceUrl).path,
  );
  if (!uri.path.startsWith(basePath)) {
    return null;
  }
  final historyPath = uri.path.substring(basePath.length);
  if (historyPath.startsWith('/pages/')) {
    return Uri(path: historyPath, queryParameters: uri.queryParameters);
  }

  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) {
    return null;
  }
  final fragmentUri = Uri.tryParse(
    fragment.startsWith('/') ? fragment : '/$fragment',
  );
  if (fragmentUri == null || !fragmentUri.path.startsWith('/pages/')) {
    return null;
  }
  return fragmentUri;
}

String trimSportsReservationBasePath(String path) {
  if (path.endsWith('/')) {
    return path.substring(0, path.length - 1);
  }
  return path;
}

String sanitizeSportsReservationWebUrl(Uri uri) {
  final sensitiveKeys = {'ticket', 'orderNo', 'json', 'signature'};
  final queryParameters = <String, String>{};
  for (final entry in uri.queryParameters.entries) {
    queryParameters[entry.key] = sensitiveKeys.contains(entry.key)
        ? '<redacted>'
        : entry.value;
  }
  return uri.replace(queryParameters: queryParameters).toString();
}

String normalizeSportsReservationJavaScriptString(Object? value) {
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

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

class _CheckoutStateOverlay extends StatelessWidget {
  const _CheckoutStateOverlay({
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
