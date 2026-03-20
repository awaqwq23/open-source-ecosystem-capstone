import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:huajuan_agenda/features/time_picker/presentation/viewmodels/time_picker_view_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class TimePickerPage extends ConsumerStatefulWidget {
  const TimePickerPage({
    this.args,
    super.key,
  });

  final TimePickerArgs? args;

  @override
  ConsumerState<TimePickerPage> createState() => _TimePickerPageState();
}

class _TimePickerPageState extends ConsumerState<TimePickerPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(timePickerViewModelProvider.notifier).initialize(widget.args),
    );
  }

  @override
  void didUpdateWidget(covariant TimePickerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.args != widget.args) {
      Future<void>.microtask(
        () => ref.read(timePickerViewModelProvider.notifier).initialize(widget.args),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timePickerViewModelProvider);
    final notifier = ref.read(timePickerViewModelProvider.notifier);
    final days = notifier.visibleDays();
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.Tooltip(
              tooltip: (context) => Text(context.l10n.commonBack),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.back),
                onPressed: context.pop,
              ),
            ),
          ],
          title: Text(context.l10n.timePickerTitle),
          trailing: [
            ui.PrimaryButton(
              onPressed: () => context.pop(state.selectedDate),
              child: const Text('确认'),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: ui.Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ui.IconButton.ghost(
                        icon: const Icon(AppIcons.previousPeriod),
                        onPressed: notifier.showPreviousMonth,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '${state.displayMonth.year}/${state.displayMonth.month}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      ui.IconButton.ghost(
                        icon: const Icon(AppIcons.nextPeriod),
                        onPressed: notifier.showNextMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _ModeChip(
                        label: '日',
                        selected: state.mode == TimePickerMode.day,
                        onTap: () => notifier.selectMode(TimePickerMode.day),
                      ),
                      _ModeChip(
                        label: '周',
                        selected: state.mode == TimePickerMode.week,
                        onTap: () => notifier.selectMode(TimePickerMode.week),
                      ),
                      _ModeChip(
                        label: '月',
                        selected: state.mode == TimePickerMode.month,
                        onTap: () => notifier.selectMode(TimePickerMode.month),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: days.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final selected = day != null &&
                          day.year == state.selectedDate.year &&
                          day.month == state.selectedDate.month &&
                          day.day == state.selectedDate.day;
                      return InkWell(
                        onTap: day == null ? null : () => notifier.selectDate(day),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: selected
                                ? theme.colorScheme.primary.withValues(alpha: 0.16)
                                : theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: Center(
                            child: Text(day == null ? '' : '${day.day}'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '已选择：${state.selectedDate.year}/${state.selectedDate.month}/${state.selectedDate.day}',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return selected
        ? ui.PrimaryButton(
            onPressed: onTap,
            child: Text(label),
          )
        : ui.OutlineButton(
            onPressed: onTap,
            child: Text(label),
          );
  }
}
