import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class AppWebViewRequest {
  const AppWebViewRequest({
    required this.uri,
    this.headers = const <String, String>{},
  });

  final Uri uri;
  final Map<String, String> headers;
}

enum AppWebViewNavigationType {
  navigate,
  prevent,
  reloadWithHeaders,
}

class AppWebViewNavigationAction {
  const AppWebViewNavigationAction._(
    this.type, {
    this.uri,
    this.headers = const <String, String>{},
  });

  const AppWebViewNavigationAction.navigate()
      : this._(AppWebViewNavigationType.navigate);

  const AppWebViewNavigationAction.prevent()
      : this._(AppWebViewNavigationType.prevent);

  const AppWebViewNavigationAction.reloadWithHeaders(
    Uri uri,
    Map<String, String> headers,
  ) : this._(
          AppWebViewNavigationType.reloadWithHeaders,
          uri: uri,
          headers: headers,
        );

  final AppWebViewNavigationType type;
  final Uri? uri;
  final Map<String, String> headers;
}

class AppWebViewRuntimeState {
  const AppWebViewRuntimeState({
    required this.preparing,
    required this.loading,
    required this.progress,
    required this.errorMessage,
  });

  final bool preparing;
  final bool loading;
  final int progress;
  final String? errorMessage;
}

typedef AppWebViewInitialRequestBuilder
    = FutureOr<AppWebViewRequest?> Function(WebViewController controller);
typedef AppWebViewControllerCallback = FutureOr<void> Function(
  WebViewController controller,
);
typedef AppWebViewUrlCallback = FutureOr<void> Function(
  String url,
  WebViewController controller,
);
typedef AppWebViewNavigationCallback
    = FutureOr<AppWebViewNavigationAction> Function(
  NavigationRequest request,
  WebViewController controller,
);
typedef AppWebViewRefreshCallback = FutureOr<void> Function(
  WebViewController controller,
  Future<void> Function() loadInitialRequest,
);
typedef AppWebViewOverlayBuilder = Widget? Function(
  BuildContext context,
  AppWebViewRuntimeState state,
  WebViewController controller,
);

class AppWebViewPage extends StatefulWidget {
  const AppWebViewPage({
    required this.title,
    required this.initialRequest,
    this.onControllerCreated,
    this.onNavigationRequest,
    this.onPageStarted,
    this.onPageFinished,
    this.onWebResourceError,
    this.onRefresh,
    this.overlayBuilder,
    this.onExit,
    this.showRefresh = true,
    this.enableZoom = true,
    this.loadingMessage = '正在加载页面...',
    this.preparingMessage = '正在准备页面...',
    this.errorTitle = '页面暂时无法打开',
    this.errorMessage = '页面加载失败，请检查网络连接后重试。',
    super.key,
  });

  final String title;
  final AppWebViewInitialRequestBuilder initialRequest;
  final AppWebViewControllerCallback? onControllerCreated;
  final AppWebViewNavigationCallback? onNavigationRequest;
  final AppWebViewUrlCallback? onPageStarted;
  final AppWebViewUrlCallback? onPageFinished;
  final void Function(WebResourceError error)? onWebResourceError;
  final AppWebViewRefreshCallback? onRefresh;
  final AppWebViewOverlayBuilder? overlayBuilder;
  final VoidCallback? onExit;
  final bool showRefresh;
  final bool enableZoom;
  final String loadingMessage;
  final String preparingMessage;
  final String errorTitle;
  final String errorMessage;

  @override
  State<AppWebViewPage> createState() => _AppWebViewPageState();
}

