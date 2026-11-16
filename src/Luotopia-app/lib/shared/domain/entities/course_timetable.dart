enum CourseTimetableSource {
  whuJw,
  wakeup,
  merged,
  manual,
}

class CourseTimetable {
  const CourseTimetable({
    required this.id,
    required this.name,
    required this.source,
    this.termLabel = '',
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final CourseTimetableSource source;
  final String termLabel;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CourseTimetable copyWith({
    String? id,
    String? name,
    CourseTimetableSource? source,
    String? termLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseTimetable(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      termLabel: termLabel ?? this.termLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CourseTimetableStore {
  const CourseTimetableStore({
    required this.timetables,
    this.selectedTimetableIds = const {},
  });

  final List<CourseTimetable> timetables;
  final Set<String> selectedTimetableIds;

  bool isSelected(String id) => selectedTimetableIds.contains(id);

  CourseTimetableStore copyWith({
    List<CourseTimetable>? timetables,
    Set<String>? selectedTimetableIds,
  }) {
    return CourseTimetableStore(
      timetables: timetables ?? this.timetables,
      selectedTimetableIds: selectedTimetableIds ?? this.selectedTimetableIds,
    );
  }
}
