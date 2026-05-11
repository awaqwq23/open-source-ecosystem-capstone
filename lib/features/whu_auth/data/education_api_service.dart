import 'dart:convert';

import 'package:luotopia/features/hot_update/data/hot_update_service.dart';
import 'package:luotopia/features/hot_update/domain/models/script_info.dart';
import 'package:luotopia/features/whu_auth/data/whu_education_client.dart';
import 'package:luotopia/features/whu_auth/domain/models/score_entity.dart';
import 'package:luotopia/features/whu_auth/domain/whu_session_checker.dart';

class EducationUserInfo {
  final String studentId;
  final String name;
  final String college;

  const EducationUserInfo({
    required this.studentId,
    required this.name,
    required this.college,
  });

  bool get isComplete =>
      studentId.isNotEmpty && name.isNotEmpty && college.isNotEmpty;
}

class EducationApiService {
  final WhuEducationClient client;
  final HotUpdateService? hotUpdateService;

  const EducationApiService({
    required this.client,
    this.hotUpdateService,
  });

  static const _casLoginUrl =
      'https://cas.whu.edu.cn/authserver/login'
      '?service=https%3A%2F%2Fjwgl.whu.edu.cn%2Fsso%2Fjznewsixlogin';

  static const _userInfoUrl =
      'https://jwgl.whu.edu.cn/xtgl/index_cxYhxxIndex.html'
      '?xt=jw&localeKey=zh_CN&_=1&gnmkdm=index';

  static const _scoreApiUrl =
      'https://jwgl.whu.edu.cn/cjcx/cjcx_cxXsgrcj.html'
      '?doType=query&gnmkdm=N305005';

  static const _healthCheckUrl =
      'https://jwgl.whu.edu.cn/cjcx/cjcx_cxXsgrcj.html'
      '?doType=query&gnmkdm=N305005';

  /// 从 CAS cookie 登录教务系统（SSO 握手）
  Future<void> loginEducation() async {
    final response = await client.get(
      Uri.parse(_casLoginUrl),
      skipRetry: true,
    );

    final text = response.body.replaceAll('\u00A0', ' ');

    if (text.contains('教学管理信息服务平台')) {
      return;
    }

    final errorMatch = RegExp(r'var dlktsxx="(.*?)";').firstMatch(text);
    final errorMsg = errorMatch?.group(1);
    if (errorMsg != null && errorMsg.isNotEmpty) {
      throw Exception('教务系统登录失败：$errorMsg');
    }

    throw Exception('教务系统登录失败，请尝试重新登录信息门户。');
  }

  /// 从教务系统拉取用户信息（学号、姓名、学院）
  Future<EducationUserInfo> getUserInfo({String? knownStudentId}) async {
    final response = await client.get(
      Uri.parse(_userInfoUrl),
      extraHeaders: {'Host': 'jwgl.whu.edu.cn'},
    );

    final text = response.body.replaceAll('\u00A0', ' ');

    String studentId = knownStudentId ?? '';
    if (studentId.isEmpty) {
      final xhMatch = RegExp(r'xh_id[=](\d+)').firstMatch(text);
      if (xhMatch != null) {
        studentId = xhMatch.group(1)!;
      }
    }

    String name = '';
    final nameMatch = RegExp(
      r'<h4[^>]*media-heading[^>]*>([^<]+)',
    ).firstMatch(text);
    if (nameMatch != null) {
      name = nameMatch
          .group(1)!
          .replaceFirst(RegExp(r'\s*学生.*'), '')
          .trim();
    }

    String college = '';
    final collegeMatch = RegExp(
      r'<div[^>]*media-body[^>]*>.*?<p[^>]*>([^<]+)',
      dotAll: true,
    ).firstMatch(text);
    if (collegeMatch != null) {
      college = collegeMatch
          .group(1)!
          .replaceFirst(RegExp(r'\s+\d{4}.*'), '')
          .trim();
    }

    return EducationUserInfo(
      studentId: studentId,
      name: name,
      college: college,
    );
  }

  /// 获取成绩列表
  Future<({List<ScoreEntity> scores, ScoreUserInfo userInfo})> getScoreList({
    int? year,
    int? semester,
    String? validate,
  }) async {
    final v = validate ?? WhuEducationClient.generateValidate();
    final body = <String, String>{
      'validate': v,
      'xnm': year != null ? '$year' : '',
      'xqm': semester != null ? '$semester' : '',
      'queryModel.showCount': '150',
    };

    final response = await client.post(
      Uri.parse(_scoreApiUrl),
      extraHeaders: {'Host': 'jwgl.whu.edu.cn'},
      body: body,
    );

    final normalizedBody = response.body.replaceAll('\u00A0', ' ');

    final decoded = jsonDecode(normalizedBody);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('成绩接口返回格式异常。');
    }

    if (hotUpdateService != null) {
      return hotUpdateService!.parse(
        parserName: ParserNames.score,
        rawData: decoded,
        dartParser: _parseScoreResponseViaJs,
      );
    }

