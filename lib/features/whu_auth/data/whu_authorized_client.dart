import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';

class WhuAuthorizedClient extends WhuServiceSession {
  WhuAuthorizedClient({
    required String initialCookieHeader,
    http.Client? inner,
  })  : _cookieJar = _CookieJar.fromHeader(initialCookieHeader),
        _inner = inner ?? http.Client();

  final http.Client _inner;
  final _CookieJar _cookieJar;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var current = request;
    for (var redirectCount = 0; redirectCount <= current.maxRedirects; redirectCount++) {
      current.followRedirects = false;
      _attachHeaders(current);
      final response = await _inner.send(current);
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        _cookieJar.mergeSetCookieHeader(setCookie);
      }
      if (!_isRedirect(response) || redirectCount == current.maxRedirects) {
        return response;
      }
      final location = response.headers['location'];
      if (location == null || location.isEmpty) {
        return response;
      }
      await response.stream.drain<void>();
      final redirectedUri = current.url.resolve(location);
      current = http.Request('GET', redirectedUri)
        ..headers.addAll(current.headers)
        ..followRedirects = false
        ..maxRedirects = request.maxRedirects;
    }
    throw StateError('redirect loop exited unexpectedly');
  }

  void _attachHeaders(http.BaseRequest request) {
    final cookieHeader = _cookieJar.header;
    if (cookieHeader.isNotEmpty) {
      request.headers['Cookie'] = cookieHeader;
    }
    request.headers.putIfAbsent(
      'User-Agent',
      () =>
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
    );
  }

  bool _isRedirect(http.BaseResponse response) {
    return response.statusCode == 301 ||
        response.statusCode == 302 ||
        response.statusCode == 303 ||
        response.statusCode == 307 ||
        response.statusCode == 308;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class _CookieJar {
  _CookieJar(this._values);

  factory _CookieJar.fromHeader(String header) {
    final values = <String, String>{};
    for (final part in header.split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty || !trimmed.contains('=')) {
        continue;
      }
      final index = trimmed.indexOf('=');
      final name = trimmed.substring(0, index).trim();
      final value = trimmed.substring(index + 1).trim();
      if (name.isNotEmpty && value.isNotEmpty) {
        values[name] = value;
      }
    }
    return _CookieJar(values);
  }

  final Map<String, String> _values;

  String get header => _values.entries
      .where((entry) => entry.key.isNotEmpty && entry.value.isNotEmpty)
      .map((entry) => '${entry.key}=${entry.value}')
      .join('; ');

  void mergeSetCookieHeader(String header) {
    for (final rawCookie in _splitSetCookie(header)) {
      final firstPart = rawCookie.split(';').first.trim();
      if (!firstPart.contains('=')) {
        continue;
      }
      final index = firstPart.indexOf('=');
      final name = firstPart.substring(0, index).trim();
      final value = firstPart.substring(index + 1).trim();
      if (name.isNotEmpty) {
        _values[name] = value;
      }
    }
  }

  List<String> _splitSetCookie(String header) {
    final result = <String>[];
    final buffer = StringBuffer();
    for (var index = 0; index < header.length; index++) {
      final char = header[index];
      if (char == ',' && _looksLikeNextCookie(header, index + 1)) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }
    return result;
  }

  bool _looksLikeNextCookie(String text, int start) {
    final rest = text.substring(start).trimLeft();
    final equals = rest.indexOf('=');
    final semicolon = rest.indexOf(';');
    return equals > 0 && (semicolon == -1 || equals < semicolon);
  }
}
