import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/perf/startup_perf_probe.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/features/widgets/data/home_widget_sync_service.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppBootstrapPhase {
  startup,
  homeMinimalHydrating,
  homeMinimalReady,
  fullHydrating,
  ready,
}

extension AppBootstrapPhaseX on AppBootstrapPhase {
  bool get hasHomeMinimalData =>
      this == AppBootstrapPhase.homeMinimalReady ||
      this == AppBootstrapPhase.fullHydrating ||
      this == AppBootstrapPhase.ready;

  bool get hasFullData => this == AppBootstrapPhase.ready;
}

final appBootstrapPhaseProvider = StateProvider<AppBootstrapPhase>((ref) {
  return AppBootstrapPhase.startup;
});

class AppRuntimeInitializer extends ConsumerStatefulWidget {
  const AppRuntimeInitializer({
    required this.preferences,
    required this.child,
    super.key,
  });

  final SharedPreferences preferences;
  final Widget child;

  @override
  ConsumerState<AppRuntimeInitializer> createState() => _AppRuntimeInitializerState();
}

class _AppRuntimeInitializerState extends ConsumerState<AppRuntimeInitializer> {
  final List<ProviderSubscription<dynamic>> _subs = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setup();
    });
  }

  Future<void> _setup() async {
    if (_initialized || !mounted) {
      return;
    }
    _initialized = true;
    StartupPerfProbe.instance.markOnce('runtime_setup_start');
    final service = ref.read(homeWidgetSyncServiceProvider);
    unawaited(service.initialize());
    _subs.add(
      ref.listenManual(agendaItemRepositoryProvider, (_, __) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appHomeSettingsProvider, (_, __) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appWidgetSettingsProvider, (_, __) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appLocaleProvider, (_, __) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appThemeModeProvider, (_, __) => service.syncDebounced()),
    );
    StartupPerfProbe.instance.markOnce('runtime_setup_end');
    unawaited(_loadNonCriticalStartupSettings());
    ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.ready;
    StartupPerfProbe.instance.markOnce('home_minimal_ready');
    StartupPerfProbe.instance.markOnce('home_full_ready');
    StartupPerfProbe.instance.markOnce('bootstrap_phase_ready');
    service.syncDebounced();
  }

  Future<void> _loadNonCriticalStartupSettings() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final settings = AppBootstrapLoader.loadNonCriticalStartupSettings(widget.preferences);
      final activeTimetableId = widget.preferences.getString(
        AppBootstrapStorageKeys.activeCourseTimetableId,
      );
      ref.read(appAiSettingsProvider.notifier).state = settings.aiSettings;
      ref.read(appWidgetSettingsProvider.notifier).state = settings.widgetSettings;
      ref.read(appNavigationSettingsProvider.notifier).state = settings.navigationSettings;
      ref
          .read(courseTimetableRepositoryProvider.notifier)
          .hydrateActiveTimetableFromBootstrapHint(activeTimetableId);
      StartupPerfProbe.instance.markOnce('shared_preferences_noncritical_ready');
    });
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.close();
    }
    ref.read(homeWidgetSyncServiceProvider).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
