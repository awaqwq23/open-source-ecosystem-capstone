import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/theme/app_semantic_colors.dart';
import 'package:luotopia/features/components/wallpaper/presentation/widgets/app_wallpaper_background.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final whuAuth = ref.watch(whuAuthProvider);
    return ui.Scaffold(
      headers: [
        buildTabAppBar(
          title: l10n.settingsTitle,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingsHero(
              child: _AccountHubCard(
                children: [
                  _AccountHubTile(
                    icon: Icons.person_outline,
                    title: l10n.settingsAccountLocalTitle,
                    subtitle: '本地模式',
                    prominent: true,
                    showTrailing: false,
                    onTap: () {
                      // 本地账户详情暂为信息展示
                    },
                  ),
                  _AccountHubTile(
                    icon: AppIcons.web,
                    title: l10n.settingsAccountWhuTitle,
                    subtitle: whuAuth.isAuthenticated
                        ? l10n.settingsAccountWhuLoggedIn
                        : l10n.settingsAccountWhuNotLoggedIn,
                    prominent: false,
                    showTrailing: true,
                    onTap: whuAuth.isAuthenticated
                        ? null
                        : () => context.push(AppRoutePaths.settingsWhuAuthLogin),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SettingsLinkCard(
              children: [
                _SettingsLinkTile(
                  title: l10n.settingsGeneralEntryTitle,
                  subtitle: l10n.settingsGeneralEntrySubtitle,
                  icon: AppIcons.settingsOutlined,
                  onTap: () => context.push(AppRoutePaths.settingsGeneral),
                ),
                _SettingsLinkTile(
                  title: l10n.settingsHomeSectionTitle,
                  subtitle: l10n.settingsHomeEntrySubtitle,
                  icon: AppIcons.homeOutlined,
                  onTap: () => context.push(AppRoutePaths.settingsHome),
                ),
                _SettingsLinkTile(
                  title: l10n.settingsAiSectionTitle,
                  subtitle: '',
                  icon: AppIcons.aiOutlined,
                  onTap: () => context.push(AppRoutePaths.settingsAi),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 252,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 164,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppWallpaperBackground(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.surface.withValues(alpha: 0.08),
                        theme.colorScheme.surface.withValues(alpha: 0.52),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 104,
            child: child,
          ),
        ],
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

    return Material(
      color: AppSemanticColors.settingsSectionBackground(theme),
      elevation: theme.brightness == Brightness.dark ? 0 : 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
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
      child: Material(
        color: AppSemanticColors.settingsSectionBackground(theme),
        elevation: theme.brightness == Brightness.dark ? 0 : 4,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
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
