import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _appearanceSectionKey = GlobalKey();
  final GlobalKey _languageSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final l10n = context.l10n;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(l10n.settingsTitle),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(l10n.settingsQuickActionsTitle),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.quickActions),
                onPressed: () => _showQuickActions(context),
              ),
            ),
          ],
        ),
      ],
      child: Center(
        child: SizedBox.expand(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: AppEntrance(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsDescription,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(24),
                    ui.Card(
                      key: _appearanceSectionKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.themeSectionTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Gap(16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _OptionButton<ui.ThemeMode>(
                                label: l10n.themeSystem,
                                icon: AppIcons.themeSystem,
                                value: ui.ThemeMode.system,
                                selected: themeMode == ui.ThemeMode.system,
                                onTap: (value) {
                                  ref.read(appThemeModeProvider.notifier).state = value;
                                },
                              ),
                              _OptionButton<ui.ThemeMode>(
                                label: l10n.themeLight,
                                icon: AppIcons.themeLight,
                                value: ui.ThemeMode.light,
                                selected: themeMode == ui.ThemeMode.light,
                                onTap: (value) {
                                  ref.read(appThemeModeProvider.notifier).state = value;
                                },
                              ),
                              _OptionButton<ui.ThemeMode>(
                                label: l10n.themeDark,
                                icon: AppIcons.themeDark,
                                value: ui.ThemeMode.dark,
                                selected: themeMode == ui.ThemeMode.dark,
                                onTap: (value) {
                                  ref.read(appThemeModeProvider.notifier).state = value;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),
                    ui.Card(
                      key: _languageSectionKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.languageSectionTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Gap(16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _OptionButton<Locale>(
                                label: l10n.languageChinese,
                                icon: AppIcons.languageChinese,
                                value: AppLocale.chinese.locale,
                                selected: locale == AppLocale.chinese.locale,
                                onTap: (value) {
                                  ref.read(appLocaleProvider.notifier).state = value;
                                },
                              ),
                              _OptionButton<Locale>(
                                label: l10n.languageEnglish,
                                icon: AppIcons.languageEnglish,
                                value: AppLocale.english.locale,
                                selected: locale == AppLocale.english.locale,
                                onTap: (value) {
                                  ref.read(appLocaleProvider.notifier).state = value;
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickActions(BuildContext context) {
    final l10n = context.l10n;

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsQuickActionsTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(AppIcons.appearanceSection),
                  title: Text(l10n.themeSectionTitle),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    _scrollToSection(_appearanceSectionKey);
                  },
                ),
                ListTile(
                  leading: const Icon(AppIcons.languageChinese),
                  title: Text(l10n.languageSectionTitle),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    _scrollToSection(_languageSectionKey);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToSection(GlobalKey sectionKey) {
    final sectionContext = sectionKey.currentContext;
    if (sectionContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }
}

class _OptionButton<T> extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final T value;
  final bool selected;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return ui.PrimaryButton(
        onPressed: () => onTap(value),
        leading: Icon(icon),
        child: Text(label),
      );
    }

    return ui.OutlineButton(
      onPressed: () => onTap(value),
      leading: Icon(icon),
      child: Text(label),
    );
  }
}
