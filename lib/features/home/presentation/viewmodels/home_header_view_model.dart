import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/build_home_grid.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/layout_home_items.dart';
import 'package:huajuan_agenda/features/settings/data/settings_repository_impl.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/shared/data/agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';

class HomeHeaderState {
  const HomeHeaderState({
    required this.anchor,
    this.selectedDate,
    this.selectedSlotIndex,
  });

  final DateTime anchor;
  final DateTime? selectedDate;
  final int? selectedSlotIndex;

  HomeHeaderState copyWith({
    DateTime? anchor,
    DateTime? selectedDate,
    int? selectedSlotIndex,
    bool clearSelectedSlotIndex = false,
  }) {
    return HomeHeaderState(
      anchor: anchor ?? this.anchor,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlotIndex: clearSelectedSlotIndex
          ? null
          : (selectedSlotIndex ?? this.selectedSlotIndex),
    );
  }
}

class HomeViewQuery {
  const HomeViewQuery({
    required this.localeTag,
    required this.allowMonthLayout,
  });

  final String localeTag;
  final bool allowMonthLayout;
}

class HomeHeaderViewModel extends Notifier<HomeHeaderState> {
  static const _gridBuilder = BuildHomeGridUseCase();
  static const _itemLayoutBuilder = LayoutHomeItemsUseCase();

  @override
  HomeHeaderState build() {
    final now = DateUtils.dateOnly(DateTime.now());
    return HomeHeaderState(
      anchor: now,
      selectedDate: now,
    );
  }

  void showPrevious(HomeDisplayScope scope) {
    state = state.copyWith(
      anchor: switch (scope) {
        HomeDisplayScope.week => state.anchor.subtract(const Duration(days: 7)),
        HomeDisplayScope.month => DateTime(state.anchor.year, state.anchor.month - 1, 1),
      },
    );
  }

  void showNext(HomeDisplayScope scope) {
    state = state.copyWith(
      anchor: switch (scope) {
        HomeDisplayScope.week => state.anchor.add(const Duration(days: 7)),
        HomeDisplayScope.month => DateTime(state.anchor.year, state.anchor.month + 1, 1),
      },
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: DateUtils.dateOnly(date));
  }

  void selectCell(DateTime date, int slotIndex) {
    state = state.copyWith(
      selectedDate: DateUtils.dateOnly(date),
      selectedSlotIndex: slotIndex,
    );
  }

  void jumpToSelection(HomePeriodSelection selection) {
    state = state.copyWith(
      anchor: DateUtils.dateOnly(selection.anchor),
      selectedDate: DateUtils.dateOnly(selection.anchor),
    );
  }
}

final homeHeaderViewModelProvider =
    NotifierProvider<HomeHeaderViewModel, HomeHeaderState>(
  HomeHeaderViewModel.new,
);

final homeViewDataProvider = Provider.family<HomeViewData, HomeViewQuery>((ref, query) {
  final state = ref.watch(homeHeaderViewModelProvider);
  final settings = ref.watch(appHomeSettingsProvider);
  final repositoryItems = ref.watch(agendaItemRepositoryProvider);
  final scope = query.allowMonthLayout && settings.wideLayoutScope == HomeWideLayoutScope.month
      ? HomeDisplayScope.month
      : HomeDisplayScope.week;
  final previewGrid = HomeHeaderViewModel._gridBuilder.build(
    localeTag: query.localeTag,
    anchor: state.anchor,
    scope: scope,
    selectedDate: state.selectedDate,
    selectedCell: null,
    settings: settings,
    items: const [],
  );
  final visibleItems = [
    for (final item in repositoryItems)
      if (item.type == ItemType.task || item.type == ItemType.schedule) item,
  ];
  final laidOutItems = HomeHeaderViewModel._itemLayoutBuilder.build(
    items: visibleItems,
    visibleRange: previewGrid.visibleRange,
    timeSlots: previewGrid.timeSlots,
  );
  final selectedCell = state.selectedDate == null || state.selectedSlotIndex == null
      ? null
      : () {
          final slotIndex = state.selectedSlotIndex!;
          if (slotIndex < 0 || slotIndex >= previewGrid.timeSlots.length) {
            return null;
          }
          return HomeCellSelection(
            date: state.selectedDate!,
            slot: previewGrid.timeSlots[slotIndex],
          );
        }();

  return HomeHeaderViewModel._gridBuilder.build(
    localeTag: query.localeTag,
    anchor: state.anchor,
    scope: scope,
    selectedDate: state.selectedDate,
    selectedCell: selectedCell,
    settings: settings,
    items: laidOutItems,
  );
});
