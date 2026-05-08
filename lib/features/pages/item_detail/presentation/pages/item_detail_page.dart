import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/motion/app_motion_widgets.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/time/now_ticker_provider.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
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
    final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
    final isCompleted = item.isEffectivelyCompleted(now);
    final canToggle = item.supportsManualCompletion;

    final infoRows = _buildInfoRows(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: icon + title + actions ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _typeIcon(item.type),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (canToggle)
              ui.Tooltip(
                tooltip: (context) => Text(
                  isCompleted ? l10n.detailMarkIncomplete : l10n.detailMarkComplete,
                ),
                child: ui.IconButton.ghost(
                  icon: Icon(isCompleted ? AppIcons.incomplete : AppIcons.complete),
                  onPressed: () => repository.toggleCompleted(item.id),
                ),
              ),
            ui.Tooltip(
              tooltip: (context) => Text(l10n.detailDelete),
              child: ui.IconButton.ghost(
                icon: Icon(AppIcons.delete, color: theme.colorScheme.error),
                onPressed: () async {
                  await repository.deleteItem(item.id);
                  if (context.mounted && context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Info card ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < infoRows.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                infoRows[i],
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Time meta ──
        _buildTimeMeta(context),
      ],
    );
  }

  List<Widget> _buildInfoRows(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isCourse = item.type == ItemType.course;
    final rows = <Widget>[];

    void addRow(IconData icon, String text) {
      rows.add(_InfoRow(icon: icon, text: text));
    }

    // ── Time ──
    if (item.type == ItemType.memo) {
      addRow(AppIcons.calendar, _formatDateWithWeekday(context, item.targetDate));
      addRow(AppIcons.clock, '预计 ${_formatDuration(context, item.estimatedDuration)}');
    } else if (item.isAllDay) {
      addRow(AppIcons.calendar, _formatDateWithWeekday(context, item.startAt));
    } else if (_isSameDay(item.startAt, item.endAt)) {
      addRow(AppIcons.calendar, _formatDateWithWeekday(context, item.startAt));
      addRow(AppIcons.clock, _formatTimeOnly(context, item.startAt, item.endAt));
    } else {
      addRow(AppIcons.calendar, '${_formatDateTime(context, item.startAt, allDay: false)} 至');
      addRow(AppIcons.clock, _formatDateTime(context, item.endAt, allDay: false));
    }

    // ── Deadline ──
    if (item.deadline != null && !isCourse) {
      final deadline = item.deadline!;
      final color = deadline.isBefore(DateTime.now())
          ? theme.colorScheme.error
          : null;
      rows.add(_InfoRow(
        icon: AppIcons.clock,
        text: '${l10n.detailDeadlineLabel} ${_formatDeadline(context, deadline)}',
        textColor: color,
      ));
    }

    // ── Location ──
    if (!isCourse && item.location.trim().isNotEmpty) {
      addRow(AppIcons.location, item.location.trim());
    }

    // ── Course info ──
    if (isCourse) {
      final c = item.courseDetails;
      if (c.courseNature.trim().isNotEmpty) {
        addRow(AppIcons.info, c.courseNature.trim());
      }
      if (c.instructor.trim().isNotEmpty) {
        addRow(AppIcons.person, c.instructor.trim());
      }
      final loc = c.classroomRaw.trim();
      if (loc.isNotEmpty) {
        addRow(AppIcons.location, loc);
      } else if (item.location.trim().isNotEmpty) {
        addRow(AppIcons.location, item.location.trim());
      }
      if (c.weekMeta.trim().isNotEmpty) {
        addRow(AppIcons.calendar, c.weekMeta.trim());
      }
    }

    // ── Details ──
    if (item.details.trim().isNotEmpty) {
      rows.add(_DetailsBlock(text: item.details.trim()));
    }

    // ── Reminder / Repeat ──
    if (item.reminder != ReminderOption.none) {
      addRow(AppIcons.clock, _reminderLabel(l10n, item));
    }
    if (item.repeatRule != RepeatRule.none) {
      addRow(AppIcons.calendar, _repeatLabel(l10n, item));
    }

    return rows;
  }

  Widget _buildTimeMeta(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final df = DateFormat('yyyy/M/d HH:mm', locale);

    final parts = <InlineSpan>[];
    parts.add(WidgetSpan(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(AppIcons.info, size: 13, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
      ),
    ));
    parts.add(TextSpan(
      text: '创建于 ${df.format(item.createdAt)}',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    ));
    if (item.updatedAt != null) {
      parts.add(TextSpan(
        text: '  ·  更新于 ${df.format(item.updatedAt!)}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ));
    }

    return RichText(text: TextSpan(children: parts));
  }

  IconData _typeIcon(ItemType type) {
    return switch (type) {
      ItemType.task => AppIcons.itemTypeTask,
      ItemType.schedule => AppIcons.itemTypeSchedule,
      ItemType.memo => AppIcons.itemTypeMemo,
      ItemType.course => AppIcons.itemTypeCourse,
    };
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.textColor,
  });

  final IconData icon;
  final String text;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _DetailsBlock extends StatelessWidget {
  const _DetailsBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(AppIcons.info, size: 16, color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ),
      ],
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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Date/time formatting helpers ─────────────────────────────────────────────

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

String _formatTimeOnly(BuildContext context, DateTime start, DateTime end) {
  final localizations = MaterialLocalizations.of(context);
  final startTime = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(start),
    alwaysUse24HourFormat: true,
  );
  final endTime = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(end),
    alwaysUse24HourFormat: true,
  );
  return '$startTime — $endTime';
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

String _formatDateWithWeekday(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(value);
  final localeName = Localizations.localeOf(context).toLanguageTag();
  final weekday = DateFormat('EEE', localeName).format(value);
  return '$weekday $date';
}

String _formatDeadline(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(value);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(value),
    alwaysUse24HourFormat: true,
  );
  return '$date  $time';
}
