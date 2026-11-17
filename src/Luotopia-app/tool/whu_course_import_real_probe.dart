import 'dart:convert';
import 'dart:io';

import 'package:luotopia/features/pages/campus/sub_apps/timetable/course_import/data/whu_course_import_service.dart';
import 'package:luotopia/features/whu_auth/data/whu_cas_service.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';

Future<void> main([List<String> args = const []]) async {
  final options = _ProbeOptions.parse(args);
  final credentials = await _loadCredentials(options.credentialsPath);

  _printHeader('课表真实导入链路探针');
  _printLine('凭证文件', options.credentialsPath);
  _printLine('CAS Cookie', _cookieState(credentials.casCookieHeader));
  _printLine('教务 Cookie', _cookieState(credentials.educationCookieHeader));
  _printLine('学年', '${options.year}');
  _printLine('学期', '${options.semester}');
  _printLine('第一周周一', _formatDate(options.weekOneMonday));

  await _tryOpenEducationWithCookies(
    const WhuCasService(),
    credentials.educationCookieHeader,
  );

  final cas = const WhuCasService();
  await _tryCasVariant(
    label: '实际流程：CAS Cookie 原样',
    cas: cas,
    casCookieHeader: credentials.casCookieHeader,
    options: options,
  );
  await _tryCasVariant(
    label: '对照：CAS Cookie 去重后保留最后值',
    cas: cas,
    casCookieHeader: _dedupeCookieHeaderKeepingLast(credentials.casCookieHeader),
    options: options,
  );
}

Future<_Credentials> _loadCredentials(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw StateError('找不到凭证文件：$path');
  }
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map) {
    throw const FormatException('凭证文件根节点不是 JSON 对象。');
  }
  final snapshot = decoded['snapshot'];
  if (snapshot is! Map) {
    throw const FormatException('凭证文件缺少 snapshot 对象。');
  }
  return _Credentials(
    casCookieHeader: '${snapshot['casCookieHeader'] ?? ''}',
    educationCookieHeader: '${snapshot['educationCookieHeader'] ?? ''}',
  );
}

Future<WhuServiceSession?> _tryOpenEducationWithCookies(
  WhuCasService cas,
  String educationCookieHeader,
) async {
  _printHeader('对照检查：用持久化教务 Cookie 建立会话');
  try {
    final client = await cas.authorizeEducationWithCookies(
      educationCookieHeader: educationCookieHeader,
    );
    _printLine('结果', '成功');
    _printLine(
      'jwgl Cookie',
      _cookieState(
        client.cookieHeaderFor(Uri.parse('https://jwgl.whu.edu.cn/')),
      ),
    );
    return client;
  } on WhuAuthException catch (error) {
    _printLine('结果', '失败');
    _printLine('错误码', error.code.name);
    _printLine('错误', error.message);
    return null;
  } on Object catch (error) {
    _printLine('结果', '异常');
    _printLine('错误', '$error');
    return null;
  }
}

Future<void> _tryCasVariant({
  required String label,
  required WhuCasService cas,
  required String casCookieHeader,
  required _ProbeOptions options,
}) async {
  _printHeader('阶段 2：$label 授权教务');
  WhuServiceSession? client;
  try {
    client = await cas.authorizeService(
      casCookieHeader: casCookieHeader,
      request: WhuCasService.educationService,
    );
    _printLine('结果', '成功');
    _printLine('最终地址', _sanitizeUri(client.lastResponseUri));
    _printLine(
      'jwgl Cookie',
      _cookieState(
        client.cookieHeaderFor(Uri.parse('https://jwgl.whu.edu.cn/')),
      ),
    );
    await _tryLoadCourses(label, client, options);
  } on WhuAuthException catch (error) {
    _printLine('结果', '失败');
    _printLine('错误码', error.code.name);
    _printLine('错误', error.message);
  } on Object catch (error, stackTrace) {
    _printLine('结果', '异常');
    _printLine('错误', '$error');
    _printLine('堆栈', stackTrace.toString().split('\n').take(3).join(' | '));
  } finally {
    client?.close();
  }
}

