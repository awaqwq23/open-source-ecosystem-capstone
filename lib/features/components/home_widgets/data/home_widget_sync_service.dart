import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/theme/theme_controller.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return HomeWidgetSyncService(ref);
});

class HomeWidgetSyncService {
  HomeWidgetSyncService(this._ref);

  static const MethodChannel _channel = MethodChannel('luotopia/widget_sync');

  final Ref _ref;
  bool _isSyncing = false;
  bool _syncQueued = false;
  Timer? _debounceTimer;
  String? _lastPayloadHash;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize() async {
    if (!_supported) {
      return;
    }
    syncDebounced(delay: const Duration(milliseconds: 800));
  }

  void syncDebounced({Duration delay = const Duration(milliseconds: 700)}) {
    if (!_supported) {
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      unawaited(sync());
    });
  }

  Future<void> sync() async {
    if (!_supported) {
      return;
    }
    if (_isSyncing) {
      _syncQueued = true;
      return;
    }
    _isSyncing = true;
    try {
      final settings = _ref.read(appWidgetSettingsProvider);
      if (!settings.enabled) {
        return;
      }

      final locale = _resolveLocale(settings);
      final languageCode = locale.languageCode.toLowerCase();
      final zh = languageCode.startsWith('zh');
      final themeMode = _ref.read(appThemeModeProvider);
      final items = _ref.read(agendaItemRepositoryProvider);
      final timetableStore = _ref.read(courseTimetableRepositoryProvider);
      final now = DateTime.now();
      final week = _weekRange(now);

      final timetabledCourseItems = items
          .where((item) => item.type == ItemType.course && item.courseDetails.timetableId.isNotEmpty)
          .toList();
      final semesterWeekLabel = _semesterWeekLabel(
        timetabledCourseItems: timetabledCourseItems,
        activeTimetableId: timetableStore.activeTimetableId,
        zh: zh,
      );
      final intendedLabel = semesterWeekLabel ?? _periodLabel(week.start, zh);

      final payload = <String, dynamic>{
        'version': 4,
        'meta': {
          'languageCode': languageCode,
          'darkMode': _isDarkMode(themeMode),
          'timezone': _timezoneLabel(),
          'updatedAt': now.toIso8601String(),
          'updatedLabel': _formatWidgetTimestamp(now, zh),
        },
        'quickCreate': {
          'title': zh ? '快速创建事项' : 'Quick Create',
          'newItemLabel': zh ? '新建事项' : 'New Item',
          'scheduleLabel': zh ? '日程' : 'Schedule',
          'taskLabel': zh ? '任务' : 'Task',
          'memoLabel': zh ? '备忘' : 'Memo',
        },
        'agendaList': _buildAgendaListPayload(
          items: items,
          now: now,
          zh: zh,
          darkMode: _isDarkMode(themeMode),
          weekSubtitle: intendedLabel,
        ),
        'weekGrid': _buildWeekGridPayload(
          items: items,
          week: week,
          now: now,
          zh: zh,
          weekLabel: zh ? '本周' : 'This Week',
          weekSubtitle: intendedLabel,
        ),
      };

      final payloadHash = jsonEncode(payload);
      if (payloadHash == _lastPayloadHash) {
        return;
      }
      _lastPayloadHash = payloadHash;
      await _channel.invokeMethod<void>('syncWidgets', payload);
    } finally {
      _isSyncing = false;
      if (_syncQueued) {
        _syncQueued = false;
        unawaited(sync());
      }
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }

  Locale _resolveLocale(WidgetSettings settings) {
    if (settings.followAppLanguage) {
      return _ref.read(appLocaleProvider);
    }
    return PlatformDispatcher.instance.locale;
  }

  bool _isDarkMode(ui.ThemeMode themeMode) {
    return switch (themeMode) {
      ui.ThemeMode.dark => true,
      ui.ThemeMode.light => false,
      ui.ThemeMode.system =>
        PlatformDispatcher.instance.platformBrightness == Brightness.dark,
    };
  }
}

