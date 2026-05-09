import 'package:flutter/material.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_cookie_manager_flutter/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WhuLoginWebViewPage extends StatefulWidget {
  const WhuLoginWebViewPage({super.key});

  @override
  State<WhuLoginWebViewPage> createState() => _WhuLoginWebViewPageState();
}

class _WhuLoginWebViewPageState extends State<WhuLoginWebViewPage> {
  static const _loginUrl =
      'https://cas.whu.edu.cn/authserver/login?service='
      'https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin';
  final _cookieManager = WebviewCookieManager();
  late final WebViewController _controller;
  var _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _loading = false;
                _errorMessage = '${error.description} (${error.errorCode})';
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_loginUrl));
  }

  void _retry() {
    _controller.loadRequest(Uri.parse(_loginUrl));
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
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
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
    Navigator.of(context).pop(cookieHeader);
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
