import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_controller.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
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
    final isZh = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: l10n.settingsGeneralEntryTitle),
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
                  title: l10n.settingsNavigationEntryTitle,
                  subtitle: l10n.settingsNavigationEntrySubtitle,
                  leading: const Icon(Icons.explore_outlined),
                  onTap: () =>
                      context.openSecondary(AppRoutePaths.settingsNavigation),
                ),
              ],
            ),
            _buildWidgetsSection(context, ref, state, viewModel, l10n, isZh),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetsSection(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
    bool isZh,
  ) {
    final widgetSettings = state.widgetSettings;
    return SettingsFlatSection(
      title: l10n.settingsGeneralWidgetsTitle,
      children: [
        SettingsFlatTile(
          title: isZh ? '启用桌面小组件同步' : 'Enable widget sync',
          leading: const Icon(Icons.sync_outlined),
          trailing: Switch(
            value: widgetSettings.enabled,
            onChanged: (value) => viewModel.saveWidgetSettings(
              widgetSettings.copyWith(enabled: value),
            ),
          ),
        ),
        SettingsFlatTile(
          title: isZh ? '兜底刷新频率' : 'Fallback refresh interval',
          subtitle: isZh
              ? '数据变更即时推送，同时按频率兜底刷新。'
              : 'Update on data changes, with periodic fallback refresh.',
          leading: const Icon(Icons.schedule_outlined),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<WidgetRefreshInterval>(
              value: widgetSettings.refreshInterval,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                viewModel.saveWidgetSettings(
                  widgetSettings.copyWith(refreshInterval: value),
                );
              },
              items: [
                DropdownMenuItem(
                  value: WidgetRefreshInterval.minutes30,
                  child: Text(isZh ? '30 分钟' : '30 minutes'),
                ),
                DropdownMenuItem(
                  value: WidgetRefreshInterval.hour1,
                  child: Text(isZh ? '1 小时' : '1 hour'),
                ),
                DropdownMenuItem(
                  value: WidgetRefreshInterval.hours3,
                  child: Text(isZh ? '3 小时' : '3 hours'),
                ),
              ],
            ),
          ),
        ),
        SettingsFlatTile(
          title: isZh ? '跟随应用语言' : 'Follow app language',
          leading: const Icon(Icons.language_outlined),
          trailing: Switch(
            value: widgetSettings.followAppLanguage,
            onChanged: (value) => viewModel.saveWidgetSettings(
              widgetSettings.copyWith(followAppLanguage: value),
            ),
          ),
        ),
        SettingsFlatTile(
          title: isZh ? '跟随应用主题' : 'Follow app theme',
          leading: const Icon(Icons.palette_outlined),
          trailing: Switch(
            value: widgetSettings.followAppTheme,
            onChanged: (value) => viewModel.saveWidgetSettings(
              widgetSettings.copyWith(followAppTheme: value),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeModeDropdown extends StatelessWidget {
  const _ThemeModeDropdown({required this.value, required this.onChanged});

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
  const _LanguageDropdown({required this.value, required this.onChanged});

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
