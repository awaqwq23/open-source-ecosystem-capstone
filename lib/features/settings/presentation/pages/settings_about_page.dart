import 'package:flutter/material.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          title: Text(l10n.settingsAboutEntryTitle),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: SettingsFlatSection(
          children: [
            SettingsFlatTile(
              title: l10n.appTitle,
              subtitle: l10n.settingsAboutProductSubtitle,
              leading: const Icon(AppIcons.info),
            ),
            SettingsFlatTile(
              title: l10n.settingsAboutVersionTitle,
              subtitle: '1.0.0+1',
              leading: const Icon(Icons.new_releases_outlined),
            ),
            SettingsFlatTile(
              title: l10n.settingsAboutLicenseTitle,
              subtitle: l10n.settingsGeneralComingSoon,
              leading: const Icon(Icons.description_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
