import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
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
    required this.startAt,
    required this.endAt,
    required this.isAllDay,
    required this.taskDetails,
    this.courseDetails = const ItemCourseDetails(),
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
  final DateTime startAt;
  final DateTime endAt;
  final bool isAllDay;
  final ItemTaskDetails taskDetails;
  final ItemCourseDetails courseDetails;
  final AgendaItemSourceKind sourceKind;
  final String sourceRef;

  DateTime? get deadline => taskDetails.deadline;
  Duration get estimatedDuration => taskDetails.estimatedDuration;

  ItemDraft copyWith({
    ItemType? type,
    String? title,
    String? notes,
    String? location,
    ItemColorOption? color,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    bool? isAllDay,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? deadline,
    bool clearDeadline = false,
    Duration? estimatedDuration,
    ItemTaskDetails? taskDetails,
    ItemCourseDetails? courseDetails,
    AgendaItemSourceKind? sourceKind,
    String? sourceRef,
  }) {
    final nextStartAt = startAt ?? this.startAt;
    final nextEndAt = endAt ?? this.endAt;
    final nextTaskDetails = taskDetails ??
        this.taskDetails.copyWith(
          deadline: deadline,
          clearDeadline: clearDeadline,
          estimatedDuration: estimatedDuration,
        );
    return ItemDraft(
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      startAt: nextStartAt,
      endAt: nextEndAt,
      isAllDay: isAllDay ?? this.isAllDay,
      taskDetails: nextTaskDetails,
      courseDetails: courseDetails ?? this.courseDetails,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
    );
  }

  DateTimeRangeValue get range {
    return DateTimeRangeValue(start: startAt, end: endAt);
  }
}
