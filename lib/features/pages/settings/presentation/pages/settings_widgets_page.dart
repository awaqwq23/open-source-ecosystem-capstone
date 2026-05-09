import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/widget_settings.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsWidgetsPage extends ConsumerWidget {
  const SettingsWidgetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final l10n = context.l10n;
    final widgetSettings = state.widgetSettings;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(l10n.settingsGeneralWidgetsTitle),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            SettingsFlatSection(
              title: _isChinese(context) ? '刷新策略' : 'Refresh',
              children: [
                SettingsFlatTile(
                  title: _isChinese(context) ? '启用桌面小组件同步' : 'Enable widget sync',
                  leading: const Icon(Icons.sync_outlined),
                  trailing: Switch(
                    value: widgetSettings.enabled,
                    onChanged: (value) => viewModel.saveWidgetSettings(
                      widgetSettings.copyWith(enabled: value),
                    ),
                  ),
                ),
                SettingsFlatTile(
                  title: _isChinese(context) ? '兜底刷新频率' : 'Fallback refresh interval',
                  subtitle: _isChinese(context)
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
                          child: Text(_isChinese(context) ? '30 分钟' : '30 minutes'),
                        ),
                        DropdownMenuItem(
                          value: WidgetRefreshInterval.hour1,
                          child: Text(_isChinese(context) ? '1 小时' : '1 hour'),
                        ),
                        DropdownMenuItem(
                          value: WidgetRefreshInterval.hours3,
                          child: Text(_isChinese(context) ? '3 小时' : '3 hours'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SettingsFlatSection(
              title: _isChinese(context) ? '显示范围' : 'Display ranges',
              children: [
                SettingsFlatTile(
                  title: _isChinese(context) ? '快速创建事项' : 'Quick create item',
                  subtitle: _isChinese(context)
                      ? '覆盖 1x1 到 6x1、2x2、2x3、3x2、3x3 等尺寸'
                      : 'Covers 1x1 to 6x1, plus 2x2 / 2x3 / 3x2 / 3x3',
                  leading: const Icon(Icons.add_box_outlined),
                ),
                SettingsFlatTile(
                  title: _isChinese(context) ? '事项列表组件' : 'Agenda list widget',
                  subtitle: _isChinese(context)
                      ? '高密度展示：今日优先 + 未来 7 天补充'
                      : 'High density: today-first with next 7 days',
                  leading: const Icon(Icons.view_list_outlined),
                ),
                SettingsFlatTile(
                  title: _isChinese(context) ? '周视图（列表版）' : 'Week view (list)',
                  subtitle: _isChinese(context) ? '按天分组展示本周事项' : 'Weekly items grouped by day',
                  leading: const Icon(Icons.reorder_outlined),
                ),
                SettingsFlatTile(
                  title: _isChinese(context) ? '周视图（表格版）' : 'Week view (grid)',
                  subtitle: _isChinese(context) ? '表格化展示本周事项总览' : 'Grid overview for all weekly items',
                  leading: const Icon(Icons.calendar_view_week_outlined),
                ),
              ],
            ),
            SettingsFlatSection(
              title: _isChinese(context) ? '继承策略' : 'Inheritance',
              children: [
                SettingsFlatTile(
                  title: _isChinese(context) ? '跟随应用语言' : 'Follow app language',
                  leading: const Icon(Icons.language_outlined),
                  trailing: Switch(
                    value: widgetSettings.followAppLanguage,
                    onChanged: (value) => viewModel.saveWidgetSettings(
                      widgetSettings.copyWith(followAppLanguage: value),
                    ),
                  ),
                ),
                SettingsFlatTile(
                  title: _isChinese(context) ? '跟随应用主题' : 'Follow app theme',
                  leading: const Icon(Icons.palette_outlined),
                  trailing: Switch(
                    value: widgetSettings.followAppTheme,
                    onChanged: (value) => viewModel.saveWidgetSettings(
                      widgetSettings.copyWith(followAppTheme: value),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }
}
