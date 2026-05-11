import 'dart:convert';
import 'dart:math';

import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_memo_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class WhuCourseImportPayload {
  const WhuCourseImportPayload({
    required this.items,
    required this.termLabel,
  });

  final List<ItemDraft> items;
  final String termLabel;
}

class WhuCourseImportService {
  final WhuAuthorizedClient client;

  WhuCourseImportService({required this.client});

  static const _courseApiUrl =
      'https://jwgl.whu.edu.cn/kbcx/xskbcx_cxXsgrkb.html?gnmkdm=N2151';

  Future<WhuCourseImportPayload> loadCourses({
    required int year,
    required int semester,
    required DateTime weekOneMonday,
    required HomeSettings homeSettings,
  }) async {
    final response = await client.post(
      Uri.parse(_courseApiUrl),
      body: {
        'validate': _generateValidate(),
        'xnm': '$year',
        'xqm': '${_mapSemester(semester)}',
        'xzlx': 'ck',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('教务接口请求失败（HTTP ${response.statusCode}）。');
    }

    final normalizedBody = response.body.replaceAll('\u00A0', '');
    final decoded = jsonDecode(normalizedBody);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('教务接口返回格式异常。');
    }
    final rawList = decoded['kbList'];
    if (rawList is! List) {
      throw Exception('教务接口返回格式异常：未找到 kbList。');
    }
    if (rawList.isEmpty) {
      throw Exception('当前学年学期未查询到课程，请确认学期设置与会话状态。');
    }

    final normalizedWeekOne = DateTime(
      weekOneMonday.year,
      weekOneMonday.month,
      weekOneMonday.day,
    );
    final items = <ItemDraft>[];
    for (final rawItem in rawList) {
      if (rawItem is! Map) {
        continue;
      }
      final item = Map<String, dynamic>.from(rawItem);
      final title = (item['kcmc'] as String? ?? '').trim();
      if (title.isEmpty) {
        continue;
      }

      final weekday = _parseWeekday(item['xqj'], item['xqjmc']) ?? -1;
      final classPeriod = _parseClassPeriod(
        _pickFirstText(item, const ['jcs', 'jc', 'jcsm']),
      );
      final weeks = _parseWeekNumbers(
        _pickFirstText(item, const ['zcd', 'zcmc', 'zc']),
      );
      if (weekday < 1 || weekday > 7) {
        continue;
      }
      if (classPeriod == null) {
        continue;
      }
      if (weeks.isEmpty) {
        continue;
      }

      final courseId = (item['jxbmc'] as String? ?? '').trim();
      final courseNature = _pickFirstText(
        item,
        const ['kcxz', 'kcxzmc', 'kclbmc', 'kclb'],
      );
      final instructor = (item['xm'] as String? ?? '').trim();
      final location = (item['cdmc'] as String? ?? '').trim();
      final weekMeta = (item['zcd'] as String? ?? '').trim();
      final color = _pickColor(title);

      for (final week in weeks) {
        final date = normalizedWeekOne.add(Duration(days: (week - 1) * 7 + (weekday - 1)));
        final periodTime = _parsePeriodTime(
          startText: _pickFirstText(item, const ['kssj', 'sksj_kssj', 'kssj_hhmm']),
          endText: _pickFirstText(item, const ['jssj', 'sksj_jssj', 'jssj_hhmm']),
          classFrom: classPeriod.classFrom,
          classTo: classPeriod.classTo,
        );
        final startMinute = periodTime.startMinute;
        final endMinute = periodTime.endMinute;
        final startAt = DateTime(
          date.year,
          date.month,
          date.day,
          startMinute ~/ 60,
          startMinute % 60,
        );
        final endAt = DateTime(
          date.year,
          date.month,
          date.day,
          endMinute ~/ 60,
          endMinute % 60,
        );
        items.add(
          ItemDraft(
            type: ItemType.course,
            title: title,
            details: '',
            location: location,
            color: color,
            reminder: ReminderOption.none,
            repeatRule: RepeatRule.none,
            scheduleDetails: ItemScheduleDetails(
              isAllDay: false,
              range: DateTimeRangeValue(start: startAt, end: endAt),
            ),
            taskDetails: ItemTaskDetails(
              schedule: ItemScheduleDetails(
                isAllDay: false,
                range: DateTimeRangeValue(start: startAt, end: endAt),
              ),
              deadline: null,
            ),
            memoDetails: ItemMemoDetails(
              targetDate: DateTime(date.year, date.month, date.day),
              estimatedDuration: endAt.difference(startAt),
            ),
            courseDetails: ItemCourseDetails(
              sourceKind: CourseItemSourceKind.whuJw,
              sourceCourseId: courseId,
              courseNature: courseNature,
              instructor: instructor,
              classroomRaw: location,
              weekMeta: weekMeta,
            ),
          ),
        );
      }
    }

    final termLabel = '$year-${semester == 1 ? year + 1 : year} 学期$semester';
    return WhuCourseImportPayload(
      items: items,
      termLabel: termLabel,
    );
  }

