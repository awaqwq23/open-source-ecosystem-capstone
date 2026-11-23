import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/features/plugins/domain/plugin_error.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/domain/builtin_plugins.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/features/plugins/presentation/plugin_icons.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/theme/app_semantic_colors.dart';
import 'package:luotopia/features/components/wallpaper/presentation/widgets/app_wallpaper_background.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/notification/presentation/providers/notification_providers.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
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

  EdgeDraggingAutoScroller? _dragScroll;

  @override
  void dispose() {
    _dragScroll?.stopAutoScroll();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = ref
        .watch(pluginManagerProvider)
        .entries(ContributionSlot.settingsRow);
    final sections = <List<PluginContribution>>[];
    for (final entry in entries) {
      if (entry.pluginId == 'luotopia.settings' && entry.id == 'accounts') {
        continue;
      }
      if (sections.isEmpty ||
          entry.pluginId == 'luotopia.notification' ||
          sections.last.last.pluginId == 'luotopia.notification' ||
          settingsGroupFor(sections.last.last.pluginId) !=
              settingsGroupFor(entry.pluginId)) {
        sections.add([]);
      }
      sections.last.add(entry);
    }
    final whuAuth = ref.watch(whuAuthProvider);
    final luotopiaAuth = ref.watch(luotopiaAuthProvider);
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
                        ? luotopiaAuth.user!.displayName
                        : '未登录',
                    prominent: true,
                    showTrailing: true,
                    onTap: luotopiaAuth.isAuthenticated
                        ? () => context.openSecondary(
                            AppRoutePaths.luotopiaAccount,
                          )
                        : () => context.openSecondary(
                            AppRoutePaths.luotopiaLogin,
                          ),
                  ),
                  _AccountHubTile(
                    icon: AppIcons.web,
                    title: l10n.settingsAccountWhuTitle,
                    subtitle: whuAuth.isAuthenticated
                        ? (whuAuth.account?.displayName ??
                              l10n.settingsAccountWhuLoggedIn)
                        : l10n.settingsAccountWhuNotLoggedIn,
                    prominent: true,
                    showTrailing: true,
                    onTap: () =>
                        context.openSecondary(AppRoutePaths.whuAccount),
                  ),
                ],
              ),
            ),
            for (var index = 0; index < sections.length; index++) ...[
              if (sections[index].singleOrNull?.pluginId ==
                  'luotopia.notification')
                _sortable(sections[index].single, const _NotificationSection())
              else ...[
                const SizedBox(height: _settingsSectionSpacing),
                _SettingsLinkCard(
                  children: [
                    for (final entry in sections[index])
                      _sortable(entry, _pluginTile(context, entry)),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _sortable(PluginContribution entry, Widget tile) {
    final manager = ref.read(pluginManagerProvider);
    return Builder(
      key: ValueKey('settings-row-${entry.key}'),
      builder: (rowContext) => DragTarget<(String, int)>(
        onWillAcceptWithDetails: (drag) => drag.data.$1 != entry.key,
        onAcceptWithDetails: (drag) async {
          final keys = manager
              .entries(ContributionSlot.settingsRow)
              .map((r) => r.key)
              .toList();
          final target = keys.indexOf(entry.key);
          if (target < 0 || !keys.remove(drag.data.$1)) return;
          keys.insert(target, drag.data.$1);
          try {
            await manager.reorder(
              ContributionSlot.settingsRow,
              keys,
              expectedRevision: drag.data.$2,
            );
          } on PluginException catch (error) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.message)));
            }
          }
        },
        builder: (context, hovering, _) => LongPressDraggable<(String, int)>(
          data: (entry.key, manager.revision),
          maxSimultaneousDrags: 1,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: () => _dragScroll = EdgeDraggingAutoScroller(
            Scrollable.of(rowContext),
            velocityScalar: 12,
          ),
          onDragUpdate: (drag) => _dragScroll?.startAutoScrollIfNecessary(
            Rect.fromCenter(center: drag.globalPosition, width: 1, height: 84),
          ),
          onDragEnd: (_) => _dragScroll?.stopAutoScroll(),
          feedback: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(entry.title),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.4, child: tile),
          child: ColoredBox(
            color: hovering.isEmpty
                ? Colors.transparent
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: tile,
          ),
        ),
      ),
    );
  }

  Widget _pluginTile(BuildContext context, PluginContribution entry) {
    final l10n = context.l10n;
    final original = switch (entry.pluginId) {
      'luotopia.home-settings' => (
        l10n.settingsHomeSectionTitle,
        l10n.settingsHomeEntrySubtitle,
        AppIcons.homeOutlined,
      ),
      'luotopia.ai-settings' => (
        l10n.settingsAiSectionTitle,
        '模型、密钥与系统提示词',
        AppIcons.aiOutlined,
      ),
      'luotopia.placeholder-1' => (
        '可选功能示例 1',
        '尚未接入功能，可在插件管理中隐藏',
        Icons.rate_review_outlined,
      ),
      'luotopia.placeholder-2' => (
        '可选功能示例 2',
        '尚未接入功能，可在插件管理中隐藏',
        Icons.school_outlined,
      ),
      'luotopia.placeholder-3' => (
        '可选功能示例 3',
        '尚未接入功能，可在插件管理中隐藏',
        Icons.auto_awesome_outlined,
      ),
      'luotopia.placeholder-4' => (
        '可选功能示例 4',
        '尚未接入功能，可在插件管理中隐藏',
        Icons.account_balance_outlined,
      ),
      'luotopia.placeholder-5' => (
        '可选功能示例 5',
        '尚未接入功能，可在插件管理中隐藏',
        Icons.forum_outlined,
      ),
      'luotopia.settings' when entry.id == 'plugins' => (
        '插件管理',
        '管理核心功能、系统插件与外部插件',
        Icons.extension_outlined,
      ),
      _ =>
        entry.pluginId == 'luotopia.settings' && entry.id == 'general'
            ? (
                l10n.settingsGeneralEntryTitle,
                l10n.settingsGeneralEntrySubtitle,
                AppIcons.settingsOutlined,
              )
            : entry.pluginId == 'luotopia.settings' && entry.id == 'data'
            ? ('数据更新', '天气、通知、脚本与同步', Icons.sync_outlined)
            : (entry.title, '', pluginIcon(entry.icon)),
    };
    final hasScript =
        ref.read(pluginManagerProvider).details(entry.pluginId).script != null;
    final description = hasScript ? '独立插件页面' : original.$2;
    final sourceLabel = switch (ref
        .read(pluginManagerProvider)
        .details(entry.pluginId)
        .source) {
      PluginSource.core => '核心功能 · 受保护',
      PluginSource.system => '系统插件 · 可选',
      PluginSource.external => '外部插件',
    };
    final title =
        !ref
            .read(pluginManagerProvider)
            .hasPresentationOverride(entry.key, 'title')
        ? original.$1
        : entry.title;
    return _SettingsLinkTile(
      title: title,
      subtitle: description.isEmpty
          ? sourceLabel
          : '$sourceLabel · $description',
      icon:
          !ref
              .read(pluginManagerProvider)
              .hasPresentationOverride(entry.key, 'icon')
          ? original.$3
          : pluginIcon(entry.icon),
      onTap: () {
        if (entry.nativeRoute != null) {
          context.openSecondary(entry.nativeRoute!);
        } else if (ref
                .read(pluginManagerProvider)
                .details(entry.pluginId)
                .script !=
            null) {
          context.go(entry.route);
        } else {
          _showLinkPending(context, title);
        }
      },
    );
  }

  void _showLinkPending(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title 尚未接入功能，可在插件管理中隐藏'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: buildTabAppBar(title: title),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({required this.scrollController, required this.child});

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
  const _AccountHubCard({required this.children});

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
    final titleStyle =
        (prominent ? theme.textTheme.titleMedium : theme.textTheme.titleSmall)
            ?.copyWith(
              color: prominent
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: prominent ? FontWeight.w800 : FontWeight.w600,
            );
    final subtitleStyle =
        (prominent ? theme.textTheme.bodyMedium : theme.textTheme.bodySmall)
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant);

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
  const _SettingsLinkCard({required this.children});

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

