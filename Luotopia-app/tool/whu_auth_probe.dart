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

  if (options.targets.contains('score')) {
    await _runSection('score', () async {
      await _probeScore(
        casCookie: casCookie,
        educationCookie: educationCookie,
        timeout: options.timeout,
      );
    });
  }

  if (options.targets.contains('timetable')) {
    await _runSection('timetable', () async {
      await _probeTimetable(
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

  if (options.targets.contains('ecard')) {
    await _runSection('ecard', () async {
      await _probeEcard(casCookie: casCookie, timeout: options.timeout);
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

Future<void> _probeScore({
  required String casCookie,
  required String educationCookie,
  required Duration timeout,
}) async {
  final client = await _openEducationSession(
    label: 'score education session',
    casCookie: casCookie,
    educationCookie: educationCookie,
    timeout: timeout,
  );
  if (client == null) {
    return;
  }
  try {
    await _request(
      label: 'score list API',
      client: client,
      method: 'POST',
      uri: Uri.parse(
        'https://jwgl.whu.edu.cn/cjcx/cjcx_cxXsgrcj.html?doType=query&gnmkdm=N305005',
      ),
      headers: const {
        'Host': 'jwgl.whu.edu.cn',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'validate': _generateValidate(),
        'xnm': '',
        'xqm': '',
        'queryModel.showCount': '150',
      },
      timeout: timeout,
    );
  } finally {
    client.close();
  }
}

Future<void> _probeTimetable({
  required String casCookie,
  required String educationCookie,
  required Duration timeout,
}) async {
  final client = await _openEducationSession(
    label: 'timetable education session',
    casCookie: casCookie,
    educationCookie: educationCookie,
    timeout: timeout,
  );
  if (client == null) {
    return;
  }
  try {
    final now = DateTime.now();
    final schoolYear = now.month >= 8 ? now.year : now.year - 1;
    final semester = now.month >= 8 || now.month <= 1 ? 3 : 12;
    await _request(
      label: 'timetable course API',
      client: client,
      method: 'POST',
      uri: Uri.parse(
        'https://jwgl.whu.edu.cn/kbcx/xskbcx_cxXsgrkb.html?gnmkdm=N2151',
      ),
      headers: const {
        'Host': 'jwgl.whu.edu.cn',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'validate': _generateValidate(),
        'xnm': '$schoolYear',
        'xqm': '$semester',
        'xzlx': 'ck',
      },
      timeout: timeout,
    );
  } finally {
    client.close();
  }
}

Future<_ProbeClient?> _openEducationSession({
  required String label,
  required String casCookie,
  required String educationCookie,
  required Duration timeout,
}) async {
  if (educationCookie.trim().isNotEmpty) {
    final client = _ProbeClient(
      initialCookieHeader: educationCookie,
      initialCookieHost: 'jwgl.whu.edu.cn',
    );
    final response = await client
        .get(_educationHomeUrl, headers: const {'Host': 'jwgl.whu.edu.cn'})
        .timeout(timeout);
    _printResponse('$label with education cookie', response);
    if (_educationRequest.isSuccess(response)) {
      return client;
    }
    client.close();
  } else {
    _printLine('$label with education cookie', 'SKIP: WHU_EDU_COOKIE is empty');
  }

  if (casCookie.trim().isEmpty) {
    _printLine('$label with CAS', 'SKIP: WHU_CAS_COOKIE is empty');
    return null;
  }
  return _authorize(
    label: '$label with CAS',
    request: _educationRequest,
    casCookie: casCookie,
    timeout: timeout,
  );
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
    final termResponse = await _request(
      label: 'empty room term API',
      client: client,
      method: 'GET',
      uri: Uri.parse('https://zhlj.whu.edu.cn/whdxEmptyRoom/getTerm'),
      headers: _smartCampusHeaders(),
      timeout: timeout,
    );
    final floorResponse = await _request(
      label: 'empty room floor API',
      client: client,
      method: 'GET',
      uri: Uri.parse('https://zhlj.whu.edu.cn/whdxEmptyRoom/getFloor'),
      headers: _smartCampusHeaders(),
      timeout: timeout,
    );
    final floorShape = _jsonShape(floorResponse.body);
    _printLine('empty room floor shape', floorShape);

    final floorJson = _jsonMap(floorResponse.body);
    final campuses = _extractCampusNames(floorJson);
    final campus = campuses.isEmpty ? '工学部' : campuses.first;
    final firstBuildingCode = _extractFirstBuildingCode(floorJson, campus);
    final termData = _extractTermData(_jsonMap(termResponse.body));
    final schoolYear = '${termData['xnmc'] ?? '2025-2026'}';
    final schoolYearStart = schoolYear.split('-').first;
    final baseBody = <String, Object?>{
      'campus': campus,
      'schoolYear': schoolYear,
      'term': '${termData['xqmc'] ?? '2'}',
      'week': termData['dqzc'] ?? 16,
      'weekDay': termData['weekDay'] ?? 3,
      'section': null,
      'teachingBuilding': firstBuildingCode,
    };
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API app-current',
      body: baseBody,
      timeout: timeout,
    );
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API term-code',
      body: {...baseBody, 'term': '${termData['xqm'] ?? '12'}'},
      timeout: timeout,
    );
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API school-year-start',
      body: {...baseBody, 'schoolYear': schoolYearStart},
      timeout: timeout,
    );
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API numeric-term-and-year',
      body: {
        ...baseBody,
        'schoolYear': int.tryParse(schoolYearStart) ?? schoolYearStart,
        'term': int.tryParse('${termData['xqm'] ?? '12'}') ?? 12,
      },
      timeout: timeout,
    );
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API string-week',
      body: {
        ...baseBody,
        'week': '${termData['dqzc'] ?? 16}',
        'weekDay': '${termData['weekDay'] ?? 3}',
      },
      timeout: timeout,
    );
    if (firstBuildingCode.isNotEmpty) {
      await _probeEmptyRoomListVariant(
        client: client,
        label: 'empty room list API building-code',
        body: {...baseBody, 'teachingBuilding': firstBuildingCode},
        timeout: timeout,
      );
    }
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API section-empty',
      body: {...baseBody, 'section': ''},
      timeout: timeout,
    );
    final noSectionBody = {...baseBody}..remove('section');
    await _probeEmptyRoomListVariant(
      client: client,
      label: 'empty room list API no-section',
      body: noSectionBody,
      timeout: timeout,
    );
  } finally {
    client.close();
  }
}

