import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/settings/data/settings_repository_impl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.locale,
  });

  final ui.ThemeMode themeMode;
  final Locale locale;
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final repository = ref.read(settingsRepositoryProvider);
    return SettingsState(
      themeMode: repository.themeMode,
      locale: repository.locale,
    );
  }

  Future<void> selectTheme(ui.ThemeMode mode) async {
    await ref.read(settingsRepositoryProvider).saveThemeMode(mode);
    state = SettingsState(
      themeMode: mode,
      locale: state.locale,
    );
  }

  Future<void> selectLocale(Locale locale) async {
    await ref.read(settingsRepositoryProvider).saveLocale(locale);
    state = SettingsState(
      themeMode: state.themeMode,
      locale: locale,
    );
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
