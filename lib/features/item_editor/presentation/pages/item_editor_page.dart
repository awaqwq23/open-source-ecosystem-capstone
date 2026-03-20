import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_validator.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/viewmodels/item_editor_header_view_model.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_header.dart';
import 'package:huajuan_agenda/shared/widgets/app_sheet_scaffold.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class ItemEditorPage extends ConsumerStatefulWidget {
  const ItemEditorPage({this.prefill, super.key});

  final ItemEditorPrefill? prefill;

  @override
  ConsumerState<ItemEditorPage> createState() => _ItemEditorPageState();
}

class _ItemEditorPageState extends ConsumerState<ItemEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _detailsController = TextEditingController();
    _locationController = TextEditingController();
    Future<void>.microtask(
      () => ref
          .read(itemEditorPageControllerProvider.notifier)
          .initialize(widget.prefill),
    );
  }

  @override
  void didUpdateWidget(covariant ItemEditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefill != widget.prefill) {
      Future<void>.microtask(
        () => ref
            .read(itemEditorPageControllerProvider.notifier)
            .initialize(widget.prefill),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(itemEditorPageControllerProvider.notifier);

    ref.listen<ItemEditorPageState>(itemEditorPageControllerProvider, (
      previous,
      next,
    ) {
      _syncControllers(next);
      if (next.submitSucceeded && mounted) {
        notifier.clearSubmitSucceeded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.editorSubmitSuccess)),
        );
      }
    });

    final state = ref.watch(itemEditorPageControllerProvider);
    _syncControllers(state);
    final l10n = context.l10n;
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final pagePadding = EdgeInsets.fromLTRB(
      isCompact ? 20 : 32,
      20,
      isCompact ? 20 : 32,
      24,
    );

    return SafeArea(
      top: false,
      child: Column(
        children: [
          AppPageHeader(
            centerTitleWhenCompact: true,
            title: AppPageHeaderTitle(
              text: _typeLabel(l10n, state.draft.type),
              center: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: pagePadding,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _typeIntro(l10n, state.draft.type),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.55,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(20),
                      _TypeSwitcherCard(
                        currentType: state.draft.type,
                        taskLabel: l10n.editorTypeTask,
                        scheduleLabel: l10n.editorTypeSchedule,
                        memoLabel: l10n.editorTypeMemo,
                        onChanged: notifier.selectType,
                      ),
                      const Gap(16),
                      _OverviewCard(
                        title: state.draft.title.trim().isEmpty
                            ? l10n.editorOverviewUntitled
                            : state.draft.title.trim(),
                        subtitle: _overviewSubtitle(l10n, state.draft.type),
                        typeLabel: _typeLabel(l10n, state.draft.type),
                        colorLabel: _colorLabel(l10n, state.draft.color),
                        timeLabel: _overviewTimeLabel(l10n, state),
                        reminderLabel: _reminderLabel(
                          l10n,
                          state.draft.reminder,
                        ),
                        repeatLabel: _repeatLabel(l10n, state.draft.repeatRule),
                        accentColor: state.draft.color.resolve(
                          Theme.of(context).brightness,
                        ),
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionBasic,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,
                              onChanged: notifier.updateTitle,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: l10n.editorFieldTitle,
                                hintText: l10n.editorHintTitle,
                                errorText: state.errors.title,
                              ),
                            ),
                            const Gap(16),
                            TextField(
                              controller: _detailsController,
                              minLines: 3,
                              maxLines: 5,
                              onChanged: notifier.updateDetails,
                              decoration: InputDecoration(
                                labelText: l10n.editorFieldDetails,
                                hintText: l10n.editorHintDetails,
                              ),
                            ),
                            const Gap(16),
                            TextField(
                              controller: _locationController,
                              onChanged: notifier.updateLocation,
                              decoration: InputDecoration(
                                labelText: l10n.editorFieldLocation,
                                hintText: l10n.editorHintLocation,
                              ),
                            ),
                            const Gap(20),
                            Text(
                              l10n.editorSectionColor,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final color in ItemColorOption.values)
                                  _ColorChip(
                                    option: color,
                                    label: _colorLabel(l10n, color),
                                    selected: state.draft.color == color,
                                    onPressed: () =>
                                        notifier.selectColor(color),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionTime,
                        child: _TimeSection(
                          isCompact: isCompact,
                          type: state.draft.type,
                          startDateText: _formatDate(
                            context,
                            state.draft.startAt,
                          ),
                          startTimeText: _formatTime(
                            context,
                            state.draft.startAt,
                          ),
                          endDateText: _formatDate(context, state.draft.endAt),
                          endTimeText: _formatTime(context, state.draft.endAt),
                          deadlineDateText: _formatDate(
                            context,
                            state.draft.deadline ?? state.draft.endAt,
                          ),
                          deadlineTimeText: _formatTime(
                            context,
                            state.draft.deadline ?? state.draft.endAt,
                          ),
                          targetDateText: _formatDate(
                            context,
                            state.draft.targetDate,
                          ),
                          durationText: _formatDuration(
                            context,
                            state.draft.estimatedDuration,
                          ),
                          timeErrorText: state.errors.timeRange,
                          deadlineErrorText: state.errors.deadline,
                          deadline: state.draft.deadline,
                          onPickStartDate: () => _pickDate(
                            context: context,
                            initialDate: state.draft.startAt,
                            onSelected: notifier.updateStartDate,
                          ),
                          onPickStartTime: () => _pickTime(
                            context: context,
                            initialDateTime: state.draft.startAt,
                            onSelected: notifier.updateStartTime,
                          ),
                          onPickEndDate: () => _pickDate(
                            context: context,
                            initialDate: state.draft.endAt,
                            onSelected: notifier.updateEndDate,
                          ),
                          onPickEndTime: () => _pickTime(
                            context: context,
                            initialDateTime: state.draft.endAt,
                            onSelected: notifier.updateEndTime,
                          ),
                          onPickDeadlineDate: () => _pickDate(
                            context: context,
                            initialDate:
                                state.draft.deadline ?? state.draft.endAt,
                            onSelected: notifier.updateDeadlineDate,
                          ),
                          onPickDeadlineTime: () => _pickTime(
                            context: context,
                            initialDateTime:
                                state.draft.deadline ?? state.draft.endAt,
                            onSelected: notifier.updateDeadlineTime,
                          ),
                          onClearDeadline: notifier.clearDeadline,
                          onPickTargetDate: () => _pickDate(
                            context: context,
                            initialDate: state.draft.targetDate,
                            onSelected: notifier.updateTargetDate,
                          ),
                          onPickDuration: () =>
                              _showDurationPicker(context, ref),
                        ),
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionRules,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.editorSectionReminder,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(12),
                            _OptionWrap(
                              options: ReminderOption.values
                                  .map(
                                    (option) => _OptionData<ReminderOption>(
                                      value: option,
                                      label: _reminderLabel(l10n, option),
                                    ),
                                  )
                                  .toList(growable: false),
                              selected: state.draft.reminder,
                              onSelected: notifier.selectReminder,
                            ),
                            const Gap(20),
                            Text(
                              l10n.editorSectionRepeat,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Gap(12),
                            _OptionWrap(
                              options: RepeatRule.values
                                  .map(
                                    (rule) => _OptionData<RepeatRule>(
                                      value: rule,
                                      label: _repeatLabel(l10n, rule),
                                    ),
                                  )
                                  .toList(growable: false),
                              selected: state.draft.repeatRule,
                              onSelected: notifier.selectRepeatRule,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _BottomSubmitBar(
            child: ui.PrimaryButton(
              onPressed: state.canSubmit
                  ? () => _submit(context, ref, state)
                  : null,
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.editorSubmitButton),
            ),
          ),
        ],
      ),
    );
  }

  void _syncControllers(ItemEditorPageState state) {
    _syncTextController(_titleController, state.draft.title);
    _syncTextController(_detailsController, state.draft.details);
    _syncTextController(_locationController, state.draft.location);
  }

  void _syncTextController(TextEditingController controller, String text) {
    if (controller.text == text) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    ItemEditorPageState state,
  ) async {
    final l10n = context.l10n;
    final errors = ItemEditorValidator.validate(state.draft, l10n);
    final success = await ref
        .read(itemEditorPageControllerProvider.notifier)
        .submit(errors);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.editorSubmitInvalid)));
    }
  }

  String _typeLabel(AppLocalizations l10n, ItemType type) {
    return switch (type) {
      ItemType.task => l10n.editorTypeTask,
      ItemType.schedule => l10n.editorTypeSchedule,
      ItemType.memo => l10n.editorTypeMemo,
    };
  }

  String _typeIntro(AppLocalizations l10n, ItemType type) {
    return switch (type) {
      ItemType.task => l10n.editorIntroTask,
      ItemType.schedule => l10n.editorIntroSchedule,
      ItemType.memo => l10n.editorIntroMemo,
    };
  }

  String _overviewSubtitle(AppLocalizations l10n, ItemType type) {
    return switch (type) {
      ItemType.task => l10n.editorOverviewTaskSubtitle,
      ItemType.schedule => l10n.editorOverviewScheduleSubtitle,
      ItemType.memo => l10n.editorOverviewMemoSubtitle,
    };
  }

  String _overviewTimeLabel(AppLocalizations l10n, ItemEditorPageState state) {
    final draft = state.draft;

    if (draft.type == ItemType.memo) {
      return '${_formatDate(context, draft.targetDate)} · '
          '${_formatDuration(context, draft.estimatedDuration)}';
    }

    final buffer = StringBuffer()
      ..write(
        '${_formatDate(context, draft.startAt)} ${_formatTime(context, draft.startAt)}',
      )
      ..write(' - ')
      ..write(
        '${_formatDate(context, draft.endAt)} ${_formatTime(context, draft.endAt)}',
      );

    if (draft.type == ItemType.task && draft.deadline != null) {
      buffer
        ..write('\n')
        ..write(l10n.editorOverviewDeadlinePrefix)
        ..write(' ')
        ..write(_formatDate(context, draft.deadline!))
        ..write(' ')
        ..write(_formatTime(context, draft.deadline!));
    }

    return buffer.toString();
  }

  String _colorLabel(AppLocalizations l10n, ItemColorOption color) {
    return switch (color) {
      ItemColorOption.sky => l10n.editorColorSky,
      ItemColorOption.jade => l10n.editorColorJade,
      ItemColorOption.amber => l10n.editorColorAmber,
      ItemColorOption.coral => l10n.editorColorCoral,
      ItemColorOption.orchid => l10n.editorColorOrchid,
      ItemColorOption.slate => l10n.editorColorSlate,
    };
  }

  String _reminderLabel(AppLocalizations l10n, ReminderOption option) {
    return switch (option) {
      ReminderOption.none => l10n.editorReminderNone,
      ReminderOption.atTime => l10n.editorReminderAtTime,
      ReminderOption.fiveMinutesBefore => l10n.editorReminderFiveMinutes,
      ReminderOption.fifteenMinutesBefore => l10n.editorReminderFifteenMinutes,
      ReminderOption.oneHourBefore => l10n.editorReminderOneHour,
      ReminderOption.oneDayBefore => l10n.editorReminderOneDay,
    };
  }

  String _repeatLabel(AppLocalizations l10n, RepeatRule rule) {
    return switch (rule) {
      RepeatRule.none => l10n.editorRepeatNone,
      RepeatRule.everyDay => l10n.editorRepeatDaily,
      RepeatRule.weekdays => l10n.editorRepeatWeekdays,
      RepeatRule.everyWeek => l10n.editorRepeatWeekly,
      RepeatRule.everyMonth => l10n.editorRepeatMonthly,
      RepeatRule.everyYear => l10n.editorRepeatYearly,
    };
  }

  String _formatDate(BuildContext context, DateTime value) {
    final material = MaterialLocalizations.of(context);
    return material.formatMediumDate(value);
  }

  String _formatTime(BuildContext context, DateTime value) {
    final material = MaterialLocalizations.of(context);
    return material.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
  }

  String _formatDuration(BuildContext context, Duration value) {
    final l10n = context.l10n;
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return l10n.editorDurationHourMinute(hours, minutes);
    }
    if (hours > 0) {
      return l10n.editorDurationHours(hours);
    }
    return l10n.editorDurationMinutes(value.inMinutes);
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  Future<void> _pickTime({
    required BuildContext context,
    required DateTime initialDateTime,
    required void Function(int hour, int minute) onSelected,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked.hour, picked.minute);
    }
  }

  Future<void> _showDurationPicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(itemEditorPageControllerProvider);
    final l10n = context.l10n;
    final currentMinutes = state.draft.estimatedDuration.inMinutes;
    final options = <int>[15, 30, 45, 60, 90, 120, 180];

    return showAppSheetScaffold(
      context: context,
      title: l10n.editorDurationPickerTitle,
      child: RadioGroup<int>(
        groupValue: currentMinutes,
        onChanged: (value) {
          if (value == null) {
            return;
          }
          ref
              .read(itemEditorPageControllerProvider.notifier)
              .updateEstimatedDuration(Duration(minutes: value));
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final minutes in options)
              RadioListTile<int>(
                value: minutes,
                title: Text(
                  _formatDuration(context, Duration(minutes: minutes)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomSubmitBar extends StatelessWidget {
  const _BottomSubmitBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}

class _TypeSwitcherCard extends StatelessWidget {
  const _TypeSwitcherCard({
    required this.currentType,
    required this.taskLabel,
    required this.scheduleLabel,
    required this.memoLabel,
    required this.onChanged,
  });

  final ItemType currentType;
  final String taskLabel;
  final String scheduleLabel;
  final String memoLabel;
  final ValueChanged<ItemType> onChanged;

  @override
  Widget build(BuildContext context) {
    return ui.Card(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _TypeOption(
              label: taskLabel,
              icon: Icons.checklist_rounded,
              selected: currentType == ItemType.task,
              onTap: () => onChanged(ItemType.task),
            ),
          ),
          const Gap(8),
          Expanded(
            child: _TypeOption(
              label: scheduleLabel,
              icon: Icons.event_note_rounded,
              selected: currentType == ItemType.schedule,
              onTap: () => onChanged(ItemType.schedule),
            ),
          ),
          const Gap(8),
          Expanded(
            child: _TypeOption(
              label: memoLabel,
              icon: Icons.sticky_note_2_outlined,
              selected: currentType == ItemType.memo,
              onTap: () => onChanged(ItemType.memo),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.14)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const Gap(8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.colorLabel,
    required this.timeLabel,
    required this.reminderLabel,
    required this.repeatLabel,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String typeLabel;
  final String colorLabel;
  final String timeLabel;
  final String reminderLabel;
  final String repeatLabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      key: const Key('item-editor-overview-card'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.18),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: theme.colorScheme.surface.withValues(alpha: 0.78),
            ),
            child: Text(
              typeLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const Gap(8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const Gap(20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _OverviewMetric(
                label: context.l10n.editorOverviewTimeLabel,
                value: timeLabel,
                icon: Icons.schedule_rounded,
              ),
              _OverviewMetric(
                label: context.l10n.editorOverviewReminderLabel,
                value: reminderLabel,
                icon: Icons.notifications_active_outlined,
              ),
              _OverviewMetric(
                label: context.l10n.editorOverviewRepeatLabel,
                value: repeatLabel,
                icon: Icons.repeat_rounded,
              ),
              _OverviewMetric(
                label: context.l10n.editorOverviewColorLabel,
                value: colorLabel,
                icon: Icons.palette_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface.withValues(alpha: 0.78),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const Gap(8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const Gap(10),
          Text(
            value,
            key: Key('overview-$label'),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({
    required this.isCompact,
    required this.type,
    required this.startDateText,
    required this.startTimeText,
    required this.endDateText,
    required this.endTimeText,
    required this.deadlineDateText,
    required this.deadlineTimeText,
    required this.targetDateText,
    required this.durationText,
    required this.timeErrorText,
    required this.deadlineErrorText,
    required this.deadline,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
    required this.onPickDeadlineDate,
    required this.onPickDeadlineTime,
    required this.onClearDeadline,
    required this.onPickTargetDate,
    required this.onPickDuration,
  });

  final bool isCompact;
  final ItemType type;
  final String startDateText;
  final String startTimeText;
  final String endDateText;
  final String endTimeText;
  final String deadlineDateText;
  final String deadlineTimeText;
  final String targetDateText;
  final String durationText;
  final String? timeErrorText;
  final String? deadlineErrorText;
  final DateTime? deadline;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;
  final VoidCallback onPickDeadlineDate;
  final VoidCallback onPickDeadlineTime;
  final VoidCallback onClearDeadline;
  final VoidCallback onPickTargetDate;
  final VoidCallback onPickDuration;

  @override
  Widget build(BuildContext context) {
    if (type == ItemType.memo) {
      return _ResponsiveGrid(
        isCompact: isCompact,
        children: [
          _SummaryActionCard(
            title: context.l10n.editorFieldTargetDate,
            value: targetDateText,
            leadingIcon: Icons.today_outlined,
            primaryLabel: context.l10n.editorFieldTargetDate,
            primaryValue: targetDateText,
            onPrimaryTap: onPickTargetDate,
            primaryKey: 'target-date',
          ),
          _SummaryActionCard(
            title: context.l10n.editorFieldEstimatedDuration,
            value: durationText,
            leadingIcon: Icons.timelapse_rounded,
            primaryLabel: context.l10n.editorFieldEstimatedDuration,
            primaryValue: durationText,
            onPrimaryTap: onPickDuration,
            primaryKey: 'estimated-duration',
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ResponsiveGrid(
          isCompact: isCompact,
          children: [
            _SummaryActionCard(
              title: context.l10n.editorSectionStart,
              value: '$startDateText $startTimeText',
              leadingIcon: Icons.play_circle_outline_rounded,
              primaryLabel: context.l10n.editorFieldStartDate,
              primaryValue: startDateText,
              onPrimaryTap: onPickStartDate,
              secondaryLabel: context.l10n.editorFieldStartTime,
              secondaryValue: startTimeText,
              onSecondaryTap: onPickStartTime,
              primaryKey: 'start-date',
              secondaryKey: 'start-time',
            ),
            _SummaryActionCard(
              title: context.l10n.editorSectionEnd,
              value: '$endDateText $endTimeText',
              leadingIcon: Icons.flag_outlined,
              primaryLabel: context.l10n.editorFieldEndDate,
              primaryValue: endDateText,
              onPrimaryTap: onPickEndDate,
              secondaryLabel: context.l10n.editorFieldEndTime,
              secondaryValue: endTimeText,
              onSecondaryTap: onPickEndTime,
              primaryKey: 'end-date',
              secondaryKey: 'end-time',
            ),
          ],
        ),
        if (timeErrorText != null) ...[
          const Gap(12),
          Text(
            timeErrorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        if (type == ItemType.task) ...[
          const Gap(16),
          _SummaryActionCard(
            title: context.l10n.editorFieldDeadline,
            value: deadline == null
                ? context.l10n.editorDeadlineUnset
                : '$deadlineDateText $deadlineTimeText',
            leadingIcon: Icons.alarm_on_outlined,
            primaryLabel: context.l10n.editorFieldDeadlineDate,
            primaryValue: deadlineDateText,
            onPrimaryTap: onPickDeadlineDate,
            secondaryLabel: context.l10n.editorFieldDeadlineTime,
            secondaryValue: deadlineTimeText,
            onSecondaryTap: onPickDeadlineTime,
            trailing: deadline == null
                ? null
                : TextButton(
                    onPressed: onClearDeadline,
                    child: Text(context.l10n.editorDeadlineClear),
                  ),
            primaryKey: 'deadline-date',
            secondaryKey: 'deadline-time',
          ),
          if (deadlineErrorText != null) ...[
            const Gap(12),
            Text(
              deadlineErrorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.isCompact, required this.children});

  final bool isCompact;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const Gap(12),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index != children.length - 1) const Gap(12),
        ],
      ],
    );
  }
}

class _SummaryActionCard extends StatelessWidget {
  const _SummaryActionCard({
    required this.title,
    required this.value,
    required this.leadingIcon,
    required this.primaryLabel,
    required this.primaryValue,
    required this.onPrimaryTap,
    required this.primaryKey,
    this.secondaryLabel,
    this.secondaryValue,
    this.onSecondaryTap,
    this.secondaryKey,
    this.trailing,
  });

  final String title;
  final String value;
  final IconData leadingIcon;
  final String primaryLabel;
  final String primaryValue;
  final VoidCallback onPrimaryTap;
  final String primaryKey;
  final String? secondaryLabel;
  final String? secondaryValue;
  final VoidCallback? onSecondaryTap;
  final String? secondaryKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerChildren = <Widget>[
      Icon(leadingIcon, color: theme.colorScheme.primary),
      const Gap(10),
      Expanded(
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ];
    if (trailing != null) {
      headerChildren.add(trailing!);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.28,
        ),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: headerChildren,
          ),
          const Gap(10),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const Gap(14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickActionChip(
                keyName: primaryKey,
                label: primaryLabel,
                value: primaryValue,
                onTap: onPrimaryTap,
              ),
              if (secondaryLabel != null &&
                  secondaryValue != null &&
                  onSecondaryTap != null)
                _QuickActionChip(
                  keyName: secondaryKey!,
                  label: secondaryLabel!,
                  value: secondaryValue!,
                  onTap: onSecondaryTap!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.keyName,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('item-editor-$keyName'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ui.Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(16),
          child,
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.option,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final ItemColorOption option;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = option.resolve(theme.brightness);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: selected ? 18 : 16,
                height: selected ? 18 : 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                        key: Key('selected-color-indicator'),
                      )
                    : null,
              ),
              const Gap(10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionWrap<T> extends StatelessWidget {
  const _OptionWrap({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<_OptionData<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option.label),
            selected: option.value == selected,
            onSelected: (_) => onSelected(option.value),
            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.16),
          ),
      ],
    );
  }
}

class _OptionData<T> {
  const _OptionData({required this.value, required this.label});

  final T value;
  final String label;
}
