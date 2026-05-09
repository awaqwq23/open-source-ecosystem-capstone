import 'package:flutter/material.dart';
import 'package:luotopia/features/pages/settings/domain/models/ai_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

abstract class SettingsRepository {
  ui.ThemeMode get themeMode;
  Locale get locale;
  HomeSettings get homeSettings;
  AiSettings get aiSettings;
  WidgetSettings get widgetSettings;
  NavigationSettings get navigationSettings;
  Future<void> saveThemeMode(ui.ThemeMode mode);
  Future<void> saveLocale(Locale locale);
  Future<void> saveHomeSettings(HomeSettings settings);
  Future<void> saveAiSettings(AiSettings settings);
  Future<void> saveWidgetSettings(WidgetSettings settings);
  Future<void> saveNavigationSettings(NavigationSettings settings);
}
