import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WhuLoginWebViewPage extends ConsumerStatefulWidget {
  const WhuLoginWebViewPage({super.key});

  @override
  ConsumerState<WhuLoginWebViewPage> createState() => _WhuLoginWebViewPageState();
}

class _WhuLoginWebViewPageState extends ConsumerState<WhuLoginWebViewPage> {
  static final _loginUri = Uri.parse(
    'https://cas.whu.edu.cn/authserver/login?service=https%3A%2F%2Fcas.whu.edu.cn%2Fauthserver%2Fmobile%2Fcallback%3FappId%3D985180443&login_type=mobileLogin',
  );

  late final WebViewController _controller;
  bool _loading = true;
  bool _completing = false;
  bool _callbackReached = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (mounted) {
              setState(() {
                _loading = false;
                _errorMessage = null;
              });
            }
            await _tryCompleteLogin();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false || !mounted) {
              return;
            }
            setState(() {
              _loading = false;
              _completing = false;
              _errorMessage = '页面加载失败，请检查网络连接后重试。';
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && _isLoginCallback(uri)) {
              _completeLoginFromCallback();
              return NavigationDecision.prevent;
            }
            if (request.url == 'https://homewh.chaoxing.com/agree/privacyPolicy?appId=1000028') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(true);
    _loadLoginPage();
  }

  Future<void> _loadLoginPage() async {
    final platformController = _controller.platform;
    if (platformController is AndroidWebViewController) {
      await platformController.setUseWideViewPort(true);
      await platformController.setTextZoom(100);
    }
    if (mounted) {
      setState(() {
        _loading = true;
        _completing = false;
        _callbackReached = false;
        _errorMessage = null;
      });
    }
    await _controller.loadRequest(_loginUri);
  }

  @override
  Widget build(BuildContext context) {
    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('登录武大教务'),
        ),
      ],
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_errorMessage != null)
            _LoginStateOverlay(
              title: '无法打开页面',
              message: _errorMessage!,
              onRetry: _loadLoginPage,
            ),
          if (_loading || _completing)
            ColoredBox(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(_completing ? '正在验证登录状态...' : '正在加载统一认证...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _tryCompleteLogin() async {
    if (_completing) {
      return;
    }
    setState(() => _completing = true);
    try {
      await ref.read(whuAuthProvider.notifier).completeCasLogin();
      if (!mounted) {
        return;
      }
      Navigator.of(context).maybePop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _completing = false;
          if (_callbackReached) {
            _errorMessage = '登录状态验证失败：$error';
          }
        });
      }
    }
  }

  void _completeLoginFromCallback() {
    if (_completing) {
      return;
    }
    _callbackReached = true;
    Future<void>.microtask(_tryCompleteLogin);
  }

  bool _isLoginCallback(Uri uri) {
    return uri.host == 'cas.whu.edu.cn' &&
        uri.path == '/authserver/mobile/callback' &&
        uri.queryParameters['appId'] == '985180443';
  }
}

class _LoginStateOverlay extends StatelessWidget {
  const _LoginStateOverlay({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

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
                Icon(Icons.wifi_off_outlined, size: 48, color: colors.primary),
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
                  onPressed: onRetry,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
