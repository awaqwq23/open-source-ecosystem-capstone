import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/theme/theme_controller.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/notification/presentation/providers/notification_providers.dart';
import 'package:luotopia/features/pages/ai/data/ai_in_memory_data_source.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';
import 'package:luotopia/features/weather/presentation/providers/weather_providers.dart';
import 'package:luotopia/shared/data/export/local_database_backup_service.dart';
import 'package:luotopia/shared/data/sync/sync_service.dart';
import 'package:luotopia/shared/data/sync/sync_state_providers.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsDataUpdatesPage extends ConsumerStatefulWidget {
  const SettingsDataUpdatesPage({super.key});

  @override
  ConsumerState<SettingsDataUpdatesPage> createState() =>
      _SettingsDataUpdatesPageState();
}

class _SettingsDataUpdatesPageState
    extends ConsumerState<SettingsDataUpdatesPage> {
  bool _weatherRefreshing = false;
  bool _notificationRefreshing = false;
  bool _hotUpdateChecking = false;
  bool _syncing = false;
  bool _databaseExporting = false;
  bool _databaseImporting = false;
  String? _syncMessage;

  @override
  Widget build(BuildContext context) {
    final luotopiaAuth = ref.watch(luotopiaAuthProvider);
    final syncEnabled = ref.watch(syncCapabilityProvider).valueOrNull == true;
    final pendingSyncCount =
        ref.watch(pendingSyncChangeCountProvider).valueOrNull ?? 0;
    final lastSyncedAt = ref.watch(lastSyncTimeProvider);

    return ui.Scaffold(
      headers: [buildSecondaryAppBar(context, title: '数据更新')],
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
            SettingsFlatSection(
              title: '用户数据备份',
              children: [
                SettingsFlatTile(
                  title: '导出用户数据',
                  subtitle: '分享非课程事项、个人设置与 AI 会话备份',
                  leading: const Icon(Icons.ios_share_outlined),
                  trailing: _ActionIconButton(
                    tooltip: '导出',
                    loading: _databaseExporting,
                    icon: Icons.file_upload_outlined,
                    onPressed: () => unawaited(_exportDatabase()),
                  ),
                ),
                SettingsFlatTile(
                  title: '导入用户数据',
                  subtitle: '选择备份文件并覆盖当前非课程用户数据',
                  leading: const Icon(Icons.restore_page_outlined),
                  trailing: _ActionIconButton(
                    tooltip: '导入',
                    loading: _databaseImporting,
                    icon: Icons.file_download_outlined,
                    onPressed: () => unawaited(_importDatabase()),
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
    final result = await ref
        .read(unifiedPullServiceProvider)
        .pullScoped(trigger: 'manual', scopes: const ['hot_update']);
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
    final userId = auth.user?.externalId;
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
      final pullResult = await ref
          .read(unifiedPullServiceProvider)
          .pullScoped(trigger: 'manual', scopes: const ['sync']);
      final sync = pullResult.response?.sync;
      if (sync != null) {
        ref
            .read(agendaSyncServiceProvider)
            .applyCapability(userId: userId, enabled: sync.enabled);
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

  Future<void> _exportDatabase() async {
    if (_databaseExporting) {
      return;
    }
    setState(() => _databaseExporting = true);
    try {
      final backup = await ref
          .read(localDatabaseBackupServiceProvider)
          .exportDatabase();
      if (!mounted) {
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          text: 'Luotopia 用户数据备份',
          files: [XFile(backup.path, name: backup.fileName)],
          fileNameOverrides: [backup.fileName],
        ),
      );
      if (mounted) {
        _showMessage('用户数据备份已准备分享');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('用户数据导出失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _databaseExporting = false);
      }
    }
  }

  Future<void> _importDatabase() async {
    if (_databaseImporting) {
      return;
    }
    final file = await file_selector.openFile(
      acceptedTypeGroups: const [
        file_selector.XTypeGroup(
          label: 'SQLite 数据库',
          extensions: ['sqlite', 'db'],
          mimeTypes: ['application/vnd.sqlite3', 'application/octet-stream'],
        ),
      ],
      confirmButtonText: '导入',
    );
    if (file == null || !mounted) {
      return;
    }
    final confirmed = await _confirmImport();
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _databaseImporting = true);
    try {
      await ref
          .read(localDatabaseBackupServiceProvider)
          .importDatabase(file.path);
      await _reloadPersonalConfiguration();
      ref.invalidate(aiChatRepositoryProvider);
      ref.invalidate(pendingSyncChangeCountProvider);
      ref.invalidate(lastSyncTimeProvider);
      if (mounted) {
        _showMessage('用户数据已导入');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('用户数据导入失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _databaseImporting = false);
      }
    }
  }

  Future<void> _reloadPersonalConfiguration() async {
    final preferences = ref.read(sharedPreferencesProvider);
    if (preferences == null) {
      return;
    }
    final bootstrap = await AppBootstrapLoader.load(preferences);
    ref.read(appLocaleProvider.notifier).state = bootstrap.locale;
    ref.read(appThemeModeProvider.notifier).state = bootstrap.themeMode;
    ref.read(appHomeSettingsProvider.notifier).state = bootstrap.homeSettings;
    ref.read(appAiSettingsProvider.notifier).state = bootstrap.aiSettings;
    ref.read(appWidgetSettingsProvider.notifier).state =
        bootstrap.widgetSettings;
    ref.read(appNavigationSettingsProvider.notifier).state =
        bootstrap.navigationSettings;
  }

  Future<bool> _confirmImport() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入用户数据'),
        content: const Text(
          '导入会覆盖当前本地非课程事项与个人设置，并重置对应同步状态。'
          '备份中的插件数据也会替换同标识数据并封存，对应外部插件需重新导入和授权后使用。'
          '账号、天气缓存、服务通知和全校课表缓存不会被恢复。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('覆盖导入'),
          ),
        ],
      ),
    );
    return result == true;
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
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    this.tooltip = '更新',
    required this.loading,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final bool loading;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
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
