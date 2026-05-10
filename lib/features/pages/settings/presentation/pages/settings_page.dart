import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/theme/app_semantic_colors.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final whuAuth = ref.watch(whuAuthProvider);
    return ui.Scaffold(
      headers: [
        buildTabAppBar(
          title: l10n.settingsTitle,
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AccountCard(
              icon: Icons.person_outline,
              title: l10n.settingsAccountLocalTitle,
              subtitle: '本地模式',
              trailing: const Icon(AppIcons.drillIn, size: 20),
              onTap: () {
                // 本地账户详情暂为信息展示
              },
            ),
            const SizedBox(height: 10),
            _AccountCard(
              icon: AppIcons.web,
              title: l10n.settingsAccountWhuTitle,
              subtitle: whuAuth.isAuthenticated
                  ? l10n.settingsAccountWhuLoggedIn
                  : l10n.settingsAccountWhuNotLoggedIn,
              trailing: const Icon(AppIcons.drillIn, size: 20),
              onTap: whuAuth.isAuthenticated
                  ? null
                  : () => context.push(AppRoutePaths.settingsWhuAuthLogin),
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

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = AppSemanticColors.settingsSectionBackground(theme);

    return Material(
      color: tileColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
