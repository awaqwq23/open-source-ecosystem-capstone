import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/features/item_detail/presentation/viewmodels/item_detail_view_model.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({
    this.args,
    super.key,
  });

  final ItemDetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itemDetailViewModelProvider(args));
    final item = state.item;

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
          title: Text(context.l10n.detailTitle),
          trailing: item == null
              ? const []
              : [
                  ui.IconButton.ghost(
                    icon: const Icon(AppIcons.edit),
                    onPressed: () => _editItem(context, item),
                  ),
                ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: AppEntrance(
              child: item == null
                  ? _EmptyDetailState(message: context.l10n.detailMissing)
                  : _ItemDetailContent(item: item),
            ),
          ),
        ),
      ),
    );
  }

  void _editItem(BuildContext context, AgendaItem item) {
    context.push(
      AppRoutePaths.itemEditor,
      extra: ItemEditorArgs(
        itemId: item.id,
        prefill: ItemEditorPrefill(
          type: item.type,
          title: item.title,
          details: item.details,
          location: item.location,
          color: item.color,
          isAllDay: item.isAllDay,
          reminder: item.reminder,
          repeatRule: item.repeatRule,
          startAt: item.startAt,
          endAt: item.endAt,
          deadline: item.deadline,
          targetDate: item.targetDate,
          estimatedDuration: item.estimatedDuration,
          courseDetails: item.courseDetails,
          isImportant: item.isImportant,
        ),
      ),
    );
  }
}

class _ItemDetailContent extends ConsumerWidget {
  const _ItemDetailContent({
    required this.item,
  });

  final AgendaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final repository = ref.read(agendaItemRepositoryProvider.notifier);

