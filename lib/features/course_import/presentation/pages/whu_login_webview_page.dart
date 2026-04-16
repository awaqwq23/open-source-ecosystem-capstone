import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _loading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_loginUrl));
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
      child: Stack(
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
    final cookies = await _cookieManager.getCookies('https://jwgl.whu.edu.cn');
    if (!mounted) {
      return;
    }
    if (cookies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isZh ? '未读取到教务会话，请先完成登录后再确认。' : 'No session cookie found. Please login first.',
          ),
        ),
      );
      return;
    }
    final cookieHeader = cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
    Navigator.of(context).pop(cookieHeader);
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }
}
