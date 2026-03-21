import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/settings/data/settings_repository_impl.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.homeSettings,
    required this.aiSettings,
  });

  final ui.ThemeMode themeMode;
  final Locale locale;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final repository = ref.read(settingsRepositoryProvider);
    return SettingsState(
      themeMode: repository.themeMode,
      locale: repository.locale,
      homeSettings: ref.watch(appHomeSettingsProvider),
      aiSettings: ref.watch(appAiSettingsProvider),
    );
  }

  Future<void> selectTheme(ui.ThemeMode mode) async {
    await ref.read(settingsRepositoryProvider).saveThemeMode(mode);
    state = SettingsState(
      themeMode: mode,
      locale: state.locale,
      homeSettings: state.homeSettings,
      aiSettings: state.aiSettings,
    );
  }

  Future<void> selectLocale(Locale locale) async {
    await ref.read(settingsRepositoryProvider).saveLocale(locale);
    state = SettingsState(
      themeMode: state.themeMode,
      locale: locale,
      homeSettings: state.homeSettings,
      aiSettings: state.aiSettings,
    );
  }

  Future<void> saveHomeSettings(HomeSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveHomeSettings(settings);
    state = SettingsState(
      themeMode: state.themeMode,
      locale: state.locale,
      homeSettings: settings,
      aiSettings: state.aiSettings,
    );
  }

  Future<void> saveAiSettings(AiSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveAiSettings(settings);
    state = SettingsState(
      themeMode: state.themeMode,
      locale: state.locale,
      homeSettings: state.homeSettings,
      aiSettings: settings,
    );
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
