import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';
import 'package:luotopia/shared/presentation/widgets/app_web_view_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SmartCampusWebSessionService {
  const SmartCampusWebSessionService({required this.gateway});

  final WhuAuthGateway gateway;

  static const packageName = 'com.chaoxing.mobile.wuhanuniversity';
  static const homepageReferer =
      'https://zhlj.whu.edu.cn/mobile/homepage?customizecolor=0x01A185';
  static const rootReferer = 'https://zhlj.whu.edu.cn/';
  static const userAgent =
      'Mozilla/5.0 (Linux; Android 14; wv) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36 '
      'Language/zh_CN '
      'com.chaoxing.mobile.wuhanuniversity/ChaoXingStudy_1000028_5.4_android_phone_640_233';

  Future<AppWebViewRequest> prepareRequest({
    required WebViewController controller,
    required Uri uri,
  }) async {
    await gateway.primeCasCookiesForWebView();
    await controller.setUserAgent(userAgent);
    return AppWebViewRequest(uri: uri, headers: headersFor(uri));
  }

  static Map<String, String> headersFor(Uri uri) {
    final referer = uri.host == 'zhlj.whu.edu.cn'
        ? homepageReferer
        : rootReferer;
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
      'User-Agent': userAgent,
      'X-Requested-With': packageName,
      'sec-ch-ua':
          '"Not(A:Brand";v="8", "Chromium";v="144", "Android WebView";v="144"',
      'sec-ch-ua-mobile': '?1',
      'sec-ch-ua-platform': '"Android"',
    };
  }
}
