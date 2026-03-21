import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/repositories/settings_repository.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

final appHomeSettingsProvider = StateProvider<HomeSettings>((ref) {
  return const HomeSettings.defaults();
});

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
  Future<void> saveLocale(Locale locale) async {
    _ref.read(appLocaleProvider.notifier).state = locale;
  }

  @override
  Future<void> saveThemeMode(ui.ThemeMode mode) async {
    _ref.read(appThemeModeProvider.notifier).state = mode;
  }

  @override
  Future<void> saveHomeSettings(HomeSettings settings) async {
    _ref.read(appHomeSettingsProvider.notifier).state = settings;
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return RiverpodSettingsRepository(ref);
});
