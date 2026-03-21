import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/home/data/home_demo_items.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/build_home_grid.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/layout_home_items.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class HomeHeaderState {
  const HomeHeaderState({
    required this.anchor,
    required this.scope,
    this.selectedDate,
  });

  final DateTime anchor;
  final HomeHeaderScope scope;
  final DateTime? selectedDate;

  HomeHeaderState copyWith({
    DateTime? anchor,
    HomeHeaderScope? scope,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
  }) {
    return HomeHeaderState(
      anchor: anchor ?? this.anchor,
      scope: scope ?? this.scope,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
    );
  }
}

enum HomeHeaderScope { week, month }

class HomeHeaderViewModel extends Notifier<HomeHeaderState> {
  static const _gridBuilder = BuildHomeGridUseCase();
  static const _itemLayoutBuilder = LayoutHomeItemsUseCase();
  static const _demoItemsSource = HomeDemoItemsSource();

  @override
  HomeHeaderState build() {
    final now = DateUtils.dateOnly(DateTime.now());
    return HomeHeaderState(
      anchor: now,
      scope: HomeHeaderScope.week,
      selectedDate: now,
    );
  }

  void showPrevious() {
    state = state.copyWith(
      anchor: switch (state.scope) {
        HomeHeaderScope.week => state.anchor.subtract(const Duration(days: 7)),
        HomeHeaderScope.month => DateTime(
            state.anchor.year,
            state.anchor.month - 1,
            state.anchor.day,
          ),
      },
    );
  }

  void showNext() {
    state = state.copyWith(
      anchor: switch (state.scope) {
        HomeHeaderScope.week => state.anchor.add(const Duration(days: 7)),
        HomeHeaderScope.month => DateTime(
            state.anchor.year,
            state.anchor.month + 1,
            state.anchor.day,
          ),
      },
    );
  }

  void switchScope(HomeHeaderScope scope) {
    state = state.copyWith(scope: scope);
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: DateTime(date.year, date.month, date.day));
  }

  void jumpToDate(DateTime date) {
    final normalized = DateUtils.dateOnly(date);
    state = state.copyWith(
      anchor: normalized,
      selectedDate: normalized,
    );
  }

  DateTimeRangeValue visibleRange() {
    return _gridBuilder.build(
      localeTag: 'zh',
      anchor: state.anchor,
      scope: state.scope,
      selectedDate: state.selectedDate,
      items: const [],
    ).visibleRange;
  }

  List<HomeLaidOutItem> buildLaidOutItems(List<HomeTimeSlot> timeSlots) {
    final range = visibleRange();
    final items = _demoItemsSource.buildForWeek(range.start);
    return _itemLayoutBuilder.build(
      items: items,
      visibleRange: range,
      timeSlots: timeSlots,
    );
  }
}

final homeHeaderViewModelProvider =
    NotifierProvider<HomeHeaderViewModel, HomeHeaderState>(
  HomeHeaderViewModel.new,
);

final homeViewDataProvider = Provider.family<HomeViewData, String>((ref, localeTag) {
  final state = ref.watch(homeHeaderViewModelProvider);
  final previewGrid = HomeHeaderViewModel._gridBuilder.build(
    localeTag: localeTag,
    anchor: state.anchor,
    scope: state.scope,
    selectedDate: state.selectedDate,
    items: const [],
  );
  final laidOutItems = ref
      .read(homeHeaderViewModelProvider.notifier)
      .buildLaidOutItems(previewGrid.timeSlots);
  return HomeHeaderViewModel._gridBuilder.build(
    localeTag: localeTag,
    anchor: state.anchor,
    scope: state.scope,
    selectedDate: state.selectedDate,
    items: laidOutItems,
  );
});
