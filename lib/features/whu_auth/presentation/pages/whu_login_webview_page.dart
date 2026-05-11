import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_cookie_manager_flutter/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WhuLoginWebViewPage extends ConsumerStatefulWidget {
  const WhuLoginWebViewPage({super.key});

  @override
  ConsumerState<WhuLoginWebViewPage> createState() =>
      _WhuLoginWebViewPageState();
}

/// 指向 JWGL SSO 作为 service，登录成功后 CAS 会重定向到 JWGL，
/// 这样 WebView 同时持有 CAS cookie 和 JWGL session cookie。
const _loginUrl =
    'https://cas.whu.edu.cn/authserver/login'
    '?service=https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin';

class _WhuLoginWebViewPageState extends ConsumerState<WhuLoginWebViewPage> {
  final _cookieManager = WebviewCookieManager();
  WebViewController? _controller;
  var _loading = true;
  String? _errorMessage;
  var _didRetryCacheMiss = false;
  var _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller = controller;

    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (!mounted) return;
          setState(() {
            _loading = true;
            _errorMessage = null;
          });
        },
        onPageFinished: (_) {
          if (!mounted) return;
          setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          if (!mounted) return;
          if (error.isForMainFrame != true) return;

          // ERR_CACHE_MISS：CAS 登录后的 POST 重定向丢失缓存数据
          // 自动重试一次即可恢复
          if (error.description.contains('ERR_CACHE_MISS') &&
              !_didRetryCacheMiss) {
            _didRetryCacheMiss = true;
            setState(() => _errorMessage = null);
            controller.loadRequest(Uri.parse(_loginUrl));
            return;
          }
          if (mounted) {
            setState(() {
              _loading = false;
              _errorMessage = '${error.description} (${error.errorCode})';
            });
          }
        },
      ),
    );

    await controller.clearCache();
    await controller.loadRequest(Uri.parse(_loginUrl));

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  void _retry() {
    setState(() {
      _errorMessage = null;
      _loading = true;
      _didRetryCacheMiss = false;
    });
    _controller?.loadRequest(Uri.parse(_loginUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isZh = _isChinese(context);
    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(isZh ? '登录武大教务' : 'WHU Login'),
          trailing: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.selected),
              onPressed: _confirmCookies,
            ),
          ],
        ),
      ],
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ui.OutlineButton(
                onPressed: _retry,
                child: Text(_isChinese(context) ? '重试' : 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoggingIn) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        if (_controller != null)
          WebViewWidget(controller: _controller!),
        if (_loading)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  /// 用户在 WebView 中完成 CAS 登录后，点击确认按钮触发 cookie 提取。
  Future<void> _confirmCookies() async {
    final isZh = _isChinese(context);

    // 从 WebView 读取 CAS 和 JWGL 两个域名的 cookie
    // WebView URL 指向了 JWGL SSO，登录后重定向链经过了 JWGL
    final cookies = await Future.wait([
      _cookieManager.getCookies('https://jwgl.whu.edu.cn'),
      _cookieManager.getCookies('https://cas.whu.edu.cn'),
    ]);

    final cookieMap = <String, String>{};
    for (final batch in cookies) {
      for (final cookie in batch) {
        if (cookie.name.isEmpty) continue;
        cookieMap[cookie.name] = cookie.value;
      }
    }

    if (!mounted) return;
    if (cookieMap.isEmpty) {
      _showMessage(
        isZh ? '未读取到登录会话，请先完成登录后再确认。' : 'No session found. Please login first.',
      );
      return;
    }

    final cookieHeader =
        cookieMap.entries.map((e) => '${e.key}=${e.value}').join('; ');

    setState(() => _isLoggingIn = true);
    try {
      await ref.read(whuAuthProvider.notifier).onLoginSuccess(
            sessionCookie: cookieHeader,
            studentId: '',
            studentName: '',
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingIn = false);
        _showMessage('登录处理出错：$e');
      }
    }
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context)
        .languageCode
        .toLowerCase()
        .startsWith('zh');
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_isChinese(ctx) ? '确定' : 'OK'),
          ),
        ],
      ),
    );
  }
}
