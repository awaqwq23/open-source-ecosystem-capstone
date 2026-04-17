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
  startupProbe.startStage('main_bootstrap');
  WidgetsFlutterBinding.ensureInitialized();
  startupProbe.markOnce('widgets_binding_ready');
  startupProbe.installFrameTimingObserver();
  startupProbe.startStage('android_bridge_bootstrap');
  startupProbe.startStage('shared_preferences_get_instance');
  final androidBridgeFuture = startupProbe.bootstrapAndroidStart().whenComplete(() {
    startupProbe.endStage('android_bridge_bootstrap');
  });
  final preferencesFuture = SharedPreferences.getInstance().whenComplete(() {
    startupProbe.endStage('shared_preferences_get_instance');
  });
  final preferences = await preferencesFuture;
  await androidBridgeFuture;
  startupProbe.startStage('load_critical_startup_settings');
  final startup = AppBootstrapLoader.loadCriticalStartupSettings(preferences);
  startupProbe.endStage('load_critical_startup_settings');
  startupProbe.markOnce('shared_preferences_minimal_ready');
  startupProbe.markOnce('startup_settings_ready');

  startupProbe.markOnce('run_app_called');
  startupProbe.startStage('run_app_provider_scope_build');
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
  startupProbe.endStage('run_app_provider_scope_build');
  startupProbe.endStage('main_bootstrap');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    startupProbe.markOnce('first_post_frame_callback');
  });
}
