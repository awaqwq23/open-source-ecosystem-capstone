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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final whuAuth = ref.watch(whuAuthProvider);
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
                    subtitle: '本地模式',
                    prominent: true,
                    showTrailing: true,
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
                    prominent: true,
                    showTrailing: true,
                    onTap: whuAuth.isAuthenticated
                        ? null
                        : () => context.push(AppRoutePaths.settingsWhuAuthLogin),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _settingsSectionSpacing),
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
    final theme = Theme.of(context);
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
            gradientStartColor:
                theme.colorScheme.surface.withValues(alpha: 0.08),
            gradientEndColor: theme.colorScheme.surface.withValues(alpha: 0.52),
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
    required this.gradientStartColor,
    required this.gradientEndColor,
  });

  final ScrollController scrollController;
  final double height;
  final Color gradientStartColor;
  final Color gradientEndColor;

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
                    gradientStartColor,
                    gradientEndColor,
                  ],
                ),
              ),
            ),
          ],
        ),
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
