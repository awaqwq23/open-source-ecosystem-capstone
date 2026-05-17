import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/presentation/pages/luojia_ecard_webview_page.dart';

void main() {
  group('LuojiaEcardEntry', () {
    test('uses WHU smart campus showApp URLs from reference app', () {
      expect(LuojiaEcardEntry.card.title, '珞珈E卡');
      expect(LuojiaEcardEntry.card.uri.host, 'zhlj.whu.edu.cn');
      expect(LuojiaEcardEntry.card.uri.path, '/mobile/homepageapi/showApp');
      expect(LuojiaEcardEntry.card.uri.queryParameters['appid'], '100000083');
      expect(
        LuojiaEcardEntry.card.uri.queryParameters['go'],
        '3A951E717A54699002E12202B5C8D4900DE42F32C030654FD17718CFBFB249AEFFE16B734A902AA80213296633D535817FC5933ADD813784A17E766EAB7860A453551EF48221E88B745FA0BB5AC35586BC7600F17BD706D54BED697A39BBAC1A56AAFE6F5F1C944C8263D962BB28A68E',
      );

      expect(LuojiaEcardEntry.paymentCode.title, 'E卡付款码');
      expect(LuojiaEcardEntry.paymentCode.uri.host, 'zhlj.whu.edu.cn');
      expect(
        LuojiaEcardEntry.paymentCode.uri.path,
        '/mobile/homepageapi/showApp',
      );
      expect(
        LuojiaEcardEntry.paymentCode.uri.queryParameters['appid'],
        '100000068',
      );
      expect(
        LuojiaEcardEntry.paymentCode.uri.queryParameters['go'],
        '3A951E717A54699002E12202B5C8D4900DE42F32C030654FD17718CFBFB249AEFFE16B734A902AA80213296633D535817FC5933ADD813784A17E766EAB7860A453551EF48221E88B745FA0BB5AC355865ACAB3000D34391C989BE65D60DF5342FE9087B270C80BE0F488AE36F6C4A96D',
      );
      expect(
        LuojiaEcardEntry.card.uri.queryParameters['go'],
        isNot(LuojiaEcardEntry.paymentCode.uri.queryParameters['go']),
      );
    });

    test('builds WHU smart campus WebView headers', () {
      final showAppHeaders = luojiaEcardSmartCampusHeaders(
        LuojiaEcardEntry.card.uri,
      );

      expect(
        showAppHeaders['X-Requested-With'],
        'com.chaoxing.mobile.wuhanuniversity',
      );
      expect(showAppHeaders['Accept-Language'], 'zh_CN');
      expect(
        showAppHeaders['Referer'],
        'https://zhlj.whu.edu.cn/mobile/homepage?customizecolor=0x01A185',
      );
      expect(
        showAppHeaders['User-Agent'],
        contains(
          'com.chaoxing.mobile.wuhanuniversity/ChaoXingStudy_1000028_5.4_android_phone_640_233',
        ),
      );
      expect(showAppHeaders['sec-ch-ua-platform'], '"Android"');

      final zsgxHeaders = luojiaEcardSmartCampusHeaders(
        Uri.parse('https://zsgx.whu.edu.cn/ydd/card/paycode'),
      );
      expect(zsgxHeaders['Referer'], 'https://zhlj.whu.edu.cn/');
    });

    test('has dedicated campus route paths', () {
      expect(AppRoutePaths.campusLuojiaEcard, '/campus/luojia-ecard');
      expect(
        AppRoutePaths.campusEcardPaymentCode,
        '/campus/ecard-payment-code',
      );
    });
  });
}
