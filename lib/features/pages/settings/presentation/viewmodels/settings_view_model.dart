import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/pages/settings/domain/repositories/settings_repository_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.homeSettings,
    required this.widgetSettings,
    required this.navigationSettings,
  });

  final ui.ThemeMode themeMode;
  final Locale locale;
  final HomeSettings homeSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;

  SettingsState copyWith({
    ui.ThemeMode? themeMode,
    Locale? locale,
    HomeSettings? homeSettings,
    WidgetSettings? widgetSettings,
    NavigationSettings? navigationSettings,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      homeSettings: homeSettings ?? this.homeSettings,
      widgetSettings: widgetSettings ?? this.widgetSettings,
      navigationSettings: navigationSettings ?? this.navigationSettings,
    );
  }
}

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final repository = ref.read(settingsRepositoryProvider);
    return SettingsState(
      themeMode: repository.themeMode,
      locale: repository.locale,
      homeSettings: ref.watch(appHomeSettingsProvider),
      widgetSettings: ref.watch(appWidgetSettingsProvider),
      navigationSettings: ref.watch(appNavigationSettingsProvider),
    );
  }

  Future<void> selectTheme(ui.ThemeMode mode) async {
    await ref.read(settingsRepositoryProvider).saveThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> selectLocale(Locale locale) async {
    await ref.read(settingsRepositoryProvider).saveLocale(locale);
    state = state.copyWith(locale: locale);
  }

  Future<void> saveHomeSettings(HomeSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveHomeSettings(settings);
    state = state.copyWith(homeSettings: settings);
  }

  Future<void> saveWidgetSettings(WidgetSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveWidgetSettings(settings);
    state = state.copyWith(widgetSettings: settings);
  }

  Future<void> saveNavigationSettings(NavigationSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveNavigationSettings(settings);
    state = state.copyWith(navigationSettings: settings);
  }

}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
