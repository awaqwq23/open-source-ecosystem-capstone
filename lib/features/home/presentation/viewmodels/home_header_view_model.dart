import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/home/domain/models/home_view_data.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/build_home_grid.dart';
import 'package:huajuan_agenda/features/home/domain/use_cases/layout_home_items.dart';
import 'package:huajuan_agenda/shared/data/agenda_item_repository.dart';
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

  @override
  HomeHeaderState build() {
    return HomeHeaderState(
      anchor: DateTime(2026, 3, 20),
      scope: HomeHeaderScope.week,
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

  DateTimeRangeValue visibleRange() {
    return _gridBuilder.build(
      anchor: state.anchor,
      scope: state.scope,
      items: const [],
    ).visibleRange;
  }
}

final homeHeaderViewModelProvider =
    NotifierProvider<HomeHeaderViewModel, HomeHeaderState>(
  HomeHeaderViewModel.new,
);

final homeViewDataProvider = Provider<HomeViewData>((ref) {
  final state = ref.watch(homeHeaderViewModelProvider);
  final items = ref.watch(agendaItemRepositoryProvider);
  final range = ref.read(homeHeaderViewModelProvider.notifier).visibleRange();
  final laidOutItems = HomeHeaderViewModel._itemLayoutBuilder.build(
    items: items,
    visibleRange: range,
  );
  return HomeHeaderViewModel._gridBuilder.build(
    anchor: state.anchor,
    scope: state.scope,
    items: laidOutItems,
  );
});
