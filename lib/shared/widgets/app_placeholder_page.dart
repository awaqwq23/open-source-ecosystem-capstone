import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppPlaceholderPage extends ConsumerWidget {
  const AppPlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
    this.header,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget? header;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return SizedBox.expand(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              header ?? const SizedBox.shrink(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 20 : 32,
                    header == null ? 28 : 12,
                    isCompact ? 20 : 32,
                    32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.12),
                              theme.colorScheme.secondary.withValues(alpha: 0.1),
                              theme.colorScheme.tertiary.withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child:
                                      Icon(icon, color: theme.colorScheme.primary),
                                ),
                                const Gap(16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface
                                              .withValues(alpha: 0.72),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          l10n.developmentTag,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Gap(14),
                                      Text(
                                        title,
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Gap(20),
                            Text(
                              description,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(height: 1.5),
                            ),
                            if (primaryActionLabel != null ||
                                secondaryActionLabel != null) ...[
                              const Gap(24),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  if (primaryActionLabel != null)
                                    ui.PrimaryButton(
                                      onPressed: onPrimaryAction ?? () {},
                                      child: Text(primaryActionLabel!),
                                    ),
                                  if (secondaryActionLabel != null)
                                    ui.GhostButton(
                                      onPressed: onSecondaryAction ?? () {},
                                      child: Text(secondaryActionLabel!),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _StatusCard(
                            title: l10n.themeSectionTitle,
                            value: switch (themeMode) {
                              ui.ThemeMode.light => l10n.themeLight,
                              ui.ThemeMode.dark => l10n.themeDark,
                              ui.ThemeMode.system => l10n.themeSystem,
                            },
                            icon: Icons.palette_outlined,
                          ),
                          _StatusCard(
                            title: l10n.languageSectionTitle,
                            value: locale.languageCode == 'zh'
                                ? l10n.languageChinese
                                : l10n.languageEnglish,
                            icon: Icons.translate_outlined,
                          ),
                          _StatusCard(
                            title: 'Layout',
                            value: isCompact ? 'Compact' : 'Expanded',
                            icon: Icons.devices_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 240,
      child: ui.Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const Gap(16),
            Text(title, style: theme.textTheme.labelLarge),
            const Gap(8),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
