import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/presentation/widgets/app_web_view_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_flutter/webview_flutter.dart';

class WhuLoginWebViewPage extends ConsumerStatefulWidget {
  const WhuLoginWebViewPage({super.key});

  @override
  ConsumerState<WhuLoginWebViewPage> createState() => _WhuLoginWebViewPageState();
}

class _WhuLoginWebViewPageState extends ConsumerState<WhuLoginWebViewPage> {
  static final _loginUri = Uri.parse(
    'https://cas.whu.edu.cn/authserver/login?service=https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin',
  );

  bool _completing = false;
  bool _educationReached = false;
  String? _loginErrorMessage;

  AppWebViewRequest _buildLoginRequest(WebViewController controller) {
    if (mounted) {
      setState(() {
        _completing = false;
        _educationReached = false;
        _loginErrorMessage = null;
      });
    }
    return AppWebViewRequest(uri: _loginUri);
  }

  Future<void> _reloadLoginPage(WebViewController controller) async {
    if (mounted) {
      setState(() {
        _completing = false;
        _educationReached = false;
        _loginErrorMessage = null;
      });
    }
    await controller.loadRequest(_loginUri);
  }

  @override
  Widget build(BuildContext context) {
    return AppWebViewPage(
      title: '登录武大教务',
      showRefresh: false,
      loadingMessage: '正在加载统一认证...',
      preparingMessage: '正在加载统一认证...',
      errorTitle: '无法打开页面',
      errorMessage: '页面加载失败，请检查网络连接后重试。',
      initialRequest: _buildLoginRequest,
      onPageFinished: (url, _) {
        final uri = Uri.tryParse(url);
        if (uri != null && _isEducationPage(uri)) {
          _completeLoginFromEducationPage();
        }
      },
      onNavigationRequest: (request, _) {
        if (request.url ==
            'https://homewh.chaoxing.com/agree/privacyPolicy?appId=1000028') {
          return const AppWebViewNavigationAction.prevent();
        }
        return const AppWebViewNavigationAction.navigate();
      },
      overlayBuilder: (context, state, controller) {
        final loginErrorMessage = _loginErrorMessage;
        if (loginErrorMessage != null) {
          return _LoginStateOverlay(
            title: '无法完成登录',
            message: loginErrorMessage,
            onRetry: () => _reloadLoginPage(controller),
          );
        }
        if (!_completing) {
          return null;
        }
        return ColoredBox(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('正在验证登录状态...'),
              ],
            ),
          ),
        );
      },
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
          if (_educationReached) {
            _loginErrorMessage = '登录状态验证失败：$error';
          }
        });
      }
    }
  }

  void _completeLoginFromEducationPage() {
    if (_completing) {
      return;
    }
    _educationReached = true;
    Future<void>.microtask(_tryCompleteLogin);
  }

  bool _isEducationPage(Uri uri) {
    return uri.host == 'jwgl.whu.edu.cn' &&
        (uri.path == '/xtgl/index_initMenu.html' ||
            uri.path == '/xtgl/login_slogin.html');
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
