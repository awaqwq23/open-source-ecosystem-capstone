import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:huajuan_agenda/features/time_picker/presentation/viewmodels/time_picker_view_model.dart';
import 'package:intl/intl.dart';
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
    final weeks = notifier.visibleWeeks();
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

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
              onPressed: () => context.pop(notifier.confirmSelection()),
              child: Text(context.l10n.editorPickerConfirm),
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
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity <= -240) {
                    notifier.showNextMonth();
                  } else if (velocity >= 240) {
                    notifier.showPreviousMonth();
                  }
                },
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
                            child: TextButton(
                              onPressed: () => _pickMonth(context, notifier, state.displayMonth),
                              child: Text(
                                '${state.displayMonth.year}/${state.displayMonth.month}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
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
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ModeChip(
                          label: context.l10n.aiPeriodDay,
                          selected: state.mode == TimePickerMode.day,
                          onTap: () => notifier.selectMode(TimePickerMode.day),
                        ),
                        _ModeChip(
                          label: context.l10n.aiPeriodWeek,
                          selected: state.mode == TimePickerMode.week,
                          onTap: () => notifier.selectMode(TimePickerMode.week),
                        ),
                        _ModeChip(
                          label: context.l10n.aiPeriodMonth,
                          selected: state.mode == TimePickerMode.month,
                          onTap: () => notifier.selectMode(TimePickerMode.month),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(90),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8, bottom: 8),
                              child: _SelectionCell(
                                label: DateFormat.MMMM(locale).format(state.displayMonth),
                                active: notifier.isMonthSelected(),
                                onTap: () => notifier.selectMonth(state.displayMonth),
                              ),
                            ),
                            for (var weekday = 0; weekday < 7; weekday++)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Center(
                                  child: Text(_weekdayLabel(locale, weekday)),
                                ),
                              ),
                          ],
                        ),
                        for (final week in weeks)
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8, bottom: 8),
                                child: _SelectionCell(
                                  label: _weekLabel(context, week.startOfWeek),
                                  active: notifier.isWeekSelected(week.startOfWeek),
                                  onTap: () => notifier.selectWeek(week.startOfWeek),
                                ),
                              ),
                              for (final day in week.days)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                                  child: _DayCell(
                                    day: day,
                                    displayMonth: state.displayMonth,
                                    selected: notifier.isDaySelected(day),
                                    onTap: () => notifier.selectDate(day),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectionSummary(context, state.selectedAnchor, state.mode),
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickMonth(
    BuildContext context,
    TimePickerViewModel notifier,
    DateTime initialDate,
  ) async {
    final result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (result == null) {
      return;
    }
    notifier.jumpToMonth(result);
  }

  String _weekdayLabel(String locale, int weekdayIndex) {
    final monday = DateTime(2026, 1, 5).add(Duration(days: weekdayIndex));
    return locale.startsWith('zh')
        ? '周${['一', '二', '三', '四', '五', '六', '日'][weekdayIndex]}'
        : DateFormat('EEE', locale).format(monday);
  }

  String _weekLabel(BuildContext context, DateTime weekStart) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekOfMonth = ((weekStart.day + DateTime(weekStart.year, weekStart.month, 1).weekday -
                DateTime.monday -
                1) ~/
            7) +
        1;
    return locale.startsWith('zh') ? '第$weekOfMonth周' : 'Week $weekOfMonth';
  }

  String _selectionSummary(
    BuildContext context,
    DateTime anchor,
    TimePickerMode mode,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return switch (mode) {
      TimePickerMode.day => '已选择：${DateFormat.yMd(locale).format(anchor)}',
      TimePickerMode.week => locale.startsWith('zh')
          ? '已选择：${DateFormat.yM(locale).format(anchor)} 第${_weekOfMonth(anchor)}周'
          : 'Selected: Week ${_weekOfMonth(anchor)} of ${DateFormat.yMMMM(locale).format(anchor)}',
      TimePickerMode.month => locale.startsWith('zh')
          ? '已选择：${anchor.year}/${anchor.month}'
          : 'Selected: ${DateFormat.yMMMM(locale).format(anchor)}',
    };
  }

  int _weekOfMonth(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final offset = firstDay.weekday - DateTime.monday;
    return ((date.day + offset - 1) ~/ 7) + 1;
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

class _SelectionCell extends StatelessWidget {
  const _SelectionCell({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 52,
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? theme.colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.displayMonth,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final DateTime displayMonth;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInMonth = day.month == displayMonth.month;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 52,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.14)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selected)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
            Text(
              '${day.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isInMonth
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