Map<String, dynamic> _buildAgendaListPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required bool zh,
  required bool darkMode,
  required String weekSubtitle,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  final todayLeftItems = items
      .where((item) => _shouldShowInLeftColumn(item, now: now, day: today))
      .toList(growable: false)
    ..sort((a, b) {
      final byStart = _sortStart(a, today).compareTo(_sortStart(b, today));
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });
  final tomorrowLeftItems = items
      .where((item) => _shouldShowInLeftColumn(item, now: now, day: tomorrow))
      .toList(growable: false)
    ..sort((a, b) {
      final byStart = _sortStart(a, tomorrow).compareTo(_sortStart(b, tomorrow));
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });
  final useTodayLeft = todayLeftItems.isNotEmpty;
  final leftDay = useTodayLeft ? today : tomorrow;
  final leftItems = useTodayLeft ? todayLeftItems : tomorrowLeftItems;
  final leftStatusLabel = useTodayLeft
      ? (zh ? '今日日程' : 'Today')
      : leftItems.isNotEmpty
          ? (zh ? '明日日程' : 'Tomorrow')
          : (zh ? '明日无日程' : 'No schedule tomorrow');

  final rightItems = items
      .where(_shouldShowInRightColumn)
      .toList(growable: false)
    ..sort((a, b) {
      final dayA = _displayDayForItem(a, fallback: today);
      final dayB = _displayDayForItem(b, fallback: today);
      final byDay = dayA.compareTo(dayB);
      if (byDay != 0) {
        return byDay;
      }
      final byStart = _sortStart(a, dayA).compareTo(_sortStart(b, dayB));
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });

  return {
    'title': zh ? '事项列表' : 'Agenda List',
    'subtitle': zh ? '左列日程，右列任务与备忘' : 'Schedule left, tasks and memos right',
    'mode': useTodayLeft
        ? 'today_schedule'
        : leftItems.isNotEmpty
            ? 'tomorrow_schedule'
            : 'tomorrow_empty',
    'leftTitle': leftStatusLabel,
    'rightTitle': zh ? '任务备忘' : 'Tasks & Memos',
    'leftRows': [
      for (final item in leftItems.take(40))
        _toAgendaListRow(
          item,
          leftDay,
          zh,
          darkMode: darkMode,
          includeDay: false,
        ),
    ],
    'rightRows': [
      for (final item in rightItems.take(80))
        _toAgendaListRow(
          item,
          _displayDayForItem(item, fallback: today),
          zh,
          darkMode: darkMode,
          includeDay: true,
        ),
    ],
    'weekdayLabel': weekSubtitle,
    'weekLabel': leftStatusLabel,
  };
}

bool _shouldShowInLeftColumn(
  AgendaItem item, {
  required DateTime now,
  required DateTime day,
}) {
  if (item.isCompleted) {
    return false;
  }
  if (item.type != ItemType.course && item.type != ItemType.schedule) {
    return false;
  }
  if (!_itemInDay(item, day)) {
    return false;
  }
  final today = DateTime(now.year, now.month, now.day);
  if (_isSameDay(day, today)) {
    return item.endAt.isAfter(now);
  }
  return true;
}

bool _shouldShowInRightColumn(AgendaItem item) {
  if (item.isCompleted) {
    return false;
  }
  return item.type == ItemType.task || item.type == ItemType.memo;
}

DateTime _displayDayForItem(
  AgendaItem item, {
  required DateTime fallback,
}) {
  if (item.type == ItemType.memo) {
    return DateTime(item.targetDate.year, item.targetDate.month, item.targetDate.day);
  }
  return DateTime(item.startAt.year, item.startAt.month, item.startAt.day);
}

Map<String, dynamic> _toAgendaListRow(
  AgendaItem item,
  DateTime today,
  bool zh, {
  required bool darkMode,
  required bool includeDay,
}) {
  final typeKey = switch (item.type) {
    ItemType.schedule => 'schedule',
    ItemType.task => 'task',
    ItemType.memo => 'memo',
    ItemType.course => 'course',
  };

  final tag = switch (item.type) {
    ItemType.schedule => zh ? '日程' : 'Schedule',
    ItemType.task => zh ? '任务' : 'Task',
    ItemType.memo => zh ? '备忘' : 'Memo',
    ItemType.course => zh ? '课程' : 'Course',
  };

  final title = item.title.trim().isEmpty
      ? (zh ? '未命名事项' : 'Untitled')
      : item.title.trim();

  final location = item.location.trim();
  final timeText = _buildItemTimeText(
    item,
    today,
    zh,
    includeDay: includeDay,
  );
  final compactMeta = location.isNotEmpty ? '$timeText · $location' : timeText;
  final clippedSubText = _clipWidgetText(
    compactMeta,
    maxChars: includeDay ? 30 : 24,
  );
  final accent = item.color.resolve(darkMode ? Brightness.dark : Brightness.light);

  return {
    'id': item.id,
    'title': title,
    'meta': clippedSubText,
    'subText': clippedSubText,
    'typeKey': typeKey,
    'tag': tag,
    'accentColor': _toArgbHex(accent),
  };
}

