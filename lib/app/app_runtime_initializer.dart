import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/ai/data/ai_in_memory_data_source.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/features/widgets/data/home_widget_sync_service.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppBootstrapPhase {
  startup,
  hydrating,
  ready,
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
    unawaited(_hydrateDeferredBootstrapData(service));
  }

  Future<void> _hydrateDeferredBootstrapData(HomeWidgetSyncService service) async {
    ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.hydrating;
    try {
      final payload = await AppBootstrapLoader.loadDeferredPayloadInBackground(widget.preferences);
      if (!mounted) {
        return;
      }
      await ref
          .read(agendaItemRepositoryProvider.notifier)
          .hydrateFromSerializedBootstrap(payload.agendaItemsJson);
      await ref
          .read(courseTimetableRepositoryProvider.notifier)
          .hydrateFromSerializedBootstrap(
            timetablesJson: payload.courseTimetablesJson,
            activeTimetableId: payload.activeCourseTimetableId,
          );
      await ref
          .read(aiChatRepositoryProvider.notifier)
          .hydrateFromSerializedBootstrap(payload.aiMessagesJson);
    } finally {
      if (mounted) {
        ref.read(appBootstrapPhaseProvider.notifier).state = AppBootstrapPhase.ready;
      }
    }
    if (mounted) {
      service.syncDebounced();
    }
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
