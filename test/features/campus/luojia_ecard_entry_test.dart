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
