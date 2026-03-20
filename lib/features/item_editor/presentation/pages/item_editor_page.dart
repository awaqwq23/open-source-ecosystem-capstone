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
        () =>
            ref.read(itemEditorPageControllerProvider.notifier).initialize(widget.prefill),
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
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Column(
        children: [
          AppPageHeader(
            centerTitleWhenCompact: true,
            title: AppPageHeaderTitle(
              text: _typeLabel(l10n, state.draft.type),
              center: true,
              showDropdownIndicator: true,
              onPressed: () => _showTypePicker(context, ref),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 20 : 32,
                20,
                isCompact ? 20 : 32,
                32,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.editorDescription,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const Gap(20),
                      _SectionCard(
                        title: l10n.editorSectionBasic,
                        child: Column(
                          children: [
                            TextField(
                              controller: _titleController,
                              onChanged: notifier.updateTitle,
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
                          ],
                        ),
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionColor,
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (final color in ItemColorOption.values)
                              _ColorChip(
                                option: color,
                                label: _colorLabel(l10n, color),
                                selected: state.draft.color == color,
                                onPressed: () => notifier.selectColor(color),
                              ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionTime,
                        child: Column(
                          children: [
                            if (state.draft.type == ItemType.memo) ...[
                              _DateField(
                                label: l10n.editorFieldTargetDate,
                                value: _formatDate(context, state.draft.targetDate),
                                onTap: () => _pickDate(
                                  context: context,
                                  initialDate: state.draft.targetDate,
                                  onSelected: notifier.updateTargetDate,
                                ),
                              ),
                              const Gap(16),
                              _DurationField(
                                label: l10n.editorFieldEstimatedDuration,
                                value: _formatDuration(context, state.draft.estimatedDuration),
                                errorText: state.errors.estimatedDuration,
                                onTap: () => _showDurationPicker(context, ref),
                              ),
                            ] else ...[
                              _DateField(
                                label: l10n.editorFieldStartDate,
                                value: _formatDate(context, state.draft.startAt),
                                onTap: () => _pickDate(
                                  context: context,
                                  initialDate: state.draft.startAt,
                                  onSelected: notifier.updateStartDate,
                                ),
                              ),
                              const Gap(16),
                              _DateField(
                                label: l10n.editorFieldStartTime,
                                value: _formatTime(context, state.draft.startAt),
                                onTap: () => _pickTime(
                                  context: context,
                                  initialDateTime: state.draft.startAt,
                                  onSelected: notifier.updateStartTime,
                                ),
                              ),
                              const Gap(16),
                              _DateField(
                                label: l10n.editorFieldEndDate,
                                value: _formatDate(context, state.draft.endAt),
                                onTap: () => _pickDate(
                                  context: context,
                                  initialDate: state.draft.endAt,
                                  onSelected: notifier.updateEndDate,
                                ),
                              ),
                              const Gap(16),
                              _DateField(
                                label: l10n.editorFieldEndTime,
                                value: _formatTime(context, state.draft.endAt),
                                onTap: () => _pickTime(
                                  context: context,
                                  initialDateTime: state.draft.endAt,
                                  onSelected: notifier.updateEndTime,
                                ),
                              ),
                              if (state.errors.timeRange != null) ...[
                                const Gap(12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    state.errors.timeRange!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                              if (state.draft.type == ItemType.task) ...[
                                const Gap(16),
                                _TaskDeadlineSection(
                                  deadline: state.draft.deadline,
                                  dateText: _formatDate(
                                    context,
                                    state.draft.deadline ?? state.draft.endAt,
                                  ),
                                  timeText: _formatTime(
                                    context,
                                    state.draft.deadline ?? state.draft.endAt,
                                  ),
                                  errorText: state.errors.deadline,
                                  onPickDate: () => _pickDate(
                                    context: context,
                                    initialDate: state.draft.deadline ?? state.draft.endAt,
                                    onSelected: notifier.updateDeadlineDate,
                                  ),
                                  onPickTime: () => _pickTime(
                                    context: context,
                                    initialDateTime:
                                        state.draft.deadline ?? state.draft.endAt,
                                    onSelected: notifier.updateDeadlineTime,
                                  ),
                                  onClear: notifier.clearDeadline,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionReminder,
                        child: _OptionWrap(
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
                      ),
                      const Gap(16),
                      _SectionCard(
                        title: l10n.editorSectionRepeat,
                        child: _OptionWrap(
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
                      ),
                      const Gap(24),
                      SizedBox(
                        width: double.infinity,
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
                ),
              ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.editorSubmitInvalid)),
      );
    }
  }

  String _typeLabel(AppLocalizations l10n, ItemType type) {
    return switch (type) {
      ItemType.task => l10n.editorTypeTask,
      ItemType.schedule => l10n.editorTypeSchedule,
      ItemType.memo => l10n.editorTypeMemo,
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
                  _formatDuration(
                    context,
                    Duration(minutes: minutes),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTypePicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(itemEditorPageControllerProvider);
    final l10n = context.l10n;

    return showAppSheetScaffold(
      context: context,
      title: l10n.editorTypePickerTitle,
      child: RadioGroup<ItemType>(
        groupValue: state.draft.type,
        onChanged: (value) {
          if (value == null) {
            return;
          }
          ref.read(itemEditorPageControllerProvider.notifier).selectType(value);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ItemType>(
              value: ItemType.task,
              title: Text(l10n.editorTypeTask),
            ),
            RadioListTile<ItemType>(
              value: ItemType.schedule,
              title: Text(l10n.editorTypeSchedule),
            ),
            RadioListTile<ItemType>(
              value: ItemType.memo,
              title: Text(l10n.editorTypeMemo),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.chevron_right),
        ),
        child: Text(value),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String value;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          suffixIcon: const Icon(Icons.timer_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}

class _TaskDeadlineSection extends StatelessWidget {
  const _TaskDeadlineSection({
    required this.deadline,
    required this.dateText,
    required this.timeText,
    required this.onPickDate,
    required this.onPickTime,
    required this.onClear,
    this.errorText,
  });

  final DateTime? deadline;
  final String dateText;
  final String timeText;
  final String? errorText;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.editorFieldDeadline,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (deadline != null)
              TextButton(
                onPressed: onClear,
                child: Text(l10n.editorDeadlineClear),
              ),
          ],
        ),
        const Gap(12),
        _DateField(
          label: l10n.editorFieldDeadlineDate,
          value: dateText,
          onTap: onPickDate,
        ),
        const Gap(16),
        _DateField(
          label: l10n.editorFieldDeadlineTime,
          value: timeText,
          onTap: onPickTime,
        ),
        if (errorText != null) ...[
          const Gap(12),
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
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? color : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
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
  const _OptionData({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}
