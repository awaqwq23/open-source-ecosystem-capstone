import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';

abstract class AgendaItemRepository {
  List<AgendaItem> get items;
  AgendaItem? findById(String id);
  List<AgendaItem> findByRange(DateTimeRangeValue range);
  Future<AgendaItem> createItem(
    ItemDraft draft, {
    bool isImportant = false,
  });
  Future<AgendaItem?> updateItem(
    String id,
    ItemDraft draft, {
    bool? isImportant,
  });
  Future<void> deleteItem(String id);
  Future<AgendaItem?> toggleCompleted(String id);
  Future<AgendaItem?> toggleImportant(String id);
  Future<void> reorderItems(List<String> orderedIds);
}
