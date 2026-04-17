import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return HomeWidgetSyncService(ref);
});

class HomeWidgetSyncService {
  HomeWidgetSyncService(this._ref);

  static const MethodChannel _channel = MethodChannel('huajuan/widget_sync');

  final Ref _ref;
  bool _isSyncing = false;
  bool _syncQueued = false;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize() async {
    if (!_supported) {
      return;
    }
    await sync();
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
      final now = DateTime.now();
      final week = _weekRange(now);

      final payload = <String, dynamic>{
        'version': 4,
        'meta': {
          'languageCode': languageCode,
          'darkMode': _isDarkMode(themeMode),
          'timezone': _timezoneLabel(),
          'updatedAt': now.toIso8601String(),
          'updatedLabel': _formatWidgetTimestamp(now, zh),
        },
        'aiEntry': {
          'title': zh ? 'AI 快速进入' : 'AI Quick Entry',
          'subtitle': zh ? '点击进入 AI 页' : 'Tap to open AI page',
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
        ),
        'weekGrid': _buildWeekGridPayload(
          items: items,
          week: week,
          now: now,
          zh: zh,
        ),
      };

      await _channel.invokeMethod<void>('syncWidgets', payload);
    } finally {
      _isSyncing = false;
      if (_syncQueued) {
        _syncQueued = false;
        unawaited(sync());
      }
    }
  }

  void dispose() {}

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
}) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  final hasCourseToday = items.any(
    (item) => item.type == ItemType.course && _itemInDay(item, today),
  );

  final leftDay = hasCourseToday ? today : tomorrow;
  final rightStart = leftDay.add(const Duration(days: 1));

  final leftItems = items
      .where((item) => _shouldShowInLeftColumn(item, now: now, leftDay: leftDay))
      .toList(growable: false)
    ..sort((a, b) {
      final byStart = _sortStart(a, leftDay).compareTo(_sortStart(b, leftDay));
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });

  final rightItems = items
      .where((item) => _shouldShowInRightColumn(item, now: now, rightStart: rightStart))
      .toList(growable: false)
    ..sort((a, b) {
      final dayA = _displayDayForItem(a, fallback: rightStart);
      final dayB = _displayDayForItem(b, fallback: rightStart);
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
    'subtitle': hasCourseToday
        ? (zh ? '左列今天，右列今天之后（右列无课程）' : 'Left today, right after today (no course on right)')
        : (zh ? '左列明天，右列明天之后（右列无课程）' : 'Left tomorrow, right after tomorrow (no course on right)'),
    'mode': hasCourseToday ? 'today_future' : 'tomorrow_future',
    'leftTitle': hasCourseToday ? (zh ? '今天' : 'Today') : (zh ? '明天' : 'Tomorrow'),
    'rightTitle': hasCourseToday ? (zh ? '今天之后' : 'After Today') : (zh ? '明天之后' : 'After Tomorrow'),
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
          _displayDayForItem(item, fallback: rightStart),
          zh,
          darkMode: darkMode,
          includeDay: true,
        ),
    ],
    'weekdayLabel': _weekdayLong(zh, leftDay.weekday),
    'weekLabel': zh ? '第${_weekOfYear(leftDay)}周' : 'Week ${_weekOfYear(leftDay)}',
  };
}

bool _shouldShowInLeftColumn(
  AgendaItem item, {
  required DateTime now,
  required DateTime leftDay,
}) {
  if (item.isCompleted) {
    return false;
  }
  if (!_itemInDay(item, leftDay)) {
    return false;
  }
  if (item.type == ItemType.course) {
    return true;
  }
  final today = DateTime(now.year, now.month, now.day);
  if (_isSameDay(leftDay, today) && item.type != ItemType.memo) {
    return item.endAt.isAfter(now);
  }
  return true;
}

bool _shouldShowInRightColumn(
  AgendaItem item, {
  required DateTime now,
  required DateTime rightStart,
}) {
  if (item.isCompleted) {
    return false;
  }
  if (item.type == ItemType.course) {
    return false;
  }
  if (!_itemIntersects(item, rightStart, rightStart.add(const Duration(days: 3650)))) {
    return false;
  }
  if (item.type != ItemType.memo && !item.endAt.isAfter(now)) {
    return false;
  }
  return true;
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
    'title': zh ? '周视图表格' : 'Week Grid',
    'subtitle': zh
        ? '${week.start.month}/${week.start.day}-${week.end.month}/${week.end.day}'
        : '${week.start.month}/${week.start.day}-${week.end.month}/${week.end.day}',
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

bool _itemIntersects(AgendaItem item, DateTime start, DateTime endExclusive) {
  if (item.type == ItemType.memo) {
    final date = DateTime(item.targetDate.year, item.targetDate.month, item.targetDate.day);
    return !date.isBefore(start) && date.isBefore(endExclusive);
  }
  return item.endAt.isAfter(start) && item.startAt.isBefore(endExclusive);
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

String _weekdayLong(bool zh, int weekday) {
  if (zh) {
    return switch (weekday) {
      DateTime.monday => '星期一',
      DateTime.tuesday => '星期二',
      DateTime.wednesday => '星期三',
      DateTime.thursday => '星期四',
      DateTime.friday => '星期五',
      DateTime.saturday => '星期六',
      _ => '星期日',
    };
  }
  return switch (weekday) {
    DateTime.monday => 'Monday',
    DateTime.tuesday => 'Tuesday',
    DateTime.wednesday => 'Wednesday',
    DateTime.thursday => 'Thursday',
    DateTime.friday => 'Friday',
    DateTime.saturday => 'Saturday',
    _ => 'Sunday',
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

int _weekOfYear(DateTime date) {
  final firstDay = DateTime(date.year, 1, 1);
  final offset = firstDay.weekday - DateTime.monday;
  final dayOfYear = date.difference(firstDay).inDays + 1;
  return ((dayOfYear + offset - 1) ~/ 7) + 1;
}

String _timezoneLabel() {
  final duration = DateTime.now().timeZoneOffset;
  final sign = duration.isNegative ? '-' : '+';
  final totalMinutes = duration.inMinutes.abs();
  final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
  return 'UTC$sign$hours:$minutes';
}
