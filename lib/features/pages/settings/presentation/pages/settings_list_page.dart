import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsListPage extends StatelessWidget {
  const SettingsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: l10n.settingsListEntryTitle),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: SettingsFlatSection(
          children: [
            SettingsFlatTile(
              title: l10n.listSettingsSort,
              subtitle: l10n.settingsGeneralComingSoon,
              leading: const Icon(Icons.sort_outlined),
            ),
            SettingsFlatTile(
              title: l10n.listSettingsReorder,
              subtitle: l10n.settingsGeneralComingSoon,
              leading: const Icon(AppIcons.drag),
            ),
            SettingsFlatTile(
              title: l10n.listSettingsTheme,
              subtitle: l10n.settingsGeneralComingSoon,
              leading: const Icon(AppIcons.appearanceSection),
            ),
          ],
        ),
      ),
    );
  }
}