Future<void> _tryLoadCourses(
  String sessionLabel,
  WhuServiceSession client,
  _ProbeOptions options,
) async {
  _printHeader('阶段 3：$sessionLabel 请求课表接口并解析');
  try {
    final payload = await WhuCourseImportService(client: client).loadCourses(
      year: options.year,
      semester: options.semester,
      weekOneMonday: options.weekOneMonday,
    );
    final titles = payload.items
        .map((item) => item.title)
        .where((title) => title.trim().isNotEmpty)
        .toSet();
    _printLine('结果', '成功');
    _printLine('termLabel', payload.termLabel);
    _printLine('事项数', '${payload.items.length}');
    _printLine('课程数', '${titles.length}');
    _printLine('课程示例', titles.take(5).join('、'));
  } on Object catch (error, stackTrace) {
    _printLine('结果', '失败');
    _printLine('错误', '$error');
    _printLine('堆栈', stackTrace.toString().split('\n').take(3).join(' | '));
  }
}

String _dedupeCookieHeaderKeepingLast(String header) {
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
  return values.entries.map((entry) => '${entry.key}=${entry.value}').join('; ');
}

String _cookieState(String value) {
  if (value.trim().isEmpty) {
    return 'empty';
  }
  final counts = <String, int>{};
  for (final part in value.split(';')) {
    final trimmed = part.trim();
    if (!trimmed.contains('=')) {
      continue;
    }
    final name = trimmed.substring(0, trimmed.indexOf('=')).trim();
    if (name.isNotEmpty) {
      counts[name] = (counts[name] ?? 0) + 1;
    }
  }
  final names = counts.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));
  return 'set (${names.map((entry) {
    final suffix = entry.value > 1 ? ' x${entry.value}' : '';
    return '${entry.key}$suffix';
  }).join(', ')})';
}

String _sanitizeUri(Uri? uri) {
  if (uri == null) {
    return '<none>';
  }
  final queryKeys =
      uri.queryParameters.keys.where((key) {
        final lower = key.toLowerCase();
        return lower != 'ticket' && lower != 'token';
      }).toList()
        ..sort();
  final queryText = queryKeys.isEmpty ? '' : '?${queryKeys.join(',')}';
  return '${uri.scheme}://${uri.host}${uri.path}$queryText';
}

String _formatDate(DateTime date) {
  String pad(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${pad(date.month)}-${pad(date.day)}';
}

void _printHeader(String text) {
  stdout.writeln('\n== $text ==');
}

void _printLine(String key, String value) {
  stdout.writeln('$key: $value');
}

class _Credentials {
  const _Credentials({
    required this.casCookieHeader,
    required this.educationCookieHeader,
  });

  final String casCookieHeader;
  final String educationCookieHeader;
}

class _ProbeOptions {
  const _ProbeOptions({
    required this.credentialsPath,
    required this.year,
    required this.semester,
    required this.weekOneMonday,
  });

  final String credentialsPath;
  final int year;
  final int semester;
  final DateTime weekOneMonday;

  factory _ProbeOptions.parse(List<String> args) {
    var credentialsPath = '../my-docs/whu_auth_snapshot.local.json';
    var year = 2025;
    var semester = 2;
    var weekOneMonday = DateTime(2026, 2, 23);

    for (final arg in args) {
      if (arg == '--help' || arg == '-h') {
        _printUsageAndExit();
      } else if (arg.startsWith('--credentials=')) {
        credentialsPath = arg.substring('--credentials='.length);
      } else if (arg.startsWith('--year=')) {
        year = int.parse(arg.substring('--year='.length));
      } else if (arg.startsWith('--semester=')) {
        semester = int.parse(arg.substring('--semester='.length));
      } else if (arg.startsWith('--week-one-monday=')) {
        weekOneMonday = DateTime.parse(
          arg.substring('--week-one-monday='.length),
        );
      }
    }

    return _ProbeOptions(
      credentialsPath: credentialsPath,
      year: year,
      semester: semester,
      weekOneMonday: weekOneMonday,
    );
  }

  static Never _printUsageAndExit([int code = 0]) {
    stdout.writeln('''
Usage:
  dart run tool/whu_course_import_real_probe.dart [--credentials=../my-docs/whu_auth_snapshot.local.json] [--year=2025] [--semester=2] [--week-one-monday=2026-02-23]
''');
    exit(code);
  }
}
