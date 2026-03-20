import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';
import 'package:huajuan_agenda/core/motion/app_motion_widgets.dart';
import 'package:huajuan_agenda/core/theme/app_icons.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_args.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/list/presentation/viewmodels/list_header_view_model.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
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
              const Color(0xFFE9F8F1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 16 : 24,
                  12,
                  isCompact ? 16 : 24,
                  112,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppEntrance(
                          child: _ListHeroCard(
                            tabLabel: _tabLabel(l10n, state.currentTab),
                            summary: _summaryLabel(l10n, section),
                            sortLabel: _sortLabel(l10n, state),
                            reorderEnabled: state.isReorderEnabled,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (section.pendingItems.isEmpty && section.completedItems.isEmpty)
                          AppEntrance(
                            delay: AppMotion.fast,
                            offset: AppMotion.sectionOffset,
                            child: _EmptyListCard(
                              title: l10n.listEmptyTitle,
                              description: l10n.listEmptyDescription,
                            ),
                          )
                        else ...[
                          AppEntrance(
                            delay: AppMotion.fast,
                            offset: AppMotion.sectionOffset,
                            child: _buildPendingSection(context, ref, section.pendingItems, state),
                          ),
                          const SizedBox(height: 16),
                          AppEntrance(
                            delay: AppMotion.fast * 2,
                            offset: AppMotion.sectionOffset,
                            child: _CompletedSection(
                              title: l10n.listCompletedSection(section.completedItems.length),
                              isExpanded: state.isCompletedExpanded,
                              items: section.completedItems,
                              onToggle: () => ref
                                  .read(listHeaderViewModelProvider.notifier)
                                  .toggleCompletedExpanded(),
                              onToggleComplete: (itemId) => ref
                                  .read(listHeaderViewModelProvider.notifier)
                                  .toggleCompleted(itemId),
                              onToggleImportant: (itemId) => ref
                                  .read(listHeaderViewModelProvider.notifier)
                                  .toggleImportant(itemId),
                              onOpenDetail: (item) => _openDetail(context, item),
                              onEdit: (item) => _openEditor(context, item: item),
                              onDelete: (itemId) => ref
                                  .read(listHeaderViewModelProvider.notifier)
                                  .deleteItem(itemId),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
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
                backgroundColor: const Color(0xFF2E7D59),
                foregroundColor: Colors.white,
                child: const Icon(AppIcons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingSection(
    BuildContext context,
    WidgetRef ref,
    List<AgendaItem> items,
    ListHeaderState state,
  ) {
    final l10n = context.l10n;
    final canReorder = state.isReorderEnabled &&
        (state.currentTab == ListHeaderTab.tasks || state.currentTab == ListHeaderTab.allItems) &&
        items.where((item) => item.type == ItemType.task).length > 1;

    if (!canReorder) {
      return _ListSectionCard(
        title: l10n.listPendingSection(items.length),
        child: Column(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SwipeableListItem(
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
              ),
          ],
        ),
      );
    }

    final taskItems = items.where((item) => item.type == ItemType.task).toList();
    final otherItems = items.where((item) => item.type != ItemType.task).toList();

    return _ListSectionCard(
      title: l10n.listPendingSection(items.length),
      subtitle: l10n.listReorderHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (taskItems.isNotEmpty)
            Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskItems.length,
                onReorder: (oldIndex, newIndex) => ref
                    .read(listHeaderViewModelProvider.notifier)
                    .reorderPendingTasks(oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final item = taskItems[index];
                  return Padding(
                    key: ValueKey(item.id),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SwipeableListItem(
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
            ),
          if (otherItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.listStaticItemsLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 10),
            for (final item in otherItems)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SwipeableListItem(
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
              ),
          ],
        ],
      ),
    );
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

  String _summaryLabel(AppLocalizations l10n, ListPageSection section) {
    return l10n.listSummary(section.pendingItems.length, section.completedItems.length);
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
              isImportant: item.isImportant,
            ),
          );
    context.push(AppRoutePaths.itemEditor, extra: extra);
  }
}

class _ListHeroCard extends StatelessWidget {
  const _ListHeroCard({
    required this.tabLabel,
    required this.summary,
    required this.sortLabel,
    required this.reorderEnabled,
  });

  final String tabLabel;
  final String summary;
  final String sortLabel;
  final bool reorderEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEF9F0),
            Color(0xFFD9F0E4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tabLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF173B2D),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            style: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF406757),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.sort,
                label: sortLabel,
              ),
              if (reorderEnabled)
                _HeroChip(
                  icon: AppIcons.drag,
                  label: context.l10n.listSortManual,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D59)),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _ListSectionCard extends StatelessWidget {
  const _ListSectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ui.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CompletedSection extends StatelessWidget {
  const _CompletedSection({
    required this.title,
    required this.isExpanded,
    required this.items,
    required this.onToggle,
    required this.onToggleComplete,
    required this.onToggleImportant,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final bool isExpanded;
  final List<AgendaItem> items;
  final VoidCallback onToggle;
  final ValueChanged<String> onToggleComplete;
  final ValueChanged<String> onToggleImportant;
  final ValueChanged<AgendaItem> onOpenDetail;
  final ValueChanged<AgendaItem> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return _ListSectionCard(
      title: title,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(isExpanded ? AppIcons.expandLess : AppIcons.expandMore),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isExpanded
                          ? context.l10n.listCompletedCollapse
                          : context.l10n.listCompletedExpand,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SwipeableListItem(
                        item: item,
                        dragIndex: null,
                        onToggleComplete: () => onToggleComplete(item.id),
                        onToggleImportant: () => onToggleImportant(item.id),
                        onOpenDetail: () => onOpenDetail(item),
                        onEdit: () => onEdit(item),
                        onDelete: () => onDelete(item.id),
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: AppMotion.fast,
          ),
        ],
      ),
    );
  }
}

