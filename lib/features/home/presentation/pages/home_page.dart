import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/presentation/layout/home_grid_metrics.dart';
import 'package:huajuan_agenda/features/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/settings/data/settings_repository_impl.dart';
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
    final allowMonthLayout = _HomeGridLayoutSpec.canFitMonthLayout(width) &&
        ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final homeSettings = ref.watch(appHomeSettingsProvider);
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
            padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
            child: Column(
              children: [
                if (homeSettings.showDemoData) ...[
                  _DemoModeBanner(message: context.l10n.homeDemoBanner),
                  const SizedBox(height: 10),
                ],
                Expanded(
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
              ],
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

class _DemoModeBanner extends StatelessWidget {
  const _DemoModeBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.info,
            size: 18,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_HomeGridLayoutSpec.gridOuterRadius),
      child: Container(
        color: theme.colorScheme.surfaceContainerLowest,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final layout = _HomeGridLayout.fromConstraints(
              constraints: constraints,
              columnCount: widget.viewData.columns.length,
              rowCount: widget.viewData.timeSlots.length,
            );

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
              onTapUp: (details) => _handleTap(details.localPosition, layout),
              onLongPressStart: (details) => _handleLongPress(
                details.localPosition,
                layout,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  layout.horizontalPadding,
                  layout.topPadding,
                  layout.horizontalPadding,
                  layout.bottomPadding,
                ),
                child: SizedBox(
                  width: layout.contentWidth,
                  height: layout.contentHeight,
                  child: Stack(
                    children: [
                      _TimelineHeaderCell(
                        width: layout.timelineLabelWidth,
                        height: layout.headerCellHeight,
                      ),
                      for (var columnIndex = 0;
                          columnIndex < widget.viewData.columns.length;
                          columnIndex++)
                        _HeaderCell(
                          column: widget.viewData.columns[columnIndex],
                          left: layout.columnLeft(columnIndex),
                          width: layout.columnWidth,
                          height: layout.headerCellHeight,
                        ),
                      for (final slot in widget.viewData.timeSlots)
                        _TimelineLabel(
                          slot: slot,
                          top: layout.rowTop(slot.index),
                          width: layout.timelineLabelWidth,
                          height: layout.cellSize,
                        ),
                      for (var columnIndex = 0;
                          columnIndex < widget.viewData.columns.length;
                          columnIndex++)
                        for (final slot in widget.viewData.timeSlots)
                          _GridSlot(
                            left: layout.columnLeft(columnIndex),
                            top: layout.rowTop(slot.index),
                            size: layout.cellSize,
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
                          left: layout.itemLeft(item),
                          top: layout.itemTop(item),
                          width: layout.itemWidth(item),
                          height: layout.itemHeight(item),
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

  void _handleTap(Offset position, _HomeGridLayout layout) {
    final hit = _resolveHit(position, layout);
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

  void _handleLongPress(Offset position, _HomeGridLayout layout) {
    final hit = _resolveHit(position, layout);
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

  _GridHit? _resolveHit(Offset position, _HomeGridLayout layout) {
    final contentPosition = layout.contentOffsetFromViewport(
      position,
      scrollOffset: _scrollController.hasClients ? _scrollController.offset : 0,
    );
    final x = contentPosition.dx;
    final y = contentPosition.dy;
    if (x < 0 || y < 0 || y < layout.headerHeight || x < layout.timelineWidth) {
      return null;
    }

    final itemHits = <HomeLaidOutItem>[];
    for (final item in widget.viewData.items) {
      final itemShape = RRect.fromRectAndRadius(
        layout.itemRect(item),
        const Radius.circular(_HomeGridLayoutSpec.itemRadius),
      );
      if (itemShape.contains(contentPosition)) {
        itemHits.add(item);
      }
    }
    if (itemHits.isNotEmpty) {
      return _ItemHit(_resolveOverlappedItems(itemHits));
    }

    final columnExtent = layout.columnWidth + layout.columnGap;
    final rowExtent = layout.cellSize + layout.rowGap;
    final columnIndex = ((x - layout.timelineWidth) / columnExtent).floor();
    final rowIndex = ((y - layout.headerHeight) / rowExtent).floor();
    if (columnIndex < 0 ||
        columnIndex >= widget.viewData.columns.length ||
        rowIndex < 0 ||
        rowIndex >= widget.viewData.timeSlots.length) {
      return null;
    }
    final columnLeft = layout.columnLeft(columnIndex);
    final rowTop = layout.rowTop(rowIndex);
    if (x < columnLeft ||
        x > columnLeft + layout.cellSize ||
        y < rowTop ||
        y > rowTop + layout.cellSize) {
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
          final compact = constraints.maxWidth < _HomeGridLayoutSpec.headerCompactWidth;
          final textColor = column.isToday
              ? theme.colorScheme.primary
              : column.emphasize
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: column.isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.14)
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(_HomeGridLayoutSpec.headerCellRadius),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact
                    ? _HomeGridLayoutSpec.headerCompactHorizontalPadding
                    : _HomeGridLayoutSpec.headerHorizontalPadding,
                vertical: compact
                    ? _HomeGridLayoutSpec.headerCompactVerticalPadding
                    : _HomeGridLayoutSpec.headerVerticalPadding,
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
                        color: textColor,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 1),
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

class _TimelineHeaderCell extends StatelessWidget {
  const _TimelineHeaderCell({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: 0,
      top: 0,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(_HomeGridLayoutSpec.headerCellRadius),
        ),
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
    final start = _formatMinute(slot.startMinute);
    final end = _formatMinute(slot.endMinute);
    final backgroundColor = theme.colorScheme.surfaceContainerLow;

    return Positioned(
      left: 0,
      top: top,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_HomeGridLayoutSpec.gridCellRadius),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < HomeGridMetrics.timelineCompactHeight;
            return Padding(
              padding: EdgeInsets.only(
                left: compact
                    ? HomeGridMetrics.timelineCompactHorizontalPadding
                    : HomeGridMetrics.timelineHorizontalPadding,
                right: compact
                    ? HomeGridMetrics.timelineCompactHorizontalPadding
                    : HomeGridMetrics.timelineHorizontalPadding,
              ),
              child: compact
                  ? Align(
                      alignment: Alignment.center,
                      child: Text(
                        start,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          height: HomeGridMetrics.timelineCompactLineHeight,
                          fontSize: HomeGridMetrics.timelineCompactFontSize,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          start,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: HomeGridMetrics.timelineLineHeight,
                            fontSize: HomeGridMetrics.timelineFontSize,
                          ),
                        ),
                        Container(
                          width: math.min(HomeGridMetrics.timelineDividerWidth, width * 0.34),
                          height: 1,
                          margin: const EdgeInsets.symmetric(
                            vertical: _HomeGridLayoutSpec.timelineDividerMargin,
                          ),
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.85),
                        ),
                        Text(
                          end,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            height: HomeGridMetrics.timelineLineHeight,
                            fontSize: HomeGridMetrics.timelineFontSize,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  String _formatMinute(int minute) {
    final normalizedHour = minute ~/ 60;
    final normalizedMinute = minute % 60;
    final hourText = normalizedHour.toString();
    final minuteText = normalizedMinute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }
}

class _HomeGridLayout {
  const _HomeGridLayout({
    required this.timelineWidth,
    required this.columnGap,
    required this.rowGap,
    required this.headerHeight,
    required this.headerCellHeight,
    required this.columnWidth,
    required this.cellSize,
    required this.gridHeight,
    required this.contentHeight,
    required this.contentWidth,
    required this.horizontalPadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.itemInset,
  });

  factory _HomeGridLayout.fromConstraints({
    required BoxConstraints constraints,
    required int columnCount,
    required int rowCount,
  }) {
    const horizontalPadding = _HomeGridLayoutSpec.contentHorizontalPadding;
    const topPadding = _HomeGridLayoutSpec.contentTopPadding;
    const bottomPadding = _HomeGridLayoutSpec.contentBottomPadding;
    const columnGap = _HomeGridLayoutSpec.columnGap;
    const rowGap = _HomeGridLayoutSpec.rowGap;
    const headerHeight = _HomeGridLayoutSpec.headerHeight;
    const headerCellHeight = _HomeGridLayoutSpec.headerCellHeight;
    const itemInset = _HomeGridLayoutSpec.itemInset;
    final availableWidth = math.max(
      0.0,
      constraints.maxWidth - horizontalPadding * 2,
    );
    final safeColumnCount = math.max(1, columnCount);
    final columnWidth = HomeGridMetrics.computeColumnWidth(
      availableWidth: availableWidth,
      columnCount: safeColumnCount,
      columnGap: columnGap,
      minimumColumnWidth: _HomeGridLayoutSpec.minimumColumnWidth,
    );
    final timelineWidth = HomeGridMetrics.computeTimelineWidth(cellWidth: columnWidth);
    final cellSize = columnWidth;
    final safeRowCount = math.max(0, rowCount);
    final gridHeight = safeRowCount == 0
        ? 0.0
        : safeRowCount * cellSize + (safeRowCount - 1) * rowGap;
    final contentWidth =
        timelineWidth + safeColumnCount * columnWidth + safeColumnCount * columnGap;

    return _HomeGridLayout(
      timelineWidth: timelineWidth,
      columnGap: columnGap,
      rowGap: rowGap,
      headerHeight: headerHeight,
      headerCellHeight: headerCellHeight,
      columnWidth: columnWidth,
      cellSize: cellSize,
      gridHeight: gridHeight,
      contentHeight: headerHeight + gridHeight,
      contentWidth: contentWidth,
      horizontalPadding: horizontalPadding,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      itemInset: itemInset,
    );
  }

  final double timelineWidth;
  final double columnGap;
  final double rowGap;
  final double headerHeight;
  final double headerCellHeight;
  final double columnWidth;
  final double cellSize;
  final double gridHeight;
  final double contentHeight;
  final double contentWidth;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;
  final double itemInset;

  double get timelineLabelWidth => timelineWidth;

  Offset contentOffsetFromViewport(Offset viewportPosition, {required double scrollOffset}) {
    return Offset(
      viewportPosition.dx - horizontalPadding,
      viewportPosition.dy + scrollOffset - topPadding,
    );
  }

  double columnLeft(int columnIndex) {
    return timelineWidth + columnGap + columnIndex * (columnWidth + columnGap);
  }

  double rowTop(int rowIndex) {
    return headerHeight + rowIndex * (cellSize + rowGap);
  }

  double itemLeft(HomeLaidOutItem item) {
    return columnLeft(item.columnIndex) + item.left * columnWidth + itemInset;
  }

  double itemTop(HomeLaidOutItem item) {
    return headerHeight + item.top * gridHeight + itemInset;
  }

  double itemWidth(HomeLaidOutItem item) {
    return math.max(
      _HomeGridLayoutSpec.minimumItemWidth,
      columnWidth * item.width - itemInset * 2,
    );
  }

  double itemHeight(HomeLaidOutItem item) {
    return math.max(
      _HomeGridLayoutSpec.minimumItemHeight,
      item.height * gridHeight - itemInset * 2,
    );
  }

  Rect itemRect(HomeLaidOutItem item) {
    return Rect.fromLTWH(
      itemLeft(item),
      itemTop(item),
      itemWidth(item),
      itemHeight(item),
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
          borderRadius: BorderRadius.circular(_HomeGridLayoutSpec.gridCellRadius),
          border: Border.all(
            color: highlight
                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1,
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
    final opacity = item.opacity.clamp(0, 1).toDouble();

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(_HomeGridLayoutSpec.itemRadius),
              border: Border.all(
                color: accent.withValues(alpha: 0.24),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compactHeight =
                    constraints.maxHeight < _HomeGridLayoutSpec.itemCompactHeight;
                final ultraCompactHeight =
                    constraints.maxHeight < _HomeGridLayoutSpec.itemUltraCompactHeight;
                final showDetails =
                    constraints.maxHeight >= _HomeGridLayoutSpec.itemDetailsHeight &&
                        item.item.details.isNotEmpty;
                final titleMaxLines = constraints.maxHeight <
                        _HomeGridLayoutSpec.itemSingleLineHeight
                    ? 1
                    : constraints.maxHeight < _HomeGridLayoutSpec.itemTwoLineHeight
                        ? 2
                        : 3;
                final horizontalPadding =
                    constraints.maxWidth < _HomeGridLayoutSpec.itemCompactWidth
                        ? _HomeGridLayoutSpec.itemCompactHorizontalPadding
                        : _HomeGridLayoutSpec.itemHorizontalPadding;
                final verticalPadding = compactHeight
                    ? _HomeGridLayoutSpec.itemCompactVerticalPadding
                    : _HomeGridLayoutSpec.itemVerticalPadding;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    verticalPadding,
                  ),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: accent.withValues(alpha: 0.96),
                      fontWeight: FontWeight.w700,
                      height: ultraCompactHeight ? 0.94 : compactHeight ? 1 : 1.12,
                    ),
                    child: ultraCompactHeight
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              item.item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: compactHeight
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.item.title,
                                maxLines: titleMaxLines,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (showDetails) ...[
                                const SizedBox(height: _HomeGridLayoutSpec.itemDetailsSpacing),
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
                );
              },
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

abstract final class _HomeGridLayoutSpec {
  static const gridOuterRadius = 12.0;
  static const gridCellRadius = 7.0;
  static const headerCellRadius = 8.0;
  static const itemRadius = 8.0;

  static const contentHorizontalPadding = 0.0;
  static const contentTopPadding = 4.0;
  static const contentBottomPadding = 6.0;
  static const columnGap = 2.0;
  static const rowGap = 2.0;
  static const headerHeight = 40.0;
  static const headerCellHeight = 38.0;
  static const minimumColumnWidth = 18.0;
  static const minimumItemWidth = 16.0;
  static const minimumItemHeight = 24.0;
  static const itemInset = 1.0;

  static const headerCompactWidth = 44.0;
  static const headerHorizontalPadding = 4.0;
  static const headerVerticalPadding = 4.0;
  static const headerCompactHorizontalPadding = 2.0;
  static const headerCompactVerticalPadding = 3.0;

  static const timelineDividerMargin = 2.0;

  static const itemUltraCompactHeight = 28.0;
  static const itemCompactHeight = 36.0;
  static const itemSingleLineHeight = 34.0;
  static const itemTwoLineHeight = 56.0;
  static const itemDetailsHeight = 60.0;
  static const itemCompactWidth = 56.0;
  static const itemCompactHorizontalPadding = 5.0;
  static const itemHorizontalPadding = 8.0;
  static const itemCompactVerticalPadding = 3.0;
  static const itemVerticalPadding = 6.0;
  static const itemDetailsSpacing = 4.0;

  static const minMonthColumnWidth = 40.0;
  static const maxMonthColumnCount = 31;

  static bool canFitMonthLayout(double viewportWidth) {
    final requiredWidth =
        maxMonthColumnCount * minMonthColumnWidth +
        (maxMonthColumnCount - 1) * columnGap +
        HomeGridMetrics.computeTimelineWidth(cellWidth: minMonthColumnWidth) +
        contentHorizontalPadding * 2;
    return viewportWidth >= requiredWidth;
  }

}
