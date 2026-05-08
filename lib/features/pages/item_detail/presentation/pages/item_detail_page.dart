import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/motion/app_motion_widgets.dart';
import 'package:luotopia/core/time/now_ticker_provider.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/item_detail/domain/models/item_detail_args.dart';
import 'package:luotopia/features/pages/item_detail/presentation/viewmodels/item_detail_view_model.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';
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
    context.openItemEditorFlow(
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
    final isCourse = item.type == ItemType.course;
    final canToggleCompleted = item.supportsManualCompletion;
    final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
    final isCompleted = item.isEffectivelyCompleted(now);

    final detailRows = <_DetailValueEntry>[];

    void addDetail(IconData icon, String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      detailRows.add(_DetailValueEntry(icon: icon, value: trimmed));
    }

    if (item.type == ItemType.memo) {
      addDetail(AppIcons.calendar, _formatDateTime(context, item.targetDate, allDay: true));
      addDetail(AppIcons.clock, _formatDuration(context, item.estimatedDuration));
    } else {
      addDetail(AppIcons.calendar, _formatDateTime(context, item.startAt, allDay: item.isAllDay));
      addDetail(AppIcons.clock, _formatDateTime(context, item.endAt, allDay: item.isAllDay));
    }

    if (isCourse) {
      addDetail(AppIcons.info, item.courseDetails.courseNature);
      addDetail(AppIcons.person, item.courseDetails.instructor);
      addDetail(AppIcons.location, _courseLocation(item));
    } else {
      if (item.deadline != null) {
        addDetail(AppIcons.clock, _formatDateTime(context, item.deadline!, allDay: item.isAllDay));
      }
      addDetail(AppIcons.location, item.location);
      addDetail(AppIcons.info, item.details);
      if (item.reminder != ReminderOption.none) {
        addDetail(AppIcons.clock, _reminderLabel(l10n, item));
      }
      if (item.repeatRule != RepeatRule.none) {
        addDetail(AppIcons.calendar, _repeatLabel(l10n, item));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.resolve(theme.brightness).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _typeIcon(item.type),
                color: item.color.resolve(theme.brightness),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  item.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    decoration: canToggleCompleted && isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (var index = 0; index < detailRows.length; index++) ...[
          if (index > 0)
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.32),
            ),
          _DetailValueRow(
            icon: detailRows[index].icon,
            value: detailRows[index].value,
          ),
        ],
        if (!isCourse) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (canToggleCompleted)
                _ActionIconButton(
                  tooltip: isCompleted
                      ? l10n.detailMarkIncomplete
                      : l10n.detailMarkComplete,
                  icon: isCompleted ? AppIcons.incomplete : AppIcons.complete,
                  onPressed: () => repository.toggleCompleted(item.id),
                ),
              const SizedBox(width: 8),
              _ActionIconButton(
                tooltip: item.isImportant
                    ? l10n.detailUnmarkImportant
                    : l10n.detailMarkImportant,
                icon: item.isImportant
                    ? AppIcons.importantOutlined
                    : AppIcons.importantFilled,
                onPressed: () => repository.toggleImportant(item.id),
              ),
              const SizedBox(width: 8),
              _ActionIconButton(
                tooltip: l10n.detailDelete,
                icon: AppIcons.delete,
                iconColor: theme.colorScheme.error,
                onPressed: () async {
                  await repository.deleteItem(item.id);
                  if (context.mounted && context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ],
      ],
    );
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
}

class _DetailValueEntry {
  const _DetailValueEntry({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ui.Tooltip(
      tooltip: (context) => Text(tooltip),
      child: ui.IconButton.ghost(
        icon: Icon(icon, color: iconColor),
        onPressed: onPressed,
      ),
    );
  }
}

class _DetailValueRow extends StatelessWidget {
  const _DetailValueRow({
    required this.icon,
    required this.value,
  });

  final IconData icon;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
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
    return Text(
      message,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

