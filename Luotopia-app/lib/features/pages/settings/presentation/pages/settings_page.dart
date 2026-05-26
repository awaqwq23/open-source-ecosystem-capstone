import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/theme/app_semantic_colors.dart';
import 'package:luotopia/features/components/wallpaper/presentation/widgets/app_wallpaper_background.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/notification/presentation/providers/notification_providers.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/data/sync/sync_service.dart';
import 'package:luotopia/shared/data/sync/sync_state_providers.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

const double _settingsHeroImageHeightFactor = 0.333;
const double _settingsHeroCardImageOverlap = 60;
const double _settingsHeroCardReservedHeight = 148;
const double _settingsHeroHorizontalPadding = 16;
const double _settingsSectionSpacing = 16;
const double _settingsPageBottomPadding = 24;

double _settingsHeroImageHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).height * _settingsHeroImageHeightFactor;
}

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _manualSyncing = false;
  String? _manualSyncMessage;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final whuAuth = ref.watch(whuAuthProvider);
    final luotopiaAuth = ref.watch(luotopiaAuthProvider);
    final syncEnabled = ref.watch(syncCapabilityProvider).valueOrNull == true;
    final pendingSyncCount = ref.watch(pendingSyncChangeCountProvider).valueOrNull ?? 0;
    final lastSyncedAt = ref.watch(lastSyncTimeProvider);
    return ui.Scaffold(
      floatingHeader: true,
      headers: [
        _SettingsFadingTopBar(
          scrollController: _scrollController,
          title: l10n.settingsTitle,
        ),
      ],
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, _settingsPageBottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsHero(
              scrollController: _scrollController,
              child: _AccountHubCard(
                children: [
                  _AccountHubTile(
                    icon: Icons.person_outline,
                    title: l10n.settingsAccountLocalTitle,
                    subtitle: luotopiaAuth.isAuthenticated
                        ? '用户 ${luotopiaAuth.user!.shortId}'
                        : '未登录',
                    prominent: true,
                    showTrailing: true,
                    onTap: luotopiaAuth.isAuthenticated
                        ? () => context.push(AppRoutePaths.settingsLuotopiaAccount)
                        : () => context.push(AppRoutePaths.settingsLuotopiaLogin),
                  ),
                  _AccountHubTile(
                    icon: AppIcons.web,
                    title: l10n.settingsAccountWhuTitle,
                    subtitle: whuAuth.isAuthenticated
                        ? (whuAuth.account?.displayName ?? l10n.settingsAccountWhuLoggedIn)
                        : l10n.settingsAccountWhuNotLoggedIn,
                    prominent: true,
                    showTrailing: true,
                    onTap: () => context.push(AppRoutePaths.settingsWhuAccount),
                  ),
                ],
              ),
            ),
            // ── 服务通知 ──
            const _NotificationSection(),
            const SizedBox(height: _settingsSectionSpacing),
            _SettingsLinkCard(
              children: [
                _SettingsLinkTile(
                  title: l10n.settingsGeneralEntryTitle,
                  subtitle: l10n.settingsGeneralEntrySubtitle,
                  icon: AppIcons.settingsOutlined,
                  onTap: () => context.push(AppRoutePaths.settingsGeneral),
                ),
                if (syncEnabled)
                  _SettingsSyncTile(
                    pendingCount: pendingSyncCount,
                    lastSyncedAt: lastSyncedAt,
                    syncing: _manualSyncing,
                    message: _manualSyncMessage,
                    onSync: () => _syncNow(luotopiaAuth),
                  ),
                _SettingsLinkTile(
                  title: '热更新脚本',
                  subtitle: '检查校园服务脚本版本',
                  icon: Icons.code_outlined,
                  onTap: () => unawaited(_checkHotUpdate()),
                ),
                _SettingsLinkTile(
                  title: l10n.settingsHomeSectionTitle,
                  subtitle: l10n.settingsHomeEntrySubtitle,
                  icon: AppIcons.homeOutlined,
                  onTap: () => context.push(AppRoutePaths.settingsHome),
                ),
                _SettingsLinkTile(
                  title: l10n.settingsAiSectionTitle,
                  subtitle: '模型、密钥与系统提示词',
                  icon: AppIcons.aiOutlined,
                  onTap: () => context.push(AppRoutePaths.settingsAi),
                ),
              ],
            ),
            const SizedBox(height: _settingsSectionSpacing),
            _SettingsLinkCard(
              children: [
                _SettingsLinkTile(
                  title: 'Lorem Ipsum',
                  subtitle: 'Dolor sit amet, consectetur adipiscing',
                  icon: Icons.rate_review_outlined,
                  onTap: () => _showLinkPending(context, 'Lorem Ipsum'),
                ),
                _SettingsLinkTile(
                  title: 'Sed Do Eiusmod',
                  subtitle: 'Tempor incididunt ut labore et dolore',
                  icon: Icons.school_outlined,
                  onTap: () => _showLinkPending(context, 'Sed Do Eiusmod'),
                ),
                _SettingsLinkTile(
                  title: 'Ut Enim Ad Minim',
                  subtitle: 'Veniam quis nostrud exercitation',
                  icon: Icons.auto_awesome_outlined,
                  onTap: () => _showLinkPending(context, 'Ut Enim Ad Minim'),
                ),
                _SettingsLinkTile(
                  title: 'Duis Aute Irure',
                  subtitle: 'Dolor in reprehenderit in voluptate',
                  icon: Icons.account_balance_outlined,
                  onTap: () => _showLinkPending(context, 'Duis Aute Irure'),
                ),
                _SettingsLinkTile(
                  title: 'Excepteur Sint',
                  subtitle: 'Occaecat cupidatat non proident',
                  icon: Icons.forum_outlined,
                  onTap: () => _showLinkPending(context, 'Excepteur Sint'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkPending(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title placeholder'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkHotUpdate() async {
    final result = await ref.read(unifiedPullServiceProvider).pullScoped(
      trigger: 'manual',
      scopes: const ['hot_update'],
    );
    if (!mounted) {
      return;
    }
    final scripts = result.response?.hotUpdate?.scripts.values;
    final changed = scripts?.where((script) => script.changed).length ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.isSuccess ? '已检查脚本更新：$changed 项有更新' : '脚本更新检查失败'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _syncNow(LuotopiaAuthState auth) async {
    final token = auth.accessToken;
    final userId = auth.user?.id;
    if (auth.status != LuotopiaAuthStatus.authenticated ||
        token == null ||
        token.isEmpty ||
        userId == null ||
        userId.isEmpty ||
        _manualSyncing) {
      return;
    }
    setState(() {
      _manualSyncing = true;
      _manualSyncMessage = null;
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
        setState(() => _manualSyncMessage = '同步完成');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _manualSyncMessage = '同步失败：$error');
      }
    } finally {
      if (mounted) {
        setState(() => _manualSyncing = false);
      }
    }
  }
}

class _SettingsFadingTopBar extends StatelessWidget {
  const _SettingsFadingTopBar({
    required this.scrollController,
    required this.title,
  });

  final ScrollController scrollController;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        final opacity = (offset / _settingsHeroImageHeight(context))
            .clamp(0.0, 1.0)
            .toDouble();
        return IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: buildTabAppBar(title: title),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.scrollController,
    required this.child,
  });

  final ScrollController scrollController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final imageHeight = _settingsHeroImageHeight(context);
    final cardTop = imageHeight - _settingsHeroCardImageOverlap;

    return SizedBox(
      height: cardTop + _settingsHeroCardReservedHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _SettingsExpandableHeroImage(
            scrollController: scrollController,
            height: imageHeight,
          ),
          Positioned(
            left: _settingsHeroHorizontalPadding,
            right: _settingsHeroHorizontalPadding,
            top: cardTop,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SettingsExpandableHeroImage extends StatelessWidget {
  const _SettingsExpandableHeroImage({
    required this.scrollController,
    required this.height,
  });

  final ScrollController scrollController;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, child) {
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        final pullDistance = offset < 0 ? -offset : 0.0;
        final scale = 1 + pullDistance / height;

        return Transform.translate(
          offset: Offset(0, -pullDistance),
          child: Transform.scale(
            alignment: Alignment.topCenter,
            scale: scale,
            child: child,
          ),
        );
      },
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: const AppWallpaperBackground(),
      ),
    );
  }
}

class _AccountHubCard extends StatelessWidget {
  const _AccountHubCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ui.Card(
      surfaceBlur: 10,
      surfaceOpacity: 0.82,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 78, right: 18),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppSemanticColors.settingsSectionDivider(theme),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AccountHubTile extends StatelessWidget {
  const _AccountHubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.prominent,
    required this.showTrailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool prominent;
  final bool showTrailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glyphSize = prominent ? 28.0 : 24.0;
    final verticalPadding = prominent ? 14.0 : 12.0;
    final titleStyle = (prominent
            ? theme.textTheme.titleMedium
            : theme.textTheme.titleSmall)
        ?.copyWith(
      color: prominent ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
      fontWeight: prominent ? FontWeight.w800 : FontWeight.w600,
    );
    final subtitleStyle = (prominent
            ? theme.textTheme.bodyMedium
            : theme.textTheme.bodySmall)
        ?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, verticalPadding, 14, verticalPadding),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Icon(
                icon,
                size: glyphSize,
                color: prominent
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                  SizedBox(height: prominent ? 3 : 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: subtitleStyle,
                  ),
                ],
              ),
            ),
            if (showTrailing)
              Icon(
                AppIcons.drillIn,
                size: 22,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsLinkCard extends StatelessWidget {
  const _SettingsLinkCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ui.Card(
        surfaceBlur: 10,
        surfaceOpacity: 0.82,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              children[index],
              if (index != children.length - 1)
                Padding(
                  padding: const EdgeInsets.only(left: 78, right: 18),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppSemanticColors.settingsSectionDivider(theme),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        child: Row(
          children: [
            SizedBox(
              width: 46,
              child: Icon(
                icon,
                size: 28,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              AppIcons.drillIn,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSyncTile extends StatelessWidget {
  const _SettingsSyncTile({
    required this.pendingCount,
    required this.lastSyncedAt,
    required this.syncing,
    required this.onSync,
    this.message,
  });

  final int pendingCount;
  final DateTime? lastSyncedAt;
  final bool syncing;
  final String? message;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = message ??
        (pendingCount > 0
            ? '待推送 $pendingCount 项变更'
            : lastSyncedAt == null
                ? '尚未同步'
                : '上次同步 ${_formatSyncTime(lastSyncedAt!)}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Icon(
              Icons.cloud_sync_outlined,
              size: 28,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据同步',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ui.IconButton.ghost(
            icon: syncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: syncing ? null : onSync,
          ),
        ],
      ),
    );
  }

  String _formatSyncTime(DateTime value) {
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
  }
}

class _NotificationSection extends ConsumerStatefulWidget {
  const _NotificationSection();

  @override
  ConsumerState<_NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends ConsumerState<_NotificationSection> {
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.campaign_outlined, size: 16, color: colors.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Text(
                '服务通知',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _refreshing ? null : () => unawaited(_manualRefresh()),
                child: _refreshing
                    ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.refresh, size: 16, color: colors.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _SettingsLinkCard(
            children: [
              if (state.hasNew)
                _SettingsLinkTile(
                  title: state.title ?? '新通知',
                  subtitle: '共 ${state.count} 条已发布公告',
                  icon: Icons.campaign_outlined,
                  onTap: () => unawaited(_showNotificationDetail(context)),
                )
              else
                _SettingsLinkTile(
                  title: '暂无新通知',
                  subtitle: '点击检查更新',
                  icon: Icons.check_circle_outline,
                  onTap: () {
                    if (!_refreshing) {
                      unawaited(_manualRefresh());
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _manualRefresh() async {
    setState(() => _refreshing = true);
    await ref.read(notificationProvider.notifier).checkLatest();
    setState(() => _refreshing = false);
  }

  Future<void> _showNotificationDetail(BuildContext context) async {
    await ref.read(notificationProvider.notifier).loadDetail();
    if (!mounted) {
      return;
    }
    final latest = ref.read(notificationProvider);
    await showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(latest.title ?? '服务通知'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Text(
                latest.content?.isNotEmpty == true ? latest.content! : '暂无详情',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
