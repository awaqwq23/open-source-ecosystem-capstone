import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';

class SportsReservationApiResponse {
  const SportsReservationApiResponse._();

  static Object? decode(http.Response response, {required String action}) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SportsReservationApiException(
        '$action失败（HTTP ${response.statusCode}）。',
        statusCode: response.statusCode,
      );
    }

    final decoded = _decodeJson(response.bodyBytes, action: action);
    if (decoded is! Map) {
      throw SportsReservationApiException('$action失败：响应格式异常。');
    }
    final envelope = SportsReservationJson.asMap(decoded);
    final success = SportsReservationJson.readBool(envelope, 'success');
    final status = SportsReservationJson.readNullableInt(envelope, 'status');
    if (!success || status != 200) {
      final message = SportsReservationJson.readString(envelope, 'msg');
      throw SportsReservationApiException(
        message.isEmpty ? '$action失败。' : '$action失败：$message',
        statusCode: status ?? response.statusCode,
      );
    }
    return envelope['response'];
  }

  static Object? _decodeJson(List<int> bodyBytes, {required String action}) {
    try {
      return jsonDecode(utf8.decode(bodyBytes));
    } on FormatException catch (error) {
      throw SportsReservationApiException(
        '$action失败：响应不是有效 JSON。${_diagnosticFromBody(bodyBytes)}',
        cause: error,
      );
    }
  }

  static String _diagnosticFromBody(List<int> bodyBytes) {
    final body = utf8.decode(bodyBytes, allowMalformed: true).trimLeft();
    if (body.isEmpty) {
      return '响应为空。';
    }
    final lower = body.toLowerCase();
    final kind = lower.contains('safeline')
        ? 'SafeLine 防护页'
        : lower.contains('authserver/login') || lower.contains('统一身份认证')
        ? '统一认证登录页'
        : lower.startsWith('<!doctype html') || lower.startsWith('<html')
        ? 'HTML 页面'
        : '非 JSON 文本';
    return '响应类型：$kind。';
  }
}

class SportsReservationJson {
  const SportsReservationJson._();

  static Map<String, Object?> asMap(Object? value) {
    if (value is! Map) {
      return const {};
    }
    return value.map((key, value) => MapEntry('$key', value));
  }

  static List<Map<String, Object?>> asMapList(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => asMap(item))
          .toList(growable: false);
    }
    final map = asMap(value);
    for (final key in const ['data', 'items', 'list', 'rows']) {
      final items = map[key];
      if (items is List) {
        return asMapList(items);
      }
    }
    return const [];
  }

  static String readString(
    Map<String, Object?> map,
    String key, {
    String fallback = '',
  }) {
    final value = map[key];
    if (value == null) {
      return fallback;
    }
    return '$value'.trim();
  }

  static int readInt(Map<String, Object?> map, String key, {int fallback = 0}) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('${value ?? ''}') ?? fallback;
  }

  static int? readNullableInt(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value');
  }

  static double readDouble(
    Map<String, Object?> map,
    String key, {
    double fallback = 0,
  }) {
    final value = map[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('${value ?? ''}') ?? fallback;
  }

  static bool readBool(
    Map<String, Object?> map,
    String key, {
    bool fallback = false,
  }) {
    final value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    final text = '${value ?? ''}'.trim().toLowerCase();
    if (text == 'true' || text == '1') {
      return true;
    }
    if (text == 'false' || text == '0') {
      return false;
    }
    return fallback;
  }

  static DateTime? readDateTime(Map<String, Object?> map, String key) {
    final text = readString(map, key);
    if (text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }
}
