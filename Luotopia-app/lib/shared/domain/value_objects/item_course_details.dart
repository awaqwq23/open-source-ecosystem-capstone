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
    this.courseNature = '',
    this.instructor = '',
    this.weekMeta = '',
  });

  final String timetableId;
  final CourseItemSourceKind sourceKind;
  final String sourceCourseId;
  final String courseNature;
  final String instructor;
  final String weekMeta;

  ItemCourseDetails copyWith({
    String? timetableId,
    CourseItemSourceKind? sourceKind,
    String? sourceCourseId,
    String? courseNature,
    String? instructor,
    String? weekMeta,
  }) {
    return ItemCourseDetails(
      timetableId: timetableId ?? this.timetableId,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceCourseId: sourceCourseId ?? this.sourceCourseId,
      courseNature: courseNature ?? this.courseNature,
      instructor: instructor ?? this.instructor,
      weekMeta: weekMeta ?? this.weekMeta,
    );
  }
}
