import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/home/data/home_demo_items.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/build_home_grid.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/layout_home_items.dart';
import 'package:huajuan_agenda/features/settings/domain/models/home_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

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
  static const _demoItemsSource = HomeDemoItemsSource();

  @override
  HomeHeaderState build() {
    final now = DateUtils.dateOnly(DateTime.now());
    return HomeHeaderState(
      anchor: now,
      selectedDate: now,
    );
  }

  void showPrevious(HomeDisplayScope scope) {
    _moveToAnchor(
      switch (scope) {
        HomeDisplayScope.week => state.anchor.subtract(const Duration(days: 7)),
        HomeDisplayScope.month => DateTime(state.anchor.year, state.anchor.month - 1, 1),
      },
      scope: scope,
    );
  }

  void showNext(HomeDisplayScope scope) {
    _moveToAnchor(
      switch (scope) {
        HomeDisplayScope.week => state.anchor.add(const Duration(days: 7)),
        HomeDisplayScope.month => DateTime(state.anchor.year, state.anchor.month + 1, 1),
      },
      scope: scope,
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
    _moveToAnchor(
      DateUtils.dateOnly(selection.anchor),
      scope: selection.scope,
      fallbackSelectedDate: DateUtils.dateOnly(selection.anchor),
    );
  }

  void _moveToAnchor(
    DateTime anchor, {
    required HomeDisplayScope scope,
    DateTime? fallbackSelectedDate,
  }) {
    final normalizedAnchor = DateUtils.dateOnly(anchor);
    final visibleRange = _gridBuilder.visibleDateRange(normalizedAnchor, scope);
    final selectedDate = state.selectedDate == null
        ? fallbackSelectedDate
        : _normalizeSelectionWithinRange(
            selectedDate: state.selectedDate!,
            visibleRange: visibleRange,
            fallbackSelectedDate: fallbackSelectedDate ?? visibleRange.start,
          );
    state = state.copyWith(
      anchor: normalizedAnchor,
      selectedDate: selectedDate,
      clearSelectedSlotIndex: true,
    );
  }

  DateTime _normalizeSelectionWithinRange({
    required DateTime selectedDate,
    required DateTimeRangeValue visibleRange,
    required DateTime fallbackSelectedDate,
  }) {
    final normalizedSelectedDate = DateUtils.dateOnly(selectedDate);
    if (normalizedSelectedDate.isBefore(visibleRange.start) ||
        !normalizedSelectedDate.isBefore(visibleRange.end)) {
      return DateUtils.dateOnly(fallbackSelectedDate);
    }
    return normalizedSelectedDate;
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
  final visibleItems = settings.showDemoData
      ? HomeHeaderViewModel._demoItemsSource.buildForRange(previewGrid.visibleRange)
      : [
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

