import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  final options = _ProbeOptions.parse(args);
  final casCookie = Platform.environment['WHU_CAS_COOKIE'] ?? '';
  final educationCookie = Platform.environment['WHU_EDU_COOKIE'] ?? '';

  _printHeader('WHU auth probe');
  _printLine('targets', options.targets.join(', '));
  _printLine('WHU_CAS_COOKIE', _cookieState(casCookie));
  _printLine('WHU_EDU_COOKIE', _cookieState(educationCookie));
  _printLine('network timeout', '${options.timeout.inSeconds}s');

  if (options.targets.contains('education')) {
    await _runSection('education', () async {
      await _probeEducation(
        casCookie: casCookie,
        educationCookie: educationCookie,
        timeout: options.timeout,
      );
    });
  }

  if (options.targets.contains('empty-room')) {
    await _runSection('empty-room', () async {
      await _probeEmptyRoom(casCookie: casCookie, timeout: options.timeout);
    });
  }

  if (options.targets.contains('seat')) {
    await _runSection('seat', () async {
      await _probeSeat(casCookie: casCookie, timeout: options.timeout);
    });
  }
}

Future<void> _probeEducation({
  required String casCookie,
  required String educationCookie,
  required Duration timeout,
}) async {
  if (educationCookie.trim().isNotEmpty) {
    final client = _ProbeClient(
      initialCookieHeader: educationCookie,
      initialCookieHost: 'jwgl.whu.edu.cn',
    );
    try {
      await _request(
        label: 'education cookie session',
        client: client,
        method: 'GET',
        uri: _educationHomeUrl,
        headers: const {'Host': 'jwgl.whu.edu.cn'},
        timeout: timeout,
      );
    } finally {
      client.close();
    }
  } else {
    _printLine('education cookie session', 'SKIP: WHU_EDU_COOKIE is empty');
  }

  if (casCookie.trim().isEmpty) {
    _printLine('education CAS authorization', 'SKIP: WHU_CAS_COOKIE is empty');
    return;
  }

  final client = await _authorize(
    label: 'education CAS authorization',
    request: _educationRequest,
    casCookie: casCookie,
    timeout: timeout,
  );
  if (client == null) {
    return;
  }
  try {
    await _request(
      label: 'education account endpoint',
      client: client,
      method: 'GET',
      uri: Uri.parse(
        'https://jwgl.whu.edu.cn/xtgl/index_cxYhxxIndex.html?xt=jw&localeKey=zh_CN&gnmkdm=index',
      ),
      headers: const {
        'Host': 'jwgl.whu.edu.cn',
        'Referer':
            'https://jwgl.whu.edu.cn/xtgl/index_initMenu.html?jsdm=xs&echarts=1',
        'X-Requested-With': 'XMLHttpRequest',
      },
      timeout: timeout,
    );
  } finally {
    client.close();
  }
}

Future<void> _probeEmptyRoom({
  required String casCookie,
  required Duration timeout,
}) async {
  if (casCookie.trim().isEmpty) {
    _printLine('smart campus authorization', 'SKIP: WHU_CAS_COOKIE is empty');
    return;
  }

  final client = await _authorize(
    label: 'smart campus authorization',
    request: _emptyRoomRequest,
    casCookie: casCookie,
    timeout: timeout,
  );
  if (client == null) {
    return;
  }
  try {
    await _request(
      label: 'empty room entry',
      client: client,
      method: 'GET',
      uri: _emptyRoomEntryUri,
      headers: _smartCampusHeaders(accept: 'text/html,application/xhtml+xml'),
      timeout: timeout,
    );
    await _request(
      label: 'empty room term API',
      client: client,
      method: 'GET',
      uri: Uri.parse('https://zhlj.whu.edu.cn/whdxEmptyRoom/getTerm'),
      headers: _smartCampusHeaders(),
      timeout: timeout,
    );
  } finally {
    client.close();
  }
}

Future<void> _probeSeat({
  required String casCookie,
  required Duration timeout,
}) async {
  final seatRequest = await _loadSeatServiceRequest(timeout);
  if (casCookie.trim().isEmpty) {
    _printLine('seat authorization', 'SKIP: WHU_CAS_COOKIE is empty');
    return;
  }

  final client = await _authorize(
    label: 'seat authorization',
    request: seatRequest,
    casCookie: casCookie,
    timeout: timeout,
  );
  client?.close();
}

