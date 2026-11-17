import 'dart:convert';

import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_session.dart';

class SportsReservationWebSession {
  const SportsReservationWebSession({
    required this.jwt,
    required this.serviceUrl,
    required this.referer,
    required this.launchUri,
    this.userId = '',
    this.cookieHeader = '',
  });

  factory SportsReservationWebSession.fromSession(
    SportsReservationSession session, {
    Uri? launchUri,
  }) {
    return SportsReservationWebSession(
      jwt: session.jwt,
      serviceUrl: session.serviceUrl,
      referer: session.referer,
      launchUri: launchUri ?? session.serviceUrl,
      userId: session.userId,
      cookieHeader: session.cookieHeader,
    );
  }

  static const userAgent =
      'Mozilla/5.0 (Linux; Android 14; wv) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36';

  final String jwt;
  final Uri serviceUrl;
  final Uri referer;
  final Uri launchUri;
  final String userId;
  final String cookieHeader;

  String get bootstrapHtml {
    final token = jsonEncode(jwt);
    final target = jsonEncode(launchUri.toString());
    return '''
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <script>
  (function () {
    window.localStorage.setItem('wxtoken', $token);
    window.localStorage.removeItem('isLogin');
    window.localStorage.removeItem('againLogin');
    window.location.replace($target);
  })();
  </script>
</head>
<body></body>
</html>
''';
  }

  String get bootstrapBaseUrl => serviceUrl.toString();

  Map<String, String> documentHeadersFor(Uri uri) {
    return {
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'zh-CN,zh;q=0.9',
      'Referer': _refererFor(uri).toString(),
      'Sec-Fetch-Dest': 'document',
      'Sec-Fetch-Mode': 'navigate',
      'Upgrade-Insecure-Requests': '1',
      'User-Agent': userAgent,
    };
  }

  Map<String, String> get apiHeaders {
    return {
      'Accept': 'application/json, text/plain, */*',
      'Authorization': 'Bearer $jwt',
      'Content-Type': 'application/json',
      if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
      'Referer': referer.toString(),
      'User-Agent': userAgent,
    };
  }

  bool isWebUri(Uri uri) {
    return uri.scheme == 'https' || uri.scheme == 'http';
  }

  bool shouldLoadWithGymHeaders(Uri uri) {
    return uri.host == serviceUrl.host &&
        uri.path.startsWith(_normalizedBasePath);
  }

  Uri _refererFor(Uri uri) {
    if (uri.host == serviceUrl.host) {
      return referer;
    }
    return serviceUrl;
  }

  String get _normalizedBasePath {
    final path = serviceUrl.path.endsWith('/')
        ? serviceUrl.path.substring(0, serviceUrl.path.length - 1)
        : serviceUrl.path;
    return path.isEmpty ? '/' : path;
  }
}
