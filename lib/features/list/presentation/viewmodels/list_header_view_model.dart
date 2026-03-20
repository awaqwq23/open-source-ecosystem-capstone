import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ListHeaderTab {
  myDay,
  allItems,
  tasks,
  schedules,
  memos,
  important,
}

extension ListHeaderTabLabelX on ListHeaderTab {
  String get key => name;
}

class ListHeaderState {
  const ListHeaderState(this.currentTab);

  final ListHeaderTab currentTab;
}

class ListHeaderViewModel extends Notifier<ListHeaderState> {
  @override
  ListHeaderState build() {
    return const ListHeaderState(ListHeaderTab.myDay);
  }

  void switchTab(ListHeaderTab tab) {
    state = ListHeaderState(tab);
  }
}

final listHeaderViewModelProvider =
    NotifierProvider<ListHeaderViewModel, ListHeaderState>(
  ListHeaderViewModel.new,
);
