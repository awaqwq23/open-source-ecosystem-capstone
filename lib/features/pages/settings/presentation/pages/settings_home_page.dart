import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:luotopia/shared/presentation/widgets/app_date_time_pickers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final settings = state.homeSettings;
    final isCourseGrid = settings.gridMode == HomeGridMode.courseGrid;
    final l10n = context.l10n;

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: l10n.settingsHomeSectionTitle),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ui.Tabs(
                index: isCourseGrid ? 0 : 1,
                onChanged: (index) => _saveHomeSettings(
                  ref,
                  settings.copyWith(
                    gridMode: index == 0
                        ? HomeGridMode.courseGrid
                        : HomeGridMode.timeGrid,
                  ),
                ),
                expand: true,
                children: [
                  ui.TabItem(
                    child: Text(l10n.homeGridModeCourse),
                  ),
                  ui.TabItem(
                    child: Text(l10n.homeGridModeTime),
                  ),
                ],
              ),
            ),
            _buildTimeGridSection(context, ref, settings),
            if (isCourseGrid) _buildCourseGridSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGridSection(BuildContext context, WidgetRef ref) {
    final isZh = Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
    return Column(
      children: [
        SettingsFlatSection(
          title: context.l10n.settingsHomeCourseImport,
          children: [
            SettingsFlatTile(
              title: isZh ? '武汉大学教务系统' : 'WHU Academic System',
              subtitle: isZh ? '通过内嵌网页登录并导入课程' : 'Import via embedded web login',
              leading: const Icon(AppIcons.web),
              onTap: () => context.push(AppRoutePaths.settingsCourseImportWhu),
            ),
            SettingsFlatTile(
              title: isZh ? 'Wakeup 分享口令/链接' : 'Wakeup Share Link/Code',
              subtitle: isZh ? '从分享文本导入课程表' : 'Import from shared text',
              leading: const Icon(AppIcons.import),
              onTap: () => context.push(AppRoutePaths.settingsCourseImportWakeup),
            ),
          ],
        ),
        SettingsFlatTile(
          title: context.l10n.settingsHomeCourseManagement,
          leading: const Icon(Icons.table_chart_outlined),
          onTap: () => context.push(AppRoutePaths.settingsCourseTimetables),
        ),
      ],
    );
  }

  Widget _buildTimeGridSection(BuildContext context, WidgetRef ref, HomeSettings settings) {
    return SettingsFlatSection(
      children: [
        _HomeStepperTile(
          title: context.l10n.settingsHomeItemOpacity,
          value: context.l10n.settingsPercentValue(settings.itemOpacityPercent),
          onDecrease: settings.itemOpacityPercent > 0
              ? () => _saveHomeSettings(
                    ref,
                    settings.copyWith(itemOpacityPercent: settings.itemOpacityPercent - 5),
                  )
              : null,
          onIncrease: settings.itemOpacityPercent < 100
              ? () => _saveHomeSettings(
                    ref,
                    settings.copyWith(itemOpacityPercent: settings.itemOpacityPercent + 5),
                  )
              : null,
        ),
        SettingsFlatTile(
          title: context.l10n.settingsHomeWideLayout,
          leading: const Icon(AppIcons.homeOutlined),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<HomeWideLayoutScope>(
              value: settings.wideLayoutScope,
              onChanged: (value) {
                if (value != null) {
                  _saveHomeSettings(ref, settings.copyWith(wideLayoutScope: value));
                }
              },
              items: [
                DropdownMenuItem(
                  value: HomeWideLayoutScope.week,
                  child: Text(context.l10n.homeScopeWeek),
                ),
                DropdownMenuItem(
                  value: HomeWideLayoutScope.month,
                  child: Text(context.l10n.homeScopeMonth),
                ),
              ],
            ),
          ),
        ),
        SettingsFlatTile(
          title: context.l10n.settingsHomeDayStart,
          subtitle: MaterialLocalizations.of(context).formatTimeOfDay(
            settings.dayStartTime,
          ),
          leading: const Icon(AppIcons.clock),
          onTap: () => _pickHomeStartTime(context, ref, settings),
        ),
        _HomeStepperTile(
          title: context.l10n.settingsHomeBlockDuration,
          value: context.l10n.settingsMinutesValue(settings.blockDurationMinutes),
          onDecrease: settings.blockDurationMinutes > 15
              ? () => _saveHomeSettings(
                    ref,
                    settings.copyWith(blockDurationMinutes: settings.blockDurationMinutes - 15),
                  )
              : null,
          onIncrease: () => _saveHomeSettings(
            ref,
            settings.copyWith(blockDurationMinutes: settings.blockDurationMinutes + 15),
          ),
        ),
        _HomeStepperTile(
          title: context.l10n.settingsHomeBlockGap,
          value: context.l10n.settingsMinutesValue(settings.blockGapMinutes),
          onDecrease: settings.blockGapMinutes > 0
              ? () => _saveHomeSettings(
                    ref,
                    settings.copyWith(blockGapMinutes: settings.blockGapMinutes - 5),
                  )
              : null,
          onIncrease: () => _saveHomeSettings(
            ref,
            settings.copyWith(blockGapMinutes: settings.blockGapMinutes + 5),
          ),
        ),
        _HomeStepperTile(
          title: context.l10n.settingsHomeBlockCount,
          value: '${settings.blockCount}',
          onDecrease: settings.blockCount > 1
              ? () => _saveHomeSettings(
                    ref,
                    settings.copyWith(blockCount: settings.blockCount - 1),
                  )
              : null,
          onIncrease: () => _saveHomeSettings(
            ref,
            settings.copyWith(blockCount: settings.blockCount + 1),
          ),
        ),
      ],
    );
  }

  Future<void> _pickHomeStartTime(
    BuildContext context,
    WidgetRef ref,
    HomeSettings settings,
  ) async {
    final result = await AppDateTimePickers.pickTime(
      context,
      initialTime: settings.dayStartTime,
    );
    if (result == null) {
      return;
    }
    await _saveHomeSettings(ref, settings.copyWith(dayStartTime: result));
  }

  Future<void> _saveHomeSettings(WidgetRef ref, HomeSettings settings) {
    return ref.read(settingsViewModelProvider.notifier).saveHomeSettings(settings);
  }
}

class _HomeStepperTile extends StatelessWidget {
  const _HomeStepperTile({
    required this.title,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String title;
  final String value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return SettingsFlatTile(
      title: title,
      subtitle: value,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ui.IconButton.ghost(
            icon: const Icon(Icons.remove),
            onPressed: onDecrease,
          ),
          ui.IconButton.ghost(
            icon: const Icon(Icons.add),
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}
