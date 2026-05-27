import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/notification/presentation/providers/notification_providers.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';
import 'package:luotopia/features/weather/presentation/providers/weather_providers.dart';
import 'package:luotopia/shared/data/sync/sync_service.dart';
import 'package:luotopia/shared/data/sync/sync_state_providers.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsDataUpdatesPage extends ConsumerStatefulWidget {
  const SettingsDataUpdatesPage({super.key});

  @override
  ConsumerState<SettingsDataUpdatesPage> createState() => _SettingsDataUpdatesPageState();
}

class _SettingsDataUpdatesPageState extends ConsumerState<SettingsDataUpdatesPage> {
  bool _weatherRefreshing = false;
  bool _notificationRefreshing = false;
  bool _hotUpdateChecking = false;
  bool _syncing = false;
  String? _syncMessage;

  @override
  Widget build(BuildContext context) {
    final luotopiaAuth = ref.watch(luotopiaAuthProvider);
    final syncEnabled = ref.watch(syncCapabilityProvider).valueOrNull == true;
    final pendingSyncCount = ref.watch(pendingSyncChangeCountProvider).valueOrNull ?? 0;
    final lastSyncedAt = ref.watch(lastSyncTimeProvider);

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: '数据更新'),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            SettingsFlatSection(
              title: '信息传达',
              children: [
                SettingsFlatTile(
                  title: '天气',
                  subtitle: '刷新武汉大学天气缓存',
                  leading: const Icon(Icons.wb_sunny_outlined),
                  trailing: _ActionIconButton(
                    loading: _weatherRefreshing,
                    icon: Icons.refresh,
                    onPressed: () => unawaited(_refreshWeather()),
                  ),
                ),
                SettingsFlatTile(
                  title: '服务通知',
                  subtitle: '检查并刷新已发布通知列表',
                  leading: const Icon(Icons.campaign_outlined),
                  trailing: _ActionIconButton(
                    loading: _notificationRefreshing,
                    icon: Icons.refresh,
                    onPressed: () => unawaited(_refreshNotifications()),
                  ),
                ),
                SettingsFlatTile(
                  title: '热更新脚本',
                  subtitle: '检查校园服务脚本版本',
                  leading: const Icon(Icons.code_outlined),
                  trailing: _ActionIconButton(
                    loading: _hotUpdateChecking,
                    icon: Icons.refresh,
                    onPressed: () => unawaited(_checkHotUpdate()),
                  ),
                ),
              ],
            ),
            if (syncEnabled)
              SettingsFlatSection(
                title: '用户数据同步',
                children: [
                  SettingsFlatTile(
                    title: '事项同步',
                    subtitle: _syncSubtitle(pendingSyncCount, lastSyncedAt),
                    leading: const Icon(Icons.sync_outlined),
                    trailing: _ActionIconButton(
                      loading: _syncing,
                      icon: Icons.sync,
                      onPressed: () => unawaited(_syncNow(luotopiaAuth)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshWeather() async {
    if (_weatherRefreshing) {
      return;
    }
    setState(() => _weatherRefreshing = true);
    await ref.read(weatherProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    setState(() => _weatherRefreshing = false);
    _showMessage('天气已刷新');
  }

  Future<void> _refreshNotifications() async {
    if (_notificationRefreshing) {
      return;
    }
    setState(() => _notificationRefreshing = true);
    await ref.read(notificationProvider.notifier).checkLatest();
    await ref.read(notificationProvider.notifier).loadList();
    if (!mounted) {
      return;
    }
    setState(() => _notificationRefreshing = false);
    _showMessage('服务通知已刷新');
  }

  Future<void> _checkHotUpdate() async {
    if (_hotUpdateChecking) {
      return;
    }
    setState(() => _hotUpdateChecking = true);
    final result = await ref.read(unifiedPullServiceProvider).pullScoped(
      trigger: 'manual',
      scopes: const ['hot_update'],
    );
    if (!mounted) {
      return;
    }
    setState(() => _hotUpdateChecking = false);
    final scripts = result.response?.hotUpdate?.scripts.values;
    final changed = scripts?.where((script) => script.changed).length ?? 0;
    _showMessage(result.isSuccess ? '已检查脚本更新：$changed 项有更新' : '脚本更新检查失败');
  }

  Future<void> _syncNow(LuotopiaAuthState auth) async {
    final token = auth.accessToken;
    final userId = auth.user?.id;
    if (auth.status != LuotopiaAuthStatus.authenticated ||
        token == null ||
        token.isEmpty ||
        userId == null ||
        userId.isEmpty ||
        _syncing) {
      return;
    }
    setState(() {
      _syncing = true;
      _syncMessage = null;
    });
    try {
      final pullResult = await ref.read(unifiedPullServiceProvider).pullScoped(
        trigger: 'manual',
        scopes: const ['sync'],
      );
      final sync = pullResult.response?.sync;
      if (sync != null) {
        ref.read(agendaSyncServiceProvider).applyCapability(
              userId: userId,
              enabled: sync.enabled,
            );
      }
      await ref
          .read(agendaSyncServiceProvider)
          .sync(accessToken: token, userId: userId);
      ref.invalidate(pendingSyncChangeCountProvider);
      ref.invalidate(lastSyncTimeProvider);
      if (mounted) {
        setState(() => _syncMessage = '同步完成');
        _showMessage('同步完成');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _syncMessage = '同步失败：$error');
        _showMessage('同步失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
      }
    }
  }

  String _syncSubtitle(int pendingCount, DateTime? lastSyncedAt) {
    final parts = <String>[];
    parts.add(pendingCount > 0 ? '$pendingCount 条待推送' : '无待推送变更');
    if (lastSyncedAt != null) {
      parts.add('上次同步 ${_formatSyncTime(lastSyncedAt)}');
    }
    if (_syncMessage != null && _syncMessage!.isNotEmpty) {
      parts.add(_syncMessage!);
    }
    return parts.join(' · ');
  }

  String _formatSyncTime(DateTime value) {
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.loading,
    required this.icon,
    required this.onPressed,
  });

  final bool loading;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: '更新',
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
    );
  }
}
