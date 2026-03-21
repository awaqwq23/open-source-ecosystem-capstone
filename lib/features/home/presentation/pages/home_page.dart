import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final viewModel = ref.read(homeHeaderViewModelProvider.notifier);
    final viewData = ref.watch(homeViewDataProvider(localeTag));
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          surfaceBlur: 0,
          surfaceOpacity: 0,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: SizedBox(
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: ui.IconButton.ghost(
                    icon: const Icon(AppIcons.previousPeriod),
                    onPressed: viewModel.showPrevious,
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => _openTimePicker(context, ref),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewData.periodLabel,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              viewData.periodSubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(AppIcons.expandSelection, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ui.IconButton.ghost(
                    icon: const Icon(AppIcons.nextPeriod),
                    onPressed: viewModel.showNext,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(
              children: [
                _WeekStrip(
                  columns: viewData.columns,
                  onSelectDate: viewModel.selectDate,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _TimetableCard(
                    viewData: viewData,
                    onPrevious: viewModel.showPrevious,
                    onNext: viewModel.showNext,
                    onOpenItem: (itemId) {
                      context.push(
                        AppRoutePaths.itemDetail,
                        extra: ItemDetailArgs(itemId: itemId),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTimePicker(BuildContext context, WidgetRef ref) async {
    final state = ref.read(homeHeaderViewModelProvider);
    final result = await context.push<DateTime>(
      AppRoutePaths.timePicker,
      extra: TimePickerArgs(
        mode: TimePickerMode.week,
        initialDate: state.anchor,
      ),
    );
    if (result == null || !context.mounted) {
      return;
    }
    ref.read(homeHeaderViewModelProvider.notifier).jumpToDate(result);
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.columns,
    required this.onSelectDate,
  });

  final List<HomeDayColumn> columns;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const SizedBox(width: 44),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              for (var index = 0; index < columns.length; index++) ...[
                if (index > 0) const SizedBox(width: 6),
                Expanded(
                  child: _DayChip(
                    column: columns[index],
                    onTap: () => onSelectDate(columns[index].date),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.28),
          ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.column,
    required this.onTap,
  });

  final HomeDayColumn column;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool highlighted = column.isToday || column.isSelected;
    final Color backgroundColor;
    final Color foregroundColor;

    if (highlighted) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.15);
      foregroundColor = theme.colorScheme.primary;
    } else if (column.emphasize) {
      backgroundColor = const Color(0xFFD9EBFF);
      foregroundColor = const Color(0xFF2B6CB0);
    } else {
      backgroundColor = theme.colorScheme.surfaceContainerLow;
      foregroundColor = theme.colorScheme.onSurfaceVariant;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlighted
                ? theme.colorScheme.primary.withValues(alpha: 0.32)
                : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                column.weekdayLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                column.dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimetableCard extends StatelessWidget {
  const _TimetableCard({
    required this.viewData,
    required this.onPrevious,
    required this.onNext,
    required this.onOpenItem,
  });

  final HomeViewData viewData;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<String> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: theme.colorScheme.surfaceContainerLowest,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const timelineWidth = 44.0;
            const columnGap = 6.0;
            final availableWidth = math.max(280.0, constraints.maxWidth);
            final columnWidth =
                (availableWidth - timelineWidth - (columnGap * 6)) / 7;
            final pixelsPerMinute = columnWidth * 0.72;
            final gridHeight = viewData.metrics.totalMinutes * pixelsPerMinute / 60;

            return GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) {
                  return;
                }
                if (details.primaryVelocity! <= -260) {
                  onNext();
                } else if (details.primaryVelocity! >= 260) {
                  onPrevious();
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                child: SizedBox(
                  height: gridHeight,
                  child: Stack(
                    children: [
                      for (final slot in viewData.timeSlots)
                        _TimelineLabel(
                          slot: slot,
                          startMinuteOfDay: viewData.metrics.startMinuteOfDay,
                          totalMinutes: viewData.metrics.totalMinutes,
                          gridHeight: gridHeight,
                        ),
                      for (var columnIndex = 0; columnIndex < viewData.columns.length; columnIndex++)
                        for (final slot in viewData.timeSlots)
                          _GridSlot(
                            columnIndex: columnIndex,
                            slot: slot,
                            columnWidth: columnWidth,
                            columnGap: columnGap,
                            timelineWidth: timelineWidth,
                            startMinuteOfDay: viewData.metrics.startMinuteOfDay,
                            totalMinutes: viewData.metrics.totalMinutes,
                            gridHeight: gridHeight,
                            highlight: viewData.columns[columnIndex].isToday,
                          ),
                      for (final item in viewData.items)
                        _AgendaBlock(
                          item: item,
                          columnWidth: columnWidth,
                          columnGap: columnGap,
                          timelineWidth: timelineWidth,
                          gridHeight: gridHeight,
                          onTap: () => onOpenItem(item.item.id),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  const _TimelineLabel({
    required this.slot,
    required this.startMinuteOfDay,
    required this.totalMinutes,
    required this.gridHeight,
  });

  final HomeTimeSlot slot;
  final int startMinuteOfDay;
  final int totalMinutes;
  final double gridHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = (slot.startMinute - startMinuteOfDay) / totalMinutes * gridHeight;

    return Positioned(
      left: 0,
      top: top - 2,
      width: 40,
      child: Text(
        slot.label,
        textAlign: TextAlign.right,
        style: theme.textTheme.labelSmall?.copyWith(
          height: 1.18,
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GridSlot extends StatelessWidget {
  const _GridSlot({
    required this.columnIndex,
    required this.slot,
    required this.columnWidth,
    required this.columnGap,
    required this.timelineWidth,
    required this.startMinuteOfDay,
    required this.totalMinutes,
    required this.gridHeight,
    required this.highlight,
  });

  final int columnIndex;
  final HomeTimeSlot slot;
  final double columnWidth;
  final double columnGap;
  final double timelineWidth;
  final int startMinuteOfDay;
  final int totalMinutes;
  final double gridHeight;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = (slot.startMinute - startMinuteOfDay) / totalMinutes * gridHeight;
    final height = (slot.endMinute - slot.startMinute) / totalMinutes * gridHeight;

    return Positioned(
      left: timelineWidth + columnIndex * (columnWidth + columnGap),
      top: top,
      width: columnWidth,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlight
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _AgendaBlock extends StatelessWidget {
  const _AgendaBlock({
    required this.item,
    required this.columnWidth,
    required this.columnGap,
    required this.timelineWidth,
    required this.gridHeight,
    required this.onTap,
  });

  final HomeLaidOutItem item;
  final double columnWidth;
  final double columnGap;
  final double timelineWidth;
  final double gridHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final accent = item.item.color.resolve(brightness);

    return Positioned(
      left: timelineWidth + item.columnIndex * (columnWidth + columnGap) + 2,
      top: item.top * gridHeight + 2,
      width: columnWidth - 4,
      height: math.max(34, item.height * gridHeight - 4),
      child: Opacity(
        opacity: item.opacity.clamp(0.34, 1),
        child: Material(
          color: accent.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: DefaultTextStyle(
                style: theme.textTheme.bodySmall!.copyWith(
                  color: accent.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                  height: 1.12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item.title,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.item.details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.item.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent.withValues(alpha: 0.88),
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
