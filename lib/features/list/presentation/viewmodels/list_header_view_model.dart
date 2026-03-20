import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/shared/data/agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';

enum ListHeaderTab {
  myDay,
  allItems,
  tasks,
  schedules,
  memos,
  important,
}

enum ListSortMode {
  importance,
  dueDate,
  todayFocus,
  alphabetical,
  createdDate,
  manual,
}

extension ListHeaderTabLabelX on ListHeaderTab {
  String get key => name;
}

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

  ItemEditorPrefill createPrefillForCurrentTab() {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    return switch (state.currentTab) {
      ListHeaderTab.myDay => ItemEditorPrefill(
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
          targetDate: today,
        ),
      ListHeaderTab.allItems => const ItemEditorPrefill(),
      ListHeaderTab.tasks => ItemEditorPrefill(
          type: ItemType.task,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
          deadline: today.add(const Duration(hours: 18)),
        ),
      ListHeaderTab.schedules => ItemEditorPrefill(
          type: ItemType.schedule,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
        ),
      ListHeaderTab.memos => ItemEditorPrefill(
          type: ItemType.memo,
          targetDate: today,
          estimatedDuration: const Duration(hours: 1),
        ),
      ListHeaderTab.important => ItemEditorPrefill(
          isImportant: true,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
          targetDate: today,
        ),
    };
  }

  static ListPageSection _computeSection({
    required List<AgendaItem> items,
    required ListHeaderState uiState,
    required DateTime now,
  }) {
    final filtered = _filterByTab(items, uiState.currentTab, now);
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
      pendingItems: _sortItems(pending, sortMode, now),
      completedItems: _sortItems(completed, sortMode, now),
    );
  }

  static List<AgendaItem> _filterByTab(
    List<AgendaItem> items,
    ListHeaderTab tab,
    DateTime now,
  ) {
    return switch (tab) {
      ListHeaderTab.myDay => items.where((item) => _isInMyDay(item, now)).toList(),
      ListHeaderTab.allItems => [...items],
      ListHeaderTab.tasks => items.where((item) => item.type == ItemType.task).toList(),
      ListHeaderTab.schedules =>
        items.where((item) => item.type == ItemType.schedule).toList(),
      ListHeaderTab.memos => items.where((item) => item.type == ItemType.memo).toList(),
      ListHeaderTab.important => items.where((item) => item.isImportant).toList(),
    };
  }

  static bool _isInMyDay(AgendaItem item, DateTime now) {
    final today = DateUtils.dateOnly(now);
    if (item.type == ItemType.memo) {
      return DateUtils.isSameDay(item.targetDate, today);
    }

    final startDay = DateUtils.dateOnly(item.startAt);
    final endDay = DateUtils.dateOnly(item.endAt);
    return !today.isBefore(startDay) && !today.isAfter(endDay);
  }

  static List<AgendaItem> _sortItems(
    List<AgendaItem> items,
    ListSortMode mode,
    DateTime now,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) => _compareItems(a, b, mode, now));
    return sorted;
  }

  static int _compareItems(
    AgendaItem a,
    AgendaItem b,
    ListSortMode mode,
    DateTime now,
  ) {
    final importanceOrder = _compareBool(b.isImportant, a.isImportant);
    switch (mode) {
      case ListSortMode.importance:
        return importanceOrder != 0 ? importanceOrder : _compareByTimeThenCreated(a, b);
      case ListSortMode.dueDate:
        return _compareNullableDate(_dueDateOf(a), _dueDateOf(b), fallback: () {
          return _compareByTimeThenCreated(a, b);
        });
      case ListSortMode.todayFocus:
        final aScore = _todayFocusScore(a, now);
        final bScore = _todayFocusScore(b, now);
        final scoreOrder = bScore.compareTo(aScore);
        if (scoreOrder != 0) {
          return scoreOrder;
        }
        return _compareByTimeThenCreated(a, b);
      case ListSortMode.alphabetical:
        final titleOrder = a.title.toLowerCase().compareTo(b.title.toLowerCase());
        if (titleOrder != 0) {
          return titleOrder;
        }
        return _compareByTimeThenCreated(a, b);
      case ListSortMode.createdDate:
        final createdOrder = b.createdAt.compareTo(a.createdAt);
        if (createdOrder != 0) {
          return createdOrder;
        }
        return _compareByTimeThenCreated(a, b);
      case ListSortMode.manual:
        final manualOrder = a.manualOrder.compareTo(b.manualOrder);
        if (manualOrder != 0) {
          return manualOrder;
        }
        return _compareByTimeThenCreated(a, b);
    }
  }

  static int _compareByTimeThenCreated(AgendaItem a, AgendaItem b) {
    final timeOrder = _primaryDateOf(a).compareTo(_primaryDateOf(b));
    if (timeOrder != 0) {
      return timeOrder;
    }
    final typeOrder = a.type.index.compareTo(b.type.index);
    if (typeOrder != 0) {
      return typeOrder;
    }
    return a.createdAt.compareTo(b.createdAt);
  }

  static DateTime _primaryDateOf(AgendaItem item) {
    return switch (item.type) {
      ItemType.memo => item.targetDate,
      ItemType.task => item.deadline ?? item.startAt,
      ItemType.schedule => item.startAt,
    };
  }

  static DateTime? _dueDateOf(AgendaItem item) {
    return switch (item.type) {
      ItemType.memo => item.targetDate,
      ItemType.task => item.deadline ?? item.endAt,
      ItemType.schedule => item.startAt,
    };
  }

  static int _todayFocusScore(AgendaItem item, DateTime now) {
    final today = DateUtils.dateOnly(now);
    final target = DateUtils.dateOnly(_primaryDateOf(item));
    final distance = target.difference(today).inDays.abs();
    final dateScore = math.max(0, 100 - distance * 10);
    final importantScore = item.isImportant ? 40 : 0;
    return dateScore + importantScore;
  }

  static int _compareBool(bool left, bool right) {
    return left == right ? 0 : (left ? 1 : -1);
  }

  static int _compareNullableDate(
    DateTime? left,
    DateTime? right, {
    required int Function() fallback,
  }) {
    if (left == null && right == null) {
      return fallback();
    }
    if (left == null) {
      return 1;
    }
    if (right == null) {
      return -1;
    }
    final result = left.compareTo(right);
    return result != 0 ? result : fallback();
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
