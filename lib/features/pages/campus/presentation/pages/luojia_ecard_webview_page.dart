import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

enum LuojiaEcardEntry {
  card,
  paymentCode;

  String get title {
    return switch (this) {
      LuojiaEcardEntry.card => '珞珈E卡',
      LuojiaEcardEntry.paymentCode => 'E卡付款码',
    };
  }

  Uri get uri {
    return switch (this) {
      LuojiaEcardEntry.card => Uri.parse(
        'https://zhlj.whu.edu.cn/mobile/homepageapi/showApp?appid=100000083&go=3A951E717A54699002E12202B5C8D4900DE42F32C030654FD17718CFBFB249AEFFE16B734A902AA80213296633D535817FC5933ADD813784A17E766EAB7860A453551EF48221E88B745FA0BB5AC35586BC7600F17BD706D54BED697A39BBAC1A56AAFE6F5F1C944C8263D962BB28A68E',
      ),
      LuojiaEcardEntry.paymentCode => Uri.parse(
        'https://zhlj.whu.edu.cn/mobile/homepageapi/showApp?appid=100000068&go=3A951E717A54699002E12202B5C8D4900DE42F32C030654FD17718CFBFB249AEFFE16B734A902AA80213296633D535817FC5933ADD813784A17E766EAB7860A453551EF48221E88B745FA0BB5AC355865ACAB3000D34391C989BE65D60DF5342FE9087B270C80BE0F488AE36F6C4A96D',
      ),
    };
  }
}

class LuojiaEcardWebViewPage extends ConsumerStatefulWidget {
  const LuojiaEcardWebViewPage({required this.entry, super.key});

  final LuojiaEcardEntry entry;

  @override
  ConsumerState<LuojiaEcardWebViewPage> createState() =>
      _LuojiaEcardWebViewPageState();
}

