import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/app/app_runtime_initializer.dart';
import 'package:huajuan_agenda/app/app.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/ai/data/ai_in_memory_data_source.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_course_timetable_repository.dart';
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
        appWidgetSettingsProvider.overrideWith((ref) => bootstrap.widgetSettings),
        aiChatBootstrapMessagesProvider.overrideWithValue(bootstrap.aiMessages),
        agendaItemsBootstrapProvider.overrideWithValue(bootstrap.agendaItems),
        courseTimetableBootstrapProvider.overrideWithValue(bootstrap.courseTimetableStore),
      ],
      child: const AppRuntimeInitializer(
        child: HuaJuanAgendaApp(),
      ),
    ),
  );
}
