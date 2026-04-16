import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/shared/data/mappers/agenda_item_storage_mapper.dart';
import 'package:huajuan_agenda/shared/data/mappers/course_timetable_storage_mapper.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppBootstrapData {
  const AppBootstrapData({
    required this.locale,
    required this.themeMode,
    required this.homeSettings,
    required this.aiSettings,
    required this.aiMessages,
    required this.agendaItems,
    required this.courseTimetableStore,
  });

  final Locale locale;
  final ui.ThemeMode themeMode;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
  final List<AiChatMessage> aiMessages;
  final List<AgendaItem> agendaItems;
  final CourseTimetableStore courseTimetableStore;
}

abstract final class AppBootstrapStorageKeys {
  static const locale = 'settings.locale';
  static const themeMode = 'settings.themeMode';
  static const homeSettings = 'settings.home';
  static const aiSettings = 'settings.ai';
  static const aiMessages = 'ai.messages';
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
      aiMessages: _readAiMessages(preferences),
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
      return AiSettings(
        baseUrl: json['baseUrl'] as String? ?? '',
        apiKey: json['apiKey'] as String? ?? '',
        model: json['model'] as String? ?? 'gpt-4o-mini',
        systemPrompt: json['systemPrompt'] as String? ??
            const AiSettings.defaults().systemPrompt,
      );
    } catch (_) {
      return const AiSettings.defaults();
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