class _NotificationSection extends ConsumerWidget {
  const _NotificationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(pluginManagerProvider);
    const key = 'luotopia.notification/row';
    if (!manager.isVisible(key)) {
      return const SizedBox.shrink();
    }
    final contribution = manager.contribution(key);
    final state = ref.watch(notificationProvider);
    final title = state.title;

    if (state.latestId == null || state.latestId!.isEmpty || title == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: _settingsSectionSpacing),
        _SettingsLinkCard(
          children: [
            _SettingsLinkTile(
              title: manager.hasPresentationOverride(key, 'title')
                  ? contribution.title
                  : title,
              subtitle: _notificationSubtitle(state),
              icon: manager.hasPresentationOverride(key, 'icon')
                  ? pluginIcon(contribution.icon)
                  : _notificationIcon(state.icon),
              onTap: () =>
                  context.openSecondary(AppRoutePaths.settingsDataUpdates),
            ),
          ],
        ),
      ],
    );
  }

  String _notificationSubtitle(NotificationState state) {
    final countText = state.count > 0 ? '共 ${state.count} 条通知' : '服务通知';
    return state.hasNew ? '有新通知 · $countText' : countText;
  }

  IconData _notificationIcon(String icon) {
    switch (icon) {
      case 'info':
        return Icons.info_outline;
      case 'event':
        return Icons.event_note_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'warning':
        return Icons.notification_important_outlined;
      case 'update':
        return Icons.system_update_alt_outlined;
      case 'campaign':
      default:
        return Icons.campaign_outlined;
    }
  }
}
