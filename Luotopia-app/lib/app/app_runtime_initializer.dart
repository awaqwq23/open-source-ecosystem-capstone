import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/theme/theme_controller.dart';
import 'package:luotopia/features/hot_update/data/hot_update_service.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/components/home_widgets/data/home_widget_sync_service.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/data/sync/sync_service.dart';

class AppRuntimeInitializer extends ConsumerStatefulWidget {
  const AppRuntimeInitializer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AppRuntimeInitializer> createState() => _AppRuntimeInitializerState();
}

final hotUpdateServiceProvider = Provider<HotUpdateService>((ref) {
  return HotUpdateService();
});

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
    // 初始化热更新服务（后台检查脚本更新）
    ref.read(hotUpdateServiceProvider).initialize();

    final service = ref.read(homeWidgetSyncServiceProvider);
    _homeWidgetSyncService = service;
    await service.initialize();
    _subs.add(
      ref.listenManual(agendaItemRepositoryProvider, (_, __) {
        service.syncDebounced();
        _syncAgendaDebounced();
      }),
    );
    _subs.add(
      ref.listenManual(courseTimetableRepositoryProvider, (_, __) {
        service.syncDebounced();
        _syncAgendaDebounced();
      }),
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
    _subs.add(
      ref.listenManual(luotopiaAuthProvider, (_, next) {
        if (next.status == LuotopiaAuthStatus.authenticated &&
            next.accessToken != null &&
            next.accessToken!.isNotEmpty) {
          ref.read(agendaSyncServiceProvider).syncDebounced(
                next.accessToken!,
                delay: const Duration(milliseconds: 300),
              );
        }
      }),
    );
    _syncAgendaDebounced();
  }

  void _syncAgendaDebounced() {
    final auth = ref.read(luotopiaAuthProvider);
    final token = auth.accessToken;
    if (auth.status != LuotopiaAuthStatus.authenticated ||
        token == null ||
        token.isEmpty) {
      return;
    }
    ref.read(agendaSyncServiceProvider).syncDebounced(token);
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
