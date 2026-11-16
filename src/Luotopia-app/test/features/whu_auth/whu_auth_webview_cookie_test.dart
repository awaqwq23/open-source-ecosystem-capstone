import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

void main() {
  group('hasWhuCasSessionCookie', () {
    test('accepts non-empty CASTGC without JSESSIONID', () {
      expect(
        hasWhuCasSessionCookie(
          'happyVoyage=value; CASTGC=TGT-53690-value; platformMultilingual=zh_CN',
        ),
        isTrue,
      );
    });

    test('rejects missing or cleared CASTGC', () {
      expect(hasWhuCasSessionCookie('JSESSIONID=session-value'), isFalse);
      expect(
        hasWhuCasSessionCookie('CASTGC=; JSESSIONID=session-value'),
        isFalse,
      );
    });
  });

  group('buildWhuCasWebViewCookies', () {
    test('maps CAS cookie header to secure WebView cookies', () {
      final cookies = buildWhuCasWebViewCookies(
        'CASTGC=ticket-value; JSESSIONID=session-value; empty=; theme=mobile',
      );

      expect(cookies.map((cookie) => cookie.name), [
        'CASTGC',
        'JSESSIONID',
        'theme',
      ]);
      expect(cookies.map((cookie) => cookie.value), [
        'ticket-value',
        'session-value',
        'mobile',
      ]);
      for (final cookie in cookies) {
        expect(cookie.domain, 'cas.whu.edu.cn');
        expect(cookie.path, '/');
        expect(cookie.secure, isTrue);
        expect(cookie.httpOnly, isTrue);
      }
    });

    test('skips malformed cookie segments', () {
      final cookies = buildWhuCasWebViewCookies(
        'CASTGC=ticket-value; malformed; =empty-name; JSESSIONID=session-value',
      );

      expect(cookies.map((cookie) => cookie.name), ['CASTGC', 'JSESSIONID']);
    });
  });
}
