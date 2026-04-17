import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/navigation_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:huajuan_agenda/shared/data/mappers/agenda_item_storage_mapper.dart';
import 'package:huajuan_agenda/shared/data/mappers/course_timetable_storage_mapper.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppBootstrapData {
  const AppBootstrapData({
    required this.locale,
    required this.themeMode,
    required this.homeSettings,
    required this.aiSettings,
    required this.widgetSettings,
    required this.navigationSettings,
    required this.aiMessages,
    required this.agendaItems,
    required this.courseTimetableStore,
  });

  final Locale locale;
  final ui.ThemeMode themeMode;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;
  final List<AiChatMessage> aiMessages;
  final List<AgendaItem> agendaItems;
  final CourseTimetableStore courseTimetableStore;
}

class AppStartupSettingsData {
  const AppStartupSettingsData({
    required this.locale,
    required this.themeMode,
    required this.homeSettings,
    required this.aiSettings,
    required this.widgetSettings,
    required this.navigationSettings,
  });

  final Locale locale;
  final ui.ThemeMode themeMode;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;
}

class AppCriticalStartupSettingsData {
  const AppCriticalStartupSettingsData({
    required this.locale,
    required this.themeMode,
    required this.homeSettings,
  });

  final Locale locale;
  final ui.ThemeMode themeMode;
  final HomeSettings homeSettings;
}

class AppNonCriticalStartupSettingsData {
  const AppNonCriticalStartupSettingsData({
    required this.aiSettings,
    required this.widgetSettings,
    required this.navigationSettings,
  });

  final AiSettings aiSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;
}

class AppDeferredBootstrapData {
  const AppDeferredBootstrapData({
    required this.aiMessages,
    required this.agendaItems,
    required this.courseTimetableStore,
  });

  final List<AiChatMessage> aiMessages;
  final List<AgendaItem> agendaItems;
  final CourseTimetableStore courseTimetableStore;
}

class AppDeferredBootstrapPayload {
  const AppDeferredBootstrapPayload({
    required this.aiMessagesJson,
    required this.agendaItemsJson,
    required this.courseTimetablesJson,
    required this.activeCourseTimetableId,
  });

  final List<Map<String, dynamic>> aiMessagesJson;
  final List<Map<String, dynamic>> agendaItemsJson;
  final List<Map<String, dynamic>> courseTimetablesJson;
  final String? activeCourseTimetableId;
}

class AppHomeMinimalBootstrapPayload {
  const AppHomeMinimalBootstrapPayload({
    required this.agendaItemsJson,
    required this.activeCourseTimetableId,
  });

  final List<Map<String, dynamic>> agendaItemsJson;
  final String? activeCourseTimetableId;
}

abstract final class AppBootstrapStorageKeys {
  static const locale = 'settings.locale';
  static const themeMode = 'settings.themeMode';
  static const homeSettings = 'settings.home';
  static const aiSettings = 'settings.ai';
  static const widgetSettings = 'settings.widget';
  static const navigationSettings = 'settings.navigation';
  static const aiMessages = 'ai.messages';
  static const agendaItems = 'agenda.items';
  static const agendaItemsCurrentWeek = 'agenda.items.currentWeek';
  static const agendaItemsCurrentWeekStart = 'agenda.items.currentWeek.start';
  static const courseTimetables = 'course.timetables';
  static const activeCourseTimetableId = 'course.activeTimetableId';
  static const whuCourseCookieHeader = 'course.whu.cookieHeader';
}

class AppBootstrapLoader {
  const AppBootstrapLoader._();

  static Future<AppBootstrapData> load(SharedPreferences preferences) async {
    final startup = loadStartupSettings(preferences);
    final deferred = loadDeferredData(preferences);
    return AppBootstrapData(
      locale: startup.locale,
      themeMode: startup.themeMode,
      homeSettings: startup.homeSettings,
      aiSettings: startup.aiSettings,
      widgetSettings: startup.widgetSettings,
      navigationSettings: startup.navigationSettings,
      aiMessages: deferred.aiMessages,
      agendaItems: deferred.agendaItems,
      courseTimetableStore: deferred.courseTimetableStore,
    );
  }

