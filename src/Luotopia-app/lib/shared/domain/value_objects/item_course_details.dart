enum CourseItemSourceKind { manual, whuJw, wakeup }

class ItemCourseDetails {
  const ItemCourseDetails({
    this.timetableId = '',
    this.sourceKind = CourseItemSourceKind.manual,
    this.sourceCourseId = '',
    this.courseNature = '',
    this.instructor = '',
    this.weekMeta = '',
    this.termCourseId = '',
    this.offeringId = '',
    this.teacherId = '',
    this.occurrenceId = '',
  });

  final String timetableId;
  final CourseItemSourceKind sourceKind;
  final String sourceCourseId;
  final String courseNature;
  final String instructor;
  final String weekMeta;
  final String termCourseId;
  final String offeringId;
  final String teacherId;
  final String occurrenceId;

  ItemCourseDetails copyWith({
    String? timetableId,
    CourseItemSourceKind? sourceKind,
    String? sourceCourseId,
    String? courseNature,
    String? instructor,
    String? weekMeta,
    String? termCourseId,
    String? offeringId,
    String? teacherId,
    String? occurrenceId,
  }) {
    return ItemCourseDetails(
      timetableId: timetableId ?? this.timetableId,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceCourseId: sourceCourseId ?? this.sourceCourseId,
      courseNature: courseNature ?? this.courseNature,
      instructor: instructor ?? this.instructor,
      weekMeta: weekMeta ?? this.weekMeta,
      termCourseId: termCourseId ?? this.termCourseId,
      offeringId: offeringId ?? this.offeringId,
      teacherId: teacherId ?? this.teacherId,
      occurrenceId: occurrenceId ?? this.occurrenceId,
    );
  }
}
