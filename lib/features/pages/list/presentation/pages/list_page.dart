import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/motion/app_motion_widgets.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/core/theme/app_semantic_colors.dart';
import 'package:luotopia/features/pages/item_detail/domain/models/item_detail_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/features/pages/list/domain/models/list_filters.dart';
import 'package:luotopia/features/pages/list/presentation/viewmodels/list_header_view_model.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewData = ref.watch(listPageViewDataProvider);
    final state = viewData.state;
    final section = viewData.section;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(_tabLabel(l10n, state.currentTab)),
          trailing: [
            ui.Tooltip(
              tooltip: (context) => Text(l10n.headerOpenListTabs),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.openListTabs),
                onPressed: () => _showTabSwitcher(context, ref),
              ),
            ),
            ui.Tooltip(
              tooltip: (context) => Text(l10n.headerOpenListSettings),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.moreActions),
                onPressed: () => _showSettingsMenu(context, ref),
              ),
            ),
          ],
        ),
      ],
      child: DecoratedBox(
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
        child: Stack(
          children: [
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = isCompact ? 16.0 : 24.0;
                  final topPadding = 8.0;
                  final bottomPadding = 112.0;
                  final rows = _buildRows(
                    pendingItems: section.pendingItems,
                    completedItems: section.completedItems,
                    isCompletedExpanded: state.isCompletedExpanded,
                  );
                  final availableHeight =
                      math.max(0.0, constraints.maxHeight - topPadding - bottomPadding);
                  final emptyRowCount = _calculateEmptyRowCount(
                    existingRowCount: _rowCount(rows),
                    availableHeight: availableHeight,
                  );

                  final hasCompletedSection = rows.any(
                    (row) => row is _CompletedHeaderRow,
                  );

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 920,
                          minHeight: math.max(0.0, constraints.maxHeight - topPadding),
                        ),
                        child: AppEntrance(
                          child: Column(
                            children: [
                              for (final row in rows)
                                switch (row) {
                                  _PendingTaskRows(:final items) => _PendingTaskRowList(
                                    items: items,
                                    state: state,
                                  ),
                                  _StaticItemRow(:final item) => _ListItemRow(
                                    item: item,
                                    dragIndex: null,
                                    onToggleComplete: () => ref
                                        .read(listHeaderViewModelProvider.notifier)
                                        .toggleCompleted(item.id),
                                    onToggleImportant: () => ref
                                        .read(listHeaderViewModelProvider.notifier)
                                        .toggleImportant(item.id),
                                    onOpenDetail: () => _openDetail(context, item),
                                    onEdit: () => _openEditor(context, item: item),
                                    onDelete: () => ref
                                        .read(listHeaderViewModelProvider.notifier)
                                        .deleteItem(item.id),
                                  ),
                                  _CompletedHeaderRow(:final count) => _CompletedToggleRow(
                                    title: l10n.listCompletedSection(count),
                                    isExpanded: state.isCompletedExpanded,
                                    onToggle: () => ref
                                        .read(listHeaderViewModelProvider.notifier)
                                        .toggleCompletedExpanded(),
                                  ),
                                },
                              for (var index = 0; index < emptyRowCount; index++)
                                _EmptyRow(
                                  showTopDivider: hasCompletedSection || index > 0,
                                ),
                              if (emptyRowCount > 0) const _EmptyRowsBottomLine(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: isCompact ? 20 : 28,
              bottom: isCompact ? 24 : 32,
              child: FloatingActionButton(
                heroTag: 'list-fab',
                onPressed: () => _openEditor(
                  context,
                  prefill: ref
                      .read(listHeaderViewModelProvider.notifier)
                      .createPrefillForCurrentTab(),
                ),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                child: const Icon(AppIcons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ListVisualRow> _buildRows({
    required List<AgendaItem> pendingItems,
    required List<AgendaItem> completedItems,
    required bool isCompletedExpanded,
  }) {
    final rows = <_ListVisualRow>[];
    final reorderableTasks = <AgendaItem>[];

    for (final item in pendingItems) {
      if (item.type == ItemType.task) {
        reorderableTasks.add(item);
      } else {
        if (reorderableTasks.isNotEmpty) {
          rows.add(_PendingTaskRows(reorderableTasks.toList(growable: false)));
          reorderableTasks.clear();
        }
        rows.add(_StaticItemRow(item));
      }
    }
    if (reorderableTasks.isNotEmpty) {
      rows.add(_PendingTaskRows(reorderableTasks.toList(growable: false)));
    }
    if (completedItems.isNotEmpty) {
      rows.add(_CompletedHeaderRow(completedItems.length));
      if (isCompletedExpanded) {
        rows.addAll(completedItems.map(_StaticItemRow.new));
      }
    }
    return rows;
  }

  int _calculateEmptyRowCount({
    required int existingRowCount,
    required double availableHeight,
  }) {
    final occupiedHeight = existingRowCount * _ListRowMetrics.rowHeight;
    if (occupiedHeight >= availableHeight) {
      return 0;
    }
    return ((availableHeight - occupiedHeight) / _ListRowMetrics.rowHeight).ceil();
  }

  int _rowCount(List<_ListVisualRow> rows) {
    var count = 0;
    for (final row in rows) {
      count += switch (row) {
        _PendingTaskRows(:final items) => items.length,
        _StaticItemRow() || _CompletedHeaderRow() => 1,
      };
    }
    return count;
  }

  String _tabLabel(AppLocalizations l10n, ListHeaderTab tab) {
    return switch (tab) {
      ListHeaderTab.myDay => l10n.listTabMyDay,
      ListHeaderTab.allItems => l10n.listTabAllItems,
      ListHeaderTab.tasks => l10n.listTabTasks,
      ListHeaderTab.schedules => l10n.listTabSchedules,
      ListHeaderTab.memos => l10n.listTabMemos,
      ListHeaderTab.important => l10n.listTabImportant,
    };
  }

  String _sortLabel(AppLocalizations l10n, ListHeaderState state) {
    final mode = state.isReorderEnabled ? ListSortMode.manual : state.sortMode;
    return _sortLabelByMode(l10n, mode);
  }

  String _sortLabelByMode(AppLocalizations l10n, ListSortMode mode) {
    return switch (mode) {
      ListSortMode.importance => l10n.listSortImportance,
      ListSortMode.dueDate => l10n.listSortDueDate,
      ListSortMode.todayFocus => l10n.listSortTodayFocus,
      ListSortMode.alphabetical => l10n.listSortAlphabetical,
      ListSortMode.createdDate => l10n.listSortCreatedDate,
      ListSortMode.manual => l10n.listSortManual,
    };
  }

  String _debugAddDemoItemsLabel(BuildContext context) {
    return _isChinese(context) ? '调试：填充假数据' : 'Debug: Fill sample items';
  }

  String _debugAddDemoItemsDescription(BuildContext context) {
    return _isChinese(context)
        ? '向列表页写入一批内置示例事项，便于查看排版和交互效果。'
        : 'Insert built-in sample items into the list page for layout and interaction review.';
  }

  String _debugAddDemoItemsDoneLabel(BuildContext context) {
    return _isChinese(context) ? '已填充列表页假数据。' : 'List demo items added.';
  }

  bool _isChinese(BuildContext context) {
    return Localizations.localeOf(context).languageCode.toLowerCase().startsWith('zh');
  }

  Future<void> _showTabSwitcher(BuildContext context, WidgetRef ref) {
    final state = ref.read(listHeaderViewModelProvider);
    final l10n = context.l10n;

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: RadioGroup<ListHeaderTab>(
              groupValue: state.currentTab,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(listHeaderViewModelProvider.notifier).switchTab(value);
                ui.closeDrawer(sheetContext);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.listMenuTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...ListHeaderTab.values.map(
                    (tab) => RadioListTile<ListHeaderTab>(
                      value: tab,
                      title: Text(_tabLabel(l10n, tab)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSettingsMenu(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.read(listHeaderViewModelProvider);

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.listSettingsMenuTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: Text(l10n.listSettingsSort),
                  subtitle: Text(_sortLabel(l10n, state)),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    _showSortSheet(context, ref);
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(AppIcons.drag),
                  title: Text(l10n.listSettingsReorder),
                  value: state.isReorderEnabled,
                  onChanged: (value) {
                    ref.read(listHeaderViewModelProvider.notifier).setReorderEnabled(value);
                  },
                ),
                ListTile(
                  leading: const Icon(AppIcons.appearanceSection),
                  title: Text(l10n.listSettingsTheme),
                  subtitle: Text(l10n.listThemeComingSoon),
                ),
                ListTile(
                  leading: const Icon(AppIcons.info),
                  title: Text(_debugAddDemoItemsLabel(context)),
                  subtitle: Text(_debugAddDemoItemsDescription(context)),
                  onTap: () async {
                    ui.closeDrawer(sheetContext);
                    await ref.read(listHeaderViewModelProvider.notifier).injectDemoItems();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_debugAddDemoItemsDoneLabel(context)),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(AppIcons.settingsOutlined),
                  title: Text(l10n.listSettingsMore),
                  onTap: () {
                    ui.closeDrawer(sheetContext);
                    context.go(AppRoutePaths.settings);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showSortSheet(BuildContext context, WidgetRef ref) {
    final state = ref.read(listHeaderViewModelProvider);
    final l10n = context.l10n;

    return ui.openSheet<void>(
      context: context,
      position: ui.OverlayPosition.bottom,
      builder: (sheetContext) {
        return AppSheetEntrance(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: RadioGroup<ListSortMode>(
              groupValue: state.isReorderEnabled ? ListSortMode.manual : state.sortMode,
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                ref.read(listHeaderViewModelProvider.notifier).selectSortMode(value);
                ui.closeDrawer(sheetContext);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.listSettingsSort,
                    style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  for (final mode in ListSortMode.values)
                    RadioListTile<ListSortMode>(
                      value: mode,
                      title: Text(_sortLabelByMode(l10n, mode)),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, AgendaItem item) {
    context.push(
      AppRoutePaths.itemDetail,
      extra: ItemDetailArgs(itemId: item.id),
    );
  }

  void _openEditor(
    BuildContext context, {
    AgendaItem? item,
    ItemEditorPrefill? prefill,
  }) {
    final extra = item == null
        ? ItemEditorArgs(prefill: prefill)
        : ItemEditorArgs(
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
          );
    context.openItemEditorFlow(extra: extra);
  }
}

class _PendingTaskRowList extends ConsumerWidget {
  const _PendingTaskRowList({
    required this.items,
    required this.state,
  });

  final List<AgendaItem> items;
  final ListHeaderState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canReorder = state.isReorderEnabled &&
        (state.currentTab == ListHeaderTab.tasks || state.currentTab == ListHeaderTab.allItems) &&
        items.length > 1;

    if (!canReorder) {
      return Column(
        children: [
          for (final item in items)
            _ListItemRow(
              item: item,
              dragIndex: null,
              onToggleComplete: () => ref
                  .read(listHeaderViewModelProvider.notifier)
                  .toggleCompleted(item.id),
              onToggleImportant: () => ref
                  .read(listHeaderViewModelProvider.notifier)
                  .toggleImportant(item.id),
              onOpenDetail: () => _openDetail(context, item),
              onEdit: () => _openEditor(context, item: item),
              onDelete: () => ref
                  .read(listHeaderViewModelProvider.notifier)
                  .deleteItem(item.id),
            ),
        ],
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        onReorder: (oldIndex, newIndex) => ref
            .read(listHeaderViewModelProvider.notifier)
            .reorderPendingTasks(oldIndex, newIndex),
        itemBuilder: (context, index) {
          final item = items[index];
          return KeyedSubtree(
            key: ValueKey(item.id),
            child: _ListItemRow(
              item: item,
              dragIndex: index,
              onToggleComplete: () => ref
                  .read(listHeaderViewModelProvider.notifier)
                  .toggleCompleted(item.id),
              onToggleImportant: () => ref
                  .read(listHeaderViewModelProvider.notifier)
                  .toggleImportant(item.id),
              onOpenDetail: () => _openDetail(context, item),
              onEdit: () => _openEditor(context, item: item),
              onDelete: () => ref
                  .read(listHeaderViewModelProvider.notifier)
                  .deleteItem(item.id),
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, AgendaItem item) {
    context.push(
      AppRoutePaths.itemDetail,
      extra: ItemDetailArgs(itemId: item.id),
    );
  }

  void _openEditor(
    BuildContext context, {
    AgendaItem? item,
  }) {
    if (item == null) {
      return;
    }
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

class _ListItemRow extends StatefulWidget {
  const _ListItemRow({
    required this.item,
    required this.dragIndex,
    required this.onToggleComplete,
    required this.onToggleImportant,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final AgendaItem item;
  final int? dragIndex;
  final VoidCallback onToggleComplete;
  final VoidCallback onToggleImportant;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ListItemRow> createState() => _ListItemRowState();
}

class _ListItemRowState extends State<_ListItemRow> with SingleTickerProviderStateMixin {
  static const _reboundDuration = Duration(milliseconds: 160);

  late final SlidableController _slidableController;
  bool _swipeActionTriggered = false;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this)
      ..endGesture.addListener(_handleEndGestureChanged)
      ..animation.addListener(_handleSlideAnimationChanged);
  }

  @override
  void dispose() {
    _slidableController.endGesture.removeListener(_handleEndGestureChanged);
    _slidableController.animation.removeListener(_handleSlideAnimationChanged);
    _slidableController.dispose();
    super.dispose();
  }

  void _handleSlideAnimationChanged() {
    if (_swipeActionTriggered && _slidableController.ratio.abs() < 0.01) {
      _swipeActionTriggered = false;
    }
  }

  void _handleEndGestureChanged() {
    if (_swipeActionTriggered) {
      return;
    }
    final ratio = _slidableController.ratio;
    if (ratio.abs() < _SwipeStageMetrics.commitThreshold) {
      return;
    }
    _swipeActionTriggered = true;
    _slidableController.close(duration: _reboundDuration);
    if (ratio.isNegative) {
      widget.onDelete();
      return;
    }
    widget.onEdit();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final accent = item.color.resolve(theme.brightness);
    final canToggleCompleted = item.supportsManualCompletion;
    final canToggleImportant = item.type != ItemType.course;
    final isEffectivelyCompleted = item.isEffectivelyCompleted(DateTime.now());
    final isManuallyCompleted = item.isCompleted && canToggleCompleted;
    final editSwipeBackground = Color.alphaBlend(
      accent.withValues(alpha: theme.brightness == Brightness.dark ? 0.34 : 0.18),
      theme.colorScheme.surfaceContainerHighest,
    );
    final cardColor = Color.alphaBlend(
      theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.62),
      theme.colorScheme.surface,
    );
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.18);

    return SizedBox(
      height: _ListRowMetrics.rowHeight,
      child: Slidable(
        key: ValueKey('swipe-${item.id}'),
        controller: _slidableController,
        closeOnScroll: true,
        startActionPane: ActionPane(
          extentRatio: 1,
          openThreshold: 0.999,
          closeThreshold: 0.999,
          motion: _PhasedSwipeMotion(
            controller: _slidableController,
            backgroundColor: editSwipeBackground,
            actionColor: accent,
            committedIconColor: AppSemanticColors.onAgendaAccent(accent),
            icon: AppIcons.edit,
            alignment: Alignment.centerLeft,
          ),
          children: const [SizedBox.expand()],
        ),
        endActionPane: ActionPane(
          extentRatio: 1,
          openThreshold: 0.999,
          closeThreshold: 0.999,
          motion: _PhasedSwipeMotion(
            controller: _slidableController,
            backgroundColor: AppSemanticColors.listSwipeBackground(theme),
            actionColor: AppSemanticColors.listSwipeDeleteAction(theme),
            committedIconColor: theme.colorScheme.onError,
            icon: AppIcons.delete,
            alignment: Alignment.centerRight,
          ),
          children: const [SizedBox.expand()],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: _ListRowMetrics.cardVerticalInset,
            ),
            child: InkWell(
              onTap: widget.onOpenDetail,
              borderRadius: BorderRadius.circular(_ListRowMetrics.cardRadius),
              child: Ink(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(_ListRowMetrics.cardRadius),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _ListRowMetrics.cardHorizontalPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _ActionIconButton(
                        onPressed: canToggleCompleted ? widget.onToggleComplete : null,
                        icon: isEffectivelyCompleted ? AppIcons.complete : AppIcons.incomplete,
                        color: accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                  decoration: isManuallyCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  height: 1,
                                ),
                          ),
                        ),
                      ),
                      if (widget.dragIndex != null) ...[
                        const SizedBox(width: 8),
                        ReorderableDragStartListener(
                          index: widget.dragIndex!,
                          child: Icon(
                            AppIcons.drag,
                            size: 20,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(width: 4),
                      canToggleImportant
                          ? _ActionIconButton(
                              onPressed: widget.onToggleImportant,
                              icon: item.isImportant
                                  ? AppIcons.importantFilled
                                  : AppIcons.importantOutlined,
                              color: item.isImportant
                                  ? AppSemanticColors.listImportantStar(theme)
                                  : theme.colorScheme.onSurfaceVariant,
                            )
                          : const SizedBox(
                              width: 28,
                              height: 28,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletedToggleRow extends StatelessWidget {
  const _CompletedToggleRow({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
  });

  final String title;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _ListRowMetrics.rowHeight,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: _ListRowMetrics.cardVerticalInset,
          ),
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(_ListRowMetrics.cardRadius),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_ListRowMetrics.cardRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _ListRowMetrics.cardHorizontalPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                        ),
                      ),
                    ),
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

class _EmptyRow extends StatelessWidget {
  const _EmptyRow({
    this.showTopDivider = true,
  });

  final bool showTopDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = Color.alphaBlend(
      theme.colorScheme.outline.withValues(alpha: 0.52),
      theme.colorScheme.surface,
    );

    return SizedBox(
      height: _ListRowMetrics.rowHeight,
      width: double.infinity,
      child: Align(
        alignment: Alignment.topCenter,
        child: showTopDivider
            ? Container(
                height: 1,
                color: dividerColor,
              )
            : null,
      ),
    );
  }
}

class _EmptyRowsBottomLine extends StatelessWidget {
  const _EmptyRowsBottomLine();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = Color.alphaBlend(
      theme.colorScheme.outline.withValues(alpha: 0.52),
      theme.colorScheme.surface,
    );

    return Container(
      height: 1,
      width: double.infinity,
      color: dividerColor,
    );
  }
}

class _PhasedSwipeMotion extends StatelessWidget {
  const _PhasedSwipeMotion({
    required this.controller,
    required this.backgroundColor,
    required this.actionColor,
    required this.committedIconColor,
    required this.icon,
    required this.alignment,
  });

  final SlidableController controller;
  final Color backgroundColor;
  final Color actionColor;
  final Color committedIconColor;
  final IconData icon;
  final Alignment alignment;

  bool get _isFromStart => alignment.x < 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) {
        final progress = controller.ratio.abs().clamp(0.0, 1.0);
        final iconProgress = _progressBetween(
          progress,
          0,
          _SwipeStageMetrics.coverThreshold,
        );
        final iconBubbleSize = lerpDouble(
              _SwipeStageMetrics.minBubbleSize,
              _SwipeStageMetrics.maxBubbleSize,
              Curves.easeOut.transform(iconProgress),
            ) ??
            _SwipeStageMetrics.maxBubbleSize;
        final iconScale = lerpDouble(
              0.92,
              1,
              Curves.easeOut.transform(iconProgress),
            ) ??
            1;
        final showCircle = progress >= _SwipeStageMetrics.commitThreshold;
        final theme = Theme.of(context);
        final iconColor = showCircle
            ? committedIconColor
            : AppSemanticColors.listSwipePassiveIcon(theme);

        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: _ListRowMetrics.cardVerticalInset,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_ListRowMetrics.cardRadius),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final paneSize = Size(constraints.maxWidth, constraints.maxHeight);
                final revealWidth = paneSize.width * progress;
                final contentGap = _SwipeStageMetrics.contentGap;
                final iconRadius = iconBubbleSize / 2;
                final iconCenterX = _isFromStart
                    ? math.max(
                        iconRadius + contentGap,
                        revealWidth - contentGap - iconRadius,
                      )
                    : math.min(
                        paneSize.width - iconRadius - contentGap,
                        paneSize.width - revealWidth + contentGap + iconRadius,
                      );
                final iconCenter = Offset(iconCenterX, paneSize.height / 2);
                final coverRadius = _coverRadius(
                  size: paneSize,
                  revealWidth: revealWidth,
                  center: iconCenter,
                );
                final circleRadius = showCircle
                    ? lerpDouble(
                          iconRadius,
                          coverRadius,
                          Curves.easeOut.transform(
                            _progressBetween(
                              progress,
                              _SwipeStageMetrics.commitThreshold,
                              _SwipeStageMetrics.coverThreshold,
                            ),
                          ),
                        ) ??
                        coverRadius
                    : 0.0;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _SwipeRevealPainter(
                        revealWidth: revealWidth,
                        isFromStart: _isFromStart,
                        backgroundColor: backgroundColor,
                        actionColor: actionColor,
                        showSolidAction: progress >= _SwipeStageMetrics.coverThreshold,
                        circleCenter: iconCenter,
                        circleRadius: circleRadius,
                      ),
                    ),
                    Positioned(
                      left: iconCenter.dx - iconRadius,
                      top: iconCenter.dy - iconRadius,
                      child: Transform.scale(
                        scale: iconScale,
                        child: SizedBox(
                          width: iconBubbleSize,
                          height: iconBubbleSize,
                          child: Icon(
                            icon,
                            size: 18,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  double _progressBetween(double value, double start, double end) {
    if (end <= start) {
      return 1;
    }
    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  double _coverRadius({
    required Size size,
    required double revealWidth,
    required Offset center,
  }) {
    final left = _isFromStart ? 0.0 : size.width - revealWidth;
    final right = _isFromStart ? revealWidth : size.width;
    final topLeft = Offset(left, 0);
    final topRight = Offset(right, 0);
    final bottomLeft = Offset(left, size.height);
    final bottomRight = Offset(right, size.height);

    return [
      (topLeft - center).distance,
      (topRight - center).distance,
      (bottomLeft - center).distance,
      (bottomRight - center).distance,
    ].reduce(math.max);
  }
}

class _SwipeRevealPainter extends CustomPainter {
  const _SwipeRevealPainter({
    required this.revealWidth,
    required this.isFromStart,
    required this.backgroundColor,
    required this.actionColor,
    required this.showSolidAction,
    required this.circleCenter,
    required this.circleRadius,
  });

  final double revealWidth;
  final bool isFromStart;
  final Color backgroundColor;
  final Color actionColor;
  final bool showSolidAction;
  final Offset circleCenter;
  final double circleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (revealWidth <= 0) {
      return;
    }

    final left = isFromStart ? 0.0 : size.width - revealWidth;
    final revealRect = Rect.fromLTWH(left, 0, revealWidth, size.height);
    final grayPaint = Paint()..color = backgroundColor;
    canvas.drawRect(revealRect, grayPaint);

    if (showSolidAction) {
      final solidPaint = Paint()..color = actionColor;
      canvas.drawRect(revealRect, solidPaint);
      return;
    }

    if (circleRadius <= 0) {
      return;
    }

    canvas.save();
    canvas.clipRect(revealRect);
    final circlePaint = Paint()..color = actionColor;
    canvas.drawCircle(circleCenter, circleRadius, circlePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SwipeRevealPainter oldDelegate) {
    return oldDelegate.revealWidth != revealWidth ||
        oldDelegate.isFromStart != isFromStart ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.actionColor != actionColor ||
        oldDelegate.showSolidAction != showSolidAction ||
        oldDelegate.circleCenter != circleCenter ||
        oldDelegate.circleRadius != circleRadius;
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        iconSize: 22,
        splashRadius: 20,
        icon: Icon(icon, color: color),
      ),
    );
  }
}

sealed class _ListVisualRow {
  const _ListVisualRow();
}

class _PendingTaskRows extends _ListVisualRow {
  const _PendingTaskRows(this.items);

  final List<AgendaItem> items;
}

class _StaticItemRow extends _ListVisualRow {
  const _StaticItemRow(this.item);

  final AgendaItem item;
}

class _CompletedHeaderRow extends _ListVisualRow {
  const _CompletedHeaderRow(this.count);

  final int count;
}

abstract final class _ListRowMetrics {
  static const rowHeight = 62.0;
  static const cardHorizontalPadding = 8.0;
  static const cardVerticalInset = 3.0;
  static const cardRadius = 4.0;
}

abstract final class _SwipeStageMetrics {
  static const commitThreshold = 0.18;
  static const coverThreshold = 4 / 7;
  static const contentGap = 18.0;
  static const minBubbleSize = 24.0;
  static const maxBubbleSize = 30.0;
}

