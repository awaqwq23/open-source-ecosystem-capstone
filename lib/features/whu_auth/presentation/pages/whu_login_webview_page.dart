import 'dart:convert';

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

const _casLoginUrl =
    'https://cas.whu.edu.cn/authserver/login?login_type=mobileLogin'
    '&service=https%3A%2F%2Fcas.whu.edu.cn%2Fauthserver%2Fmobile%2Fcallback%3FappId%3D985180443';

const _injectedScript = r'''
(function() {
  var removeEl = document.getElementsByClassName('social-aut-login')[0];
  if (removeEl) removeEl.remove();

  var langWrap = document.getElementById('languages') || document.querySelector('.language-wrap');
  if (langWrap) langWrap.style.display = 'none';

  var headerEl = document.querySelector('header');
  if (headerEl) headerEl.textContent = '武汉大学';

  var forgetPwd = document.getElementById('mobileGetPasswordControllerId');
  if (forgetPwd) forgetPwd.style.display = 'none';

  var usernameEl = document.getElementById('mobileUsername');
  var passwordEl = document.getElementById('mobilePassword');
  var loginEl = document.getElementById('load');

  if (usernameEl) {
    usernameEl.setAttribute('placeholder', '学号');
    usernameEl.addEventListener('change', function() {
      WhuAuthChannel.postMessage(JSON.stringify({
        type: 'usernameChange', studentId: this.value
      }));
    });
  }
  if (passwordEl) {
    passwordEl.setAttribute('placeholder', '密码');
  }

  if (loginEl) {
    var origClick = loginEl.onclick;
    loginEl.onclick = function(e) {
      var sid = (usernameEl && usernameEl.value) || '';
      WhuAuthChannel.postMessage(JSON.stringify({
        type: 'login', studentId: sid
      }));
      return true;
    };
  }

  var rememberLabel = document.querySelector('label[for="rememberMe"]');
  if (rememberLabel) rememberLabel.textContent = '记住密码';

  var agreeLabel = document.querySelector('label[for="isAgree"]');
  if (agreeLabel) agreeLabel.textContent = '已阅读并同意';

  var privacyLink = document.querySelector('.login-idx-opt a[href*="privacyPolicy"]');
  if (privacyLink) privacyLink.textContent = '隐私协议';

  var mainArea = document.getElementsByClassName('main');
  if (mainArea && mainArea.length) {
    mainArea[0].setAttribute('style', 'height:' + window.innerHeight + 'px');
  }

  function extractText(input) {
    if (!input) return '';
    if (typeof input === 'string') return input.trim();
    return (input.textContent || input.innerText || '').trim();
  }

  function overrideShowTips() {
    if (typeof showTips !== 'function' || showTips.__whuWrapped) return;
    var orig = showTips;
    showTips = function(input) {
      var text = extractText(input);
      if (text.includes('请先阅读并同意隐私协议')) {
        orig('请先阅读并同意隐私协议');
        return;
      }
      if (text.includes('该帐号已经过期')) {
        orig('该帐号已过期，请联系学校处理');
        return;
      }
      if (text.includes('用户名或者密码有误')) {
        orig('学号或密码错误，请重试');
        return;
      }
      orig(typeof input === 'string' ? input : text);
    };
    showTips.__whuWrapped = true;
  }
  if (!overrideShowTips()) {
    var iv = setInterval(function() {
      if (overrideShowTips()) clearInterval(iv);
    }, 200);
    setTimeout(function() { clearInterval(iv); }, 2000);
  }
})();
''';

class _WhuLoginWebViewPageState extends ConsumerState<WhuLoginWebViewPage> {
  late final WebViewController _controller;
  String? _capturedStudentId;
  bool _loginSuccessReported = false;
  bool _jsInjected = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final cookieManager = WebviewCookieManager();
    await cookieManager.clearCookies();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'WhuAuthChannel',
        onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            if (data['type'] == 'login') {
              _capturedStudentId = data['studentId'] as String?;
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) => _onPageFinished(url),
        onWebResourceError: (err) {
          if (mounted) {
            setState(() {
              _errorMessage = '加载 CAS 登录页失败：${err.description}';
              _isLoading = false;
            });
          }
        },
      ));

    await _controller.loadRequest(Uri.parse(_casLoginUrl));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onPageFinished(String url) async {
    if (!_jsInjected && url.contains('cas.whu.edu.cn/authserver/login')) {
      _jsInjected = true;
      await _controller.runJavaScript(_injectedScript);
    }
    await _checkLoginSuccess();
  }

  Future<void> _checkLoginSuccess() async {
    if (_loginSuccessReported) return;

    try {
      final cookieManager = WebviewCookieManager();
      final cookies = await cookieManager.getCookies('https://cas.whu.edu.cn/authserver/');
      final cookieMap = {for (final c in cookies) c.name: c.value};

      if (cookieMap.containsKey('CASTGC') && cookieMap.containsKey('JSESSIONID')) {
        _loginSuccessReported = true;
        final cookieStr = cookies.map((c) => '${c.name}=${c.value}').join('; ');
        final studentId = _capturedStudentId ?? '';

        await ref.read(whuAuthProvider.notifier).onLoginSuccess(
              sessionCookie: cookieStr,
              studentId: studentId,
              studentName: '',
            );
        if (mounted) {
          Navigator.of(context).maybePop();
        }
      }
    } catch (_) {
      // cookie 读取失败，让用户继续在 WebView 中操作
    }
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
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isLoading = true;
                    _loginSuccessReported = false;
                    _jsInjected = false;
                  });
                  _initWebView();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return WebViewWidget(controller: _controller);
  }
}
