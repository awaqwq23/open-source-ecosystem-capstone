import 'package:luotopia/features/pages/list/domain/models/list_filters.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';

class FilterListItemsUseCase {
  const FilterListItemsUseCase();

  List<AgendaItem> call(
    List<AgendaItem> items,
    ListHeaderTab tab,
    DateTime now,
  ) {
    return switch (tab) {
      ListHeaderTab.myDay => items.where((item) => _isInMyDay(item, now)).toList(),
      ListHeaderTab.allItems =>
        items.where((item) => item.type != ItemType.course).toList(),
      ListHeaderTab.tasks => items.where((item) => item.type == ItemType.task).toList(),
      ListHeaderTab.schedules =>
        items.where((item) => item.type == ItemType.schedule).toList(),
      ListHeaderTab.memos => items.where((item) => item.type == ItemType.memo).toList(),
    };
  }

  bool _isInMyDay(AgendaItem item, DateTime now) {
    if (!item.isEffectivelyCompleted(now) &&
        (item.type == ItemType.task || item.type == ItemType.memo)) {
      return true;
    }
    final today = DateTime(now.year, now.month, now.day);
    final start = item.timelineStartAt;
    final end = item.timelineEndAt;
    if (start == null || end == null) {
      return false;
    }
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    return !today.isBefore(startDay) && !today.isAfter(endDay);
  }
}

