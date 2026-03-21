import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/time_picker/domain/models/time_picker_args.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final viewModel = ref.read(homeHeaderViewModelProvider.notifier);
    final width = MediaQuery.sizeOf(context).width;
    final allowMonthLayout = width >= 1360 &&
        ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final viewData = ref.watch(
      homeViewDataProvider(
        HomeViewQuery(
          localeTag: localeTag,
          allowMonthLayout: allowMonthLayout,
        ),
      ),
    );
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
                    onPressed: () => viewModel.showPrevious(viewData.scope),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => _openTimePicker(context, ref, viewData),
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
                    onPressed: () => viewModel.showNext(viewData.scope),
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
            child: _HomeGrid(
              viewData: viewData,
              onPrevious: () => viewModel.showPrevious(viewData.scope),
              onNext: () => viewModel.showNext(viewData.scope),
              onSelectCell: (date, slotIndex) => viewModel.selectCell(date, slotIndex),
              onOpenItem: (itemId) {
                context.push(
                  AppRoutePaths.itemDetail,
                  extra: ItemDetailArgs(itemId: itemId),
                );
              },
              onEditItem: (item) {
                context.push(
                  AppRoutePaths.itemEditor,
                  extra: ItemEditorArgs(
                    itemId: item.item.id,
                    prefill: ItemEditorPrefill(
                      type: item.item.type,
                      title: item.item.title,
                      details: item.item.details,
                      location: item.item.location,
                      color: item.item.color,
                      isAllDay: item.item.isAllDay,
                      reminder: item.item.reminder,
                      repeatRule: item.item.repeatRule,
                      startAt: item.item.startAt,
                      endAt: item.item.endAt,
                      deadline: item.item.deadline,
                      targetDate: item.item.targetDate,
                      estimatedDuration: item.item.estimatedDuration,
                      isImportant: item.item.isImportant,
                    ),
                  ),
                );
              },
              onCreateFromCell: (date, slot) {
                context.push(
                  AppRoutePaths.itemEditor,
                  extra: ItemEditorPrefill(
                    startAt: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      slot.startMinute ~/ 60,
                      slot.startMinute % 60,
                    ),
                    endAt: DateTime(
                      date.year,
                      date.month,
                      date.day,
                      slot.endMinute ~/ 60,
                      slot.endMinute % 60,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTimePicker(
    BuildContext context,
    WidgetRef ref,
    HomeViewData viewData,
  ) async {
    final result = await context.push<TimePickerSelection>(
      AppRoutePaths.timePicker,
      extra: TimePickerArgs(
        mode: switch (viewData.scope) {
          HomeDisplayScope.week => TimePickerMode.week,
          HomeDisplayScope.month => TimePickerMode.month,
        },
        initialDate: viewData.periodSelection.anchor,
      ),
    );
    if (result == null || !context.mounted) {
      return;
    }
    ref.read(homeHeaderViewModelProvider.notifier).jumpToSelection(
          HomePeriodSelection(
            anchor: result.anchor,
            scope: switch (result.mode) {
              TimePickerMode.month => HomeDisplayScope.month,
              _ => HomeDisplayScope.week,
            },
          ),
        );
  }
}

class _HomeGrid extends StatefulWidget {
  const _HomeGrid({
    required this.viewData,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectCell,
    required this.onOpenItem,
    required this.onEditItem,
    required this.onCreateFromCell,
  });

  final HomeViewData viewData;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(DateTime date, int slotIndex) onSelectCell;
  final ValueChanged<String> onOpenItem;
  final ValueChanged<HomeLaidOutItem> onEditItem;
  final void Function(DateTime date, HomeTimeSlot slot) onCreateFromCell;

  @override
  State<_HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<_HomeGrid> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        color: theme.colorScheme.surfaceContainerLowest,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const timelineWidth = 74.0;
            const columnGap = 6.0;
            const rowGap = 6.0;
            const headerHeight = 60.0;
            final availableWidth = math.max(320.0, constraints.maxWidth);
            final columnWidth = math.max(
              26.0,
              (availableWidth - timelineWidth - columnGap * (widget.viewData.columns.length - 1)) /
                  widget.viewData.columns.length,
            );
            final cellSize = columnWidth;
            final gridHeight = widget.viewData.timeSlots.length * cellSize +
                (widget.viewData.timeSlots.length - 1) * rowGap;
            final contentHeight = headerHeight + gridHeight;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity <= -260) {
                  widget.onNext();
                } else if (velocity >= 260) {
                  widget.onPrevious();
                }
              },
              onTapUp: (details) => _handleTap(details.localPosition, cellSize, rowGap, columnGap),
              onLongPressStart: (details) => _handleLongPress(
                details.localPosition,
                cellSize,
                rowGap,
                columnGap,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                child: SizedBox(
                  height: contentHeight,
                  child: Stack(
                    children: [
                      for (var columnIndex = 0;
                          columnIndex < widget.viewData.columns.length;
                          columnIndex++)
                        _HeaderCell(
                          column: widget.viewData.columns[columnIndex],
                          left: timelineWidth + columnIndex * (columnWidth + columnGap),
                          width: columnWidth,
                          height: headerHeight - 8,
                        ),
                      for (final slot in widget.viewData.timeSlots)
                        _TimelineLabel(
                          slot: slot,
                          top: headerHeight + slot.index * (cellSize + rowGap),
                          width: timelineWidth - 12,
                          height: cellSize,
                        ),
                      for (var columnIndex = 0;
                          columnIndex < widget.viewData.columns.length;
                          columnIndex++)
                        for (final slot in widget.viewData.timeSlots)
                          _GridSlot(
                            left: timelineWidth + columnIndex * (columnWidth + columnGap),
                            top: headerHeight + slot.index * (cellSize + rowGap),
                            size: cellSize,
                            highlight: DateUtils.isSameDay(
                                  widget.viewData.selectedCell?.date,
                                  widget.viewData.columns[columnIndex].date,
                                ) &&
                                widget.viewData.selectedCell?.slot.index == slot.index,
                            today: widget.viewData.columns[columnIndex].isToday,
                          ),
                      for (final item in widget.viewData.items)
                        _AgendaBlock(
                          item: item,
                          left: timelineWidth +
                              item.columnIndex * (columnWidth + columnGap) +
                              item.left * columnWidth +
                              2,
                          top: headerHeight + item.top * gridHeight + 2,
                          width: math.max(18, columnWidth * item.width - 4),
                          height: math.max(26, item.height * gridHeight - 4),
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

  void _handleTap(Offset position, double cellSize, double rowGap, double columnGap) {
    final hit = _resolveHit(position, cellSize, rowGap, columnGap);
    if (hit == null) {
      return;
    }
    switch (hit) {
      case _ItemHit(:final item):
        widget.onOpenItem(item.item.id);
      case _CellHit(:final date, :final slotIndex):
        widget.onSelectCell(date, slotIndex);
    }
  }

  void _handleLongPress(Offset position, double cellSize, double rowGap, double columnGap) {
    final hit = _resolveHit(position, cellSize, rowGap, columnGap);
    if (hit == null) {
      return;
    }
    switch (hit) {
      case _ItemHit(:final item):
        widget.onEditItem(item);
      case _CellHit(:final date, :final slotIndex):
        widget.onCreateFromCell(date, widget.viewData.timeSlots[slotIndex]);
    }
  }

  _GridHit? _resolveHit(Offset position, double cellSize, double rowGap, double columnGap) {
    const timelineWidth = 74.0;
    const headerHeight = 60.0;
    final x = position.dx;
    final y = position.dy;
    if (y < headerHeight || x < timelineWidth) {
      return null;
    }

    final itemHits = <HomeLaidOutItem>[];
    for (final item in widget.viewData.items) {
      final left = timelineWidth + item.columnIndex * (cellSize + columnGap) + item.left * cellSize;
      final top = headerHeight +
          item.top *
              (widget.viewData.timeSlots.length * cellSize +
                  (widget.viewData.timeSlots.length - 1) * rowGap);
      final width = cellSize * item.width;
      final height = math.max(
        26,
        item.height *
                (widget.viewData.timeSlots.length * cellSize +
                    (widget.viewData.timeSlots.length - 1) * rowGap) -
            4,
      );
      if (x >= left && x <= left + width && y >= top && y <= top + height) {
        itemHits.add(item);
      }
    }
    if (itemHits.isNotEmpty) {
      return _ItemHit(_resolveOverlappedItems(itemHits));
    }

    final columnExtent = cellSize + columnGap;
    final rowExtent = cellSize + rowGap;
    final columnIndex = ((x - timelineWidth) / columnExtent).floor();
    final rowIndex = ((y - headerHeight) / rowExtent).floor();
    if (columnIndex < 0 ||
        columnIndex >= widget.viewData.columns.length ||
        rowIndex < 0 ||
        rowIndex >= widget.viewData.timeSlots.length) {
      return null;
    }
    final columnLeft = timelineWidth + columnIndex * columnExtent;
    final rowTop = headerHeight + rowIndex * rowExtent;
    if (x > columnLeft + cellSize || y > rowTop + cellSize) {
      return null;
    }
    return _CellHit(widget.viewData.columns[columnIndex].date, rowIndex);
  }

  HomeLaidOutItem _resolveOverlappedItems(List<HomeLaidOutItem> items) {
    final wrapped = [
      for (final item in items)
        if (items.any(
          (other) =>
              other.item.id != item.item.id &&
              other.startMinute <= item.startMinute &&
              other.endMinute >= item.endMinute,
        ))
          item,
    ];
    final candidates = wrapped.isNotEmpty ? wrapped : items;
    candidates.sort((left, right) {
      final startCompare = left.item.startAt.compareTo(right.item.startAt);
      if (startCompare != 0) {
        return startCompare;
      }
      return left.item.createdAt.compareTo(right.item.createdAt);
    });
    return candidates.first;
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.column,
    required this.left,
    required this.width,
    required this.height,
  });

  final HomeDayColumn column;
  final double left;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: left,
      top: 0,
      width: width,
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 44;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: column.isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.14)
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 2 : 6,
                vertical: compact ? 4 : 6,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      compact ? column.dateLabel : column.weekdayLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: column.isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 2),
                      Text(
                        column.dateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimelineLabel extends StatelessWidget {
  const _TimelineLabel({
    required this.slot,
    required this.top,
    required this.width,
    required this.height,
  });

  final HomeTimeSlot slot;
  final double top;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: 0,
      top: top,
      width: width,
      height: height,
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          slot.label,
          textAlign: TextAlign.right,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _GridSlot extends StatelessWidget {
  const _GridSlot({
    required this.left,
    required this.top,
    required this.size,
    required this.highlight,
    required this.today,
  });

  final double left;
  final double top;
  final double size;
  final bool highlight;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: highlight
              ? theme.colorScheme.primary.withValues(alpha: 0.18)
              : today
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: highlight
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class _AgendaBlock extends StatelessWidget {
  const _AgendaBlock({
    required this.item,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final HomeLaidOutItem item;
  final double left;
  final double top;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = item.item.color.resolve(theme.brightness);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Opacity(
          opacity: item.opacity.clamp(0.25, 1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent.withValues(alpha: 0.24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (height > 44 && item.item.details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.item.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accent.withValues(alpha: 0.84),
                          fontWeight: FontWeight.w600,
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

sealed class _GridHit {
  const _GridHit();
}

class _ItemHit extends _GridHit {
  const _ItemHit(this.item);

  final HomeLaidOutItem item;
}

class _CellHit extends _GridHit {
  const _CellHit(this.date, this.slotIndex);

  final DateTime date;
  final int slotIndex;
}
