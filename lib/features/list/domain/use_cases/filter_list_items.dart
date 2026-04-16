import 'package:huajuan_agenda/features/list/domain/models/list_filters.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';

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
      ListHeaderTab.courses => items.where((item) => item.type == ItemType.course).toList(),
      ListHeaderTab.important => items.where((item) => item.isImportant).toList(),
    };
  }

  bool _isInMyDay(AgendaItem item, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    if (item.type == ItemType.memo) {
      final target = item.targetDate;
      return target.year == today.year && target.month == today.month && target.day == today.day;
    }

    final startDay = DateTime(item.startAt.year, item.startAt.month, item.startAt.day);
    final endDay = DateTime(item.endAt.year, item.endAt.month, item.endAt.day);
    return !today.isBefore(startDay) && !today.isAfter(endDay);
  }
}

