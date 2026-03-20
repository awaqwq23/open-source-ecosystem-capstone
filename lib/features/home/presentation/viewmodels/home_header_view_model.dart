import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeHeaderState {
  const HomeHeaderState({
    required this.anchor,
    required this.scope,
  });

  final DateTime anchor;
  final HomeHeaderScope scope;
}

enum HomeHeaderScope { week, month }

class HomeHeaderViewModel extends Notifier<HomeHeaderState> {
  @override
  HomeHeaderState build() {
    return HomeHeaderState(
      anchor: DateTime(2026, 3, 20),
      scope: HomeHeaderScope.week,
    );
  }

  void showPrevious() {
    state = HomeHeaderState(
      anchor: switch (state.scope) {
        HomeHeaderScope.week => state.anchor.subtract(const Duration(days: 7)),
        HomeHeaderScope.month => DateTime(
            state.anchor.year,
            state.anchor.month - 1,
            state.anchor.day,
          ),
      },
      scope: state.scope,
    );
  }

  void showNext() {
    state = HomeHeaderState(
      anchor: switch (state.scope) {
        HomeHeaderScope.week => state.anchor.add(const Duration(days: 7)),
        HomeHeaderScope.month => DateTime(
            state.anchor.year,
            state.anchor.month + 1,
            state.anchor.day,
          ),
      },
      scope: state.scope,
    );
  }

  void switchScope(HomeHeaderScope scope) {
    state = HomeHeaderState(anchor: state.anchor, scope: scope);
  }
}

final homeHeaderViewModelProvider =
    NotifierProvider<HomeHeaderViewModel, HomeHeaderState>(
  HomeHeaderViewModel.new,
);
