import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';

class WhuAuthorizedClient extends WhuServiceSession {
  WhuAuthorizedClient({
    required String initialCookieHeader,
    String initialCookieHost = 'cas.whu.edu.cn',
    http.Client? inner,
  }) : _cookieJar = _CookieJar.fromHeader(
         initialCookieHeader,
         host: initialCookieHost,
       ),
       _inner = inner ?? http.Client();

  final http.Client _inner;
  final _CookieJar _cookieJar;
  Uri? _lastResponseUri;

  @override
  Uri? get lastResponseUri => _lastResponseUri;

  @override
  String cookieHeaderFor(Uri uri) => _cookieJar.headerFor(uri);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var current = request;
    for (
      var redirectCount = 0;
      redirectCount <= current.maxRedirects;
      redirectCount++
    ) {
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
      debugPrint(
        '[WhuAuthorizedClient] redirect to ${_sanitizeUri(redirectedUri)}',
      );
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
    final queryKeys =
        uri.queryParameters.keys
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
        values.putIfAbsent(
          _CookieKey(host: host, path: '/', name: name),
          () => value,
        );
      }
    }
    return _CookieJar(values);
  }

  final Map<_CookieKey, String> _values;

  String headerFor(Uri uri) {
    final entries =
        _values.entries
            .where((entry) => entry.value.isNotEmpty && entry.key.matches(uri))
            .toList()
          ..sort(
            (left, right) =>
                right.key.path.length.compareTo(left.key.path.length),
          );
    return entries
        .map((entry) => '${entry.key.name}=${entry.value}')
        .join('; ');
  }

  String debugNamesFor(Uri uri) {
    final names =
        _values.keys
            .where((key) => key.matches(uri))
            .map((key) => key.name)
            .toSet()
            .toList(growable: false)
          ..sort();
    return names.isEmpty ? '<none>' : names.join(',');
  }

  void mergeSetCookieHeader(String header, Uri uri) {
    for (final rawCookie in _splitSetCookie(header)) {
      final parts = rawCookie
          .split(';')
          .map((part) => part.trim())
          .toList(growable: false);
      final firstPart = parts.first;
      if (!firstPart.contains('=')) {
        continue;
      }
      final index = firstPart.indexOf('=');
      final name = firstPart.substring(0, index).trim();
      final value = firstPart.substring(index + 1).trim();
      if (name.isNotEmpty) {
        final key = _CookieKey(
          host: _cookieDomain(parts, uri.host),
          path: _cookiePath(parts, uri),
          name: name,
        );
        if (value.isEmpty || _isDeletion(parts)) {
          _values.remove(key);
        } else {
          _values[key] = value;
        }
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

  String _cookiePath(List<String> parts, Uri uri) {
    for (final part in parts.skip(1)) {
      final index = part.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = part.substring(0, index).trim().toLowerCase();
      if (name == 'path') {
        final value = part.substring(index + 1).trim();
        if (value.startsWith('/')) {
          return value;
        }
      }
    }
    return _defaultCookiePath(uri.path);
  }

  String _defaultCookiePath(String requestPath) {
    if (requestPath.isEmpty || !requestPath.startsWith('/')) {
      return '/';
    }
    final lastSlash = requestPath.lastIndexOf('/');
    if (lastSlash <= 0) {
      return '/';
    }
    return requestPath.substring(0, lastSlash);
  }

  bool _isDeletion(List<String> parts) {
    for (final part in parts.skip(1)) {
      final index = part.indexOf('=');
      if (index <= 0) {
        continue;
      }
      final name = part.substring(0, index).trim().toLowerCase();
      final value = part.substring(index + 1).trim().toLowerCase();
      if (name == 'max-age' && value == '0') {
        return true;
      }
      if (name == 'expires' && value.startsWith('thu, 01 jan 1970')) {
        return true;
      }
    }
    return false;
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
    required this.path,
    required this.name,
  });

  final String host;
  final String path;
  final String name;

  bool matches(Uri uri) {
    final normalizedHost = uri.host.toLowerCase();
    final normalizedCookieHost = host.toLowerCase();
    final hostMatches =
        normalizedHost == normalizedCookieHost ||
        (normalizedCookieHost.startsWith('.') &&
            normalizedHost.endsWith(normalizedCookieHost.substring(1)));
    if (!hostMatches) {
      return false;
    }
    return _pathMatches(uri.path);
  }

  bool _pathMatches(String requestPath) {
    final normalizedPath = requestPath.isEmpty ? '/' : requestPath;
    if (normalizedPath == path) {
      return true;
    }
    if (!normalizedPath.startsWith(path)) {
      return false;
    }
    return path.endsWith('/') || normalizedPath[path.length] == '/';
  }

  @override
  bool operator ==(Object other) {
    return other is _CookieKey &&
        other.host == host &&
        other.path == path &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(host, path, name);
}
