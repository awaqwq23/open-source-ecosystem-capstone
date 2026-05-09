import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final settings = state.homeSettings;

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: context.l10n.settingsHomeSectionTitle),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: SettingsFlatSection(
          children: [
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
                        settings.copyWith(
                          blockDurationMinutes: settings.blockDurationMinutes - 15,
                        ),
                      )
                  : null,
              onIncrease: () => _saveHomeSettings(
                ref,
                settings.copyWith(
                  blockDurationMinutes: settings.blockDurationMinutes + 15,
                ),
              ),
            ),
            _HomeStepperTile(
              title: context.l10n.settingsHomeBlockGap,
              value: context.l10n.settingsMinutesValue(settings.blockGapMinutes),
              onDecrease: settings.blockGapMinutes > 0
                  ? () => _saveHomeSettings(
                        ref,
                        settings.copyWith(
                          blockGapMinutes: settings.blockGapMinutes - 5,
                        ),
                      )
                  : null,
              onIncrease: () => _saveHomeSettings(
                ref,
                settings.copyWith(
                  blockGapMinutes: settings.blockGapMinutes + 5,
                ),
              ),
            ),
            _HomeStepperTile(
              title: context.l10n.settingsHomeBlockCount,
              value: '${settings.blockCount}',
              onDecrease: settings.blockCount > 1
                  ? () => _saveHomeSettings(
                        ref,
                        settings.copyWith(
                          blockCount: settings.blockCount - 1,
                        ),
                      )
                  : null,
              onIncrease: () => _saveHomeSettings(
                ref,
                settings.copyWith(
                  blockCount: settings.blockCount + 1,
                ),
              ),
            ),
            _HomeStepperTile(
              title: context.l10n.settingsHomeItemOpacity,
              value: context.l10n.settingsPercentValue(settings.itemOpacityPercent),
              onDecrease: settings.itemOpacityPercent > 0
                  ? () => _saveHomeSettings(
                        ref,
                        settings.copyWith(
                          itemOpacityPercent: settings.itemOpacityPercent - 5,
                        ),
                      )
                  : null,
              onIncrease: settings.itemOpacityPercent < 100
                  ? () => _saveHomeSettings(
                        ref,
                        settings.copyWith(
                          itemOpacityPercent: settings.itemOpacityPercent + 5,
                        ),
                      )
                  : null,
            ),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(context.l10n.settingsHomeDemoModeTitle),
              value: settings.showDemoData,
              onChanged: (value) => _saveHomeSettings(
                ref,
                settings.copyWith(showDemoData: value),
              ),
            ),
            SettingsFlatTile(
              title: context.l10n.settingsHomeGridMode,
              leading: const Icon(Icons.grid_view),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<HomeGridMode>(
                  value: settings.gridMode,
                  onChanged: (value) {
                    if (value != null) {
                      _saveHomeSettings(
                        ref,
                        settings.copyWith(gridMode: value),
                      );
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: HomeGridMode.timeGrid,
                      child: Text(context.l10n.homeGridModeTime),
                    ),
                    DropdownMenuItem(
                      value: HomeGridMode.courseGrid,
                      child: Text(context.l10n.homeGridModeCourse),
                    ),
                  ],
                ),
              ),
            ),
            SettingsFlatTile(
              title: context.l10n.settingsHomeWideLayout,
              leading: const Icon(AppIcons.homeOutlined),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<HomeWideLayoutScope>(
                  value: settings.wideLayoutScope,
                  onChanged: (value) {
                    if (value != null) {
                      _saveHomeSettings(
                        ref,
                        settings.copyWith(wideLayoutScope: value),
                      );
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
          ],
        ),
      ),
    );
  }

  Future<void> _pickHomeStartTime(
    BuildContext context,
    WidgetRef ref,
    HomeSettings settings,
  ) async {
    final result = await showTimePicker(
      context: context,
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
