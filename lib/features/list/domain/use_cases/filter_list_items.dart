import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/list/presentation/viewmodels/list_header_view_model.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';

class FilterListItemsUseCase {
  const FilterListItemsUseCase();

  List<AgendaItem> call(
    List<AgendaItem> items,
    ListHeaderTab tab,
    DateTime now,
  ) {
    return switch (tab) {
      ListHeaderTab.myDay => items.where((item) => _isInMyDay(item, now)).toList(),
      ListHeaderTab.allItems => [...items],
      ListHeaderTab.tasks => items.where((item) => item.type == ItemType.task).toList(),
      ListHeaderTab.schedules =>
        items.where((item) => item.type == ItemType.schedule).toList(),
      ListHeaderTab.memos => items.where((item) => item.type == ItemType.memo).toList(),
      ListHeaderTab.important => items.where((item) => item.isImportant).toList(),
    };
  }

  bool _isInMyDay(AgendaItem item, DateTime now) {
    final today = DateUtils.dateOnly(now);
    if (item.type == ItemType.memo) {
      return DateUtils.isSameDay(item.targetDate, today);
    }

    final startDay = DateUtils.dateOnly(item.startAt);
    final endDay = DateUtils.dateOnly(item.endAt);
    return !today.isBefore(startDay) && !today.isAfter(endDay);
  }
}
