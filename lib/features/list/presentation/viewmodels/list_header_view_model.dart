import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/list/data/list_demo_items.dart';
import 'package:huajuan_agenda/features/list/domain/models/list_filters.dart';
import 'package:huajuan_agenda/features/list/domain/use_cases/build_list_prefill.dart';
import 'package:huajuan_agenda/features/list/domain/use_cases/filter_list_items.dart';
import 'package:huajuan_agenda/features/list/domain/use_cases/sort_list_items.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';

class ListPageSection {
  const ListPageSection({
    required this.pendingItems,
    required this.completedItems,
  });

  final List<AgendaItem> pendingItems;
  final List<AgendaItem> completedItems;
}

class ListHeaderState {
  const ListHeaderState({
    required this.currentTab,
    required this.sortMode,
    required this.isReorderEnabled,
    required this.isCompletedExpanded,
  });

  final ListHeaderTab currentTab;
  final ListSortMode sortMode;
  final bool isReorderEnabled;
  final bool isCompletedExpanded;

  ListHeaderState copyWith({
    ListHeaderTab? currentTab,
    ListSortMode? sortMode,
    bool? isReorderEnabled,
    bool? isCompletedExpanded,
  }) {
    return ListHeaderState(
      currentTab: currentTab ?? this.currentTab,
      sortMode: sortMode ?? this.sortMode,
      isReorderEnabled: isReorderEnabled ?? this.isReorderEnabled,
      isCompletedExpanded: isCompletedExpanded ?? this.isCompletedExpanded,
    );
  }
}

class ListPageViewData {
  const ListPageViewData({
    required this.state,
    required this.section,
  });

  final ListHeaderState state;
  final ListPageSection section;
}

class ListHeaderViewModel extends Notifier<ListHeaderState> {
  static const _filterItems = FilterListItemsUseCase();
  static const _sortItemsUseCase = SortListItemsUseCase();
  static const _buildPrefill = BuildListPrefillUseCase();
  static const _demoItemsSource = ListDemoItemsSource();

  @override
  ListHeaderState build() {
    return const ListHeaderState(
      currentTab: ListHeaderTab.myDay,
      sortMode: ListSortMode.importance,
      isReorderEnabled: false,
      isCompletedExpanded: false,
    );
  }

  void switchTab(ListHeaderTab tab) {
    state = state.copyWith(currentTab: tab);
  }

  void selectSortMode(ListSortMode mode) {
    state = state.copyWith(
      sortMode: mode,
      isReorderEnabled: mode == ListSortMode.manual,
    );
  }

  void setReorderEnabled(bool enabled) {
    state = state.copyWith(
      isReorderEnabled: enabled,
      sortMode: enabled ? ListSortMode.manual : ListSortMode.importance,
    );
  }

  void toggleCompletedExpanded() {
    state = state.copyWith(isCompletedExpanded: !state.isCompletedExpanded);
  }

  Future<void> toggleCompleted(String itemId) {
    return ref.read(agendaItemRepositoryProvider.notifier).toggleCompleted(itemId);
  }

  Future<void> toggleImportant(String itemId) {
    return ref.read(agendaItemRepositoryProvider.notifier).toggleImportant(itemId);
  }

  Future<void> deleteItem(String itemId) {
    return ref.read(agendaItemRepositoryProvider.notifier).deleteItem(itemId);
  }

  Future<void> reorderPendingTasks(int oldIndex, int newIndex) async {
    final section = _computeSection(
      items: ref.read(agendaItemRepositoryProvider),
      uiState: state,
      now: DateTime.now(),
    );
    final taskIds = [
      for (final item in section.pendingItems)
        if (item.type == ItemType.task) item.id,
    ];
    if (taskIds.length < 2) {
      return;
    }

    final normalizedNewIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    if (oldIndex < 0 ||
        oldIndex >= taskIds.length ||
        normalizedNewIndex < 0 ||
        normalizedNewIndex >= taskIds.length) {
      return;
    }

    final moved = taskIds.removeAt(oldIndex);
    taskIds.insert(normalizedNewIndex, moved);
    await ref.read(agendaItemRepositoryProvider.notifier).reorderItems(taskIds);
  }

  Future<void> injectDemoItems() {
    final now = DateTime.now();
    return ref.read(agendaItemRepositoryProvider.notifier).replaceItemsByIdPrefix(
          idPrefix: ListDemoItemsSource.idPrefix,
          items: _demoItemsSource.build(now),
        );
  }

  ItemEditorPrefill createPrefillForCurrentTab() {
    return _buildPrefill(state.currentTab, DateTime.now());
  }

  static ListPageSection _computeSection({
    required List<AgendaItem> items,
    required ListHeaderState uiState,
    required DateTime now,
  }) {
    final visibleItems = [
      for (final item in items)
        if (item.type != ItemType.course) item,
    ];
    final filtered = _filterItems(visibleItems, uiState.currentTab, now);
    final pending = <AgendaItem>[];
    final completed = <AgendaItem>[];

    for (final item in filtered) {
      if (item.isCompleted) {
        completed.add(item);
      } else {
        pending.add(item);
      }
    }

    final sortMode = uiState.isReorderEnabled ? ListSortMode.manual : uiState.sortMode;
    return ListPageSection(
      pendingItems: _sortItemsUseCase(pending, sortMode, now),
      completedItems: _sortItemsUseCase(completed, sortMode, now),
    );
  }
}

final listHeaderViewModelProvider =
    NotifierProvider<ListHeaderViewModel, ListHeaderState>(
  ListHeaderViewModel.new,
);

final listPageViewDataProvider = Provider<ListPageViewData>((ref) {
  final uiState = ref.watch(listHeaderViewModelProvider);
  final items = ref.watch(agendaItemRepositoryProvider);
  final section = ListHeaderViewModel._computeSection(
    items: items,
    uiState: uiState,
    now: DateTime.now(),
  );
  return ListPageViewData(
    state: uiState,
    section: section,
  );
});