  static AppStartupSettingsData loadStartupSettings(SharedPreferences preferences) {
    return AppStartupSettingsData(
      locale: _readLocale(preferences),
      themeMode: _readThemeMode(preferences),
      homeSettings: _readHomeSettings(preferences),
      aiSettings: _readAiSettings(preferences),
      widgetSettings: _readWidgetSettings(preferences),
      navigationSettings: _readNavigationSettings(preferences),
    );
  }

  static AppDeferredBootstrapData loadDeferredData(SharedPreferences preferences) {
    return AppDeferredBootstrapData(
      aiMessages: _readAiMessages(preferences),
      agendaItems: _readAgendaItems(preferences),
      courseTimetableStore: _readCourseTimetableStore(preferences),
    );
  }

  static Future<AppDeferredBootstrapPayload> loadDeferredPayloadInBackground(
    SharedPreferences preferences,
  ) async {
    final rawPayload = <String, String?>{
      AppBootstrapStorageKeys.aiMessages:
          preferences.getString(AppBootstrapStorageKeys.aiMessages),
      AppBootstrapStorageKeys.agendaItems:
          preferences.getString(AppBootstrapStorageKeys.agendaItems),
      AppBootstrapStorageKeys.courseTimetables:
          preferences.getString(AppBootstrapStorageKeys.courseTimetables),
      AppBootstrapStorageKeys.activeCourseTimetableId:
          preferences.getString(AppBootstrapStorageKeys.activeCourseTimetableId),
    };
    final decoded = await compute(_decodeDeferredPayloadRaw, rawPayload);
    final activeId = decoded[AppBootstrapStorageKeys.activeCourseTimetableId] as String?;
    return AppDeferredBootstrapPayload(
      aiMessagesJson: _castJsonObjectList(decoded[AppBootstrapStorageKeys.aiMessages]),
      agendaItemsJson: _castJsonObjectList(decoded[AppBootstrapStorageKeys.agendaItems]),
      courseTimetablesJson: _castJsonObjectList(
        decoded[AppBootstrapStorageKeys.courseTimetables],
      ),
      activeCourseTimetableId: (activeId == null || activeId.isEmpty) ? null : activeId,
    );
  }

  static AppCriticalStartupSettingsData loadCriticalStartupSettings(
    SharedPreferences preferences,
  ) {
    return AppCriticalStartupSettingsData(
      locale: _readLocale(preferences),
      themeMode: _readThemeMode(preferences),
      homeSettings: _readHomeSettings(preferences),
    );
  }

  static AppNonCriticalStartupSettingsData loadNonCriticalStartupSettings(
    SharedPreferences preferences,
  ) {
    return AppNonCriticalStartupSettingsData(
      aiSettings: _readAiSettings(preferences),
      widgetSettings: _readWidgetSettings(preferences),
      navigationSettings: _readNavigationSettings(preferences),
    );
  }

  static Future<AppHomeMinimalBootstrapPayload> loadHomeMinimalPayloadInBackground(
    SharedPreferences preferences, {
    required DateTime weekStart,
    required DateTime weekEndExclusive,
  }) async {
    final rawPayload = <String, String?>{
      AppBootstrapStorageKeys.agendaItems:
          preferences.getString(AppBootstrapStorageKeys.agendaItems),
      AppBootstrapStorageKeys.agendaItemsCurrentWeek:
          preferences.getString(AppBootstrapStorageKeys.agendaItemsCurrentWeek),
      AppBootstrapStorageKeys.agendaItemsCurrentWeekStart:
          preferences.getString(AppBootstrapStorageKeys.agendaItemsCurrentWeekStart),
      AppBootstrapStorageKeys.activeCourseTimetableId:
          preferences.getString(AppBootstrapStorageKeys.activeCourseTimetableId),
      'weekStartIso': weekStart.toIso8601String(),
      'weekEndIso': weekEndExclusive.toIso8601String(),
    };
    final decoded = await compute(_decodeHomeMinimalPayloadRaw, rawPayload);
    final activeId = decoded[AppBootstrapStorageKeys.activeCourseTimetableId] as String?;
    return AppHomeMinimalBootstrapPayload(
      agendaItemsJson: _castJsonObjectList(decoded[AppBootstrapStorageKeys.agendaItems]),
      activeCourseTimetableId: (activeId == null || activeId.isEmpty) ? null : activeId,
    );
  }