Future<void> _probeEmptyRoomListVariant({
  required _ProbeClient client,
  required String label,
  required Map<String, Object?> body,
  required Duration timeout,
}) async {
  _printLine('$label bodyKeys', body.keys.join(','));
  final response = await _request(
    label: label,
    client: client,
    method: 'POST',
    uri: Uri.parse('https://zhlj.whu.edu.cn/whdxEmptyRoom/getEmptyRoom'),
    headers: _smartCampusHeaders(
      contentType: 'application/json; charset=utf-8',
    ),
    body: jsonEncode(body),
    timeout: timeout,
  );
  _printLine('$label shape', _jsonShape(response.body));
}

Map<String, dynamic> _jsonMap(String body) {
  final decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  return const <String, dynamic>{};
}

String _jsonShape(String body) {
  try {
    final decoded = jsonDecode(body);
    return _shapeOf(decoded);
  } catch (error) {
    return 'invalid-json: $error';
  }
}

String _shapeOf(Object? value) {
  if (value is Map) {
    final keys = value.keys.map((key) => '$key').take(8).join(',');
    final data = value['data'];
    if (data == null) {
      return 'map(keys=$keys)';
    }
    return 'map(keys=$keys; data=${_shapeOf(data)})';
  }
  if (value is List) {
    if (value.isEmpty) {
      return 'list(len=0)';
    }
    return 'list(len=${value.length}; first=${_shapeOf(value.first)})';
  }
  return value == null ? 'null' : value.runtimeType.toString();
}

List<String> _extractCampusNames(Map<String, dynamic> floorJson) {
  final data = floorJson['data'];
  if (data is List) {
    return [
      for (final item in data)
        if (item is Map && item['campus'] != null) '${item['campus']}',
    ];
  }
  if (data is Map) {
    final keys = data.keys.map((key) => '$key').where((key) => key.isNotEmpty);
    return keys.toList(growable: false);
  }
  return const <String>[];
}

String _extractFirstBuildingCode(
  Map<String, dynamic> floorJson,
  String campus,
) {
  final data = floorJson['data'];
  if (data is! List) {
    return '';
  }
  for (final item in data) {
    if (item is! Map || '${item['campus'] ?? ''}' != campus) {
      continue;
    }
    final floors = item['floors'];
    if (floors is! List) {
      return '';
    }
    for (final floor in floors) {
      if (floor is Map && '${floor['jxldm'] ?? ''}'.isNotEmpty) {
        return '${floor['jxldm']}';
      }
    }
  }
  return '';
}