    return ui.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.color.resolve(theme.brightness).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _typeIcon(item.type),
                  color: item.color.resolve(theme.brightness),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: item.isCompleted ? AppIcons.complete : AppIcons.incomplete,
                          label: item.isCompleted
                              ? l10n.listStatusCompleted
                              : l10n.listStatusPending,
                        ),
                        _MetaChip(
                          icon: item.isImportant
                              ? AppIcons.importantFilled
                              : AppIcons.importantOutlined,
                          label: item.isImportant
                              ? l10n.listImportantEnabled
                              : l10n.listImportantDisabled,
                        ),
                        _MetaChip(
                          icon: _typeIcon(item.type),
                          label: _typeLabel(l10n, item.type),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _DetailRow(
            icon: AppIcons.calendar,
            label: l10n.detailTimeLabel,
            value: _dateSummary(context, item),
          ),
          if (item.type == ItemType.course) ...[
            if (item.courseDetails.courseNature.trim().isNotEmpty)
              _DetailRow(
                icon: AppIcons.info,
                label: _isChinese(l10n) ? '性质' : 'Nature',
                value: item.courseDetails.courseNature.trim(),
              ),
            if (item.courseDetails.instructor.trim().isNotEmpty)
              _DetailRow(
                icon: AppIcons.person,
                label: _isChinese(l10n) ? '教师' : 'Instructor',
                value: item.courseDetails.instructor.trim(),
              ),
            if (_courseLocation(item).isNotEmpty)
              _DetailRow(
                icon: AppIcons.location,
                label: _isChinese(l10n) ? '地点' : 'Location',
                value: _courseLocation(item),
              ),
          ] else ...[
            if (item.deadline != null)
              _DetailRow(
                icon: AppIcons.clock,
                label: l10n.detailDeadlineLabel,
                value: _formatDateTime(context, item.deadline!, allDay: item.isAllDay),
              ),
            if (item.location.isNotEmpty)
              _DetailRow(
                icon: AppIcons.location,
                label: l10n.detailLocationLabel,
                value: item.location,
              ),
            if (item.details.isNotEmpty)
              _DetailRow(
                icon: AppIcons.info,
                label: l10n.detailNotesLabel,
                value: item.details,
              ),
            _DetailRow(
              icon: AppIcons.clock,
              label: l10n.detailReminderLabel,
              value: _reminderLabel(l10n, item),
            ),
            _DetailRow(
              icon: AppIcons.calendar,
              label: l10n.detailRepeatLabel,
              value: _repeatLabel(l10n, item),
            ),
          ],
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ui.PrimaryButton(
                onPressed: () => repository.toggleCompleted(item.id),
                leading: Icon(item.isCompleted ? AppIcons.incomplete : AppIcons.complete),
                child: Text(
                  item.isCompleted
                      ? l10n.detailMarkIncomplete
                      : l10n.detailMarkComplete,
                ),
              ),
              ui.OutlineButton(
                onPressed: () => repository.toggleImportant(item.id),
                leading: Icon(
                  item.isImportant
                      ? AppIcons.importantOutlined
                      : AppIcons.importantFilled,
                ),
                child: Text(
                  item.isImportant
                      ? l10n.detailUnmarkImportant
                      : l10n.detailMarkImportant,
                ),
              ),
              ui.DestructiveButton(
                onPressed: () async {
                  await repository.deleteItem(item.id);
                  if (context.mounted && context.canPop()) {
                    context.pop();
                  }
                },
                leading: const Icon(AppIcons.delete),
                child: Text(l10n.detailDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _dateSummary(BuildContext context, AgendaItem item) {
    return switch (item.type) {
      ItemType.memo => context.l10n.detailMemoDate(
          _formatDateTime(context, item.targetDate, allDay: true),
          _formatDuration(context, item.estimatedDuration),
        ),
      _ => context.l10n.detailRangeDate(
          _formatDateTime(context, item.startAt, allDay: item.isAllDay),
          _formatDateTime(context, item.endAt, allDay: item.isAllDay),
        ),
    };
  }

  String _formatDateTime(BuildContext context, DateTime value, {required bool allDay}) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(value);
    if (allDay) {
      return date;
    }
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
    return '$date  $time';
  }

  String _formatDuration(BuildContext context, Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) {
      return context.l10n.editorDurationHourMinute(hours, minutes);
    }
    if (hours > 0) {
      return context.l10n.editorDurationHours(hours);
    }
    return context.l10n.editorDurationMinutes(value.inMinutes);
  }

  String _typeLabel(AppLocalizations l10n, ItemType type) {
    return switch (type) {
      ItemType.task => l10n.listTabTasks,
      ItemType.schedule => l10n.listTabSchedules,
      ItemType.memo => l10n.listTabMemos,
      ItemType.course => _isChinese(l10n) ? '课程' : 'Course',
    };
  }

  String _courseLocation(AgendaItem item) {
    final fromCourse = item.courseDetails.classroomRaw.trim();
    if (fromCourse.isNotEmpty) {
      return fromCourse;
    }
    return item.location.trim();
  }

  String _reminderLabel(AppLocalizations l10n, AgendaItem item) {
    return switch (item.reminder) {
      ReminderOption.none => l10n.editorReminderNone,
      ReminderOption.atTime => l10n.editorReminderAtTime,
      ReminderOption.fiveMinutesBefore => l10n.editorReminderFiveMinutes,
      ReminderOption.fifteenMinutesBefore => l10n.editorReminderFifteenMinutes,
      ReminderOption.oneHourBefore => l10n.editorReminderOneHour,
      ReminderOption.oneDayBefore => l10n.editorReminderOneDay,
    };
  }

  String _repeatLabel(AppLocalizations l10n, AgendaItem item) {
    return switch (item.repeatRule) {
      RepeatRule.none => l10n.editorRepeatNone,
      RepeatRule.everyDay => l10n.editorRepeatDaily,
      RepeatRule.weekdays => l10n.editorRepeatWeekdays,
      RepeatRule.everyWeek => l10n.editorRepeatWeekly,
      RepeatRule.everyMonth => l10n.editorRepeatMonthly,
      RepeatRule.everyYear => l10n.editorRepeatYearly,
    };
  }

  IconData _typeIcon(ItemType type) {
    return switch (type) {
      ItemType.task => AppIcons.itemTypeTask,
      ItemType.schedule => AppIcons.itemTypeSchedule,
      ItemType.memo => AppIcons.itemTypeMemo,
      ItemType.course => AppIcons.itemTypeCourse,
    };
  }

  bool _isChinese(AppLocalizations l10n) {
    return l10n.localeName.toLowerCase().startsWith('zh');
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return ui.Card(
      child: Text(
        message,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

