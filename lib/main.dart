import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/app/app.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/ai/data/ai_in_memory_data_source.dart';
import 'package:huajuan_agenda/features/settings/data/settings_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final bootstrap = await AppBootstrapLoader.load(preferences);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appLocaleProvider.overrideWith((ref) => bootstrap.locale),
        appThemeModeProvider.overrideWith((ref) => bootstrap.themeMode),
        appHomeSettingsProvider.overrideWith((ref) => bootstrap.homeSettings),
        appAiSettingsProvider.overrideWith((ref) => bootstrap.aiSettings),
        aiChatBootstrapMessagesProvider.overrideWithValue(bootstrap.aiMessages),
      ],
      child: const HuaJuanAgendaApp(),
    ),
  );
}
