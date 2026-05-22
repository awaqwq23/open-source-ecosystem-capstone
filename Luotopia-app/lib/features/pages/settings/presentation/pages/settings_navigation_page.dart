import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
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
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');

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
              title: isZh ? '中间标签页' : 'Middle tab',
              subtitle: isZh
                  ? '导航栏中间位置显示论坛或 AI 助手（默认论坛）'
                  : 'Choose between Forum or AI for the middle tab (default Forum).',
              leading: const Icon(Icons.swap_horiz_outlined),
              trailing: _MiddleTabDropdown(
                value: state.navigationSettings.middleTabMode,
                onChanged: (value) => viewModel.saveNavigationSettings(
                  state.navigationSettings.copyWith(middleTabMode: value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiddleTabDropdown extends StatelessWidget {
  const _MiddleTabDropdown({
    required this.value,
    required this.onChanged,
  });

  final MiddleTabMode value;
  final ValueChanged<MiddleTabMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    return DropdownButtonHideUnderline(
      child: DropdownButton<MiddleTabMode>(
        value: value,
        onChanged: (selected) {
          if (selected != null) {
            onChanged(selected);
          }
        },
        items: [
          DropdownMenuItem(
            value: MiddleTabMode.forum,
            child: Text(isZh ? '论坛' : 'Forum'),
          ),
          DropdownMenuItem(
            value: MiddleTabMode.ai,
            child: Text(isZh ? 'AI 助手' : 'AI'),
          ),
        ],
      ),
    );
  }
}