    final rawItems = decoded['items'];
    if (rawItems is! List) {
      throw Exception('成绩接口返回格式异常：未找到 items。');
    }
    return _parseScoreResponse(rawItems);
  }

  /// 快速检测教务会话是否有效
  Future<bool> isSessionValid() async {
    try {
      final response = await client.post(
        Uri.parse(_healthCheckUrl),
        body: {
          'validate': WhuEducationClient.generateValidate(),
          'xnm': '',
          'xqm': '',
          'queryModel.showCount': '1',
        },
        skipRetry: true,
      );

      final text = response.body.replaceAll('\u00A0', ' ');
      return !looksLikeWhuLoginRedirect(text);
    } catch (_) {
      return false;
    }
  }

  /// 将教务系统学期代码映射为内部表示
  /// 3 → 1（第一学期）, 12 → 2（第二学期）, 16 → 3（第三学期）
  static int mapSemester(int apiSemester) {
    return switch (apiSemester) {
      3 => 1,
      12 => 2,
      16 => 3,
      _ => 1,
    };
  }

  /// 反向映射：内部学期 → 教务系统代码
  static int reverseMapSemester(int internalSemester) {
    return switch (internalSemester) {
      1 => 3,
      2 => 12,
      3 => 16,
      _ => 3,
    };
  }

  ({List<ScoreEntity> scores, ScoreUserInfo userInfo}) _parseScoreResponseViaJs(
    Map<String, dynamic> json,
  ) {
    final rawScores = json['scores'] as List<dynamic>?;
    if (rawScores != null) {
      final userInfoData = json['userInfo'];
      final userInfo = userInfoData is Map<String, dynamic>
          ? ScoreUserInfo(
              college: (userInfoData['college'] as String? ?? ''),
              major: (userInfoData['major'] as String? ?? ''),
              name: (userInfoData['name'] as String? ?? ''),
              studentId: (userInfoData['studentId'] as String? ?? ''),
            )
          : const ScoreUserInfo(
              college: '',
              major: '',
              name: '',
              studentId: '',
            );

      final scores = rawScores
          .map((e) {
            if (e is! Map) {
              return null;
            }
            final m = Map<String, dynamic>.from(e as Map);
            final score = (m['score'] as num?)?.toInt() ?? 0;
            final credit = (m['credit'] as num?)?.toDouble() ?? 0;
            if (score <= 0 || credit <= 0) {
              return null;
            }
            return ScoreEntity(
              year: (m['year'] as num?)?.toInt() ?? 0,
              semester: (m['semester'] as num?)?.toInt() ?? 1,
              name: (m['name'] as String? ?? '').trim(),
              courseId: (m['courseId'] as String? ?? '').trim(),
              instructor: (m['instructor'] as String? ?? '').trim(),
              credit: credit,
              courseType: (m['courseType'] as String? ?? '').trim(),
              score: score,
              courseCollege: (m['courseCollege'] as String? ?? '').trim(),
            );
          })
          .whereType<ScoreEntity>()
          .toList();
      return (scores: scores, userInfo: userInfo);
    }

    final rawItems = json['items'] as List<dynamic>?;
    if (rawItems != null) {
      return _parseScoreResponse(rawItems);
    }

    throw Exception('成绩解析失败：无法识别的数据格式。');
  }

  ({List<ScoreEntity> scores, ScoreUserInfo userInfo}) _parseScoreResponse(
    List rawItems,
  ) {
    var userInfo = const ScoreUserInfo(
      college: '',
      major: '',
      name: '',
      studentId: '',
    );
    final scores = <ScoreEntity>[];

    for (final raw in rawItems) {
      if (raw is! Map) {
        continue;
      }
      final item = Map<String, dynamic>.from(raw as Map);

      final xh = (item['xh'] as String? ?? '').trim();
      final xm = (item['xm'] as String? ?? '').trim();
      final jgmc = (item['jgmc'] as String? ?? '').trim();
      final zymc = (item['zymc'] as String? ?? '').trim();
      if (xh.isNotEmpty && userInfo.studentId.isEmpty) {
        userInfo = ScoreUserInfo(
          college: jgmc,
          major: zymc,
          name: xm,
          studentId: xh,
        );
      }

      final year = int.tryParse('${item['xnm'] ?? ''}') ?? 0;
      final apiSemester = int.tryParse('${item['xqm'] ?? ''}') ?? 0;
      final credit = double.tryParse('${item['xf'] ?? ''}') ?? double.nan;
      final score = int.tryParse('${item['bfzcj'] ?? ''}') ?? 0;

      if (year <= 0 || credit.isNaN || score <= 0) {
        continue;
      }

      scores.add(ScoreEntity(
        year: year,
        semester: mapSemester(apiSemester),
        name: (item['kcmc'] as String? ?? '').trim(),
        courseId: (item['jxbmc'] as String? ?? '').trim(),
        instructor: (item['jsxm'] as String? ?? '').trim(),
        credit: credit,
        courseType: (item['kcxzmc'] as String? ?? '').trim(),
        score: score,
        courseCollege: (item['kkbmmc'] as String? ?? '').trim(),
      ));
    }

    return (scores: scores, userInfo: userInfo);
  }
}
