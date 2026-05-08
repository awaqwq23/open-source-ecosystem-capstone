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
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
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
    final color = item.color.resolve(theme.brightness);
    final isCompleted = item.isEffectivelyCompleted(now);
    final isCourse = item.type == ItemType.course;
    final canToggle = item.supportsManualCompletion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderSection(
          item: item,
          color: color,
          isCompleted: isCompleted,
        ),
        const SizedBox(height: 24),
        _TimeSection(
          item: item,
          color: color,
        ),
        if (!isCourse && item.location.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _DetailCard(
            icon: AppIcons.location,
            label: l10n.detailLocationLabel,
            child: Text(
              item.location.trim(),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
        if (isCourse) ...[
          const SizedBox(height: 12),
          _CourseInfoSection(course: item.courseDetails, location: item.location),
        ],
        if (item.details.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _DetailCard(
            icon: AppIcons.info,
            label: l10n.detailNotesLabel,
            child: Text(
              item.details.trim(),
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
        ],
        if (item.reminder != ReminderOption.none ||
            item.repeatRule != RepeatRule.none) ...[
          const SizedBox(height: 16),
          _TagRow(item: item),
        ],
        const SizedBox(height: 24),
        Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (canToggle)
              _ActionIconButton(
                tooltip: isCompleted ? l10n.detailMarkIncomplete : l10n.detailMarkComplete,
                icon: isCompleted ? AppIcons.incomplete : AppIcons.complete,
                iconColor: isCompleted ? null : color,
                onPressed: () => repository.toggleCompleted(item.id),
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
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.item,
    required this.color,
    required this.isCompleted,
  });

  final AgendaItem item;
  final Color color;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _typeIcon(item.type),
            color: color,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _TypeBadge(type: item.type, color: color),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      _CompletedBadge(),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.color});

  final ItemType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (type) {
      ItemType.task => '任务',
      ItemType.schedule => '日程',
      ItemType.memo => '备忘',
      ItemType.course => '课程',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '已完成',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DefaultTextStyle(
            style: theme.textTheme.bodyLarge ?? const TextStyle(),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({
    required this.item,
    required this.color,
  });

  final AgendaItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.clock, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                l10n.detailTimeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          switch (item.type) {
            ItemType.memo => _memoTimeRows(context, theme),
            _ => _scheduleTimeRows(context, theme, l10n),
          },
        ],
      ),
    );
  }

  Widget _memoTimeRows(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimeRow(
          icon: AppIcons.calendar,
          text: _formatDateWithWeekday(context, item.targetDate),
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        _TimeRow(
          icon: AppIcons.clock,
          text: '预计 ${_formatDuration(context, item.estimatedDuration)}',
          color: theme.colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _scheduleTimeRows(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    if (item.isAllDay) {
      return _TimeRow(
        icon: AppIcons.calendar,
        text: _formatDateWithWeekday(context, item.startAt),
        color: theme.colorScheme.onSurface,
      );
    }

    if (_isSameDay(item.startAt, item.endAt)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeRow(
            icon: AppIcons.calendar,
            text: _formatDateWithWeekday(context, item.startAt),
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 8),
          _TimeRow(
            icon: AppIcons.clock,
            text: _formatTimeOnly(context, item.startAt, item.endAt),
            color: theme.colorScheme.onSurface,
          ),
          if (item.deadline != null && item.type != ItemType.course) ...[
            const SizedBox(height: 8),
            _TimeRow(
              icon: AppIcons.clock,
              text: '${l10n.detailDeadlineLabel} ${_formatDeadline(context, item.deadline!)}',
              color: _deadlineColor(context, theme, item.deadline!),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimeRow(
          icon: AppIcons.calendar,
          text: _formatDateTime(context, item.startAt, allDay: false),
          color: theme.colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        _TimeRow(
          icon: AppIcons.clock,
          text: '${_formatDateTimeShort(context, item.endAt)} 结束',
          color: theme.colorScheme.onSurface,
        ),
        if (item.deadline != null && item.type != ItemType.course) ...[
          const SizedBox(height: 8),
          _TimeRow(
            icon: AppIcons.clock,
            text: '${l10n.detailDeadlineLabel} ${_formatDeadline(context, item.deadline!)}',
            color: _deadlineColor(context, theme, item.deadline!),
          ),
        ],
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _deadlineColor(BuildContext context, ThemeData theme, DateTime deadline) {
    final now = DateTime.now();
    if (deadline.isBefore(now)) {
      return theme.colorScheme.error;
    }
    if (deadline.isBefore(now.add(const Duration(hours: 24)))) {
      return theme.colorScheme.tertiary;
    }
    return theme.colorScheme.onSurface;
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _CourseInfoSection extends StatelessWidget {
  const _CourseInfoSection({
    required this.course,
    required this.location,
  });

  final ItemCourseDetails course;
  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rows = <Widget>[];
    void addRow(String label, String value) {
      if (value.trim().isEmpty) return;
      rows.add(_CourseInfoRow(label: label, value: value.trim()));
    }

    addRow('课程性质', course.courseNature);
    addRow('授课教师', course.instructor);

    final loc = course.classroomRaw.trim();
    addRow('上课地点', loc.isNotEmpty ? loc : location.trim());
    addRow('上课周次', course.weekMeta);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(AppIcons.person, size: 16),
              const SizedBox(width: 6),
              Text(
                '课程信息',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _CourseInfoRow extends StatelessWidget {
  const _CourseInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow({required this.item});

  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (item.reminder != ReminderOption.none)
          _TagChip(
            icon: AppIcons.clock,
            label: _reminderLabel(context.l10n, item),
            color: theme.colorScheme.secondary,
          ),
        if (item.repeatRule != RepeatRule.none)
          _TagChip(
            icon: AppIcons.calendar,
            label: _repeatLabel(context.l10n, item),
            color: theme.colorScheme.tertiary,
          ),
      ],
    );
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

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
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

String _formatDateTimeShort(BuildContext context, DateTime value) {
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(value);
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
