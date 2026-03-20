import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

abstract class SettingsRepository {
  ui.ThemeMode get themeMode;
  Locale get locale;
  Future<void> saveThemeMode(ui.ThemeMode mode);
  Future<void> saveLocale(Locale locale);
}
