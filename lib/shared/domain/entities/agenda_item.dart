import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/item_memo_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';
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
    required this.details,
    required this.location,
    required this.color,
    required this.reminder,
    required this.repeatRule,
    required this.scheduleDetails,
    required this.taskDetails,
    required this.memoDetails,
    this.courseDetails = const ItemCourseDetails(),
    required this.isCompleted,
    required this.createdAt,
    required this.completedAt,
    required this.manualOrder,
    this.updatedAt,
    this.syncState = AgendaItemSyncState.localOnly,
    this.sourceId,
  });

  final String id;
  final ItemType type;
  final String title;
  final String details;
  final String location;
  final ItemColorOption color;
  final ReminderOption reminder;
  final RepeatRule repeatRule;
  final ItemScheduleDetails scheduleDetails;
  final ItemTaskDetails taskDetails;
  final ItemMemoDetails memoDetails;
  final ItemCourseDetails courseDetails;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final double manualOrder;
  final AgendaItemSyncState syncState;
  final String? sourceId;

  bool get isAllDay => activeScheduleDetails.isAllDay;
  DateTime get startAt => activeScheduleDetails.range.start;
  DateTime get endAt => activeScheduleDetails.range.end;
  DateTime? get deadline => taskDetails.deadline;
  DateTime get targetDate => memoDetails.targetDate;
  Duration get estimatedDuration => memoDetails.estimatedDuration;
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

  ItemScheduleDetails get activeScheduleDetails {
    return switch (type) {
      ItemType.task => taskDetails.schedule,
      ItemType.schedule => scheduleDetails,
      ItemType.memo => scheduleDetails,
      ItemType.course => scheduleDetails,
    };
  }

  AgendaItem copyWith({
    String? id,
    ItemType? type,
    String? title,
    String? details,
    String? location,
    ItemColorOption? color,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    ItemScheduleDetails? scheduleDetails,
    ItemTaskDetails? taskDetails,
    ItemMemoDetails? memoDetails,
    ItemCourseDetails? courseDetails,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    double? manualOrder,
    AgendaItemSyncState? syncState,
    String? sourceId,
    bool clearSourceId = false,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      details: details ?? this.details,
      location: location ?? this.location,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      scheduleDetails: scheduleDetails ?? this.scheduleDetails,
      taskDetails: taskDetails ?? this.taskDetails,
      memoDetails: memoDetails ?? this.memoDetails,
      courseDetails: courseDetails ?? this.courseDetails,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      manualOrder: manualOrder ?? this.manualOrder,
      syncState: syncState ?? this.syncState,
      sourceId: clearSourceId ? null : (sourceId ?? this.sourceId),
    );
  }

  ItemDraft toDraft() {
    return ItemDraft(
      type: type,
      title: title,
      details: details,
      location: location,
      color: color,
      reminder: reminder,
      repeatRule: repeatRule,
      scheduleDetails: scheduleDetails,
      taskDetails: taskDetails,
      memoDetails: memoDetails,
      courseDetails: courseDetails,
    );
  }

  static AgendaItem fromDraft({
    required String id,
    required ItemDraft draft,
    required DateTime createdAt,
    required double manualOrder,
    bool isCompleted = false,
    DateTime? completedAt,
  }) {
    return AgendaItem(
      id: id,
      type: draft.type,
      title: draft.title.trim(),
      details: draft.details.trim(),
      location: draft.location.trim(),
      color: draft.color,
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      scheduleDetails: draft.scheduleDetails,
      taskDetails: draft.taskDetails,
      memoDetails: draft.memoDetails,
      courseDetails: draft.courseDetails,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      manualOrder: manualOrder,
    );
  }
}

enum AgendaItemSyncState {
  localOnly,
  pendingUpload,
  synced,
  pendingDelete,
}