Future<_ServiceRequest> _loadSeatServiceRequest(Duration timeout) async {
  final response = await http
      .post(
        Uri.parse(
          'https://seat.lib.whu.edu.cn/jsq/static/public/cg/getSysSet/MOBILE',
        ),
        headers: const {'Content-Type': 'application/json;charset=UTF-8'},
        body: '{}',
      )
      .timeout(timeout);
  _printResponse('seat config', response);

  final decoded = jsonDecode(response.body);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('seat config root is not a JSON object');
  }
  final data = decoded['data'];
  if (data is! Map<String, dynamic>) {
    throw const FormatException('seat config data is not a JSON object');
  }
  final vueConfig = data['vueConfig'];
  if (vueConfig is! Map<String, dynamic>) {
    throw const FormatException('seat config vueConfig is not a JSON object');
  }

  final casService = _readConfigUri(vueConfig, 'CASSSERVICE');
  final vueService = _readConfigUri(vueConfig, 'VUESERVICE');
  final entryUri = _appendPath(
    casService,
    'static/sso/login',
  ).replace(queryParameters: {'redirectUrl': vueService.toString()});
  _printLine('seat CASSSERVICE', _sanitizeUri(casService));
  _printLine('seat VUESERVICE', _sanitizeUri(vueService));
  _printLine('seat entryUrl', _sanitizeUri(entryUri));

  return _ServiceRequest(
    serviceUrl: entryUri,
    entryUrl: entryUri,
    isSuccess: (response) => _extractToken(response.request?.url) != null,
    parseFailure: (response) {
      if (_looksLikeCasLoginPage(response.body)) {
        return 'CAS login page returned';
      }
      return 'seat token not found';
    },
  );
}

Future<_ProbeClient?> _authorize({
  required String label,
  required _ServiceRequest request,
  required String casCookie,
  required Duration timeout,
}) async {
  final client = _ProbeClient(initialCookieHeader: casCookie);
  try {
    final loginUri =
        request.entryUrl ??
        Uri.parse(
          'https://cas.whu.edu.cn/authserver/login?service=${Uri.encodeComponent(request.serviceUrl.toString())}',
        );
    final response = await client.get(loginUri).timeout(timeout);
    _printResponse(label, response);
    _printLine('$label success predicate', '${request.isSuccess(response)}');
    _printLine(
      '$label failure parser',
      request.parseFailure?.call(response) ?? '<none>',
    );
    _printLine(
      '$label client lastResponseUri',
      _sanitizeUri(client.lastResponseUri),
    );
    if (!request.isSuccess(response)) {
      client.close();
      return null;
    }
    return client;
  } on Object catch (error) {
    client.close();
    _printLine(label, 'ERROR: $error');
    return null;
  }
}

Future<void> _request({
  required String label,
  required _ProbeClient client,
  required String method,
  required Uri uri,
  required Map<String, String> headers,
  required Duration timeout,
  Object? body,
}) async {
  final response = switch (method) {
    'GET' => await client.get(uri, headers: headers).timeout(timeout),
    'POST' =>
      await client.post(uri, headers: headers, body: body).timeout(timeout),
    _ => throw ArgumentError.value(method, 'method'),
  };
  _printResponse(label, response);
}

final _educationHomeUrl = Uri.parse(
  'https://jwgl.whu.edu.cn/xtgl/index_initMenu.html?jsdm=xs&echarts=1',
);

final _educationRequest = _ServiceRequest(
  serviceUrl: Uri.parse('https://jwgl.whu.edu.cn/sso/jznewsixlogin'),
  isSuccess: (response) {
    final uri = response.request?.url;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return false;
    }
    if (uri != null &&
        uri.host == 'jwgl.whu.edu.cn' &&
        (uri.path == '/xtgl/index_initMenu.html' ||
            uri.path == '/xtgl/login_slogin.html')) {
      return true;
    }
    final body = response.body;
    if (_looksLikeCasLoginPage(body) || body.contains('login-page')) {
      return false;
    }
    return body.contains('教学管理信息服务平台') ||
        body.contains('index_initMenu.html') ||
        body.contains('xh_id=');
  },
  parseFailure: (response) {
    final match = RegExp(r'var dlktsxx="(.*?)";').firstMatch(response.body);
    final reason = match?.group(1)?.trim();
    if (reason != null && reason.isNotEmpty) {
      return 'education login failed: $reason';
    }
    return 'education login failed';
  },
);

