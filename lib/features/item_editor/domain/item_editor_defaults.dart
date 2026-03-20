import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';
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
      type: prefill?.type ?? ItemType.task,
      title: prefill?.title ?? '',
      details: prefill?.details ?? '',
      location: prefill?.location ?? '',
      color: prefill?.color ?? ItemColorOption.sky,
      reminder: prefill?.reminder ?? ReminderOption.none,
      repeatRule: prefill?.repeatRule ?? RepeatRule.none,
      startAt: start,
      endAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
      deadline: prefill?.deadline,
      targetDate: targetDate,
      estimatedDuration: prefill?.estimatedDuration ?? const Duration(hours: 1),
    );
  }

  static ItemDraft applyType(ItemDraft draft, ItemType type) {
    if (draft.type == type) {
      return draft;
    }

    return draft.copyWith(
      type: type,
      clearDeadline: type != ItemType.task,
      deadline: type == ItemType.task ? (draft.deadline ?? draft.endAt) : null,
      targetDate: type == ItemType.memo ? _dateOnly(draft.targetDate) : draft.targetDate,
      estimatedDuration: type == ItemType.memo
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
