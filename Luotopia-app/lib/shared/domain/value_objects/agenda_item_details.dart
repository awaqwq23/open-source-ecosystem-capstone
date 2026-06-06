import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';

sealed class AgendaItemDetails {
  const AgendaItemDetails();
}

class ScheduleItemDetails extends AgendaItemDetails {
  const ScheduleItemDetails({
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    this.autoCompletedOnceAt,
  });

  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final DateTime? autoCompletedOnceAt;

  ScheduleItemDetails copyWith({
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    DateTime? autoCompletedOnceAt,
    bool clearAutoCompletedOnceAt = false,
  }) {
    return ScheduleItemDetails(
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      autoCompletedOnceAt: clearAutoCompletedOnceAt
          ? null
          : (autoCompletedOnceAt ?? this.autoCompletedOnceAt),
    );
  }
}

class TaskItemDetails extends AgendaItemDetails {
  const TaskItemDetails({
    required this.deadlineAt,
  });

  final DateTime deadlineAt;

  TaskItemDetails copyWith({
    DateTime? deadlineAt,
  }) {
    return TaskItemDetails(
      deadlineAt: deadlineAt ?? this.deadlineAt,
    );
  }
}

class MemoItemDetails extends AgendaItemDetails {
  const MemoItemDetails();
}

class CourseAgendaItemDetails extends AgendaItemDetails {
  const CourseAgendaItemDetails({
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    this.course = const ItemCourseDetails(),
  });

  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final ItemCourseDetails course;

  CourseAgendaItemDetails copyWith({
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    ItemCourseDetails? course,
  }) {
    return CourseAgendaItemDetails(
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      course: course ?? this.course,
    );
  }
}