Map<String, dynamic> _extractTermData(Map<String, dynamic> termJson) {
  final data = termJson['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return const <String, dynamic>{};
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

Future<void> _probeEcard({
  required String casCookie,
  required Duration timeout,
}) async {
  if (casCookie.trim().isEmpty) {
    _printLine(
      'ecard smart campus authorization',
      'SKIP: WHU_CAS_COOKIE is empty',
    );
    return;
  }
  final client = await _authorize(
    label: 'ecard smart campus authorization',
    request: _emptyRoomRequest,
    casCookie: casCookie,
    timeout: timeout,
  );
  if (client == null) {
    return;
  }
  try {
    await _request(
      label: 'ecard page entry',
      client: client,
      method: 'GET',
      uri: _ecardEntryUri,
      headers: _smartCampusWebHeaders(_ecardEntryUri),
      timeout: timeout,
    );
  } finally {
    client.close();
  }
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
    isSuccess: (response) {
      final uri = response.request?.url;
      if (response.statusCode < 200 || response.statusCode >= 400) {
        return false;
      }
      if (_looksLikeCasLoginPage(response.body)) {
        return false;
      }
      return uri != null && uri.host == 'seat.lib.whu.edu.cn';
    },
    parseFailure: (response) {
      if (_looksLikeCasLoginPage(response.body)) {
        return 'CAS login page returned';
      }
      return 'seat system page not reached';
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

Future<http.Response> _request({
  required String label,
  required _ProbeClient client,
  required String method,
  required Uri uri,
  required Map<String, String> headers,
  required Duration timeout,
  Object? body,
}) async {
  final response = switch (method) {
    'GET' =>
      await client
          .send(
            http.Request('GET', uri)
              ..headers.addAll(headers)
              ..maxRedirects = 12,
          )
          .then(http.Response.fromStream)
          .timeout(timeout),
    'POST' =>
      await client
          .send(_postRequest(uri: uri, headers: headers, body: body))
          .then(http.Response.fromStream)
          .timeout(timeout),
    _ => throw ArgumentError.value(method, 'method'),
  };
  _printResponse(label, response);
  return response;
}

http.Request _postRequest({
  required Uri uri,
  required Map<String, String> headers,
  required Object? body,
}) {
  final request = http.Request('POST', uri)
    ..headers.addAll(headers)
    ..maxRedirects = 12;
  if (body is Map<String, String>) {
    request.bodyFields = body;
  } else if (body is String) {
    request.body = body;
  }
  return request;
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
        uri.path == '/xtgl/index_initMenu.html') {
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

final _ecardEntryUri = Uri.parse(
  'https://zhlj.whu.edu.cn/mobile/homepageapi/showApp?appid=100000083&go=3A951E717A54699002E12202B5C8D4900DE42F32C030654FD17718CFBFB249AEFFE16B734A902AA80213296633D535817FC5933ADD813784A17E766EAB7860A453551EF48221E88B745FA0BB5AC35586BC7600F17BD706D54BED697A39BBAC1A56AAFE6F5F1C944C8263D962BB28A68E',
);

final _emptyRoomRequest = _ServiceRequest(
  serviceUrl: Uri.parse('https://zhlj.whu.edu.cn/casLogin'),
  isSuccess: (response) {
    final uri = response.request?.url;
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return false;
    }
    if (uri == null || uri.host != 'zhlj.whu.edu.cn') {
      return false;
    }
    return !_looksLikeSmartCampusNotLoggedIn(response.body);
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

Map<String, String> _smartCampusWebHeaders(Uri uri) {
  final referer = uri.host == 'zhlj.whu.edu.cn'
      ? 'https://zhlj.whu.edu.cn/mobile/homepage?customizecolor=0x01A185'
      : 'https://zhlj.whu.edu.cn/';
  return <String, String>{
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
    'Accept-Language': 'zh_CN',
    'Referer': referer,
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14; wv) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36 '
        'Language/zh_CN '
        'com.chaoxing.mobile.wuhanuniversity/ChaoXingStudy_1000028_5.4_android_phone_640_233',
    'X-Requested-With': 'com.chaoxing.mobile.wuhanuniversity',
  };
}

String _generateValidate() {
  const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
  final now = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  final seed = DateTime.now().microsecondsSinceEpoch;
  final randomPart = List.generate(7, (index) {
    final value = (seed + index * 1103515245) & 0x7fffffff;
    return chars[value % chars.length];
  }).join();
  return 'sl$randomPart$now';
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

bool _looksLikeCasLoginPage(String body) {
  return body.contains('authserver/login') ||
      body.contains('统一身份认证') ||
      body.contains('统一身份认证登录') ||
      body.contains('用户登录') ||
      body.contains('cas.whu.edu.cn');
}

bool _looksLikeSmartCampusAuthFailure(String body) {
  return _looksLikeSmartCampusNotLoggedIn(body) ||
      _looksLikeCasLoginPage(body) ||
      body.contains('login-page');
}

bool _looksLikeSmartCampusNotLoggedIn(String body) {
  final normalized = body.trim();
  return normalized == '未登录' || body.contains('未登录');
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

class _ProbeOptions {
  const _ProbeOptions({required this.targets, required this.timeout});

  final Set<String> targets;
  final Duration timeout;

  static const _allTargets = {
    'education',
    'score',
    'timetable',
    'empty-room',
    'seat',
    'ecard',
  };

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
  dart run tool/whu_auth_probe.dart [--target=education,score,timetable,empty-room,seat,ecard] [--timeout=15]

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
