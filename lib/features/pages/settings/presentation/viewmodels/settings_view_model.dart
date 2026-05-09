import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:luotopia/features/pages/settings/domain/models/ai_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/pages/settings/domain/repositories/settings_repository_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

enum SettingsAiConnectionStatus {
  idle,
  testing,
  success,
  failure,
}

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.locale,
    required this.homeSettings,
    required this.aiSettings,
    required this.widgetSettings,
    required this.navigationSettings,
    this.aiConnectionStatus = SettingsAiConnectionStatus.idle,
    this.aiConnectionMessage,
  });

  final ui.ThemeMode themeMode;
  final Locale locale;
  final HomeSettings homeSettings;
  final AiSettings aiSettings;
  final WidgetSettings widgetSettings;
  final NavigationSettings navigationSettings;
  final SettingsAiConnectionStatus aiConnectionStatus;
  final String? aiConnectionMessage;

  SettingsState copyWith({
    ui.ThemeMode? themeMode,
    Locale? locale,
    HomeSettings? homeSettings,
    AiSettings? aiSettings,
    WidgetSettings? widgetSettings,
    NavigationSettings? navigationSettings,
    SettingsAiConnectionStatus? aiConnectionStatus,
    String? aiConnectionMessage,
    bool clearAiConnectionMessage = false,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      homeSettings: homeSettings ?? this.homeSettings,
      aiSettings: aiSettings ?? this.aiSettings,
      widgetSettings: widgetSettings ?? this.widgetSettings,
      navigationSettings: navigationSettings ?? this.navigationSettings,
      aiConnectionStatus: aiConnectionStatus ?? this.aiConnectionStatus,
      aiConnectionMessage: clearAiConnectionMessage
          ? null
          : (aiConnectionMessage ?? this.aiConnectionMessage),
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
      aiSettings: ref.watch(appAiSettingsProvider),
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

  Future<void> saveAiSettings(AiSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveAiSettings(settings);
    state = state.copyWith(
      aiSettings: settings,
      aiConnectionStatus: SettingsAiConnectionStatus.idle,
      clearAiConnectionMessage: true,
    );
  }

  Future<void> saveWidgetSettings(WidgetSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveWidgetSettings(settings);
    state = state.copyWith(widgetSettings: settings);
  }

  Future<void> saveNavigationSettings(NavigationSettings settings) async {
    await ref.read(settingsRepositoryProvider).saveNavigationSettings(settings);
    state = state.copyWith(navigationSettings: settings);
  }

  Future<void> testAiConnection(AiSettings settings) async {
    state = state.copyWith(
      aiConnectionStatus: SettingsAiConnectionStatus.testing,
      clearAiConnectionMessage: true,
    );

    try {
      await ref.read(aiServiceProvider).validateConnection(settings: settings);
      state = state.copyWith(
        aiConnectionStatus: SettingsAiConnectionStatus.success,
        aiConnectionMessage: 'AI 连接测试成功。',
      );
    } on OpenAiConfigurationException catch (error) {
      state = state.copyWith(
        aiConnectionStatus: SettingsAiConnectionStatus.failure,
        aiConnectionMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        aiConnectionStatus: SettingsAiConnectionStatus.failure,
        aiConnectionMessage: '连接失败：$error',
      );
    }
  }
}

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, SettingsState>(
  SettingsViewModel.new,
);
