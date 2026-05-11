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
  ConsumerState<WhuLoginWebViewPage> createState() => _WhuLoginWebViewPageState();
}

class _WhuLoginWebViewPageState extends ConsumerState<WhuLoginWebViewPage> {
  static const _loginUrl =
      'https://cas.whu.edu.cn/authserver/login?service='
      'https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin';
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
    final controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    // 预先赋值，让闭包能通过实例字段引用 controller
    _controller = controller;

    controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _loading = true;
            _errorMessage = null;
          });
        },
        onPageFinished: (_) {
          if (!mounted) {
            return;
          }
          setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          if (!mounted) {
            return;
          }
          // 非主框架错误（子资源、iframe 等）忽略，避免误杀正常流程
          if (error.isForMainFrame != true) {
            return;
          }
          // ERR_CACHE_MISS：CAS 登录后的 POST 重定向丢失缓存数据
          // 自动重试一次即可恢复，而不是直接瘫痪
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

    // 启动前清除缓存，避免干扰 CAS 登录流程
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
      child: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ui.OutlineButton(
                      onPressed: _retry,
                      child: Text(
                        _isChinese(context) ? '重试' : 'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _isLoggingIn
              ? const Center(child: CircularProgressIndicator())
              : Stack(
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
                ),
    );
  }

  Future<void> _confirmCookies() async {
    final isZh = _isChinese(context);

    final jwglCookies = await _cookieManager.getCookies('https://jwgl.whu.edu.cn');
    final jwglCookieMap = <String, String>{};
    for (final cookie in jwglCookies) {
      if (cookie.name.isEmpty) {
        continue;
      }
      jwglCookieMap[cookie.name] = cookie.value;
    }
    if (!mounted) {
      return;
    }
    if (jwglCookieMap.isEmpty) {
      _showMessage(
        isZh
            ? '未读取到教务会话，请先完成登录后再确认。'
            : 'No education session cookie found. Please login first.',
      );
      return;
    }
    final cookieHeader =
        jwglCookieMap.entries.map((entry) => '${entry.key}=${entry.value}').join('; ');

    // 调用增强的登录流程：保存 cookie → 教务 SSO → 拉取用户信息
    setState(() => _isLoggingIn = true);
    try {
      await ref.read(whuAuthProvider.notifier).login(cookieHeader);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingIn = false);
        _showMessage('登录处理出错：$e');
      }
    }
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_isChinese(dialogContext) ? '确定' : 'OK'),
            ),
          ],
        );
      },
    );
  }
}
