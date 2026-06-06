import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  const ItemDetailPage({this.args, super.key});

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
                onPressed: () => Navigator.of(context).pop(),
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
          notes: item.notes,
          location: item.location,
          color: item.color,
          isAllDay: item.timelineIsAllDay,
          reminder: item.reminder,
          repeatRule: item.repeatRule,
          startAt: item.timelineStartAt,
          endAt: item.timelineEndAt,
          deadlineAt: item.deadlineAt,
          courseDetails: item.courseDetails,
          sourceKind: item.sourceKind,
          sourceRef: item.sourceRef,
        ),
      ),
    );
  }
}

class _ItemDetailContent extends ConsumerWidget {
  const _ItemDetailContent({required this.item});

  final AgendaItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final repository = ref.read(agendaItemRepositoryProvider.notifier);
    final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
    final isCompleted = item.isEffectivelyCompleted(now);
    final canToggle = item.supportsManualCompletion;
    final isCourse = item.type == ItemType.course;
    final color = item.color.resolve(theme.brightness);

    final infoRows = _buildInfoRows(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: icon + title + actions ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(_typeIcon(item.type), size: 24, color: color),
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
                  isCompleted
                      ? l10n.detailMarkIncomplete
                      : l10n.detailMarkComplete,
                ),
                child: ui.IconButton.ghost(
                  icon: Icon(
                    isCompleted ? AppIcons.incomplete : AppIcons.complete,
                  ),
                  onPressed: () => repository.toggleCompleted(item.id),
                ),
              ),
            ui.Tooltip(
              tooltip: (context) => Text(l10n.detailDelete),
              child: ui.IconButton.ghost(
                icon: Icon(AppIcons.delete, color: theme.colorScheme.error),
                onPressed: () async {
                  await repository.deleteItem(item.id);
                  if (context.mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
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
        // ── Course grading & reviews ──
        if (isCourse) ...[
          const SizedBox(height: 20),
          _CourseGradingSection(),
          const SizedBox(height: 20),
          _CourseReviewsSection(),
        ],
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
    final startAt = item.timelineStartAt;
    final endAt = item.timelineEndAt;
    if (startAt != null && endAt != null && item.timelineIsAllDay) {
      addRow(AppIcons.calendar, _formatDateWithWeekday(context, startAt));
    } else if (startAt != null && endAt != null && _isSameDay(startAt, endAt)) {
      addRow(AppIcons.calendar, _formatDateWithWeekday(context, startAt));
      addRow(
        AppIcons.clock,
        _formatTimeOnly(context, startAt, endAt),
      );
    } else if (startAt != null && endAt != null) {
      addRow(
        AppIcons.calendar,
        '${_formatDateTime(context, startAt, allDay: false)} 至',
      );
      addRow(
        AppIcons.clock,
        _formatDateTime(context, endAt, allDay: false),
      );
    }

    // ── Deadline ──
    if (item.deadlineAt != null && !isCourse) {
      final deadline = item.deadlineAt!;
      final color = deadline.isBefore(DateTime.now())
          ? theme.colorScheme.error
          : null;
      rows.add(
        _InfoRow(
          icon: AppIcons.clock,
          text:
              '${l10n.detailDeadlineLabel} ${_formatDeadline(context, deadline)}',
          textColor: color,
        ),
      );
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
      final loc = item.location.trim();
      if (loc.isNotEmpty) {
        addRow(AppIcons.location, loc);
      }
      if (c.weekMeta.trim().isNotEmpty) {
        addRow(AppIcons.calendar, c.weekMeta.trim());
      }
    }

    // ── Details ──
    if (item.notes.trim().isNotEmpty) {
      rows.add(_DetailsBlock(text: item.notes.trim()));
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
  const _InfoRow({required this.icon, required this.text, this.textColor});

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
          child: Icon(
            AppIcons.info,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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
  const _EmptyDetailState({required this.message});

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

// ─── Course grading section ─────────────────────────────────────────────────────

class _CourseGradingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: '课程给分'),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              // ── Overall score ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ScoreRing(score: 85, label: '总评'),
                  const SizedBox(width: 24),
                  _ScoreRing(score: 90, label: '平时'),
                  const SizedBox(width: 24),
                  _ScoreRing(score: 82, label: '期末'),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              // ── Score distribution ──
              Text(
                '成绩分布',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _DistributionBar(
                label: '90-100',
                fraction: 0.25,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              _DistributionBar(
                label: '80-89',
                fraction: 0.40,
                color: theme.colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 8),
              _DistributionBar(
                label: '70-79',
                fraction: 0.20,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 8),
              _DistributionBar(
                label: '60-69',
                fraction: 0.10,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              _DistributionBar(
                label: '<60',
                fraction: 0.05,
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.label});

  final int score;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = score >= 90
        ? theme.colorScheme.primary
        : score >= 80
        ? theme.colorScheme.tertiary
        : theme.colorScheme.error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: CustomPaint(
            painter: _RingPainter(
              progress: score / 100.0,
              color: color,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                '$score',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 4;
    final strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _DistributionBar extends StatelessWidget {
  const _DistributionBar({
    required this.label,
    required this.fraction,
    required this.color,
  });

  final String label;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: color,
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${(fraction * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Course reviews section ────────────────────────────────────────────────────

class _CourseReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: '课程评价'),
        const SizedBox(height: 10),
        _ReviewCard(
          rating: 4.5,
          content: '老师讲得很清楚，课件制作精良，给分也不错。每节课都有课堂练习，对理解概念帮助很大。',
          reviewer: '匿名同学',
          date: '2025-12',
        ),
        const SizedBox(height: 10),
        _ReviewCard(
          rating: 3.5,
          content: '课程内容比较充实，但期末考试有一定难度。平时作业量适中，建议提前复习。',
          reviewer: '匿名同学',
          date: '2025-11',
        ),
        const SizedBox(height: 10),
        _ReviewCard(
          rating: 5.0,
          content: '强烈推荐！这门课让我对专业方向有了更清晰的认识，实验环节设计得很好。',
          reviewer: '匿名同学',
          date: '2025-10',
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.rating,
    required this.content,
    required this.reviewer,
    required this.date,
  });

  final double rating;
  final String content;
  final String reviewer;
  final String date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final filled = index < rating.floor();
                  final half = !filled && index < rating;
                  return Icon(
                    half ? Icons.star_half : Icons.star,
                    size: 16,
                    color: filled || half
                        ? Colors.amber
                        : theme.colorScheme.surfaceContainerHighest,
                  );
                }),
              ),
              const SizedBox(width: 8),
              Text(
                rating.toStringAsFixed(1),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reviewer,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─── Date/time formatting helpers ─────────────────────────────────────────────

String _formatDateTime(
  BuildContext context,
  DateTime value, {
  required bool allDay,
}) {
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
  return '$startTime ~ $endTime';
}
String _formatDateWithWeekday(BuildContext context, DateTime value) {
  final localeName = Localizations.localeOf(context).toLanguageTag();
  if (localeName.startsWith('zh')) {
    final date = DateFormat('M月d日', localeName).format(value);
    final weekday = DateFormat('EEE', localeName).format(value);
    return '$date $weekday';
  }
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(value);
  final weekday = DateFormat('EEE', localeName).format(value);
  return '$date $weekday';
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
