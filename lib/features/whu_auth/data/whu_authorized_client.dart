import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';

class WhuAuthorizedClient extends WhuServiceSession {
  WhuAuthorizedClient({
    required String initialCookieHeader,
    http.Client? inner,
  })  : _cookieJar = _CookieJar.fromHeader(
          initialCookieHeader,
          host: 'cas.whu.edu.cn',
        ),
        _inner = inner ?? http.Client();

  final http.Client _inner;
  final _CookieJar _cookieJar;
  Uri? _lastResponseUri;

  @override
  Uri? get lastResponseUri => _lastResponseUri;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var current = request;
    for (var redirectCount = 0; redirectCount <= current.maxRedirects; redirectCount++) {
      current.followRedirects = false;
      _attachHeaders(current);
      final response = await _inner.send(current);
      _lastResponseUri = response.request?.url ?? current.url;
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null && setCookie.isNotEmpty) {
        _cookieJar.mergeSetCookieHeader(setCookie, current.url);
      }
      debugPrint(
        '[WhuAuthorizedClient] ${current.method} ${_sanitizeUri(current.url)} '
        '-> ${response.statusCode}; cookies=${_cookieJar.debugNamesFor(current.url)}',
      );
      if (!_isRedirect(response) || redirectCount == current.maxRedirects) {
        return response;
      }
      final location = response.headers['location'];
      if (location == null || location.isEmpty) {
        return response;
      }
      await response.stream.drain<void>();
      final redirectedUri = current.url.resolve(location);
      debugPrint('[WhuAuthorizedClient] redirect to ${_sanitizeUri(redirectedUri)}');
      current = http.Request('GET', redirectedUri)
        ..headers.addAll(current.headers)
        ..followRedirects = false
        ..maxRedirects = request.maxRedirects;
    }
    throw StateError('redirect loop exited unexpectedly');
  }

  void _attachHeaders(http.BaseRequest request) {
    final cookieHeader = _cookieJar.headerFor(request.url);
    if (cookieHeader.isNotEmpty) {
      request.headers['Cookie'] = cookieHeader;
    } else {
      request.headers.remove('Cookie');
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

  String _sanitizeUri(Uri uri) {
    final queryKeys = uri.queryParameters.keys
        .where((key) {
          final lower = key.toLowerCase();
          return lower != 'ticket' && lower != 'token';
        })
        .toList(growable: false)
      ..sort();
    final queryText = queryKeys.isEmpty ? '' : '?${queryKeys.join(',')}';
    return '${uri.scheme}://${uri.host}${uri.path}$queryText';
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class _CookieJar {
  _CookieJar(this._values);

  factory _CookieJar.fromHeader(String header, {required String host}) {
    final values = <_CookieKey, String>{};
    for (final part in header.split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty || !trimmed.contains('=')) {
        continue;
      }
      final index = trimmed.indexOf('=');
      final name = trimmed.substring(0, index).trim();
      final value = trimmed.substring(index + 1).trim();
      if (name.isNotEmpty && value.isNotEmpty) {
        values[_CookieKey(host: host, name: name)] = value;
      }
    }
    return _CookieJar(values);
  }

  final Map<_CookieKey, String> _values;

  String headerFor(Uri uri) => _values.entries
      .where((entry) => entry.value.isNotEmpty && entry.key.matches(uri.host))
      .map((entry) => '${entry.key.name}=${entry.value}')
      .join('; ');

  String debugNamesFor(Uri uri) {
    final names = _values.keys
        .where((key) => key.matches(uri.host))
        .map((key) => key.name)
        .toSet()
        .toList(growable: false)
      ..sort();
    return names.isEmpty ? '<none>' : names.join(',');
  }

  void mergeSetCookieHeader(String header, Uri uri) {
    for (final rawCookie in _splitSetCookie(header)) {
      final parts = rawCookie.split(';').map((part) => part.trim()).toList(growable: false);
      final firstPart = parts.first;
      if (!firstPart.contains('=')) {
        continue;
      }
      final index = firstPart.indexOf('=');
      final name = firstPart.substring(0, index).trim();
      final value = firstPart.substring(index + 1).trim();
      if (name.isNotEmpty) {
        _values[_CookieKey(host: _cookieDomain(parts, uri.host), name: name)] = value;
      }
    }
  }

  String _cookieDomain(List<String> parts, String fallbackHost) {
    for (final part in parts.skip(1)) {
      final index = part.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = part.substring(0, index).trim().toLowerCase();
      if (name == 'domain') {
        final value = part.substring(index + 1).trim().toLowerCase();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return fallbackHost.toLowerCase();
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

class _CookieKey {
  const _CookieKey({
    required this.host,
    required this.name,
  });

  final String host;
  final String name;

  bool matches(String requestHost) {
    final normalizedHost = requestHost.toLowerCase();
    final normalizedCookieHost = host.toLowerCase();
    if (normalizedHost == normalizedCookieHost) {
      return true;
    }
    if (normalizedCookieHost.startsWith('.')) {
      return normalizedHost.endsWith(normalizedCookieHost.substring(1));
    }
    return false;
  }

  @override
  bool operator ==(Object other) {
    return other is _CookieKey && other.host == host && other.name == name;
  }

  @override
  int get hashCode => Object.hash(host, name);
}