Map<String, dynamic> _buildWeekGridPayload({
  required List<AgendaItem> items,
  required DateTimeRange week,
  required DateTime now,
  required bool zh,
  required String weekLabel,
  required String weekSubtitle,
}) {
  final filtered = items
      .where((item) => item.type != ItemType.course)
      .toList(growable: false);

  final days = <Map<String, dynamic>>[];
  for (var i = 0; i < 7; i++) {
    final day = week.start.add(Duration(days: i));
    final dayItems = filtered.where((item) => _itemInDay(item, day)).toList(growable: false)
      ..sort((a, b) => _sortStart(a, day).compareTo(_sortStart(b, day)));

    days.add({
      'weekdayLabel': _weekdayShort(zh, day.weekday),
      'dateLabel': '${day.month}/${day.day}',
      'items': [
        for (final item in dayItems.take(8)) _toCompactDayLine(item, day, zh),
      ],
    });
  }

  return {
    'title': weekLabel,
    'subtitle': weekSubtitle,
    'weekStartIso': DateTime(
      week.start.year,
      week.start.month,
      week.start.day,
    ).toIso8601String(),
    'days': days,
    'generatedAt': now.toIso8601String(),
  };
}

DateTimeRange _weekRange(DateTime now) {
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - DateTime.monday));
  final end = start.add(const Duration(days: 6));
  return DateTimeRange(start: start, end: end);
}

bool _itemInDay(AgendaItem item, DateTime day) {
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  if (item.type == ItemType.memo) {
    final target = DateTime(item.targetDate.year, item.targetDate.month, item.targetDate.day);
    return target.year == dayStart.year &&
        target.month == dayStart.month &&
        target.day == dayStart.day;
  }
  return item.endAt.isAfter(dayStart) && item.startAt.isBefore(dayEnd);
}

DateTime _sortStart(AgendaItem item, DateTime day) {
  final dayStart = DateTime(day.year, day.month, day.day);
  if (item.type == ItemType.memo) {
    return dayStart.add(const Duration(hours: 23, minutes: 59));
  }
  return item.startAt.isBefore(dayStart) ? dayStart : item.startAt;
}

String _toCompactDayLine(AgendaItem item, DateTime day, bool zh) {
  final prefix = switch (item.type) {
    ItemType.schedule => zh ? '日' : 'S',
    ItemType.task => zh ? '任' : 'T',
    ItemType.memo => zh ? '备' : 'M',
    ItemType.course => zh ? '课' : 'C',
  };
  final when = _buildItemTimeText(item, day, zh);
  final title = item.title.trim().isEmpty ? (zh ? '未命名' : 'Untitled') : item.title.trim();
  return '[$prefix] $when $title';
}

String _buildItemTimeText(
  AgendaItem item,
  DateTime day,
  bool zh, {
  bool includeDay = false,
}) {
  if (item.type == ItemType.memo) {
    final minutes = item.estimatedDuration.inMinutes;
    final memoText = zh ? '全天/${minutes}分' : 'AllDay/${minutes}m';
    if (!includeDay) {
      return memoText;
    }
    return '${day.month}/${day.day} $memoText';
  }
  if (item.isAllDay) {
    final allDayText = zh ? '全天' : 'All day';
    if (!includeDay) {
      return allDayText;
    }
    return '${day.month}/${day.day} $allDayText';
  }

  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final effectiveStart = item.startAt.isBefore(dayStart) ? dayStart : item.startAt;
  final effectiveEnd = item.endAt.isAfter(dayEnd) ? dayEnd : item.endAt;
  final range = '${_formatHm(effectiveStart)}-${_formatHm(effectiveEnd)}';
  if (!includeDay) {
    return range;
  }
  return '${day.month}/${day.day} $range';
}

