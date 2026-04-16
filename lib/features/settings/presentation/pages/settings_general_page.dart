import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_controller.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:huajuan_agenda/features/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsGeneralPage extends ConsumerWidget {
  const SettingsGeneralPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final l10n = context.l10n;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(l10n.settingsGeneralEntryTitle),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            SettingsFlatSection(
              children: [
                SettingsFlatChoiceRow<ui.ThemeMode>(
                  label: l10n.themeModeLabel,
                  value: state.themeMode,
                  options: [
                    SettingsFlatChoiceOption(
                      value: ui.ThemeMode.system,
                      label: l10n.themeSystem,
                    ),
                    SettingsFlatChoiceOption(
                      value: ui.ThemeMode.light,
                      label: l10n.themeLight,
                    ),
                    SettingsFlatChoiceOption(
                      value: ui.ThemeMode.dark,
                      label: l10n.themeDark,
                    ),
                  ],
                  onChanged: (value) => viewModel.selectTheme(value),
                ),
                SettingsFlatChoiceRow<Locale>(
                  label: l10n.languageLabel,
                  value: state.locale,
                  options: [
                    SettingsFlatChoiceOption(
                      value: AppLocale.chinese.locale,
                      label: l10n.languageChinese,
                    ),
                    SettingsFlatChoiceOption(
                      value: AppLocale.english.locale,
                      label: l10n.languageEnglish,
                    ),
                  ],
                  onChanged: (value) => viewModel.selectLocale(value),
                ),
              ],
            ),
            SettingsFlatSection(
              title: l10n.settingsGeneralCapabilitiesTitle,
              children: [
                SettingsFlatTile(
                  title: l10n.settingsGeneralSyncTitle,
                  subtitle: l10n.settingsGeneralComingSoon,
                  leading: const Icon(Icons.sync_outlined),
                ),
                SettingsFlatTile(
                  title: l10n.settingsGeneralNotificationTitle,
                  subtitle: l10n.settingsGeneralComingSoon,
                  leading: const Icon(Icons.notifications_outlined),
                ),
                SettingsFlatTile(
                  title: l10n.settingsGeneralWidgetsTitle,
                  subtitle: l10n.settingsGeneralComingSoon,
                  leading: const Icon(Icons.widgets_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