class _SwipeableListItem extends StatelessWidget {
  const _SwipeableListItem({
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = item.color.resolve(theme.brightness);

    return Dismissible(
      key: ValueKey('swipe-${item.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false;
        }
        onDelete();
        return false;
      },
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: accent.withValues(alpha: 0.18),
        icon: AppIcons.edit,
        label: context.l10n.listActionEdit,
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.errorContainer,
        icon: AppIcons.delete,
        label: context.l10n.listActionDelete,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onOpenDetail,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withValues(alpha: 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onToggleComplete,
                  icon: Icon(
                    item.isCompleted ? AppIcons.complete : AppIcons.incomplete,
                    color: item.isCompleted ? const Color(0xFF2E7D59) : accent,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration:
                                  item.isCompleted ? TextDecoration.lineThrough : null,
                              color: theme.colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _subtitle(context, item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (dragIndex != null)
                  ReorderableDragStartListener(
                    index: dragIndex!,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(AppIcons.drag),
                    ),
                  ),
                IconButton(
                  onPressed: onToggleImportant,
                  icon: Icon(
                    item.isImportant
                        ? AppIcons.importantFilled
                        : AppIcons.importantOutlined,
                    color: item.isImportant
                        ? const Color(0xFFF4A63E)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _subtitle(BuildContext context, AgendaItem item) {
    final l10n = context.l10n;
    final localizations = MaterialLocalizations.of(context);
    final date = item.type == ItemType.memo
        ? item.targetDate
        : (item.type == ItemType.task ? (item.deadline ?? item.startAt) : item.startAt);
    final dateLabel = localizations.formatShortDate(date);
    final typeLabel = switch (item.type) {
      ItemType.task => l10n.listTabTasks,
      ItemType.schedule => l10n.listTabSchedules,
      ItemType.memo => l10n.listTabMemos,
    };
    return '$typeLabel · $dateLabel';
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _EmptyListCard extends StatelessWidget {
  const _EmptyListCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ui.Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
