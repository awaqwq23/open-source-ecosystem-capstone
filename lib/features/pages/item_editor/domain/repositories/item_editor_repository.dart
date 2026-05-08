import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

abstract class ItemEditorRepository {
  Future<AgendaItem> createItem(ItemDraft draft);
  Future<AgendaItem?> updateItem(String id, ItemDraft draft);
}
