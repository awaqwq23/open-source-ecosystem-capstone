import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      final themeMode = _ref.read(appThemeModeProvider);
      final items = _ref.read(agendaItemRepositoryProvider);
      final now = DateTime.now();
      final zh = locale.languageCode.startsWith('zh');

      final payload = <String, dynamic>{
        'meta': {
          'languageCode': locale.languageCode,
          'darkMode': _isDarkMode(themeMode),
          'updatedAt': now.toIso8601String(),
          'updatedLabel': _formatWidgetTimestamp(now, zh),
        },
        'ai': {
          'title': zh ? 'AI 快速入口' : 'AI Entry',
          'subtitle': zh ? '点击直达 AI 页面' : 'Tap to open AI page',
        },
        'quickCreate': {
          'title': zh ? '快速创建事项' : 'Quick Create',
          'newItemLabel': zh ? '新建事项' : 'New Item',
          'scheduleLabel': zh ? '日程' : 'Schedule',
          'taskLabel': zh ? '任务' : 'Task',
          'memoLabel': zh ? '备忘' : 'Memo',
        },
        'list': _buildListWidgetPayload(items: items, now: now, zh: zh),
        'weekList': _buildWeekListWidgetPayload(items: items, now: now, zh: zh),
        'weekGrid': _buildWeekGridWidgetPayload(items: items, now: now, zh: zh),
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
      ui.ThemeMode.system => PlatformDispatcher.instance.platformBrightness == Brightness.dark,
    };
  }
}

Map<String, dynamic> _buildListWidgetPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required bool zh,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final endDay = today.add(const Duration(days: 7));
  final filtered = items
      .where((item) => item.type != ItemType.course)
      .where((item) => _itemIntersects(item, today, endDay))
      .toList(growable: false)
    ..sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final byStart = _sortStart(a, today).compareTo(_sortStart(b, today));
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });

  final todayOpen = filtered.where((item) => !item.isCompleted && _itemInDay(item, today)).length;
  final rows = [
    for (final item in filtered.take(80)) _toListRow(item, today, zh),
  ];

  return {
    'title': zh ? '事项列表' : 'Agenda List',
    'subtitle': zh
        ? '今日未完成 $todayOpen 条 · 未来 7 天'
        : '$todayOpen open today · next 7 days',
    'rows': rows,
  };
}

Map<String, dynamic> _buildWeekListWidgetPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required bool zh,
}) {
  final week = _weekRange(now);
  final rows = <String>[];
  final filtered = items.where((item) => item.type != ItemType.course);

  for (var i = 0; i < 7; i++) {
    final day = week.start.add(Duration(days: i));
    final dayItems = [
      for (final item in filtered)
        if (_itemInDay(item, day)) item,
    ]..sort((a, b) => _sortStart(a, day).compareTo(_sortStart(b, day)));

    rows.add('${_weekdayLabel(zh, day.weekday)} ${day.month}/${day.day} (${dayItems.length})');
    for (final item in dayItems.take(6)) {
      rows.add('  ${_toCompactDayLine(item, day, zh)}');
    }
  }

  return {
    'title': zh ? '周视图（列表版）' : 'Week View (List)',
    'subtitle': zh ? '${week.start.month}/${week.start.day}-${week.end.month}/${week.end.day}' : '${week.start.month}/${week.start.day}-${week.end.month}/${week.end.day}',
    'rows': rows,
  };
}

Map<String, dynamic> _buildWeekGridWidgetPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required bool zh,
}) {
  final week = _weekRange(now);
  final filtered = items.where((item) => item.type != ItemType.course).toList(growable: false);
  final headers = <String>[];
  final cells = <String>[];
  final rows = <String>[];

  for (var i = 0; i < 7; i++) {
    final day = week.start.add(Duration(days: i));
    final dayItems = filtered.where((item) => _itemInDay(item, day)).toList(growable: false);
    headers.add(_weekdayShort(zh, day.weekday));
    cells.add('${day.month}/${day.day}\n${dayItems.length}');

    final top = dayItems.take(2).map((item) => _toCompactDayLine(item, day, zh)).join(' | ');
    if (top.isNotEmpty) {
      rows.add('${_weekdayShort(zh, day.weekday)} $top');
    }
  }

  return {
    'title': zh ? '周视图（表格版）' : 'Week View (Grid)',
    'subtitle': zh ? '本周事项总览' : 'Weekly overview',
    'headers': headers,
    'cells': cells,
    'rows': rows,
  };
}

DateTimeRange _weekRange(DateTime now) {
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - DateTime.monday));
  final inclusiveEnd = start.add(const Duration(days: 6));
  return DateTimeRange(start: start, end: inclusiveEnd);
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

String _toListRow(AgendaItem item, DateTime today, bool zh) {
  final typeLabel = switch (item.type) {
    ItemType.schedule => zh ? '日程' : 'Sch',
    ItemType.task => zh ? '任务' : 'Task',
    ItemType.memo => zh ? '备忘' : 'Memo',
    ItemType.course => zh ? '课程' : 'Course',
  };
  final status = item.isCompleted
      ? (zh ? '已完成' : 'Done')
      : (item.isImportant ? (zh ? '重要' : 'Important') : (zh ? '待办' : 'Open'));
  final when = _buildItemTimeText(item, today, zh);
  final title = item.title.trim().isEmpty ? (zh ? '未命名事项' : 'Untitled') : item.title.trim();
  return '[$typeLabel][$status] $when $title';
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

String _buildItemTimeText(AgendaItem item, DateTime day, bool zh) {
  if (item.type == ItemType.memo) {
    final minutes = item.estimatedDuration.inMinutes;
    return zh ? '全天/${minutes}分' : 'AllDay/${minutes}m';
  }
  if (item.isAllDay) {
    return zh ? '全天' : 'All day';
  }
  final dayStart = DateTime(day.year, day.month, day.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final effectiveStart = item.startAt.isBefore(dayStart) ? dayStart : item.startAt;
  final effectiveEnd = item.endAt.isAfter(dayEnd) ? dayEnd : item.endAt;
  return '${_formatHm(effectiveStart)}-${_formatHm(effectiveEnd)}';
}

String _weekdayShort(bool zh, int weekday) {
  if (zh) {
    return switch (weekday) {
      DateTime.monday => '一',
      DateTime.tuesday => '二',
      DateTime.wednesday => '三',
      DateTime.thursday => '四',
      DateTime.friday => '五',
      DateTime.saturday => '六',
      _ => '日',
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

String _weekdayLabel(bool zh, int weekday) {
  if (zh) {
    return '周${_weekdayShort(true, weekday)}';
  }
  return _weekdayShort(false, weekday);
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
