import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_memo_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_schedule_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_task_details.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class ItemDraft {
  const ItemDraft({
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
  });

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

  bool get isAllDay => activeScheduleDetails.isAllDay;
  DateTime get startAt => activeScheduleDetails.range.start;
  DateTime get endAt => activeScheduleDetails.range.end;
  DateTime? get deadline => taskDetails.deadline;
  DateTime get targetDate => memoDetails.targetDate;
  Duration get estimatedDuration => memoDetails.estimatedDuration;

  ItemScheduleDetails get activeScheduleDetails {
    return switch (type) {
      ItemType.task => taskDetails.schedule,
      ItemType.schedule => scheduleDetails,
      ItemType.memo => scheduleDetails,
    };
  }

  ItemDraft copyWith({
    ItemType? type,
    String? title,
    String? details,
    String? location,
    ItemColorOption? color,
    ReminderOption? reminder,
    RepeatRule? repeatRule,
    bool? isAllDay,
    DateTime? startAt,
    DateTime? endAt,
    DateTime? deadline,
    bool clearDeadline = false,
    DateTime? targetDate,
    Duration? estimatedDuration,
    ItemScheduleDetails? scheduleDetails,
    ItemTaskDetails? taskDetails,
    ItemMemoDetails? memoDetails,
  }) {
    final nextScheduleDetails = scheduleDetails ??
        this.scheduleDetails.copyWith(
          isAllDay: isAllDay,
          range: startAt != null || endAt != null
              ? DateTimeRangeValue(
                  start: startAt ?? this.scheduleDetails.range.start,
                  end: endAt ?? this.scheduleDetails.range.end,
                )
              : null,
        );
    final nextTaskDetails = taskDetails ??
        this.taskDetails.copyWith(
          schedule: this.taskDetails.schedule.copyWith(
            isAllDay: isAllDay,
            range: startAt != null || endAt != null
                ? DateTimeRangeValue(
                    start: startAt ?? this.taskDetails.schedule.range.start,
                    end: endAt ?? this.taskDetails.schedule.range.end,
                  )
                : null,
          ),
          deadline: deadline,
          clearDeadline: clearDeadline,
        );
    final nextMemoDetails = memoDetails ??
        this.memoDetails.copyWith(
          targetDate: targetDate,
          estimatedDuration: estimatedDuration,
        );
    return ItemDraft(
      type: type ?? this.type,
      title: title ?? this.title,
      details: details ?? this.details,
      location: location ?? this.location,
      color: color ?? this.color,
      reminder: reminder ?? this.reminder,
      repeatRule: repeatRule ?? this.repeatRule,
      scheduleDetails: nextScheduleDetails,
      taskDetails: nextTaskDetails,
      memoDetails: nextMemoDetails,
    );
  }
}
