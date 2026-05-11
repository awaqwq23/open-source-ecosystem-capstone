import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/settings/domain/models/ai_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';

export 'package:luotopia/core/storage/shared_preferences_provider.dart';

final appHomeSettingsProvider = StateProvider<HomeSettings>((ref) {
  return const HomeSettings.defaults();
});

final appAiSettingsProvider = StateProvider<AiSettings>((ref) {
  return const AiSettings.defaults();
});

final appWidgetSettingsProvider = StateProvider<WidgetSettings>((ref) {
  return const WidgetSettings.defaults();
});

final appNavigationSettingsProvider = StateProvider<NavigationSettings>((ref) {
  return const NavigationSettings.defaults();
});
