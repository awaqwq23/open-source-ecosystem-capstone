import 'dart:convert';

import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_course_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_memo_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_schedule_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_task_details.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';
import 'package:http/http.dart' as http;

class WhuCourseImportPayload {
  const WhuCourseImportPayload({
    required this.items,
    required this.termLabel,
  });

  final List<ItemDraft> items;
  final String termLabel;
}

class WhuCourseImportService {
  static const _courseApiUrl =
      'https://jwgl.whu.edu.cn/kbcx/xskbcx_cxXsgrkb.html?gnmkdm=N2151';

  Future<WhuCourseImportPayload> loadCourses({
    required String cookieHeader,
    required int year,
    required int semester,
    required DateTime weekOneMonday,
    required HomeSettings homeSettings,
  }) async {
    final response = await http.post(
      Uri.parse(_courseApiUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Cookie': cookieHeader,
      },
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

    final raw = response.body.replaceAll('\u00A0', '');
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('教务接口返回格式异常。');
    }
    final rawList = decoded['kbList'];
    if (rawList is! List) {
      throw Exception('未获取到课表列表（kbList）。');
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
      final item = Map<String, dynamic>.from(rawItem as Map);
      final title = (item['kcmc'] as String? ?? '').trim();
      if (title.isEmpty) {
        continue;
      }

      final weekday = int.tryParse('${item['xqj'] ?? ''}') ?? -1;
      final classPeriod = _parseClassPeriod('${item['jcs'] ?? ''}');
      final weeks = _parseWeekNumbers('${item['zcd'] ?? ''}');
      if (weekday < 1 || weekday > 7 || classPeriod == null || weeks.isEmpty) {
        continue;
      }

      final courseId = (item['jxbmc'] as String? ?? '').trim();
      final instructor = (item['xm'] as String? ?? '').trim();
      final location = (item['cdmc'] as String? ?? '').trim();
      final weekMeta = (item['zcd'] as String? ?? '').trim();
      final details = instructor.isEmpty ? '' : '教师：$instructor';
      final color = _pickColor(title, courseId);

      for (final week in weeks) {
        final date = normalizedWeekOne.add(Duration(days: (week - 1) * 7 + (weekday - 1)));
        final startMinute = _classStartMinute(
          classFrom: classPeriod.classFrom,
          settings: homeSettings,
        );
        final endMinute = _classEndMinute(
          classTo: classPeriod.classTo,
          settings: homeSettings,
        );
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
            details: details,
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
              instructor: instructor,
              classroomRaw: location,
              weekMeta: weekMeta,
            ),
          ),
        );
      }
    }

    final termLabel = '$year-${semester == 1 ? year + 1 : year} 学期$semester';
    return WhuCourseImportPayload(items: items, termLabel: termLabel);
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
    final random = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return 'sl$random';
  }

  _ClassPeriod? _parseClassPeriod(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }
    if (!text.contains('-')) {
      final single = int.tryParse(text);
      if (single == null) {
        return null;
      }
      return _ClassPeriod(classFrom: single, classTo: single);
    }
    final parts = text.split('-');
    if (parts.length != 2) {
      return null;
    }
    final from = int.tryParse(parts[0]);
    final to = int.tryParse(parts[1]);
    if (from == null || to == null || from <= 0 || to < from) {
      return null;
    }
    return _ClassPeriod(classFrom: from, classTo: to);
  }

  List<int> _parseWeekNumbers(String weekText) {
    final result = <int>{};
    for (final segment in weekText.split(',')) {
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
    final clean = raw.replaceAll(RegExp(r'[()周单双]'), '');
    if (clean.isEmpty) {
      return const [];
    }
    var start = 0;
    var end = 0;
    if (clean.contains('-')) {
      final parts = clean.split('-');
      if (parts.length != 2) {
        return const [];
      }
      start = int.tryParse(parts[0]) ?? 0;
      end = int.tryParse(parts[1]) ?? 0;
    } else {
      start = int.tryParse(clean) ?? 0;
      end = start;
    }
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

  int _classStartMinute({
    required int classFrom,
    required HomeSettings settings,
  }) {
    final dayStart = settings.dayStartTime.hour * 60 + settings.dayStartTime.minute;
    final step = settings.blockDurationMinutes + settings.blockGapMinutes;
    return dayStart + (classFrom - 1) * step;
  }

  int _classEndMinute({
    required int classTo,
    required HomeSettings settings,
  }) {
    final dayStart = settings.dayStartTime.hour * 60 + settings.dayStartTime.minute;
    final step = settings.blockDurationMinutes + settings.blockGapMinutes;
    return dayStart + (classTo - 1) * step + settings.blockDurationMinutes;
  }

  ItemColorOption _pickColor(String title, String id) {
    final seed = '$title#$id'.hashCode.abs();
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
