import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';

abstract class ItemEditorRepository {
  Future<AgendaItem> createItem(ItemDraft draft);
  Future<AgendaItem?> updateItem(String id, ItemDraft draft);
  Future<int> updateCourseColorByTitle({
    required String title,
    required ItemColorOption color,
  });
}
