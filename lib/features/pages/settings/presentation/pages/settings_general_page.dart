import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
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
                SettingsFlatTile(
                  title: _isChinese(context) ? '导航栏显示文字' : 'Show navigation labels',
                  subtitle: _isChinese(context)
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
                  title: _isChinese(context) ? '中间标签页' : 'Middle tab',
                  subtitle: _isChinese(context)
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
                  subtitle: _isChinese(context)
                      ? '配置刷新策略、展示范围和跳转行为'
                      : 'Configure refresh policy, ranges and launch actions',
                  leading: const Icon(Icons.widgets_outlined),
                  onTap: () => context.push(AppRoutePaths.settingsWidgets),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

bool _isChinese(BuildContext context) {
  return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
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

class _MiddleTabDropdown extends StatelessWidget {
  const _MiddleTabDropdown({
    required this.value,
    required this.onChanged,
  });

  final MiddleTabMode value;
  final ValueChanged<MiddleTabMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isChinese = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
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
            child: Text(isChinese ? '论坛' : 'Forum'),
          ),
          DropdownMenuItem(
            value: MiddleTabMode.ai,
            child: Text(isChinese ? 'AI 助手' : 'AI'),
          ),
        ],
      ),
    );
  }
}
