enum ListHeaderTab {
  myDay,
  allItems,
  tasks,
  schedules,
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
