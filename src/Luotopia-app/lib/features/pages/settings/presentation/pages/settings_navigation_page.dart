import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsNavigationPage extends ConsumerWidget {
  const SettingsNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final l10n = context.l10n;
    final entries = ref
        .watch(pluginManagerProvider)
        .entries(ContributionSlot.navigation);
    final isZh = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: l10n.settingsNavigationEntryTitle),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: SettingsFlatSection(
          children: [
            SettingsFlatTile(
              title: isZh ? '导航栏显示文字' : 'Show navigation labels',
              subtitle: isZh
                  ? '关闭后仅显示图标（默认）'
                  : 'When off, only icons are shown (default).',
              leading: const Icon(Icons.subtitles_outlined),
              trailing: Switch(
                value: state.navigationSettings.showLabels,
                onChanged: (value) => viewModel.saveNavigationSettings(
                  state.navigationSettings.copyWith(showLabels: value),
                ),
              ),
            ),
            SettingsFlatTile(
              title: isZh ? '管理导航入口' : 'Manage navigation plugins',
              leading: const Icon(Icons.extension_outlined),
              onTap: () => context.openSecondary('/settings/plugins'),
            ),
            SettingsFlatTile(
              title: isZh ? '启动时默认页面' : 'Default home tab',
              subtitle: isZh
                  ? '打开应用时首先显示的页面（默认主页）'
                  : 'The page shown when the app starts (default Home).',
              leading: const Icon(Icons.home_outlined),
              trailing: _DefaultTabDropdown(
                value:
                    entries.any(
                      (c) => c.route == state.navigationSettings.defaultTab,
                    )
                    ? state.navigationSettings.defaultTab
                    : '/',
                entries: entries,
                onChanged: (value) => viewModel.saveNavigationSettings(
                  state.navigationSettings.copyWith(defaultTab: value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultTabDropdown extends StatelessWidget {
  const _DefaultTabDropdown({
    required this.value,
    required this.entries,
    required this.onChanged,
  });

  final String value;
  final List<PluginContribution> entries;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
        items: [
          for (final destination in entries)
            DropdownMenuItem(
              value: destination.route,
              child: Text(destination.title),
            ),
        ],
      ),
    );
  }
}
