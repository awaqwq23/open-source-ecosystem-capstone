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
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
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
        activeTimetableId: timetableStore.selectedTimetableIds.isEmpty
            ? null
            : timetableStore.selectedTimetableIds.first,
        zh: zh,
      );
      final intendedLabel = semesterWeekLabel ?? _periodLabel(week.start, zh);

      final payload = <String, dynamic>{
        'version': 4,
        'meta': {
          'languageCode': languageCode,
          'darkMode': _isDarkMode(settings, themeMode),
          'timezone': _timezoneLabel(),
          'updatedAt': now.toIso8601String(),
          'updatedLabel': _formatWidgetTimestamp(now, zh),
        },
        'agendaList': _buildAgendaListPayload(
          items: items,
          now: now,
          zh: zh,
          darkMode: _isDarkMode(settings, themeMode),
          weekSubtitle: intendedLabel,
        ),
      };

      final transport = <String, dynamic>{
        'version': 5,
        'renderedPayload': payload,
        'snapshot': _buildSnapshotPayload(
          items: items,
          timetableStore: timetableStore,
          settings: settings,
          now: now,
          languageCode: languageCode,
          darkMode: _isDarkMode(settings, themeMode),
        ),
      };

      final payloadHash = jsonEncode(transport);
      if (payloadHash == _lastPayloadHash) {
        return;
      }
      _lastPayloadHash = payloadHash;
      await _channel.invokeMethod<void>('syncWidgets', transport);
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

  bool _isDarkMode(WidgetSettings settings, ui.ThemeMode themeMode) {
    if (!settings.followAppTheme) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return switch (themeMode) {
      ui.ThemeMode.dark => true,
      ui.ThemeMode.light => false,
      ui.ThemeMode.system =>
        PlatformDispatcher.instance.platformBrightness == Brightness.dark,
    };
  }
}

Map<String, dynamic> _buildSnapshotPayload({
  required List<AgendaItem> items,
  required CourseTimetableStore timetableStore,
  required WidgetSettings settings,
  required DateTime now,
  required String languageCode,
  required bool darkMode,
}) {
  return {
    'version': 1,
    'generatedAt': now.toIso8601String(),
    'settings': {
      'enabled': settings.enabled,
      'refreshInterval': settings.refreshInterval.name,
      'languageCode': languageCode,
      'followAppLanguage': settings.followAppLanguage,
      'darkMode': darkMode,
      'followAppTheme': settings.followAppTheme,
    },
    'timetables': {
      'activeTimetableId': timetableStore.selectedTimetableIds.isEmpty
          ? ''
          : timetableStore.selectedTimetableIds.first,
      'items': [
        for (final timetable in timetableStore.timetables)
          {
            'id': timetable.id,
            'name': timetable.name,
            'termLabel': timetable.termLabel,
            'createdAt': timetable.createdAt.toIso8601String(),
          },
      ],
    },
    'items': [
      for (final item in items)
        {
          'id': item.id,
          'type': item.type.name,
          'title': item.title,
          'location': item.location,
          'isCompleted': item.isCompleted,
          'manualOrder': item.manualOrder,
          'startAt': item.startAt.toIso8601String(),
          'endAt': item.endAt.toIso8601String(),
          'isAllDay': item.isAllDay,
          'timetableId': item.courseDetails.timetableId,
          'accentColorLight': _toArgbHex(item.color.resolve(Brightness.light)),
          'accentColorDark': _toArgbHex(item.color.resolve(Brightness.dark)),
        },
    ],
  };
}

Map<String, dynamic> _buildAgendaListPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required bool zh,
  required bool darkMode,
  required String weekSubtitle,
}) {
  final today = DateTime(now.year, now.month, now.day);

  final leftItems = items
      .where((item) => _shouldShowInLeftColumn(item, now: now, day: today))
      .toList(growable: false)
    ..sort((a, b) {
      final byStart = _sortStart(a, today).compareTo(_sortStart(b, today));
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });
  final leftStatusLabel = leftItems.isEmpty
      ? (zh ? '今日无日程' : 'No schedule today')
      : (zh ? '今日日程' : 'Today');

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
    'mode': leftItems.isEmpty ? 'today_empty' : 'today_schedule',
    'leftTitle': leftStatusLabel,
    'rightTitle': zh ? '任务备忘' : 'Tasks & Memos',
    'leftRows': [
      for (final item in leftItems.take(40))
        _toAgendaListRow(
          item,
          today,
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
    return fallback;
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
    return true;
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

String _buildItemTimeText(
  AgendaItem item,
  DateTime day,
  bool zh, {
  bool includeDay = false,
}) {
  if (item.type == ItemType.memo) {
    return zh ? '备忘' : 'Memo';
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