  int _mapSemester(int semester) {
    if (semester == 1) {
      return 3;
    }
    if (semester == 2) {
      return 12;
    }
    if (semester == 3) {
      return 16;
    }
    return 3;
  }

  String _generateValidate() {
    const chars = '0123456789abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    final randomPart = List.generate(
      7,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'sl$randomPart${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
  }

  _ClassPeriod? _parseClassPeriod(String value) {
    final raw = value.trim();
    if (raw.isEmpty) {
      return null;
    }
    final normalized = raw
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('～', '-')
        .replaceAll('~', '-')
        .replaceAll('—', '-')
        .replaceAll('－', '-');
    final numbers = RegExp(r'\d+')
        .allMatches(normalized)
        .map((match) => int.tryParse(match.group(0) ?? ''))
        .whereType<int>()
        .toList(growable: false);
    if (numbers.isEmpty) {
      return null;
    }
    final from = numbers.first;
    final to = numbers.length >= 2 ? numbers[1] : numbers.first;
    if (from <= 0 || to < from) {
      return null;
    }
    return _ClassPeriod(classFrom: from, classTo: to);
  }

  int? _parsePositiveInt(Object? raw) {
    if (raw == null) {
      return null;
    }
    final text = '$raw';
    final match = RegExp(r'\d+').firstMatch(text);
    final value = int.tryParse(match?.group(0) ?? '');
    if (value == null || value <= 0) {
      return null;
    }
    return value;
  }

  int? _parseWeekday(Object? rawWeekday, Object? rawWeekdayLabel) {
    final numeric = _parsePositiveInt(rawWeekday);
    if (numeric != null && numeric >= 1 && numeric <= 7) {
      return numeric;
    }
    final text = '${rawWeekdayLabel ?? rawWeekday ?? ''}';
    if (text.isEmpty) {
      return null;
    }
    if (text.contains('一')) return 1;
    if (text.contains('二')) return 2;
    if (text.contains('三')) return 3;
    if (text.contains('四')) return 4;
    if (text.contains('五')) return 5;
    if (text.contains('六')) return 6;
    if (text.contains('日') || text.contains('天') || text.contains('七')) return 7;
    return null;
  }

