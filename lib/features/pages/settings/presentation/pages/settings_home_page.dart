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
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsHomePage extends ConsumerWidget {
  const SettingsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final settings = state.homeSettings;
    final l10n = context.l10n;
    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: l10n.settingsHomeSectionTitle),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        child: Column(
          children: [
            SettingsFlatSection(
              children: [
                _HomeStepperTile(
                  title: l10n.settingsHomeItemOpacity,
                  value: l10n.settingsPercentValue(settings.itemOpacityPercent),
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
                  title: l10n.settingsHomeWideLayout,
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
                          child: Text(l10n.homeScopeWeek),
                        ),
                        DropdownMenuItem(
                          value: HomeWideLayoutScope.month,
                          child: Text(l10n.homeScopeMonth),
                        ),
                      ],
                    ),
                  ),
                ),
                SettingsFlatTile(
                  title: l10n.settingsHomeGridMode,
                  leading: const Icon(Icons.grid_view),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<HomeGridMode>(
                      value: settings.gridMode,
                      onChanged: (value) {
                        if (value != null) {
                          _saveHomeSettings(ref, settings.copyWith(gridMode: value));
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: HomeGridMode.timeGrid,
                          child: Text(l10n.homeGridModeTime),
                        ),
                        DropdownMenuItem(
                          value: HomeGridMode.courseGrid,
                          child: Text(l10n.homeGridModeCourse),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SettingsFlatTile(
              title: l10n.settingsHomeTimeGridSettings,
              leading: const Icon(Icons.schedule_outlined),
              onTap: () => context.push(AppRoutePaths.settingsTimeGrid),
            ),
            SettingsFlatTile(
              title: l10n.settingsHomeCourseGridSettings,
              leading: const Icon(Icons.school_outlined),
              onTap: () => context.push(AppRoutePaths.settingsCourseGrid),
            ),
          ],
        ),
      ),
    );
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
