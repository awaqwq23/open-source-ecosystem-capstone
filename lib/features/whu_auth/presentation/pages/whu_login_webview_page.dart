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
  late final WebViewController _controller;
  bool _loading = true;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (mounted) {
              setState(() => _loading = false);
            }
            await _tryCompleteLogin();
          },
          onNavigationRequest: (request) {
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
    await _controller.loadRequest(
      Uri.parse(
        'https://cas.whu.edu.cn/authserver/login?service=https%3A%2F%2Fcas.whu.edu.cn%2Fauthserver%2Fmobile%2Fcallback%3FappId%3D985180443&login_type=mobileLogin',
      ),
    );
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
    } catch (_) {
      if (mounted) {
        setState(() => _completing = false);
      }
    }
  }
}