class _LuojiaEcardWebViewPageState
    extends ConsumerState<LuojiaEcardWebViewPage> {
  static const _smartCampusPackage = 'com.chaoxing.mobile.wuhanuniversity';
  static const _smartCampusReferer =
      'https://zhlj.whu.edu.cn/mobile/homepage?customizecolor=0x01A185';
  static const _zhljReferer = 'https://zhlj.whu.edu.cn/';
  static const _smartCampusUserAgent =
      'Mozilla/5.0 (Linux; Android 14; wv) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36 '
      'Language/zh_CN '
      'com.chaoxing.mobile.wuhanuniversity/ChaoXingStudy_1000028_5.4_android_phone_640_233';

  late final WebViewController _controller;
  final Set<String> _smartCampusHeaderLoadUrls = <String>{};
  var _preparing = true;
  var _loading = true;
  var _needsLogin = false;
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
              setState(() {
                _loading = false;
                _progress = 100;
              });
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false || !mounted) {
              return;
            }
            setState(() {
              _loading = false;
              _errorMessage = '页面加载失败，请检查网络连接后重试。';
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || !_isWebScheme(uri.scheme)) {
              if (mounted) {
                setState(() {
                  _errorMessage = '当前链接需要在浏览器或学校应用中打开。';
                });
              }
              return NavigationDecision.prevent;
            }
            if (_shouldLoadWithSmartCampusHeaders(uri)) {
              final url = uri.toString();
              if (_smartCampusHeaderLoadUrls.remove(url)) {
                return NavigationDecision.navigate;
              }
              unawaited(_loadSmartCampusRequest(uri));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(true);
    unawaited(_prepareAndLoad());
  }

  Future<void> _prepareAndLoad() async {
    setState(() {
      _preparing = true;
      _loading = true;
      _needsLogin = false;
      _errorMessage = null;
      _progress = 0;
    });

    final authState = ref.read(whuAuthProvider);
    if (!authState.isAuthenticated || authState.isExpired) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preparing = false;
        _loading = false;
        _needsLogin = true;
      });
      return;
    }

    try {
      await ref.read(whuAuthProvider.notifier).primeCasCookiesForWebView();
      await _configurePlatformController();
      await _controller.setUserAgent(_smartCampusUserAgent);
      await _loadSmartCampusRequest(widget.entry.uri);
      if (!mounted) {
        return;
      }
      setState(() => _preparing = false);
    } on WhuAuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preparing = false;
        _loading = false;
        _needsLogin = true;
        _errorMessage = error.message;
      });
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

  Future<void> _configurePlatformController() async {
    final platformController = _controller.platform;
    if (platformController is AndroidWebViewController) {
      await platformController.setUseWideViewPort(true);
      await platformController.setTextZoom(100);
    }
  }

  Future<void> _refresh() async {
    if (_needsLogin) {
      await _prepareAndLoad();
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
      _progress = 0;
    });
    await _controller.reload();
  }

  Future<void> _loadSmartCampusRequest(Uri uri) async {
    _smartCampusHeaderLoadUrls.add(uri.toString());
    await _controller.loadRequest(
      uri,
      headers: luojiaEcardSmartCampusHeaders(uri),
    );
  }

  Future<void> _openLoginGuide() async {
    await context.push(AppRoutePaths.settingsWhuAccount);
    if (mounted) {
      await _prepareAndLoad();
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
          title: Text(widget.entry.title),
          trailing: [
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
          if (_preparing || _loading) _LoadingOverlay(progress: _progress),
          if (_needsLogin)
            _StateOverlay(
              icon: Icons.account_circle_outlined,
              title: '需要登录武大统一认证',
              message: _errorMessage ?? '登录后可继续访问${widget.entry.title}。',
              primaryText: '去登录',
              onPrimary: _openLoginGuide,
              secondaryText: '重试',
              onSecondary: _prepareAndLoad,
            ),
          if (!_needsLogin && _errorMessage != null)
            _StateOverlay(
              icon: Icons.wifi_off_outlined,
              title: '页面暂时无法打开',
              message: _errorMessage!,
              primaryText: '刷新',
              onPrimary: _refresh,
              secondaryText: '账户状态',
              onSecondary: _openLoginGuide,
            ),
        ],
      ),
    );
  }

  bool _isWebScheme(String scheme) {
    return scheme == 'https' || scheme == 'http';
  }

  bool _shouldLoadWithSmartCampusHeaders(Uri uri) {
    if (uri.host == 'zhlj.whu.edu.cn' &&
        uri.path == '/mobile/homepageapi/showApp') {
      return true;
    }
    if (uri.host == 'zsgx.whu.edu.cn') {
      return uri.path == '/mobile/api/dologin' ||
          uri.path == '/ydd/card/ematong' ||
          uri.path == '/ydd/card/paycode';
    }
    if (uri.host == 'app.xiaoyuan.ccb.com') {
      return uri.path == '/LHECISM/CCBYXLgServiceReqServlet';
    }
    return false;
  }
}

Map<String, String> luojiaEcardSmartCampusHeaders(Uri uri) {
  final referer = uri.host == 'zhlj.whu.edu.cn'
      ? _LuojiaEcardWebViewPageState._smartCampusReferer
      : _LuojiaEcardWebViewPageState._zhljReferer;

  return <String, String>{
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'Accept-Language': 'zh_CN',
    'Referer': referer,
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': _LuojiaEcardWebViewPageState._smartCampusUserAgent,
    'X-Requested-With': _LuojiaEcardWebViewPageState._smartCampusPackage,
    'sec-ch-ua':
        '"Not(A:Brand";v="8", "Chromium";v="144", "Android WebView";v="144"',
    'sec-ch-ua-mobile': '?1',
    'sec-ch-ua-platform': '"Android"',
  };
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.progress});

  final int progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surface.withValues(alpha: 0.58),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress <= 0 ? null : progress / 100),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

class _StateOverlay extends StatelessWidget {
  const _StateOverlay({
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
