import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/time/now_ticker_provider.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/features/pages/list/domain/models/list_filters.dart';
import 'package:luotopia/features/pages/list/domain/use_cases/build_list_prefill.dart';
import 'package:luotopia/features/pages/list/domain/use_cases/filter_list_items.dart';
import 'package:luotopia/features/pages/list/domain/use_cases/sort_list_items.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';

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

  @override
  ListHeaderState build() {
    return const ListHeaderState(
      currentTab: ListHeaderTab.myDay,
      sortMode: ListSortMode.dueDate,
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
      sortMode: enabled ? ListSortMode.manual : ListSortMode.dueDate,
    );
  }

  void toggleCompletedExpanded() {
    state = state.copyWith(isCompletedExpanded: !state.isCompletedExpanded);
  }

  Future<void> toggleCompleted(String itemId) {
    return ref.read(agendaItemRepositoryProvider.notifier).toggleCompleted(itemId);
  }

  Future<void> deleteItem(String itemId) {
    return ref.read(agendaItemRepositoryProvider.notifier).deleteItem(itemId);
  }

  Future<void> reorderPendingTasks(int oldIndex, int newIndex) async {
    final section = _computeSection(
      items: ref.read(agendaItemRepositoryProvider),
      activeCourseTimetableId: ref.read(courseTimetableRepositoryProvider).activeTimetableId,
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

  ItemEditorPrefill createPrefillForCurrentTab() {
    return _buildPrefill(state.currentTab, DateTime.now());
  }

  static ListPageSection _computeSection({
    required List<AgendaItem> items,
    required String? activeCourseTimetableId,
    required ListHeaderState uiState,
    required DateTime now,
  }) {
    final visibleItems = [
      for (final item in items)
        if (item.type != ItemType.course ||
            (activeCourseTimetableId != null &&
                item.courseDetails.timetableId == activeCourseTimetableId))
          item,
    ];
    final filtered = _filterItems(visibleItems, uiState.currentTab, now);
    final pending = <AgendaItem>[];
    final completed = <AgendaItem>[];

    for (final item in filtered) {
      if (item.isEffectivelyCompleted(now)) {
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
  final now = ref.watch(nowTickerProvider).value ?? DateTime.now();
  final activeCourseTimetableId =
      ref.watch(courseTimetableRepositoryProvider).activeTimetableId;
  final section = ListHeaderViewModel._computeSection(
    items: items,
    activeCourseTimetableId: activeCourseTimetableId,
    uiState: uiState,
    now: now,
  );
  return ListPageViewData(
    state: uiState,
    section: section,
  );
});