  static List<Map<String, dynamic>> _castJsonObjectList(Object? value) {
    final raw = value;
    if (raw is! List<dynamic>) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map<Object?, Object?>)
          item.map(
            (key, value) => MapEntry(
              key is String ? key : key.toString(),
              value,
            ),
          ),
    ];
  }

  static Locale _readLocale(SharedPreferences preferences) {
    final code = preferences.getString(AppBootstrapStorageKeys.locale);
    return switch (code) {
      'en' => AppLocale.english.locale,
      'zh' => AppLocale.chinese.locale,
      _ => AppLocale.chinese.locale,
    };
  }

  static ui.ThemeMode _readThemeMode(SharedPreferences preferences) {
    final value = preferences.getString(AppBootstrapStorageKeys.themeMode);
    return switch (value) {
      'light' => ui.ThemeMode.light,
      'dark' => ui.ThemeMode.dark,
      _ => ui.ThemeMode.system,
    };
  }

  static HomeSettings _readHomeSettings(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.homeSettings);
    if (raw == null || raw.isEmpty) {
      return const HomeSettings.defaults();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return HomeSettings(
        dayStartTime: TimeOfDay(
          hour: json['startHour'] as int? ?? 8,
          minute: json['startMinute'] as int? ?? 0,
        ),
        blockDurationMinutes: json['blockDurationMinutes'] as int? ?? 60,
        blockGapMinutes: json['blockGapMinutes'] as int? ?? 0,
        blockCount: json['blockCount'] as int? ?? 12,
        wideLayoutScope: switch (json['wideLayoutScope']) {
          'month' => HomeWideLayoutScope.month,
          _ => HomeWideLayoutScope.week,
        },
        showDemoData: json['showDemoData'] as bool? ?? false,
        itemOpacityPercent:
            ((json['itemOpacityPercent'] as int? ?? 100).clamp(0, 100) as int),
      );
    } catch (_) {
      return const HomeSettings.defaults();
    }
  }

  static AiSettings _readAiSettings(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.aiSettings);
    if (raw == null || raw.isEmpty) {
      return const AiSettings.defaults();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      const defaults = AiSettings.defaults();
      return AiSettings(
        baseUrl: json['baseUrl'] as String? ?? defaults.baseUrl,
        apiKey: json['apiKey'] as String? ?? '',
        model: json['model'] as String? ?? defaults.model,
        systemPrompt: json['systemPrompt'] as String? ?? defaults.systemPrompt,
      );
    } catch (_) {
      return const AiSettings.defaults();
    }
  }

  static WidgetSettings _readWidgetSettings(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.widgetSettings);
    if (raw == null || raw.isEmpty) {
      return const WidgetSettings.defaults();
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WidgetSettings(
        enabled: json['enabled'] as bool? ?? true,
        refreshInterval: switch (json['refreshInterval']) {
          'minutes30' => WidgetRefreshInterval.minutes30,
          'hours3' => WidgetRefreshInterval.hours3,
          _ => WidgetRefreshInterval.hour1,
        },
        gridShowThisWeek: json['gridShowThisWeek'] as bool? ?? true,
        listShowTodayAndPending: json['listShowTodayAndPending'] as bool? ?? true,
        followAppLanguage: json['followAppLanguage'] as bool? ?? true,
        followAppTheme: json['followAppTheme'] as bool? ?? true,
      );
    } catch (_) {
      return const WidgetSettings.defaults();
    }
  }

  static NavigationSettings _readNavigationSettings(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.navigationSettings);
    if (raw == null || raw.isEmpty) {
      return const NavigationSettings.defaults();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NavigationSettings(
        showLabels: json['showLabels'] as bool? ?? false,
      );
    } catch (_) {
      return const NavigationSettings.defaults();
    }
  }

  static List<AiChatMessage> _readAiMessages(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.aiMessages);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final json = jsonDecode(raw) as List<dynamic>;
      return json
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => AiChatMessage(
              id: item['id'] as String? ?? '',
              content: item['content'] as String? ?? '',
              createdAt: DateTime.tryParse(item['createdAt'] as String? ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              role: switch (item['role']) {
                'assistant' => AiChatRole.assistant,
                _ => AiChatRole.user,
              },
              kind: switch (item['kind']) {
                'answer' => AiMessageKind.answer,
                'system' => AiMessageKind.system,
                _ => AiMessageKind.chat,
              },
              citations: [
                for (final citation in (item['citations'] as List<dynamic>? ?? const []))
                  if (citation is Map<String, dynamic>)
                    AiCitation(
                      itemId: citation['itemId'] as String? ?? '',
                      title: citation['title'] as String? ?? '',
                      type: switch (citation['type']) {
                        'task' => ItemType.task,
                        'memo' => ItemType.memo,
                        'course' => ItemType.course,
                        _ => ItemType.schedule,
                      },
                      startAt: DateTime.tryParse(citation['startAt'] as String? ?? ''),
                      endAt: DateTime.tryParse(citation['endAt'] as String? ?? ''),
                      reason: citation['reason'] as String?,
                    ),
              ].where((citation) => citation.itemId.isNotEmpty).toList(growable: false),
            ),
          )
          .where((message) => message.id.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static List<AgendaItem> _readAgendaItems(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.agendaItems);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final json = jsonDecode(raw) as List<dynamic>;
      return json
          .whereType<Map<String, dynamic>>()
          .map(AgendaItemStorageMapper.fromJson)
          .whereType<AgendaItem>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static CourseTimetableStore _readCourseTimetableStore(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.courseTimetables);
    final rawActiveId = preferences.getString(AppBootstrapStorageKeys.activeCourseTimetableId);
    if (raw == null || raw.isEmpty) {
      return CourseTimetableStore(
        timetables: const [],
        activeTimetableId: (rawActiveId == null || rawActiveId.isEmpty) ? null : rawActiveId,
      );
    }

    try {
      final json = jsonDecode(raw) as List<dynamic>;
      final timetables = json
          .whereType<Map<String, dynamic>>()
          .map(CourseTimetableStorageMapper.fromJson)
          .whereType<CourseTimetable>()
          .toList(growable: false);
      final activeId = (rawActiveId == null || rawActiveId.isEmpty) ? null : rawActiveId;
      final normalizedActiveId = activeId != null &&
              timetables.any((timetable) => timetable.id == activeId)
          ? activeId
          : (timetables.isEmpty ? null : timetables.first.id);
      return CourseTimetableStore(
        timetables: timetables,
        activeTimetableId: normalizedActiveId,
      );
    } catch (_) {
      return const CourseTimetableStore(timetables: []);
    }
  }
}

