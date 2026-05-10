import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/theme/app_semantic_colors.dart';
import 'package:luotopia/features/components/wallpaper/presentation/widgets/app_wallpaper_background.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
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
                    icon: Icons.sentiment_satisfied_alt_outlined,
                    iconBackground: theme.colorScheme.surfaceContainerHigh,
                    iconColor: theme.colorScheme.onSurfaceVariant,
                    title: l10n.settingsAccountLocalTitle,
                    subtitle: '本地模式',
                    prominent: false,
                    onTap: () {
                      // 本地账户详情暂为信息展示
                    },
                  ),
                  _AccountHubTile(
                    icon: AppIcons.web,
                    iconBackground: theme.colorScheme.primaryContainer,
                    iconColor: theme.colorScheme.primary,
                    title: l10n.settingsAccountWhuTitle,
                    subtitle: whuAuth.isAuthenticated
                        ? l10n.settingsAccountWhuLoggedIn
                        : l10n.settingsAccountWhuNotLoggedIn,
                    prominent: true,
                    onTap: whuAuth.isAuthenticated
                        ? null
                        : () => context.push(AppRoutePaths.settingsWhuAuthLogin),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsFlatSection(
              children: [
                SettingsFlatTile(
                  title: l10n.settingsGeneralEntryTitle,
                  subtitle: l10n.settingsGeneralEntrySubtitle,
                  leading: const Icon(AppIcons.settingsOutlined),
                  onTap: () => context.push(AppRoutePaths.settingsGeneral),
                ),
                SettingsFlatTile(
                  title: l10n.settingsHomeSectionTitle,
                  subtitle: l10n.settingsHomeEntrySubtitle,
                  leading: const Icon(AppIcons.homeOutlined),
                  onTap: () => context.push(AppRoutePaths.settingsHome),
                ),
                SettingsFlatTile(
                  title: l10n.settingsAiSectionTitle,
                  subtitle: '',
                  leading: const Icon(AppIcons.aiOutlined),
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
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.prominent,
    this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool prominent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = prominent ? 48.0 : 42.0;
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
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: glyphSize,
                color: iconColor,
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