String _weekdayShort(bool zh, int weekday) {
  if (zh) {
    return switch (weekday) {
      DateTime.monday => '周一',
      DateTime.tuesday => '周二',
      DateTime.wednesday => '周三',
      DateTime.thursday => '周四',
      DateTime.friday => '周五',
      DateTime.saturday => '周六',
      _ => '周日',
    };
  }
  return switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    _ => 'Sun',
  };
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatWidgetTimestamp(DateTime time, bool zh) {
  final hhmm = _formatHm(time);
  return zh ? '更新于 $hhmm' : 'Updated $hhmm';
}

String _formatHm(DateTime time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _clipWidgetText(String text, {required int maxChars}) {
  final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (normalized.length <= maxChars) {
    return normalized;
  }
  return '${normalized.substring(0, maxChars - 1)}…';
}

String _toArgbHex(Color color) {
  final a = color.alpha.toRadixString(16).padLeft(2, '0').toUpperCase();
  final r = color.red.toRadixString(16).padLeft(2, '0').toUpperCase();
  final g = color.green.toRadixString(16).padLeft(2, '0').toUpperCase();
  final b = color.blue.toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#$a$r$g$b';
}

int _weekOfMonth(DateTime date) {
  final firstDay = DateTime(date.year, date.month, 1);
  final offset = firstDay.weekday - DateTime.monday;
  return ((date.day + offset - 1) ~/ 7) + 1;
}

int _weekOfYear(DateTime date) {
  final firstDay = DateTime(date.year, 1, 1);
  final offset = firstDay.weekday - DateTime.monday;
  final dayOfYear = date.difference(firstDay).inDays + 1;
  return ((dayOfYear + offset - 1) ~/ 7) + 1;
}

String? _semesterWeekLabel({
  required List<AgendaItem> timetabledCourseItems,
  required String? activeTimetableId,
  required bool zh,
}) {
  if (timetabledCourseItems.isEmpty) return null;

  final String? targetTimetableId = () {
    if (activeTimetableId != null && activeTimetableId.isNotEmpty) {
      return activeTimetableId;
    }
    final ids = <String>{
      for (final item in timetabledCourseItems) item.courseDetails.timetableId,
    };
    return ids.length == 1 ? ids.first : null;
  }();
  if (targetTimetableId == null) return null;

  DateTime? semesterFirstDay;
  for (final item in timetabledCourseItems) {
    if (item.courseDetails.timetableId != targetTimetableId) continue;
    final startDate = DateUtils.dateOnly(item.startAt);
    if (semesterFirstDay == null || startDate.isBefore(semesterFirstDay)) {
      semesterFirstDay = startDate;
    }
  }
  if (semesterFirstDay == null) return null;

  final semesterWeekOneMonday =
      semesterFirstDay.subtract(Duration(days: semesterFirstDay.weekday - DateTime.monday));
  final nowMonday = DateUtils.dateOnly(DateTime.now())
      .subtract(Duration(days: DateTime.now().weekday - DateTime.monday));
  final weekIndex = nowMonday.difference(semesterWeekOneMonday).inDays ~/ 7 + 1;
  if (weekIndex <= 0) return null;

  return zh ? '第$weekIndex周' : 'Week $weekIndex';
}

String _periodLabel(DateTime weekStart, bool zh) {
  final weekEnd = weekStart.add(const Duration(days: 6));
  if (zh) {
    return weekStart.month == weekEnd.month
        ? '${weekStart.month}月第${_weekOfMonth(weekStart)}周'
        : '${weekStart.year}年第${_weekOfYear(weekStart)}周';
  }
  if (weekStart.month == weekEnd.month) {
    return 'Week ${_weekOfMonth(weekStart)} of ${DateFormat.yMMMM('en').format(weekStart)}';
  }
  return 'Week ${_weekOfYear(weekStart)} of ${weekStart.year}';
}

String _timezoneLabel() {
  final duration = DateTime.now().timeZoneOffset;
  final sign = duration.isNegative ? '-' : '+';
  final totalMinutes = duration.inMinutes.abs();
  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return 'UTC$sign$hours:$minutes';
}
