import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class AgendaItem {
  const AgendaItem({
    required this.id,
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
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.completedAt,
    required this.sortOrder,
    this.sourceKind = AgendaItemSourceKind.manual,
    this.sourceRef = '',
  });

  final String id;
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
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final double sortOrder;
  final AgendaItemSourceKind sourceKind;
  final String sourceRef;

  DateTime? get deadline => taskDetails.deadline;
  Duration get estimatedDuration => taskDetails.estimatedDuration;
  bool get supportsManualCompletion {
    return switch (type) {
      ItemType.task || ItemType.memo || ItemType.schedule || ItemType.course => true,
    };
  }

  bool isEffectivelyCompleted(DateTime now) {
    if (supportsManualCompletion) {
      return isCompleted;
    }
    return !endAt.isAfter(now);
  }

  AgendaItem copyWith({
    String? id,
    ItemType? type,
    String? title,
    String? notes,
    String? location,
    ItemColorOption? color,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    DateTime? startAt,
    DateTime? endAt,
    bool? isAllDay,
    ItemTaskDetails? taskDetails,
    ItemCourseDetails? courseDetails,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    double? sortOrder,
    AgendaItemSourceKind? sourceKind,
    String? sourceRef,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      isAllDay: isAllDay ?? this.isAllDay,
      taskDetails: taskDetails ?? this.taskDetails,
      courseDetails: courseDetails ?? this.courseDetails,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      sortOrder: sortOrder ?? this.sortOrder,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
    );
  }

  ItemDraft toDraft() {
    return ItemDraft(
      type: type,
      title: title,
      notes: notes,
      location: location,
      color: color,
      reminder: reminder,
      repeatRule: repeatRule,
      startAt: startAt,
      endAt: endAt,
      isAllDay: isAllDay,
      taskDetails: taskDetails,
      courseDetails: courseDetails,
      sourceKind: sourceKind,
      sourceRef: sourceRef,
    );
  }

  static AgendaItem fromDraft({
    required String id,
    required ItemDraft draft,
    required DateTime createdAt,
    required DateTime updatedAt,
    required double sortOrder,
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    return AgendaItem(
      id: id,
      type: draft.type,
      title: draft.title.trim(),
      notes: draft.notes.trim(),
      location: draft.location.trim(),
      color: draft.color,
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      startAt: draft.startAt,
      endAt: draft.endAt,
      isAllDay: draft.isAllDay,
      taskDetails: draft.taskDetails,
      courseDetails: draft.courseDetails,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      sortOrder: sortOrder,
      sourceKind: draft.sourceKind,
      sourceRef: draft.sourceRef.trim(),
    );
  }
}

enum AgendaItemSourceKind {
  manual,
  whuCourse,
  wakeupCourse,
  seatReservation,
  aiGenerated,
}
