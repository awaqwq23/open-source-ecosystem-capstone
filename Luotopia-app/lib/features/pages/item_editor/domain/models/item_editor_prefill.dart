import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class ItemEditorPrefill {
  const ItemEditorPrefill({
    this.type,
    this.title,
    this.notes,
    this.location,
    this.color,
    this.isAllDay,
    this.reminder,
    this.repeatRule,
    this.startAt,
    this.endAt,
    this.deadline,
    this.estimatedDuration,
    this.courseDetails,
    this.sourceKind,
    this.sourceRef,
  });

  final ItemType? type;
  final String? title;
  final String? notes;
  final String? location;
  final ItemColorOption? color;
  final bool? isAllDay;
  final ReminderOption? reminder;
  final RepeatRule? repeatRule;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? deadline;
  final Duration? estimatedDuration;
  final ItemCourseDetails? courseDetails;
  final AgendaItemSourceKind? sourceKind;
  final String? sourceRef;
}