  String _pickFirstText(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      final text = (value == null ? '' : '$value').trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  List<int> _parseWeekNumbers(String weekText) {
    final result = <int>{};
    for (final segment in weekText.split(RegExp(r'[,，;；、]'))) {
      final parsed = _parseWeekSegment(segment);
      if (parsed.isEmpty) {
        continue;
      }
      result.addAll(parsed);
    }
    final sorted = result.toList()..sort();
    return sorted;
  }

  List<int> _parseWeekSegment(String segment) {
    final raw = segment.trim();
    if (raw.isEmpty) {
      return const [];
    }
    final oddOnly = raw.contains('单');
    final evenOnly = raw.contains('双');
    final numbers = RegExp(r'\d+')
        .allMatches(raw)
        .map((match) => int.tryParse(match.group(0) ?? ''))
        .whereType<int>()
        .toList(growable: false);
    if (numbers.isEmpty) {
      return const [];
    }
    final start = numbers.first;
    final end = numbers.length >= 2 ? numbers[1] : numbers.first;
    if (start <= 0 || end <= 0 || end < start) {
      return const [];
    }

    final weeks = <int>[];
    for (var week = start; week <= end; week++) {
      if (oddOnly && week % 2 == 0) {
        continue;
      }
      if (evenOnly && week % 2 == 1) {
        continue;
      }
      weeks.add(week);
    }
    return weeks;
  }

  _PeriodTime _parsePeriodTime({
    required String startText,
    required String endText,
    required int classFrom,
    required int classTo,
  }) {
    final startFromText = _parseClockMinute(startText);
    final endFromText = _parseClockMinute(endText);
    if (startFromText != null && endFromText != null && endFromText > startFromText) {
      return _PeriodTime(startMinute: startFromText, endMinute: endFromText);
    }
    return _periodTimeFromClassRange(classFrom: classFrom, classTo: classTo);
  }

  int? _parseClockMinute(String text) {
    final raw = text.trim();
    if (raw.isEmpty) {
      return null;
    }
    final match = RegExp(r'(\d{1,2})[:：](\d{1,2})').firstMatch(raw);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  _PeriodTime _periodTimeFromClassRange({
    required int classFrom,
    required int classTo,
  }) {
    final fallbackStart = _periodStartMinute(classFrom);
    final fallbackEnd = _periodEndMinute(classTo);
    if (fallbackEnd > fallbackStart) {
      return _PeriodTime(startMinute: fallbackStart, endMinute: fallbackEnd);
    }
    return _PeriodTime(startMinute: fallbackStart, endMinute: fallbackStart + 45);
  }

  int _periodStartMinute(int period) {
    return switch (period) {
      1 => 8 * 60,
      2 => 8 * 60 + 50,
      3 => 9 * 60 + 50,
      4 => 10 * 60 + 40,
      5 => 11 * 60 + 30,
      6 => 14 * 60 + 5,
      7 => 14 * 60 + 55,
      8 => 15 * 60 + 45,
      9 => 16 * 60 + 40,
      10 => 17 * 60 + 30,
      11 => 18 * 60 + 30,
      12 => 19 * 60 + 20,
      13 => 20 * 60 + 10,
      _ => 8 * 60 + ((period - 1) * 50),
    };
  }

  int _periodEndMinute(int period) {
    return switch (period) {
      1 => 8 * 60 + 45,
      2 => 9 * 60 + 35,
      3 => 10 * 60 + 35,
      4 => 11 * 60 + 25,
      5 => 12 * 60 + 15,
      6 => 14 * 60 + 50,
      7 => 15 * 60 + 40,
      8 => 16 * 60 + 30,
      9 => 17 * 60 + 25,
      10 => 18 * 60 + 15,
      11 => 19 * 60 + 15,
      12 => 20 * 60 + 5,
      13 => 20 * 60 + 55,
      _ => _periodStartMinute(period) + 45,
    };
  }

  ItemColorOption _pickColor(String title) {
    final seed = title.hashCode.abs();
    return ItemColorOption.values[seed % ItemColorOption.values.length];
  }
}

class _ClassPeriod {
  const _ClassPeriod({
    required this.classFrom,
    required this.classTo,
  });

  final int classFrom;
  final int classTo;
}

class _PeriodTime {
  const _PeriodTime({
    required this.startMinute,
    required this.endMinute,
  });

  final int startMinute;
  final int endMinute;
}
