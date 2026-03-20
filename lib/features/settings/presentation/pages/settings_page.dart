import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/theme_controller.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final l10n = context.l10n;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Gap(12),
              Text(
                l10n.settingsDescription,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(24),
              ui.Card(
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
                          icon: Icons.brightness_auto_outlined,
                          value: ui.ThemeMode.system,
                          selected: themeMode == ui.ThemeMode.system,
                          onTap: (value) {
                            ref.read(appThemeModeProvider.notifier).state = value;
                          },
                        ),
                        _OptionButton<ui.ThemeMode>(
                          label: l10n.themeLight,
                          icon: Icons.light_mode_outlined,
                          value: ui.ThemeMode.light,
                          selected: themeMode == ui.ThemeMode.light,
                          onTap: (value) {
                            ref.read(appThemeModeProvider.notifier).state = value;
                          },
                        ),
                        _OptionButton<ui.ThemeMode>(
                          label: l10n.themeDark,
                          icon: Icons.dark_mode_outlined,
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
                          icon: Icons.translate_outlined,
                          value: AppLocale.chinese.locale,
                          selected: locale == AppLocale.chinese.locale,
                          onTap: (value) {
                            ref.read(appLocaleProvider.notifier).state = value;
                          },
                        ),
                        _OptionButton<Locale>(
                          label: l10n.languageEnglish,
                          icon: Icons.language_outlined,
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
