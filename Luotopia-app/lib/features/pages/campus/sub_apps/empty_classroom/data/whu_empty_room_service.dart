import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/exceptions/empty_classroom_exception.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';

class WhuEmptyRoomService {
  WhuEmptyRoomService({required this.client});

  final WhuServiceSession client;

  static const _smartCampusPackage = 'com.chaoxing.mobile.wuhanuniversity';
  static const _smartCampusUserAgent =
      'Mozilla/5.0 (Linux; Android 14; wv) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Version/4.0 Chrome/144.0.7559.59 Mobile Safari/537.36 '
      'Language/zh_CN '
      'com.chaoxing.mobile.wuhanuniversity/ChaoXingStudy_1000028_5.4_android_phone_640_233';

  static final smartCampusServiceRequest = WhuCasServiceRequest(
    serviceUrl: _smartCampusLoginUri,
    isSuccess: _isSmartCampusLoginSuccess,
    parseFailure: _parseSmartCampusLoginFailure,
  );

  static final _smartCampusLoginUri = Uri.parse(
    'https://zhlj.whu.edu.cn/casLogin',
  );
  static final emptyRoomEntryUri = Uri.parse(
    'https://zhlj.whu.edu.cn/pc/toEmptyRoom',
  );
  static final _getTermUri = Uri.parse(
    'https://zhlj.whu.edu.cn/whdxEmptyRoom/getTerm',
  );
  static final _getFloorUri = Uri.parse(
    'https://zhlj.whu.edu.cn/whdxEmptyRoom/getFloor',
  );
  static final _getEmptyRoomUri = Uri.parse(
    'https://zhlj.whu.edu.cn/whdxEmptyRoom/getEmptyRoom',
  );

  Future<void> prepareSession() async {
    final response = await client.get(
      emptyRoomEntryUri,
      headers: _smartCampusHeaders(accept: 'text/html,application/xhtml+xml'),
    );
    _checkResponse(response);
  }

  Future<TermInfo> getTerm() async {
    final response = await client.get(
      _getTermUri,
      headers: _smartCampusHeaders(),
    );
    _checkResponse(response);
    final decoded = _decodeMap(response);
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const EmptyClassroomException(
        EmptyClassroomExceptionCode.invalidResponse,
        '学期信息返回格式异常。',
      );
    }
    return TermInfo.fromJson(data);
  }

  Future<List<CampusBuilding>> getFloor() async {
    final response = await client.get(
      _getFloorUri,
      headers: _smartCampusHeaders(),
    );
    _checkResponse(response);
    final decoded = _decodeMap(response);
    final data = decoded['data'];
    if (data is! List) {
      throw const EmptyClassroomException(
        EmptyClassroomExceptionCode.invalidResponse,
        '楼栋信息返回格式异常。',
      );
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(CampusBuilding.fromJson)
        .toList();
  }

  Future<List<EmptyClassroom>> getEmptyRoom({
    required String campus,
    required String schoolYear,
    required String term,
    required String week,
    required String weekDay,
    String? teachingBuilding,
  }) async {
    final body = <String, dynamic>{
      'campus': campus,
      'schoolYear': schoolYear,
      'term': term,
      'week': int.tryParse(week) ?? week,
      'weekDay': int.tryParse(weekDay) ?? weekDay,
      'section': null,
      'teachingBuilding': teachingBuilding ?? '',
    };
    final response = await client.post(
      _getEmptyRoomUri,
      headers: _smartCampusHeaders(
        contentType: 'application/json; charset=utf-8',
      ),
      body: jsonEncode(body),
    );
    _checkResponse(response);
    final decoded = _decodeMap(response);
    final data = decoded['data'];
    if (data is! List) {
      if (decoded['code'] == -1) {
        throw EmptyClassroomException(
          EmptyClassroomExceptionCode.serverRejected,
          decoded['msg'] as String? ?? '请求数据异常',
        );
      }
      throw const EmptyClassroomException(
        EmptyClassroomExceptionCode.invalidResponse,
        '空闲教室返回格式异常。',
      );
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(EmptyClassroom.fromJson)
        .toList();
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw EmptyClassroomException(
        EmptyClassroomExceptionCode.networkFailure,
        '空闲教室接口请求失败（HTTP ${response.statusCode}）。',
      );
    }
    if (_looksLikeAuthFailure(response.body)) {
      throw const EmptyClassroomException(
        EmptyClassroomExceptionCode.authExpired,
        '空闲教室授权已失效，请重新登录武大统一认证。',
      );
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw const FormatException('not a JSON object');
    } on FormatException {
      if (_looksLikeAuthFailure(response.body)) {
        throw const EmptyClassroomException(
          EmptyClassroomExceptionCode.authExpired,
          '空闲教室授权已失效，请重新登录武大统一认证。',
        );
      }
      throw const EmptyClassroomException(
        EmptyClassroomExceptionCode.invalidResponse,
        '空闲教室接口返回格式异常。',
      );
    }
  }

  static Map<String, String> _smartCampusHeaders({
    String accept = 'application/json, text/plain, */*',
    String? contentType,
  }) {
    final headers = <String, String>{
      'Accept': accept,
      'Accept-Language': 'zh_CN',
      'Referer': emptyRoomEntryUri.toString(),
      'User-Agent': _smartCampusUserAgent,
      'X-Requested-With': _smartCampusPackage,
    };
    if (contentType != null) {
      headers['Content-Type'] = contentType;
    }
    return headers;
  }

  static bool _isSmartCampusLoginSuccess(http.Response response) {
    final uri = response.request?.url;
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return false;
    }
    if (_looksLikeAuthFailure(response.body)) {
      return false;
    }
    return uri != null && uri.host == 'zhlj.whu.edu.cn';
  }

  static String? _parseSmartCampusLoginFailure(http.Response response) {
    if (_looksLikeAuthFailure(response.body)) {
      return '智慧珞珈授权失败，请重新登录武大统一认证。';
    }
    if (response.statusCode < 200 || response.statusCode >= 400) {
      return '智慧珞珈授权失败（HTTP ${response.statusCode}）。';
    }
    return '智慧珞珈授权失败，请稍后重试。';
  }

  static bool _looksLikeAuthFailure(String body) {
    final normalized = body.trim();
    return normalized == '未登录' ||
        body.contains('未登录') ||
        body.contains('authserver/login') ||
        body.contains('统一身份认证') ||
        body.contains('统一认证') ||
        body.contains('cas.whu.edu.cn') ||
        body.contains('/casLogin') ||
        body.contains('login-page');
  }
}
