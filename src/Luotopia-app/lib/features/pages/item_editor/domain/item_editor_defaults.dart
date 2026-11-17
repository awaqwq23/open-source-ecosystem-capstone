import 'dart:math';

import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

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
    final type = prefill?.type ?? ItemType.schedule;
    final start = prefill?.startAt ?? roundedStart;
    final end = prefill?.endAt ?? start.add(const Duration(hours: 1));
    final details = switch (type) {
      ItemType.schedule => ScheduleItemDetails(
        startAt: start,
        endAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
        isAllDay: prefill?.isAllDay ?? false,
        countdownEnabled: prefill?.countdownEnabled ?? false,
      ),
      ItemType.task => TaskItemDetails(deadlineAt: prefill?.deadlineAt ?? end),
      ItemType.memo => const MemoItemDetails(),
      ItemType.course => CourseAgendaItemDetails(
        startAt: start,
        endAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
        isAllDay: prefill?.isAllDay ?? false,
        course: prefill?.courseDetails ?? const ItemCourseDetails(),
      ),
    };

    return ItemDraft(
      type: type,
      title: prefill?.title ?? '',
      notes: prefill?.notes ?? '',
      location: prefill?.location ?? '',
      color: prefill?.color ?? _randomColor(),
      reminder: prefill?.reminder ?? ReminderOption.none,
      repeatRule: prefill?.repeatRule ?? RepeatRule.none,
      details: details,
      sourceKind: prefill?.sourceKind ?? AgendaItemSourceKind.manual,
      sourceRef: prefill?.sourceRef ?? '',
    );
  }

  static ItemColorOption _randomColor() {
    final colors = ItemColorOption.values;
    return colors[Random().nextInt(colors.length)];
  }

  static ItemDraft applyType(ItemDraft draft, ItemType type) {
    if (draft.type == type) {
      return draft;
    }

    final start = draft.timelineStartAt ?? DateTime.now();
    final end = draft.timelineEndAt ?? start.add(const Duration(hours: 1));
    final details = switch (type) {
      ItemType.schedule => ScheduleItemDetails(
        startAt: start,
        endAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
        isAllDay: draft.timelineIsAllDay,
        countdownEnabled: draft.scheduleCountdownEnabled,
      ),
      ItemType.task => TaskItemDetails(deadlineAt: draft.deadlineAt ?? end),
      ItemType.memo => const MemoItemDetails(),
      ItemType.course => CourseAgendaItemDetails(
        startAt: start,
        endAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
        isAllDay: draft.timelineIsAllDay,
        course: draft.courseDetails,
      ),
    };

    return draft.copyWith(
      type: type,
      reminder: type == ItemType.course ? ReminderOption.none : draft.reminder,
      repeatRule: type == ItemType.course ? RepeatRule.none : draft.repeatRule,
      details: details,
    );
  }
}
