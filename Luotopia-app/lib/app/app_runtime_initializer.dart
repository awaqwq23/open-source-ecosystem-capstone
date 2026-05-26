import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/theme/theme_controller.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/components/home_widgets/data/home_widget_sync_service.dart';
import 'package:luotopia/features/unified_pull/pull.dart';
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

class _AppRuntimeInitializerState extends ConsumerState<AppRuntimeInitializer> with WidgetsBindingObserver {
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _handleForegroundResume();
    }
  }

  void _handleForegroundResume() {
    final auth = ref.read(luotopiaAuthProvider);
    if (auth.status != LuotopiaAuthStatus.authenticated) return;
    unawaited(ref.read(unifiedPullServiceProvider).pullSilent());
    _syncAgendaDebounced();
  }

  Future<void> _setup() async {
    if (_initialized || !mounted) {
      return;
    }
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);

    final service = ref.read(homeWidgetSyncServiceProvider);
    _homeWidgetSyncService = service;
    await service.initialize();
    _subs.add(
      ref.listenManual(agendaItemRepositoryProvider, (_, _) {
        service.syncDebounced();
        _syncAgendaDebounced();
      }),
    );
    _subs.add(
      ref.listenManual(courseTimetableRepositoryProvider, (_, _) {
        service.syncDebounced();
        _syncAgendaDebounced();
      }),
    );
    _subs.add(
      ref.listenManual(appHomeSettingsProvider, (_, _) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appWidgetSettingsProvider, (_, _) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appLocaleProvider, (_, _) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(appThemeModeProvider, (_, _) => service.syncDebounced()),
    );
    _subs.add(
      ref.listenManual(luotopiaAuthProvider, (_, next) {
        if (next.status == LuotopiaAuthStatus.authenticated &&
            next.accessToken != null &&
            next.accessToken!.isNotEmpty &&
            next.user != null &&
            next.user!.id.isNotEmpty) {
          _onAuthenticated(next);
        } else {
          ref.read(agendaSyncServiceProvider).resetCapability();
        }
      }),
    );
    // 首次同步尝试（如果已认证）
    _syncAgendaDebounced();
  }

  void _onAuthenticated(LuotopiaAuthState auth) {
    final userId = auth.user!.id;
    // 统一拉取：一次请求获取所有信息
    unawaited(_performPull(auth));
    // 同时保留同步触发（但能力检测会从 pull 结果获取）
    ref.read(agendaSyncServiceProvider).syncDebounced(
          accessToken: auth.accessToken!,
          userId: userId,
          delay: const Duration(milliseconds: 300),
        );
  }

  Future<void> _performPull(LuotopiaAuthState auth) async {
    final result = await ref.read(unifiedPullServiceProvider).pullFull();
    if (result.isSuccess && result.response != null) {
      final data = result.response!;
      // 同步能力从拉取结果获取
      if (data.sync != null) {
        ref.read(agendaSyncServiceProvider).applyCapability(
              userId: auth.user!.id,
              enabled: data.sync!.enabled,
            );
      }
    }
  }

  void _syncAgendaDebounced() {
    final auth = ref.read(luotopiaAuthProvider);
    final token = auth.accessToken;
    final userId = auth.user?.id;
    if (auth.status != LuotopiaAuthStatus.authenticated ||
        token == null ||
        token.isEmpty ||
        userId == null ||
        userId.isEmpty) {
      return;
    }
    ref
        .read(agendaSyncServiceProvider)
        .syncDebounced(accessToken: token, userId: userId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