class _AppWebViewPageState extends State<AppWebViewPage> {
  late final WebViewController _controller;
  final Set<String> _headerReloadUrls = <String>{};
  var _preparing = true;
  var _loading = true;
  var _progress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() => _progress = progress);
            }
          },
          onPageStarted: (url) async {
            if (mounted) {
              setState(() {
                _loading = true;
                _errorMessage = null;
              });
            }
            await widget.onPageStarted?.call(url, _controller);
          },
          onPageFinished: (url) async {
            if (mounted) {
              setState(() {
                _preparing = false;
                _loading = false;
                _progress = 100;
              });
            }
            await widget.onPageFinished?.call(url, _controller);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) {
              return;
            }
            widget.onWebResourceError?.call(error);
            if (mounted) {
              setState(() {
                _preparing = false;
                _loading = false;
                _errorMessage = widget.errorMessage;
              });
            }
          },
          onNavigationRequest: _handleNavigationRequest,
        ),
      )
      ..enableZoom(widget.enableZoom);
    unawaited(_configureAndLoad());
  }

  Future<void> _configureAndLoad() async {
    try {
      final platformController = _controller.platform;
      if (platformController is AndroidWebViewController) {
        await platformController.setUseWideViewPort(true);
        await platformController.setTextZoom(100);
      }
      await widget.onControllerCreated?.call(_controller);
      await _loadInitialRequest();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preparing = false;
        _loading = false;
        _errorMessage = '页面准备失败：$error';
      });
    }
  }

  Future<void> _loadInitialRequest() async {
    if (mounted) {
      setState(() {
        _preparing = true;
        _loading = true;
        _progress = 0;
        _errorMessage = null;
      });
    }
    try {
      final request = await widget.initialRequest(_controller);
      if (request == null) {
        if (mounted) {
          setState(() {
            _preparing = false;
            _loading = false;
          });
        }
        return;
      }
      await _controller.loadRequest(request.uri, headers: request.headers);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preparing = false;
        _loading = false;
        _errorMessage = '页面准备失败：$error';
      });
    }
  }

  FutureOr<NavigationDecision> _handleNavigationRequest(
    NavigationRequest request,
  ) async {
    if (_headerReloadUrls.remove(request.url)) {
      return NavigationDecision.navigate;
    }

    final callback = widget.onNavigationRequest;
    if (callback == null) {
      return NavigationDecision.navigate;
    }
    final action = await callback(request, _controller);
    return switch (action.type) {
      AppWebViewNavigationType.navigate => NavigationDecision.navigate,
      AppWebViewNavigationType.prevent => NavigationDecision.prevent,
      AppWebViewNavigationType.reloadWithHeaders => _reloadWithHeaders(action),
    };
  }

  NavigationDecision _reloadWithHeaders(AppWebViewNavigationAction action) {
    final uri = action.uri;
    if (uri == null) {
      return NavigationDecision.prevent;
    }
    _headerReloadUrls.add(uri.toString());
    unawaited(_controller.loadRequest(uri, headers: action.headers));
    return NavigationDecision.prevent;
  }

  Future<void> _refresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!.call(_controller, _loadInitialRequest);
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
      _progress = 0;
    });
    await _controller.reload();
  }

  Future<void> _handleBackNavigation() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    widget.onExit?.call();
    if (widget.onExit == null && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final runtimeState = AppWebViewRuntimeState(
      preparing: _preparing,
      loading: _loading,
      progress: _progress,
      errorMessage: _errorMessage,
    );
    final customOverlay =
        widget.overlayBuilder?.call(context, runtimeState, _controller);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _handleBackNavigation();
        }
      },
      child: ui.Scaffold(
        headers: [
          ui.AppBar(
            leading: [
              ui.IconButton.ghost(
                icon: const Icon(AppIcons.back),
                onPressed: _handleBackNavigation,
              ),
            ],
            title: Text(widget.title),
            trailing: [
              if (widget.showRefresh)
                ui.IconButton.ghost(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
            ],
          ),
        ],
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_errorMessage != null)
              _AppWebViewStateOverlay(
                icon: Icons.wifi_off_outlined,
                title: widget.errorTitle,
                message: _errorMessage!,
                primaryText: '重试',
                onPrimary: _loadInitialRequest,
              ),
            if (_preparing || _loading)
              _AppWebViewLoadingOverlay(
                progress: _progress,
                message: _preparing
                    ? widget.preparingMessage
                    : widget.loadingMessage,
              ),
            if (customOverlay != null) customOverlay,
          ],
        ),
      ),
    );
  }
}

class _AppWebViewLoadingOverlay extends StatelessWidget {
  const _AppWebViewLoadingOverlay({
    required this.progress,
    required this.message,
  });

  final int progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surface.withValues(alpha: 0.72),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress <= 0 ? null : progress / 100),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(message),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppWebViewStateOverlay extends StatelessWidget {
  const _AppWebViewStateOverlay({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.onPrimary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryText;
  final VoidCallback onPrimary;

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
                ui.PrimaryButton(
                  onPressed: onPrimary,
                  child: Text(primaryText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
