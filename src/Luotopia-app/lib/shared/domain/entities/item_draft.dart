import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class ItemDraft {
  const ItemDraft({
    required this.type,
    required this.title,
    required this.notes,
    required this.location,
    required this.color,
    required this.reminder,
    required this.repeatRule,
    required this.details,
    this.sourceKind = AgendaItemSourceKind.manual,
    this.sourceRef = '',
  });

  final ItemType type;
  final String title;
  final String notes;
  final String location;
  final ItemColorOption color;
  final ReminderOption reminder;
  final RepeatRule repeatRule;
  final AgendaItemDetails details;
  final AgendaItemSourceKind sourceKind;
  final String sourceRef;

  DateTime? get deadlineAt {
    final details = this.details;
    return details is TaskItemDetails ? details.deadlineAt : null;
  }

  ScheduleItemDetails? get scheduleDetails {
    final details = this.details;
    return details is ScheduleItemDetails ? details : null;
  }

  CourseAgendaItemDetails? get courseAgendaDetails {
    final details = this.details;
    return details is CourseAgendaItemDetails ? details : null;
  }

  ItemCourseDetails get courseDetails {
    final details = this.details;
    return details is CourseAgendaItemDetails
        ? details.course
        : const ItemCourseDetails();
  }

  DateTime? get timelineStartAt {
    return switch (details) {
      ScheduleItemDetails(:final startAt) => startAt,
      CourseAgendaItemDetails(:final startAt) => startAt,
      _ => null,
    };
  }

  DateTime? get timelineEndAt {
    return switch (details) {
      ScheduleItemDetails(:final endAt) => endAt,
      CourseAgendaItemDetails(:final endAt) => endAt,
      _ => null,
    };
  }

  bool get timelineIsAllDay {
    return switch (details) {
      ScheduleItemDetails(:final isAllDay) => isAllDay,
      CourseAgendaItemDetails(:final isAllDay) => isAllDay,
      _ => false,
    };
  }

  bool get scheduleCountdownEnabled {
    final details = this.details;
    return details is ScheduleItemDetails && details.countdownEnabled;
  }

  ItemDraft copyWith({
    ItemType? type,
    String? title,
    String? notes,
    String? location,
    ItemColorOption? color,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    AgendaItemDetails? details,
    DateTime? scheduleStartAt,
    DateTime? scheduleEndAt,
    bool? scheduleIsAllDay,
    bool? scheduleCountdownEnabled,
    DateTime? taskDeadlineAt,
    ItemCourseDetails? courseDetails,
    AgendaItemSourceKind? sourceKind,
    String? sourceRef,
  }) {
    final nextDetails =
        details ??
        _copyDetails(
          scheduleStartAt: scheduleStartAt,
          scheduleEndAt: scheduleEndAt,
          scheduleIsAllDay: scheduleIsAllDay,
          scheduleCountdownEnabled: scheduleCountdownEnabled,
          taskDeadlineAt: taskDeadlineAt,
          courseDetails: courseDetails,
        );
    return ItemDraft(
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      details: nextDetails,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
    );
  }

  DateTimeRangeValue get range {
    final start = timelineStartAt;
    final end = timelineEndAt;
    if (start == null || end == null) {
      throw StateError('Only timed agenda drafts expose a range.');
    }
    return DateTimeRangeValue(start: start, end: end);
  }

  AgendaItemDetails _copyDetails({
    DateTime? scheduleStartAt,
    DateTime? scheduleEndAt,
    bool? scheduleIsAllDay,
    bool? scheduleCountdownEnabled,
    DateTime? taskDeadlineAt,
    ItemCourseDetails? courseDetails,
  }) {
    return switch (details) {
      ScheduleItemDetails details => details.copyWith(
        startAt: scheduleStartAt,
        endAt: scheduleEndAt,
        isAllDay: scheduleIsAllDay,
        countdownEnabled: scheduleCountdownEnabled,
      ),
      TaskItemDetails details => details.copyWith(deadlineAt: taskDeadlineAt),
      MemoItemDetails details => details,
      CourseAgendaItemDetails details => details.copyWith(
        startAt: scheduleStartAt,
        endAt: scheduleEndAt,
        isAllDay: scheduleIsAllDay,
        course: courseDetails,
      ),
    };
  }
}
