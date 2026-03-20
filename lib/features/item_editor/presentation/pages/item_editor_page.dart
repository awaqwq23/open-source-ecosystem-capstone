import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:date_field/date_field.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
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

const double _kEditorBaseRowHeight = 56;
const double _kEditorMultiLineMinHeight = 112;
const double _kEditorHorizontalPadding = 16;
const double _kEditorTrailingPadding = 12;
const double _kEditorErrorGap = 6;
const double _kEditorErrorBottomPadding = 4;

class ItemEditorPage extends ConsumerStatefulWidget {
  const ItemEditorPage({
    this.prefill,
    super.key,
  });

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
      () => ref.read(itemEditorPageControllerProvider.notifier).initialize(widget.prefill),
    );
  }

  @override
  void didUpdateWidget(covariant ItemEditorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.prefill != widget.prefill) {
      Future<void>.microtask(
        () => ref.read(itemEditorPageControllerProvider.notifier).initialize(widget.prefill),
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

    ref.listen<ItemEditorPageState>(
      itemEditorPageControllerProvider,
      (previous, next) {
        _syncControllers(next);
        if (next.submitSucceeded && mounted) {
          notifier.clearSubmitSucceeded();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.editorSubmitSuccess)),
          );
        }
      },
    );

    final state = ref.watch(itemEditorPageControllerProvider);
    _syncControllers(state);
    final l10n = context.l10n;
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final horizontalPadding = isCompact ? 20.0 : 32.0;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 32),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  padding: EdgeInsets.zero,
                  title: AppPageHeaderTitle(
                    text: _createTitle(l10n, state.draft.type),
                  ),
                  trailing: [
                    _SubmitActionButton(
                      onPressed: state.canSubmit ? () => _submit(context, ref, state) : null,
                      isSubmitting: state.isSubmitting,
                    ),
                  ],
                ),
                const Gap(16),
                _TypeSelectorRow(
                  selectedType: state.draft.type,
                  onSelected: notifier.selectType,
                  taskLabel: l10n.editorTypeTask,
                  scheduleLabel: l10n.editorTypeSchedule,
                  memoLabel: l10n.editorTypeMemo,
                ),
                const Gap(20),
                _RoundedInputField(
                  containerKey: const ValueKey('item-editor-field-title'),
                  controller: _titleController,
                  hintText: l10n.editorHintTitle,
                  errorText: state.errors.title,
                  onChanged: notifier.updateTitle,
                  trailing: _ColorTrigger(
                    color: state.draft.color.resolve(Theme.of(context).brightness),
                    onPressed: () => _showColorPicker(context, ref),
                  ),
                ),
                const Gap(12),
                if (state.draft.type != ItemType.memo)
                  _SwitchRow(
                    rowKey: const ValueKey('item-editor-row-all-day'),
                    label: l10n.editorAllDayTitle,
                    value: state.draft.isAllDay,
                    onChanged: notifier.toggleAllDay,
                  ),
                if (state.draft.type == ItemType.memo) ...[
                  _PlainActionRow(
                    rowKey: const ValueKey('item-editor-row-target-date'),
                    label: l10n.editorFieldTargetDate,
                    value: _formatDate(context, state.draft.targetDate),
                    onTap: () => _pickMemoTargetDate(context, ref, state.draft.targetDate),
                  ),
                  _PlainActionRow(
                    rowKey: const ValueKey('item-editor-row-estimated-duration'),
                    label: l10n.editorFieldEstimatedDuration,
                    value: _formatDuration(context, state.draft.estimatedDuration),
                    errorText: state.errors.estimatedDuration,
                    onTap: () => _showDurationPicker(context, ref),
                  ),
                ] else ...[
                  _PlainActionRow(
                    rowKey: const ValueKey('item-editor-row-start'),
                    labelKey: const ValueKey('item-editor-row-start-label'),
                    trailingGroupKey: const ValueKey('item-editor-row-start-trailing-group'),
                    valueKey: const ValueKey('item-editor-row-start-value'),
                    trailingKey: const ValueKey('item-editor-row-start-chevron'),
                    label: l10n.editorFieldStart,
                    value: _formatDateTimeSummary(
                      context,
                      state.draft.startAt,
                      allDay: state.draft.isAllDay,
                    ),
                    onTap: () => _pickStartDateTime(context, ref, state),
                  ),
                  _PlainActionRow(
                    rowKey: const ValueKey('item-editor-row-end'),
                    label: l10n.editorFieldEnd,
                    value: _formatDateTimeSummary(
                      context,
                      state.draft.endAt,
                      allDay: state.draft.isAllDay,
                    ),
                    errorText: state.errors.timeRange,
                    onTap: () => _pickEndDateTime(context, ref, state),
                  ),
                  _PlainActionRow(
                    rowKey: const ValueKey('item-editor-row-repeat'),
                    label: l10n.editorSectionRepeat,
                    value: _repeatLabel(l10n, state.draft.repeatRule),
                    onTap: () => _openRepeatSettings(context, ref, state.draft.repeatRule),
                  ),
                  if (state.draft.type == ItemType.task)
                    _PlainActionRow(
                      rowKey: const ValueKey('item-editor-row-deadline'),
                      label: l10n.editorFieldDeadline,
                      value: state.draft.deadline == null
                          ? l10n.editorDeadlineUnset
                          : _formatDateTimeSummary(
                              context,
                              state.draft.deadline!,
                              allDay: state.draft.isAllDay,
                            ),
                      errorText: state.errors.deadline,
                      onTap: () => _pickDeadlineDateTime(context, ref, state),
                    ),
                ],
                const Gap(20),
                const Divider(),
                const Gap(8),
                _PlainActionRow(
                  rowKey: const ValueKey('item-editor-row-reminder'),
                  label: l10n.editorSectionReminder,
                  value: _reminderLabel(l10n, state.draft.reminder),
                  onTap: () => _openReminderSettings(context, ref, state.draft.reminder),
                ),
                const Gap(20),
                const Divider(),
                const Gap(20),
                _RoundedInputField(
                  containerKey: const ValueKey('item-editor-field-location'),
                  controller: _locationController,
                  hintText: l10n.editorHintLocation,
                  onChanged: notifier.updateLocation,
                ),
                const Gap(12),
                _RoundedInputField(
                  containerKey: const ValueKey('item-editor-field-details'),
                  controller: _detailsController,
                  hintText: l10n.editorHintDetails,
                  onChanged: notifier.updateDetails,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editorSubmitInvalid)),
      );
    }
  }

  Future<void> _showColorPicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(itemEditorPageControllerProvider);
    final l10n = context.l10n;

    return showAppSheetScaffold(
      context: context,
      title: l10n.editorColorPickerTitle,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final color in ItemColorOption.values)
            _ColorChoiceChip(
              color: color.resolve(Theme.of(context).brightness),
              label: _colorLabel(l10n, color),
              selected: state.draft.color == color,
              onPressed: () {
                ref.read(itemEditorPageControllerProvider.notifier).selectColor(color);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickMemoTargetDate(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final picked = await _showDateTimePicker(
      context: context,
      initialDateTime: initialDate,
      mode: DateTimeFieldPickerMode.date,
    );

    if (picked != null && mounted) {
      ref.read(itemEditorPageControllerProvider.notifier).updateTargetDate(
            DateTime(picked.year, picked.month, picked.day),
          );
    }
  }

  Future<void> _pickStartDateTime(
    BuildContext context,
    WidgetRef ref,
    ItemEditorPageState state,
  ) async {
    final picked = await _showDateTimePicker(
      context: context,
      initialDateTime: state.draft.startAt,
      mode: state.draft.isAllDay
          ? DateTimeFieldPickerMode.date
          : DateTimeFieldPickerMode.dateAndTime,
    );

    if (picked != null && mounted) {
      final normalized = state.draft.isAllDay
          ? DateTime(picked.year, picked.month, picked.day)
          : picked;
      ref
          .read(itemEditorPageControllerProvider.notifier)
          .updateStartDateTime(normalized);
    }
  }

  Future<void> _pickEndDateTime(
    BuildContext context,
    WidgetRef ref,
    ItemEditorPageState state,
  ) async {
    final picked = await _showDateTimePicker(
      context: context,
      initialDateTime: state.draft.endAt,
      mode: state.draft.isAllDay
          ? DateTimeFieldPickerMode.date
          : DateTimeFieldPickerMode.dateAndTime,
    );

    if (picked != null && mounted) {
      final normalized = state.draft.isAllDay
          ? DateTime(picked.year, picked.month, picked.day, 23, 59)
          : picked;
      ref.read(itemEditorPageControllerProvider.notifier).updateEndDateTime(normalized);
    }
  }

  Future<void> _pickDeadlineDateTime(
    BuildContext context,
    WidgetRef ref,
    ItemEditorPageState state,
  ) async {
    final picked = await _showDateTimePicker(
      context: context,
      initialDateTime: state.draft.deadline ?? state.draft.endAt,
      mode: state.draft.isAllDay
          ? DateTimeFieldPickerMode.date
          : DateTimeFieldPickerMode.dateAndTime,
    );

    if (picked != null && mounted) {
      final normalized = state.draft.isAllDay
          ? DateTime(picked.year, picked.month, picked.day, 23, 59)
          : picked;
      ref
          .read(itemEditorPageControllerProvider.notifier)
          .updateDeadlineDateTime(normalized);
    }
  }

  Future<DateTime?> _showDateTimePicker({
    required BuildContext context,
    required DateTime initialDateTime,
    required DateTimeFieldPickerMode mode,
  }) {
    return showAdaptiveDateTimePicker(
      context: context,
      mode: mode,
      pickerPlatform: DateTimeFieldPickerPlatform.cupertino,
      initialPickerDateTime: initialDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      cupertinoDatePickerOptions: CupertinoDatePickerOptions(
        minuteInterval: 5,
        saveText: context.l10n.editorPickerConfirm,
        cancelText: context.l10n.editorPickerCancel,
        modalTitleText: switch (mode) {
          DateTimeFieldPickerMode.date => context.l10n.editorFieldTargetDate,
          DateTimeFieldPickerMode.time => context.l10n.editorSectionTime,
          DateTimeFieldPickerMode.dateAndTime => context.l10n.editorSectionTime,
        },
      ),
    );
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
                title: Text(_formatDuration(context, Duration(minutes: minutes))),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRepeatSettings(
    BuildContext context,
    WidgetRef ref,
    RepeatRule current,
  ) async {
    final result = await context.push<RepeatRule>(
      AppRoutePaths.repeatSettings,
      extra: current,
    );
    if (result != null && mounted) {
      ref.read(itemEditorPageControllerProvider.notifier).selectRepeatRule(result);
    }
  }

  Future<void> _openReminderSettings(
    BuildContext context,
    WidgetRef ref,
    ReminderOption current,
  ) async {
    final result = await context.push<ReminderOption>(
      AppRoutePaths.reminderSettings,
      extra: current,
    );
    if (result != null && mounted) {
      ref.read(itemEditorPageControllerProvider.notifier).selectReminder(result);
    }
  }

  String _createTitle(AppLocalizations l10n, ItemType type) {
    return switch (type) {
      ItemType.task => l10n.editorCreateTask,
      ItemType.schedule => l10n.editorCreateSchedule,
      ItemType.memo => l10n.editorCreateMemo,
    };
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
    return MaterialLocalizations.of(context).formatMediumDate(value);
  }

  String _formatTime(BuildContext context, DateTime value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
  }

  String _formatDateTimeSummary(
    BuildContext context,
    DateTime value, {
    required bool allDay,
  }) {
    if (allDay) {
      return _formatDate(context, value);
    }
    return '${_formatDate(context, value)}  ${_formatTime(context, value)}';
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
}

class _TypeSelectorRow extends StatelessWidget {
  const _TypeSelectorRow({
    required this.selectedType,
    required this.onSelected,
    required this.taskLabel,
    required this.scheduleLabel,
    required this.memoLabel,
  });

  final ItemType selectedType;
  final ValueChanged<ItemType> onSelected;
  final String taskLabel;
  final String scheduleLabel;
  final String memoLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeButton(
            selected: selectedType == ItemType.task,
            icon: Icons.check_circle_outline,
            label: taskLabel,
            onPressed: () => onSelected(ItemType.task),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _TypeButton(
            selected: selectedType == ItemType.schedule,
            icon: Icons.calendar_month_outlined,
            label: scheduleLabel,
            onPressed: () => onSelected(ItemType.schedule),
          ),
        ),
        const Gap(12),
        Expanded(
          child: _TypeButton(
            selected: selectedType == ItemType.memo,
            icon: Icons.sticky_note_2_outlined,
            label: memoLabel,
            onPressed: () => onSelected(ItemType.memo),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const Gap(8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorTrigger extends StatelessWidget {
  const _ColorTrigger({
    required this.color,
    required this.onPressed,
  });

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.l10n.editorColorPickerTitle,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.14),
        minimumSize: const Size(32, 32),
        maximumSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
      icon: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ColorChoiceChip extends StatelessWidget {
  const _ColorChoiceChip({
    required this.color,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
            color: color.withValues(alpha: selected ? 0.16 : 0.08),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const Gap(8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitActionButton extends StatelessWidget {
  const _SubmitActionButton({
    required this.onPressed,
    required this.isSubmitting,
  });

  final VoidCallback? onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      return SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      tooltip: context.l10n.editorSubmitButton,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.add_circle_outline),
    );
  }
}

class _RoundedInputField extends StatelessWidget {
  const _RoundedInputField({
    this.containerKey,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.trailing,
    this.maxLines = 1,
    this.onChanged,
  });

  final Key? containerKey;
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final Widget? trailing;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSingleLine = maxLines == 1;
    final minHeight =
        isSingleLine ? _kEditorBaseRowHeight : _kEditorMultiLineMinHeight;
    final maxHeight = isSingleLine ? _kEditorBaseRowHeight : _kEditorBaseRowHeight * maxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: containerKey,
          constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textAlignVertical: isSingleLine ? TextAlignVertical.center : null,
                  minLines: isSingleLine ? 1 : 4,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                    isCollapsed: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: _kEditorHorizontalPadding,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              if (trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: _kEditorTrailingPadding),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
        if (errorText != null) ...[
          const Gap(_kEditorErrorGap),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    this.rowKey,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final Key? rowKey;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: rowKey,
      height: _kEditorBaseRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _PlainActionRow extends StatelessWidget {
  const _PlainActionRow({
    this.rowKey,
    this.labelKey,
    this.trailingGroupKey,
    this.valueKey,
    this.trailingKey,
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final Key? rowKey;
  final Key? labelKey;
  final Key? trailingGroupKey;
  final Key? valueKey;
  final Key? trailingKey;
  final String label;
  final String value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: SizedBox(
            key: rowKey,
            height: _kEditorBaseRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    key: labelKey,
                    label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: Row(
                    key: trailingGroupKey,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          key: valueKey,
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        key: trailingKey,
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: _kEditorErrorBottomPadding),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
