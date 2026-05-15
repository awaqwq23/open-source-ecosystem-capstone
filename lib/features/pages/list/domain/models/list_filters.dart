enum ListHeaderTab {
  myDay,
  allItems,
  schedules,
  tasks,
  memos,
}

enum ListSortMode {
  dueDate,
  todayFocus,
  alphabetical,
  createdDate,
  manual,
}

extension ListHeaderTabLabelX on ListHeaderTab {
  String get key => name;
}
