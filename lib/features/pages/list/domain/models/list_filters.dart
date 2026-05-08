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
