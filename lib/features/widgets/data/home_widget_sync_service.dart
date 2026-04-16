import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

abstract final class HomeWidgetIds {
  static const gridProvider = 'com.example.huajuan_agenda.widget.HuaJuanGridWidgetProvider';
  static const listProvider = 'com.example.huajuan_agenda.widget.HuaJuanListWidgetProvider';
  static const aiProvider = 'com.example.huajuan_agenda.widget.HuaJuanAiShortcutWidgetProvider';
  static const newItemProvider =
      'com.example.huajuan_agenda.widget.HuaJuanNewItemShortcutWidgetProvider';
}

abstract final class HomeWidgetStorageKeys {
  static const gridPayload = 'hj.widget.grid.payload';
  static const listPayload = 'hj.widget.list.payload';
  static const aiPayload = 'hj.widget.ai.payload';
  static const newItemPayload = 'hj.widget.newItem.payload';
}

final homeWidgetSyncServiceProvider = Provider<HomeWidgetSyncService>((ref) {
  return HomeWidgetSyncService(ref);
});

class HomeWidgetSyncService {
  HomeWidgetSyncService(this._ref);

  final Ref _ref;
  StreamSubscription<Uri?>? _clickSub;
  bool _isSyncing = false;
  bool _syncQueued = false;
  bool _initialized = false;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize(GoRouter router) async {
    if (!_supported || _initialized) {
      return;
    }
    _initialized = true;
    final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (initialUri != null) {
      _handleWidgetUri(router, initialUri);
    }
    _clickSub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        _handleWidgetUri(router, uri);
      }
    });
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

      final gridPayload = _buildGridPayload(
        items: items,
        now: now,
        locale: locale,
        darkMode: _isDarkMode(themeMode),
      );
      final listPayload = _buildListPayload(
        items: items,
        now: now,
        locale: locale,
        darkMode: _isDarkMode(themeMode),
      );
      final aiPayload = _buildAiPayload(locale: locale);
      final newItemPayload = _buildNewItemPayload(locale: locale);

      await HomeWidget.saveWidgetData<String>(
        HomeWidgetStorageKeys.gridPayload,
        jsonEncode(gridPayload),
      );
      await HomeWidget.saveWidgetData<String>(
        HomeWidgetStorageKeys.listPayload,
        jsonEncode(listPayload),
      );
      await HomeWidget.saveWidgetData<String>(
        HomeWidgetStorageKeys.aiPayload,
        jsonEncode(aiPayload),
      );
      await HomeWidget.saveWidgetData<String>(
        HomeWidgetStorageKeys.newItemPayload,
        jsonEncode(newItemPayload),
      );

      await HomeWidget.updateWidget(qualifiedAndroidName: HomeWidgetIds.gridProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: HomeWidgetIds.listProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: HomeWidgetIds.aiProvider);
      await HomeWidget.updateWidget(qualifiedAndroidName: HomeWidgetIds.newItemProvider);
    } finally {
      _isSyncing = false;
      if (_syncQueued) {
        _syncQueued = false;
        unawaited(sync());
      }
    }
  }

  void dispose() {
    final sub = _clickSub;
    _clickSub = null;
    if (sub != null) {
      unawaited(sub.cancel());
    }
  }

  void _handleWidgetUri(GoRouter router, Uri uri) {
    final path = uri.path.isEmpty ? AppRoutePaths.home : uri.path;
    final query = uri.query.isEmpty ? '' : '?${uri.query}';
    final directRoutes = <String>{
      AppRoutePaths.home,
      AppRoutePaths.list,
      AppRoutePaths.ai,
      AppRoutePaths.itemEditor,
    };
    if (directRoutes.contains(path)) {
      router.go('$path$query');
      return;
    }

    final target = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    if (target == 'ai') {
      router.go('${AppRoutePaths.ai}?focusInput=1&source=home_widget');
      return;
    }
    if (target == 'new-item') {
      router.go('${AppRoutePaths.itemEditor}?showTypePicker=1&source=home_widget');
      return;
    }
    if (target == 'list') {
      router.go('${AppRoutePaths.list}?source=home_widget');
      return;
    }
    router.go(AppRoutePaths.home);
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
      ui.ThemeMode.system => PlatformDispatcher.instance.platformBrightness == Brightness.dark,
    };
  }
}

Map<String, dynamic> _buildGridPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required Locale locale,
  required bool darkMode,
}) {
  final week = _weekRange(now);
  final weekItems = items
      .where((item) => item.type != ItemType.memo)
      .where(
        (item) => item.endAt.isAfter(week.start) && item.startAt.isBefore(week.end),
      )
      .toList(growable: false);

  final dayRows = <String>[];
  for (var i = 0; i < 7; i++) {
    final date = week.start.add(Duration(days: i));
    final count = weekItems
        .where((item) => _sameDay(item.startAt, date) || _sameDay(item.endAt, date))
        .length;
    dayRows.add('${_weekdayLabel(locale, date.weekday)} ${date.month}/${date.day}  $count');
  }

  return {
    'title': locale.languageCode.startsWith('zh') ? '本周表格概览' : 'This Week Grid',
    'subtitle': locale.languageCode.startsWith('zh')
        ? '事项 ${weekItems.length} 条'
        : '${weekItems.length} items',
    'content': dayRows.join('\n'),
    'darkMode': darkMode,
    'updatedAt': now.toIso8601String(),
  };
}

Map<String, dynamic> _buildListPayload({
  required List<AgendaItem> items,
  required DateTime now,
  required Locale locale,
  required bool darkMode,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final pending = items.where((item) => !item.isCompleted).toList()
    ..removeWhere((item) => item.type == ItemType.course)
    ..sort((a, b) {
      final aToday = _sameDay(a.startAt, today) ? 0 : 1;
      final bToday = _sameDay(b.startAt, today) ? 0 : 1;
      if (aToday != bToday) {
        return aToday.compareTo(bToday);
      }
      final byStart = a.startAt.compareTo(b.startAt);
      if (byStart != 0) {
        return byStart;
      }
      return a.manualOrder.compareTo(b.manualOrder);
    });

  final lines = [
    for (final item in pending.take(6))
      '• ${item.title.isEmpty ? (locale.languageCode.startsWith('zh') ? '未命名事项' : 'Untitled') : item.title}',
  ];

  return {
    'title': locale.languageCode.startsWith('zh') ? '今天与未完成' : 'Today & Pending',
    'subtitle': locale.languageCode.startsWith('zh')
        ? '未完成 ${pending.length} 条'
        : '${pending.length} pending',
    'content': lines.isEmpty
        ? (locale.languageCode.startsWith('zh') ? '暂无事项' : 'No items')
        : lines.join('\n'),
    'darkMode': darkMode,
    'updatedAt': now.toIso8601String(),
  };
}

Map<String, dynamic> _buildAiPayload({required Locale locale}) {
  return {
    'title': locale.languageCode.startsWith('zh') ? 'AI 交互' : 'AI Chat',
    'subtitle': locale.languageCode.startsWith('zh')
        ? '点击直达输入框'
        : 'Tap to open input',
  };
}

Map<String, dynamic> _buildNewItemPayload({required Locale locale}) {
  return {
    'title': locale.languageCode.startsWith('zh') ? '新建事项' : 'New Item',
    'subtitle': locale.languageCode.startsWith('zh')
        ? '打开后先选择类型'
        : 'Pick type after opening',
  };
}

DateTimeRange _weekRange(DateTime now) {
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - DateTime.monday));
  return DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _weekdayLabel(Locale locale, int weekday) {
  final zh = locale.languageCode.startsWith('zh');
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