final _emptyRoomEntryUri = Uri.parse('https://zhlj.whu.edu.cn/pc/toEmptyRoom');

final _emptyRoomRequest = _ServiceRequest(
  serviceUrl: Uri.parse('https://zhlj.whu.edu.cn/casLogin'),
  isSuccess: (response) {
    final uri = response.request?.url;
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return false;
    }
    if (_looksLikeSmartCampusAuthFailure(response.body)) {
      return false;
    }
    return uri != null && uri.host == 'zhlj.whu.edu.cn';
  },
  parseFailure: (response) {
    if (_looksLikeSmartCampusAuthFailure(response.body)) {
      return 'smart campus auth failure';
    }
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return 'smart campus HTTP ${response.statusCode}';
    }
    return 'smart campus auth failed';
  },
);

Map<String, String> _smartCampusHeaders({
  String accept = 'application/json, text/plain, */*',
  String? contentType,
}) {
  final headers = <String, String>{
    'Accept': accept,
    'Accept-Language': 'zh_CN',
    'Referer': _emptyRoomEntryUri.toString(),
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14; wv) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36 '
        'Language/zh_CN '
        'com.chaoxing.mobile.wuhanuniversity/ChaoXingStudy_1000028_5.4_android_phone_640_233',
    'X-Requested-With': 'com.chaoxing.mobile.wuhanuniversity',
  };
  if (contentType != null) {
    headers['Content-Type'] = contentType;
  }
  return headers;
}

Uri _readConfigUri(Map<String, dynamic> config, String key) {
  final value = config[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key is empty');
  }
  final uri = Uri.tryParse(value.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw FormatException('$key is not a valid URI');
  }
  return uri;
}

Uri _appendPath(Uri base, String path) {
  final basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;
  final nextPath = path.startsWith('/') ? path.substring(1) : path;
  return base.replace(path: '$basePath/$nextPath');
}

String? _extractToken(Uri? uri) {
  final token = uri?.queryParameters['token']?.trim();
  if (token != null && token.isNotEmpty) {
    return token;
  }
  final fragment = uri?.fragment;
  if (fragment == null || fragment.isEmpty || !fragment.contains('?')) {
    return null;
  }
  final query = fragment.substring(fragment.indexOf('?') + 1);
  return Uri.splitQueryString(query)['token']?.trim();
}

bool _looksLikeCasLoginPage(String body) {
  return body.contains('authserver/login') ||
      body.contains('统一身份认证') ||
      body.contains('cas.whu.edu.cn');
}

bool _looksLikeSmartCampusAuthFailure(String body) {
  final normalized = body.trim();
  return normalized == '未登录' ||
      body.contains('未登录') ||
      _looksLikeCasLoginPage(body) ||
      body.contains('统一认证') ||
      body.contains('/casLogin') ||
      body.contains('login-page');
}

String _bodyKind(String body) {
  final trimmed = body.trimLeft();
  if (trimmed.startsWith('{')) {
    return 'json';
  }
  if (_looksLikeCasLoginPage(body)) {
    return 'cas-login-page';
  }
  if (body.contains('<html') || body.contains('<!DOCTYPE html')) {
    return 'html';
  }
  if (body.contains('未登录')) {
    return 'not-logged-in-text';
  }
  return 'unknown';
}

void _printResponse(String label, http.Response response) {
  _printHeader(label);
  _printLine('status', '${response.statusCode}');
  _printLine('finalUrl', _sanitizeUri(response.request?.url));
  _printLine('contentType', response.headers['content-type'] ?? '<none>');
  _printLine('setCookieNames', _setCookieNames(response.headers['set-cookie']));
  _printLine('bodyKind', _bodyKind(response.body));
  _printLine('bodyExcerpt', _bodyExcerpt(response.body));
}

