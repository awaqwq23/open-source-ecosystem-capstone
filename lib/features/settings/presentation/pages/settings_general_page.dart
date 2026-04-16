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
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            SettingsFlatSection(
              children: [
                SettingsFlatTile(
                  title: l10n.themeModeLabel,
                  leading: const Icon(AppIcons.appearanceSection),
                  trailing: _ThemeModeDropdown(
                    value: state.themeMode,
                    onChanged: (value) => viewModel.selectTheme(value),
                  ),
                ),
                SettingsFlatTile(
                  title: l10n.languageLabel,
                  leading: const Icon(AppIcons.languageEnglish),
                  trailing: _LanguageDropdown(
                    value: state.locale,
                    onChanged: (value) => viewModel.selectLocale(value),
                  ),
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

class _ThemeModeDropdown extends StatelessWidget {
  const _ThemeModeDropdown({
    required this.value,
    required this.onChanged,
  });

  final ui.ThemeMode value;
  final ValueChanged<ui.ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonHideUnderline(
      child: DropdownButton<ui.ThemeMode>(
        value: value,
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
        items: [
          DropdownMenuItem(
            value: ui.ThemeMode.system,
            child: Text(l10n.themeSystem),
          ),
          DropdownMenuItem(
            value: ui.ThemeMode.light,
            child: Text(l10n.themeLight),
          ),
          DropdownMenuItem(
            value: ui.ThemeMode.dark,
            child: Text(l10n.themeDark),
          ),
        ],
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  const _LanguageDropdown({
    required this.value,
    required this.onChanged,
  });

  final Locale value;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: value,
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
        items: [
          DropdownMenuItem(
            value: AppLocale.chinese.locale,
            child: Text(l10n.languageChinese),
          ),
          DropdownMenuItem(
            value: AppLocale.english.locale,
            child: Text(l10n.languageEnglish),
          ),
        ],
      ),
    );
  }
}