Map<String, dynamic> _decodeDeferredPayloadRaw(Map<String, String?> rawPayload) {
  List<dynamic> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      return decoded is List<dynamic> ? decoded : const [];
    } catch (_) {
      return const [];
    }
  }

  final activeIdRaw = rawPayload[AppBootstrapStorageKeys.activeCourseTimetableId];
  final activeId = (activeIdRaw == null || activeIdRaw.isEmpty) ? null : activeIdRaw;
  return <String, dynamic>{
    AppBootstrapStorageKeys.aiMessages:
        decodeList(rawPayload[AppBootstrapStorageKeys.aiMessages]),
    AppBootstrapStorageKeys.agendaItems:
        decodeList(rawPayload[AppBootstrapStorageKeys.agendaItems]),
    AppBootstrapStorageKeys.courseTimetables:
        decodeList(rawPayload[AppBootstrapStorageKeys.courseTimetables]),
    AppBootstrapStorageKeys.activeCourseTimetableId: activeId,
  };
}

Map<String, dynamic> _decodeHomeMinimalPayloadRaw(Map<String, String?> rawPayload) {
  final activeIdRaw = rawPayload[AppBootstrapStorageKeys.activeCourseTimetableId];
  final activeId = (activeIdRaw == null || activeIdRaw.isEmpty) ? null : activeIdRaw;
  final weekStart = DateTime.tryParse(rawPayload['weekStartIso'] ?? '');
  final weekEndExclusive = DateTime.tryParse(rawPayload['weekEndIso'] ?? '');
  final agendaRaw = rawPayload[AppBootstrapStorageKeys.agendaItems];
  final agendaCurrentWeekRaw = rawPayload[AppBootstrapStorageKeys.agendaItemsCurrentWeek];
  final agendaCurrentWeekStartRaw =
      rawPayload[AppBootstrapStorageKeys.agendaItemsCurrentWeekStart];

  List<dynamic> decodedAgenda = const [];
  if (agendaRaw != null && agendaRaw.isNotEmpty) {
    try {
      final decoded = jsonDecode(agendaRaw);
      if (decoded is List<dynamic>) {
        decodedAgenda = decoded;
      }
    } catch (_) {
      decodedAgenda = const [];
    }
  }

  List<dynamic> decodedCurrentWeekAgenda = const [];
  if (agendaCurrentWeekRaw != null && agendaCurrentWeekRaw.isNotEmpty) {
    try {
      final decoded = jsonDecode(agendaCurrentWeekRaw);
      if (decoded is List<dynamic>) {
        decodedCurrentWeekAgenda = decoded;
      }
    } catch (_) {
      decodedCurrentWeekAgenda = const [];
    }
  }

  bool intersectsWeek(Map<Object?, Object?> item) {
    if (weekStart == null || weekEndExclusive == null) {
      return false;
    }
    final type = item['type']?.toString() ?? '';
    if (type != 'task' && type != 'schedule' && type != 'course') {
      return false;
    }

    Object? startRaw;
    Object? endRaw;
    if (type == 'task') {
      final taskDetails = item['taskDetails'];
      if (taskDetails is Map<Object?, Object?>) {
        final schedule = taskDetails['schedule'];
        if (schedule is Map<Object?, Object?>) {
          startRaw = schedule['start'];
          endRaw = schedule['end'];
        }
      }
    } else {
      final schedule = item['scheduleDetails'];
      if (schedule is Map<Object?, Object?>) {
        startRaw = schedule['start'];
        endRaw = schedule['end'];
      }
    }

    final start = DateTime.tryParse(startRaw?.toString() ?? '');
    final end = DateTime.tryParse(endRaw?.toString() ?? '');
    if (start == null || end == null) {
      return false;
    }
    return end.isAfter(weekStart) && start.isBefore(weekEndExclusive);
  }

  final canUseCurrentWeekCache =
      weekStart != null &&
      agendaCurrentWeekRaw != null &&
      agendaCurrentWeekStartRaw != null &&
      agendaCurrentWeekStartRaw == weekStart.toIso8601String();
  final minimalAgenda = canUseCurrentWeekCache
      ? <Map<Object?, Object?>>[
          for (final item in decodedCurrentWeekAgenda)
            if (item is Map<Object?, Object?>) item,
        ]
      : <Map<Object?, Object?>>[
          for (final item in decodedAgenda)
            if (item is Map<Object?, Object?> && intersectsWeek(item)) item,
        ];

  return <String, dynamic>{
    AppBootstrapStorageKeys.agendaItems: minimalAgenda,
    AppBootstrapStorageKeys.activeCourseTimetableId: activeId,
  };
}
