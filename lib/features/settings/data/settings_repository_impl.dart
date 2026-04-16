import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/navigation_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class RiverpodSettingsRepository implements SettingsRepository {
  const RiverpodSettingsRepository(this._ref);

  final Ref _ref;

  @override
  Locale get locale => _ref.read(appLocaleProvider);

  @override
  ui.ThemeMode get themeMode => _ref.read(appThemeModeProvider);

  @override
  HomeSettings get homeSettings => _ref.read(appHomeSettingsProvider);

  @override
  AiSettings get aiSettings => _ref.read(appAiSettingsProvider);

  @override
  WidgetSettings get widgetSettings => _ref.read(appWidgetSettingsProvider);

  @override
  NavigationSettings get navigationSettings => _ref.read(appNavigationSettingsProvider);

  @override
  Future<void> saveLocale(Locale locale) async {
    _ref.read(appLocaleProvider.notifier).state = locale;
    await _prefs?.setString(AppBootstrapStorageKeys.locale, locale.languageCode);
  }

  @override
  Future<void> saveThemeMode(ui.ThemeMode mode) async {
    _ref.read(appThemeModeProvider.notifier).state = mode;
    await _prefs?.setString(AppBootstrapStorageKeys.themeMode, mode.name);
  }

  @override
  Future<void> saveHomeSettings(HomeSettings settings) async {
    _ref.read(appHomeSettingsProvider.notifier).state = settings;
    await _prefs?.setString(
      AppBootstrapStorageKeys.homeSettings,
      jsonEncode({
        'startHour': settings.dayStartTime.hour,
        'startMinute': settings.dayStartTime.minute,
        'blockDurationMinutes': settings.blockDurationMinutes,
        'blockGapMinutes': settings.blockGapMinutes,
        'blockCount': settings.blockCount,
        'wideLayoutScope': settings.wideLayoutScope.name,
        'showDemoData': settings.showDemoData,
        'itemOpacityPercent': settings.itemOpacityPercent,
      }),
    );
  }

  @override
  Future<void> saveAiSettings(AiSettings settings) async {
    _ref.read(appAiSettingsProvider.notifier).state = settings;
    await _prefs?.setString(
      AppBootstrapStorageKeys.aiSettings,
      jsonEncode({
        'baseUrl': settings.baseUrl,
        'apiKey': settings.apiKey,
        'model': settings.model,
        'systemPrompt': settings.systemPrompt,
      }),
    );
  }

  @override
  Future<void> saveWidgetSettings(WidgetSettings settings) async {
    _ref.read(appWidgetSettingsProvider.notifier).state = settings;
    await _prefs?.setString(
      AppBootstrapStorageKeys.widgetSettings,
      jsonEncode({
        'enabled': settings.enabled,
        'refreshInterval': settings.refreshInterval.name,
        'gridShowThisWeek': settings.gridShowThisWeek,
        'listShowTodayAndPending': settings.listShowTodayAndPending,
        'followAppLanguage': settings.followAppLanguage,
        'followAppTheme': settings.followAppTheme,
      }),
    );
  }

  @override
  Future<void> saveNavigationSettings(NavigationSettings settings) async {
    _ref.read(appNavigationSettingsProvider.notifier).state = settings;
    await _prefs?.setString(
      AppBootstrapStorageKeys.navigationSettings,
      jsonEncode({
        'showLabels': settings.showLabels,
      }),
    );
  }

  SharedPreferences? get _prefs => _ref.read(sharedPreferencesProvider);
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return RiverpodSettingsRepository(ref);
});
