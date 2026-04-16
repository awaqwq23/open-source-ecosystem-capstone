enum CourseItemSourceKind {
  manual,
  whuJw,
  wakeup,
}

class ItemCourseDetails {
  const ItemCourseDetails({
    this.timetableId = '',
    this.sourceKind = CourseItemSourceKind.manual,
    this.sourceCourseId = '',
    this.instructor = '',
    this.classroomRaw = '',
    this.weekMeta = '',
  });

  final String timetableId;
  final CourseItemSourceKind sourceKind;
  final String sourceCourseId;
  final String instructor;
  final String classroomRaw;
  final String weekMeta;

  ItemCourseDetails copyWith({
    String? timetableId,
    CourseItemSourceKind? sourceKind,
    String? sourceCourseId,
    String? instructor,
    String? classroomRaw,
    String? weekMeta,
  }) {
    return ItemCourseDetails(
      timetableId: timetableId ?? this.timetableId,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceCourseId: sourceCourseId ?? this.sourceCourseId,
      instructor: instructor ?? this.instructor,
      classroomRaw: classroomRaw ?? this.classroomRaw,
      weekMeta: weekMeta ?? this.weekMeta,
    );
  }
}
