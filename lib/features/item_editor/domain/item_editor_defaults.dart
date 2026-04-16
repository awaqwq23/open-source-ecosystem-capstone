import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_memo_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_course_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_schedule_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_task_details.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class ItemEditorDefaults {
  const ItemEditorDefaults._();

  static ItemDraft createDraft([ItemEditorPrefill? prefill]) {
    final now = DateTime.now();
    final roundedStart = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute >= 30 ? 30 : 0,
    );
    final start = prefill?.startAt ?? roundedStart;
    final end = prefill?.endAt ?? start.add(const Duration(hours: 1));
    final targetDate = _dateOnly(prefill?.targetDate ?? start);

    return ItemDraft(
      type: prefill?.type ?? ItemType.schedule,
      title: prefill?.title ?? '',
      details: prefill?.details ?? '',
      location: prefill?.location ?? '',
      color: prefill?.color ?? ItemColorOption.sky,
      reminder: prefill?.reminder ?? ReminderOption.none,
      repeatRule: prefill?.repeatRule ?? RepeatRule.none,
      scheduleDetails: ItemScheduleDetails(
        isAllDay: prefill?.isAllDay ?? false,
        range: DateTimeRangeValue(
          start: start,
          end: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
        ),
      ),
      taskDetails: ItemTaskDetails(
        schedule: ItemScheduleDetails(
          isAllDay: prefill?.isAllDay ?? false,
          range: DateTimeRangeValue(
            start: start,
            end: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
          ),
        ),
        deadline: prefill?.deadline,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: targetDate,
        estimatedDuration: prefill?.estimatedDuration ?? const Duration(hours: 1),
      ),
      courseDetails: prefill?.courseDetails ?? const ItemCourseDetails(),
    );
  }

  static ItemDraft applyType(ItemDraft draft, ItemType type) {
    if (draft.type == type) {
      return draft;
    }

    return draft.copyWith(
      type: type,
      isAllDay: type == ItemType.memo ? false : draft.isAllDay,
      reminder: type == ItemType.course ? ReminderOption.none : draft.reminder,
      repeatRule: type == ItemType.course ? RepeatRule.none : draft.repeatRule,
      details: type == ItemType.course ? '' : draft.details,
      clearDeadline: type != ItemType.task,
      deadline: type == ItemType.task ? (draft.deadline ?? draft.endAt) : null,
      targetDate: type == ItemType.memo ? _dateOnly(draft.targetDate) : draft.targetDate,
      estimatedDuration: (type == ItemType.memo ||
              type == ItemType.task ||
              type == ItemType.schedule)
          ? (draft.estimatedDuration > Duration.zero
              ? draft.estimatedDuration
              : const Duration(hours: 1))
          : draft.estimatedDuration,
    );
  }

  static DateTime _dateOnly(DateTime dateTime) {
    return DateUtils.dateOnly(dateTime);
  }
}

