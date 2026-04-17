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
  HomeWidgetSyncService? _homeWidgetSyncService;
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
    final probe = StartupPerfProbe.instance;
    probe.markOnce('runtime_setup_start');
    probe.startStage('runtime_setup_total');
    probe.markOnce('runtime_setup_end');
    probe.startStage('runtime_load_noncritical_schedule');
    unawaited(_loadNonCriticalStartupSettings());
    probe.endStage('runtime_load_noncritical_schedule');
    probe.startStage('runtime_bootstrap_phase_set_ready');
    ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.ready;
    probe.endStage('runtime_bootstrap_phase_set_ready');
    probe.markOnce('home_minimal_ready');
    probe.markOnce('home_full_ready');
    probe.markOnce('bootstrap_phase_ready');
    probe.startStage('runtime_widget_sync_deferred_schedule');
    unawaited(_setupDeferredWidgetSync());
    probe.endStage('runtime_widget_sync_deferred_schedule');
    probe.endStage('runtime_setup_total');
  }

  Future<void> _setupDeferredWidgetSync() async {
    final probe = StartupPerfProbe.instance;
    probe.mark(
      'runtime_widget_sync_deferred_wait_start',
      extras: const <String, Object?>{
        'delay_ms': 3000,
      },
    );
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) {
      probe.mark('runtime_widget_sync_deferred_cancelled');
      return;
    }

    probe.startStage('runtime_widget_sync_init_and_listeners');
    final service = ref.read(homeWidgetSyncServiceProvider);
    _homeWidgetSyncService = service;
    await service.initialize();
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
    service.syncDebounced();
    probe.endStage(
      'runtime_widget_sync_init_and_listeners',
      extras: <String, Object?>{
        'listener_count': _subs.length,
      },
    );
  }

  Future<void> _loadNonCriticalStartupSettings() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final probe = StartupPerfProbe.instance;
      probe.startStage('runtime_load_noncritical_post_frame_callback');
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
      probe.markOnce('shared_preferences_noncritical_ready');
      probe.endStage(
        'runtime_load_noncritical_post_frame_callback',
        extras: <String, Object?>{
          'has_active_timetable_hint': activeTimetableId != null && activeTimetableId.isNotEmpty,
        },
      );
    });
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.close();
    }
    _homeWidgetSyncService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
