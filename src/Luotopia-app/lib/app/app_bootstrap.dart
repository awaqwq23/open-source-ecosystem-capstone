import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/features/pages/ai/data/ai_chat_session_storage_mapper.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/features/pages/settings/domain/models/ai_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
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
    required this.aiChatSessionStore,
  });

  final Locale locale;
  final ui.ThemeMode themeMode;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;
  final AiChatSessionStore aiChatSessionStore;
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
      aiChatSessionStore: _readAiChatSessionStore(preferences),
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
        gridMode: switch (json['gridMode']) {
          'courseGrid' => HomeGridMode.courseGrid,
          _ => HomeGridMode.timeGrid,
        },
        itemOpacityPercent: (json['itemOpacityPercent'] as int? ?? 100).clamp(
          0,
          100,
        ),
        firstDayOfWeek: switch (json['firstDayOfWeek'] as String?) {
          'tuesday' => FirstDayOfWeek.tuesday,
          'wednesday' => FirstDayOfWeek.wednesday,
          'thursday' => FirstDayOfWeek.thursday,
          'friday' => FirstDayOfWeek.friday,
          'saturday' => FirstDayOfWeek.saturday,
          'sunday' => FirstDayOfWeek.sunday,
          'today' => FirstDayOfWeek.today,
          _ => FirstDayOfWeek.monday,
        },
      );
    } catch (_) {
      return const HomeSettings.defaults();
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
        followAppLanguage: json['followAppLanguage'] as bool? ?? true,
        followAppTheme: json['followAppTheme'] as bool? ?? true,
      );
    } catch (_) {
      return const WidgetSettings.defaults();
    }
  }

  static NavigationSettings _readNavigationSettings(
    SharedPreferences preferences,
  ) {
    final raw = preferences.getString(
      AppBootstrapStorageKeys.navigationSettings,
    );
    if (raw == null || raw.isEmpty) {
      return const NavigationSettings.defaults();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return NavigationSettings(
        showLabels: json['showLabels'] as bool? ?? false,
        middleTabMode: switch (json['middleTabMode'] as String?) {
          'ai' => MiddleTabMode.ai,
          _ => MiddleTabMode.forum,
        },
        defaultTab: json['defaultTab'] as String? ?? '/',
      );
    } catch (_) {
      return const NavigationSettings.defaults();
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
        model: json['model'] as String? ?? '',
        systemPrompt: json['systemPrompt'] as String? ?? '',
      );
    } catch (_) {
      return const AiSettings.defaults();
    }
  }

  static AiChatSessionStore _readAiChatSessionStore(
    SharedPreferences preferences,
  ) {
    return AiChatSessionStorageMapper.fromStorage(
      sessionsRaw: preferences.getString(AppBootstrapStorageKeys.aiSessions),
      activeSessionId: preferences.getString(
        AppBootstrapStorageKeys.activeAiSessionId,
      ),
    );
  }

}
