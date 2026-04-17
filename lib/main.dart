import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/app/app_runtime_initializer.dart';
import 'package:huajuan_agenda/app/app.dart';
import 'package:huajuan_agenda/core/perf/startup_perf_probe.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/ai/data/ai_in_memory_data_source.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/navigation_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/models/widget_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final startupProbe = StartupPerfProbe.instance;
  startupProbe.startMainStopwatchIfNeeded();
  startupProbe.markOnce('main_enter');
  WidgetsFlutterBinding.ensureInitialized();
  startupProbe.markOnce('widgets_binding_ready');
  startupProbe.installFrameTimingObserver();
  await startupProbe.bootstrapAndroidStart();

  final preferences = await SharedPreferences.getInstance();
  final startup = AppBootstrapLoader.loadCriticalStartupSettings(preferences);
  startupProbe.markOnce('shared_preferences_minimal_ready');
  startupProbe.markOnce('startup_settings_ready');

  startupProbe.markOnce('run_app_called');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appLocaleProvider.overrideWith((ref) => startup.locale),
        appThemeModeProvider.overrideWith((ref) => startup.themeMode),
        appHomeSettingsProvider.overrideWith((ref) => startup.homeSettings),
        appAiSettingsProvider.overrideWith((ref) => const AiSettings.defaults()),
        appWidgetSettingsProvider.overrideWith((ref) => const WidgetSettings.defaults()),
        appNavigationSettingsProvider.overrideWith((ref) => const NavigationSettings.defaults()),
        aiChatBootstrapMessagesProvider.overrideWithValue(const []),
        agendaItemsBootstrapProvider.overrideWithValue(const []),
        courseTimetableBootstrapProvider.overrideWithValue(
          const CourseTimetableStore(timetables: []),
        ),
      ],
      child: AppRuntimeInitializer(
        preferences: preferences,
        child: HuaJuanAgendaApp(),
      ),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    startupProbe.markOnce('first_post_frame_callback');
  });
}
