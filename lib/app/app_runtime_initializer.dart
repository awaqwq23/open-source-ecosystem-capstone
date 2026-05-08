import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/features/widgets/data/home_widget_sync_service.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';

class AppRuntimeInitializer extends ConsumerStatefulWidget {
  const AppRuntimeInitializer({
    required this.child,
    super.key,
  });

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
