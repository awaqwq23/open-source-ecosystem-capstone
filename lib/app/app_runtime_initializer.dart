import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/perf/startup_perf_probe.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/ai/data/ai_in_memory_data_source.dart';
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
  bool _fullHydrateScheduled = false;

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
    unawaited(_hydrateBootstrapData(service));
  }

  Future<void> _loadNonCriticalStartupSettings() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final settings = AppBootstrapLoader.loadNonCriticalStartupSettings(widget.preferences);
      ref.read(appAiSettingsProvider.notifier).state = settings.aiSettings;
      ref.read(appWidgetSettingsProvider.notifier).state = settings.widgetSettings;
      ref.read(appNavigationSettingsProvider.notifier).state = settings.navigationSettings;
      StartupPerfProbe.instance.markOnce('shared_preferences_noncritical_ready');
    });
  }

  Future<void> _hydrateBootstrapData(HomeWidgetSyncService service) async {
    final probe = StartupPerfProbe.instance;
    probe.markOnce('home_minimal_hydrate_start');
    ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.homeMinimalHydrating;
    try {
      probe.markOnce('home_minimal_payload_decode_start');
      final now = DateUtils.dateOnly(DateTime.now());
      final weekStart = now.subtract(Duration(days: now.weekday - DateTime.monday));
      final weekEndExclusive = weekStart.add(const Duration(days: 7));
      final minimalPayload = await AppBootstrapLoader.loadHomeMinimalPayloadInBackground(
        widget.preferences,
        weekStart: weekStart,
        weekEndExclusive: weekEndExclusive,
      );
      probe.markOnce(
        'home_minimal_payload_decode_end',
        extras: <String, Object?>{
          'agenda_json_count': minimalPayload.agendaItemsJson.length,
        },
      );
      if (!mounted) {
        return;
      }
      probe.markOnce('home_minimal_agenda_hydrate_start');
      await ref
          .read(agendaItemRepositoryProvider.notifier)
          .hydrateMinimalFromSerializedBootstrap(minimalPayload.agendaItemsJson);
      probe.markOnce('home_minimal_agenda_hydrate_end');
      ref
          .read(courseTimetableRepositoryProvider.notifier)
          .hydrateActiveTimetableFromBootstrapHint(minimalPayload.activeCourseTimetableId);
      probe.markOnce('home_minimal_course_hint_ready');
    } finally {
      if (mounted) {
        ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.homeMinimalReady;
        probe.markOnce('home_minimal_ready');
      }
    }
    if (mounted) {
      service.syncDebounced();
    }
    _scheduleDeferredHydration(service);
  }

  void _scheduleDeferredHydration(HomeWidgetSyncService service) {
    if (_fullHydrateScheduled || !mounted) {
      return;
    }
    _fullHydrateScheduled = true;
    final probe = StartupPerfProbe.instance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      probe.markOnce('full_hydrate_scheduled_after_first_frame');
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!mounted) {
          return;
        }
        unawaited(_hydrateDeferredBootstrapData(service));
      });
    });
  }

  Future<void> _hydrateDeferredBootstrapData(HomeWidgetSyncService service) async {
    final probe = StartupPerfProbe.instance;
    probe.markOnce('full_hydrate_actual_start');
    probe.markOnce('deferred_hydrate_start');
    if (mounted) {
      ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.fullHydrating;
    }
    try {
      probe.markOnce('deferred_payload_decode_start');
      final payload = await AppBootstrapLoader.loadDeferredPayloadInBackground(widget.preferences);
      probe.markOnce(
        'deferred_payload_decode_end',
        extras: <String, Object?>{
          'agenda_json_count': payload.agendaItemsJson.length,
          'course_json_count': payload.courseTimetablesJson.length,
          'ai_json_count': payload.aiMessagesJson.length,
        },
      );
      if (!mounted) {
        return;
      }
      probe.markOnce('agenda_hydrate_start');
      await ref
          .read(agendaItemRepositoryProvider.notifier)
          .hydrateRemainingFromSerializedBootstrap(payload.agendaItemsJson);
      probe.markOnce('agenda_hydrate_end');
      probe.markOnce('course_hydrate_start');
      await ref
          .read(courseTimetableRepositoryProvider.notifier)
          .hydrateRemainingFromSerializedBootstrap(
            timetablesJson: payload.courseTimetablesJson,
            activeTimetableId: payload.activeCourseTimetableId,
          );
      probe.markOnce('course_hydrate_end');
      probe.markOnce('ai_hydrate_start');
      await ref
          .read(aiChatRepositoryProvider.notifier)
          .hydrateFromSerializedBootstrap(payload.aiMessagesJson);
      probe.markOnce('ai_hydrate_end');
    } finally {
      if (mounted) {
        ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.ready;
        probe.markOnce('home_full_ready');
        probe.markOnce('bootstrap_phase_ready');
      }
    }
    if (mounted) {
      service.syncDebounced();
    }
    probe.markOnce('deferred_hydrate_end');
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
