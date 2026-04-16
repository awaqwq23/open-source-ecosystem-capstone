import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appHomeSettingsProvider = StateProvider<HomeSettings>((ref) {
  return const HomeSettings.defaults();
});

final appAiSettingsProvider = StateProvider<AiSettings>((ref) {
  return const AiSettings.defaults();
});

final appWidgetSettingsProvider = StateProvider<WidgetSettings>((ref) {
  return const WidgetSettings.defaults();
});

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  return null;
});
