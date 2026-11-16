import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/settings/domain/models/home_settings.dart';
import 'package:luotopia/features/pages/settings/presentation/viewmodels/settings_view_model.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:luotopia/shared/presentation/widgets/app_date_time_pickers.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SettingsTimeGridPage extends ConsumerWidget {
  const SettingsTimeGridPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsViewModelProvider);
    final settings = state.homeSettings;

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: context.l10n.settingsHomeTimeGridSettings),
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
            _StepperTile(
              title: context.l10n.settingsHomeBlockDuration,
              value: context.l10n.settingsMinutesValue(settings.blockDurationMinutes),
              onDecrease: settings.blockDurationMinutes > 15
                  ? () => _save(ref, settings.copyWith(
                        blockDurationMinutes: settings.blockDurationMinutes - 15,
                      ))
                  : null,
              onIncrease: () => _save(ref, settings.copyWith(
                    blockDurationMinutes: settings.blockDurationMinutes + 15,
                  )),
            ),
            _StepperTile(
              title: context.l10n.settingsHomeBlockGap,
              value: context.l10n.settingsMinutesValue(settings.blockGapMinutes),
              onDecrease: settings.blockGapMinutes > 0
                  ? () => _save(ref, settings.copyWith(
                        blockGapMinutes: settings.blockGapMinutes - 5,
                      ))
                  : null,
              onIncrease: () => _save(ref, settings.copyWith(
                    blockGapMinutes: settings.blockGapMinutes + 5,
                  )),
            ),
            _StepperTile(
              title: context.l10n.settingsHomeBlockCount,
              value: '${settings.blockCount}',
              onDecrease: settings.blockCount > 1
                  ? () => _save(ref, settings.copyWith(
                        blockCount: settings.blockCount - 1,
                      ))
                  : null,
              onIncrease: () => _save(ref, settings.copyWith(
                    blockCount: settings.blockCount + 1,
                  )),
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
    final result = await AppDateTimePickers.pickTime(
      context,
      initialTime: settings.dayStartTime,
    );
    if (result == null) return;
    await _save(ref, settings.copyWith(dayStartTime: result));
  }

  Future<void> _save(WidgetRef ref, HomeSettings settings) {
    return ref.read(settingsViewModelProvider.notifier).saveHomeSettings(settings);
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
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
