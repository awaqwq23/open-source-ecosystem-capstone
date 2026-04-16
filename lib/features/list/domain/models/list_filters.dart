enum ListHeaderTab {
  myDay,
  allItems,
  tasks,
  schedules,
  memos,
  courses,
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