String _setCookieNames(String? header) {
  if (header == null || header.trim().isEmpty) {
    return '<none>';
  }
  final names =
      RegExp(r'(^|,\s*)([^=;, ]+)=')
          .allMatches(header)
          .map((match) => match.group(2) ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return names.isEmpty ? '<unknown>' : names.join(', ');
}

String _bodyExcerpt(String body) {
  final text = body
      .replaceAll(
        RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
        ' ',
      )
      .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(RegExp(r'ticket=[^&\s]+'), 'ticket=<redacted>')
      .replaceAll(RegExp(r'token=[^&\s]+'), 'token=<redacted>')
      .trim();
  if (text.isEmpty) {
    return '<empty>';
  }
  return text.length <= 180 ? text : '${text.substring(0, 180)}...';
}

String _sanitizeUri(Uri? uri) {
  if (uri == null) {
    return '<none>';
  }
  final queryKeys =
      uri.queryParameters.keys
          .where((key) {
            final lower = key.toLowerCase();
            return lower != 'ticket' && lower != 'token';
          })
          .toList(growable: false)
        ..sort();
  final queryText = queryKeys.isEmpty ? '' : '?${queryKeys.join(',')}';
  final fragmentText = uri.fragment.isEmpty ? '' : '#<fragment>';
  return '${uri.scheme}://${uri.host}${uri.path}$queryText$fragmentText';
}

String _cookieState(String value) {
  if (value.trim().isEmpty) {
    return 'empty';
  }
  final names =
      value
          .split(';')
          .map((part) => part.trim())
          .where((part) => part.contains('='))
          .map((part) => part.substring(0, part.indexOf('=')).trim())
          .where((name) => name.isNotEmpty)
          .toList()
        ..sort();
  return 'set (${names.join(', ')})';
}

Future<void> _runSection(String label, Future<void> Function() body) async {
  try {
    await body();
  } on TimeoutException catch (error) {
    _printLine(label, 'TIMEOUT: $error');
  } on Object catch (error, stackTrace) {
    _printLine(label, 'ERROR: $error');
    _printLine(
      '$label stack',
      stackTrace.toString().split('\n').take(3).join(' | '),
    );
  }
}

void _printHeader(String text) {
  stdout.writeln('\n== $text ==');
}

void _printLine(String key, String value) {
  stdout.writeln('$key: $value');
}

class _ServiceRequest {
  const _ServiceRequest({
    required this.serviceUrl,
    required this.isSuccess,
    this.entryUrl,
    this.parseFailure,
  });

  final Uri serviceUrl;
  final Uri? entryUrl;
  final bool Function(http.Response response) isSuccess;
  final String? Function(http.Response response)? parseFailure;
}

class _ProbeClient extends http.BaseClient {
  _ProbeClient({
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

  Uri? get lastResponseUri => _lastResponseUri;

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
      _printLine(
        'redirect[$redirectCount]',
        '${current.method} ${_sanitizeUri(current.url)} -> ${response.statusCode}; '
            'cookies=${_cookieJar.debugNamesFor(current.url)}',
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
    final names =
        _values.keys
            .where((key) => key.matches(uri.host))
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
        _values[_CookieKey(host: _cookieDomain(parts, uri.host), name: name)] =
            value;
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
  const _CookieKey({required this.host, required this.name});

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

class _ProbeOptions {
  const _ProbeOptions({required this.targets, required this.timeout});

  final Set<String> targets;
  final Duration timeout;

  static const _allTargets = {'education', 'empty-room', 'seat'};

  factory _ProbeOptions.parse(List<String> args) {
    var targets = _allTargets;
    var timeout = const Duration(seconds: 15);

    for (final arg in args) {
      if (arg == '--help' || arg == '-h') {
        _printUsageAndExit();
      }
      if (arg.startsWith('--target=')) {
        final rawTargets = arg.substring('--target='.length);
        targets = rawTargets
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toSet();
        final unknown = targets.difference(_allTargets);
        if (unknown.isNotEmpty) {
          stderr.writeln('Unknown target: ${unknown.join(', ')}');
          _printUsageAndExit(2);
        }
      } else if (arg.startsWith('--timeout=')) {
        final seconds = int.tryParse(arg.substring('--timeout='.length));
        if (seconds == null || seconds <= 0) {
          stderr.writeln('Invalid timeout: $arg');
          _printUsageAndExit(2);
        }
        timeout = Duration(seconds: seconds);
      }
    }

    return _ProbeOptions(targets: targets, timeout: timeout);
  }

  static Never _printUsageAndExit([int code = 0]) {
    stdout.writeln('''
Usage:
  dart run tool/whu_auth_probe.dart [--target=education,empty-room,seat] [--timeout=15]

Environment:
  WHU_CAS_COOKIE   CAS cookie header copied from cas.whu.edu.cn
  WHU_EDU_COOKIE   optional jwgl.whu.edu.cn cookie header

Examples:
  dart run tool/whu_auth_probe.dart
  WHU_CAS_COOKIE="CASTGC=...; JSESSIONID=..." dart run tool/whu_auth_probe.dart --target=empty-room
''');
    exit(code);
  }
}
