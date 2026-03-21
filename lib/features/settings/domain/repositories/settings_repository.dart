import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

abstract class SettingsRepository {
  ui.ThemeMode get themeMode;
  Locale get locale;
  HomeSettings get homeSettings;
  Future<void> saveThemeMode(ui.ThemeMode mode);
  Future<void> saveLocale(Locale locale);
  Future<void> saveHomeSettings(HomeSettings settings);
}
