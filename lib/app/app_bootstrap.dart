import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/navigation_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:huajuan_agenda/shared/data/mappers/agenda_item_storage_mapper.dart';
import 'package:huajuan_agenda/shared/data/mappers/course_timetable_storage_mapper.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
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
    required this.aiSessionStore,
    required this.agendaItems,
    required this.courseTimetableStore,
  });

  final Locale locale;
  final ui.ThemeMode themeMode;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;
  final AiChatSessionStore aiSessionStore;
  final List<AgendaItem> agendaItems;
  final CourseTimetableStore courseTimetableStore;
}

abstract final class AppBootstrapStorageKeys {
  static const locale = 'settings.locale';
  static const themeMode = 'settings.themeMode';
  static const homeSettings = 'settings.home';
  static const aiSettings = 'settings.ai';
  static const widgetSettings = 'settings.widget';
  static const navigationSettings = 'settings.navigation';
  static const aiSessions = 'ai.sessions';
  static const activeAiSessionId = 'ai.activeSessionId';
  static const agendaItems = 'agenda.items';
  static const courseTimetables = 'course.timetables';
  static const activeCourseTimetableId = 'course.activeTimetableId';
  static const whuCourseCookieHeader = 'course.whu.cookieHeader';
}

class AppBootstrapLoader {
  const AppBootstrapLoader._();

  static Future<AppBootstrapData> load(SharedPreferences preferences) async {
    return AppBootstrapData(
      locale: _readLocale(preferences),
      themeMode: _readThemeMode(preferences),
      homeSettings: _readHomeSettings(preferences),
      aiSettings: _readAiSettings(preferences),
      widgetSettings: _readWidgetSettings(preferences),
      navigationSettings: _readNavigationSettings(preferences),
      aiSessionStore: _readAiSessionStore(preferences),
      agendaItems: _readAgendaItems(preferences),
      courseTimetableStore: _readCourseTimetableStore(preferences),
    );
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

  static AiChatSessionStore _readAiSessionStore(SharedPreferences preferences) {
    final raw = preferences.getString(AppBootstrapStorageKeys.aiSessions);
    final activeSessionId = preferences.getString(AppBootstrapStorageKeys.activeAiSessionId);
    if (raw == null || raw.isEmpty) {
      return _emptyAiSessionStore();
    }

    try {
      final json = jsonDecode(raw) as List<dynamic>;
      return _decodeAiSessionStore(
        _castJsonObjectList(json),
        activeSessionId,
      );
    } catch (_) {
      return _emptyAiSessionStore();
    }
  }

  static AiChatSessionStore _decodeAiSessionStore(
    List<Map<String, dynamic>> sessionsJson,
    String? activeSessionId,
  ) {
    final sessions = [
      for (final item in sessionsJson) _decodeAiSession(item),
    ].whereType<AiChatSession>().toList(growable: false)
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));

    if (sessions.isEmpty) {
      return _emptyAiSessionStore();
    }

    final normalizedActiveId =
        activeSessionId != null && sessions.any((session) => session.id == activeSessionId)
            ? activeSessionId
            : sessions.first.id;
    return AiChatSessionStore(
      sessions: sessions,
      activeSessionId: normalizedActiveId,
    );
  }

  static AiChatSession? _decodeAiSession(Map<String, dynamic> item) {
    final id = item['id'] as String? ?? '';
    if (id.isEmpty) {
      return null;
    }
    final createdAt = DateTime.tryParse(item['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final messages = [
      for (final message in (item['messages'] as List<dynamic>? ?? const []))
        if (message is Map<String, dynamic>) _decodeAiMessage(message, id),
    ].whereType<AiChatMessage>().toList(growable: false)
      ..sort((left, right) => left.createdAt.compareTo(right.createdAt));
    final fallbackUpdatedAt = messages.isEmpty ? createdAt : messages.last.createdAt;
    return AiChatSession(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.tryParse(item['updatedAt'] as String? ?? '') ?? fallbackUpdatedAt,
      messages: messages,
    );
  }

  static AiChatMessage? _decodeAiMessage(
    Map<String, dynamic> item,
    String fallbackSessionId,
  ) {
    final id = item['id'] as String? ?? '';
    if (id.isEmpty) {
      return null;
    }
    return AiChatMessage(
      id: id,
      sessionId: item['sessionId'] as String? ?? fallbackSessionId,
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
    );
  }

  static AiChatSessionStore _emptyAiSessionStore() {
    const sessionId = 'session_initial';
    final now = DateTime.now();
    return AiChatSessionStore(
      sessions: [
        AiChatSession(
          id: sessionId,
          createdAt: now,
          updatedAt: now,
          messages: const [],
        ),
      ],
      activeSessionId: sessionId,
    );
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
}
