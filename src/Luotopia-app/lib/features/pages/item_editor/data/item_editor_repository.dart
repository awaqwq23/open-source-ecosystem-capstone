import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/item_editor/domain/repositories/item_editor_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/repositories/agenda_item_repository.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';

class SharedItemEditorRepository implements ItemEditorRepository {
  const SharedItemEditorRepository(this._repository);

  final AgendaItemRepository _repository;

  @override
  Future<AgendaItem> createItem(ItemDraft draft) {
    return _repository.createItem(draft);
  }

  @override
  Future<AgendaItem?> updateItem(String id, ItemDraft draft) {
    return _repository.updateItem(id, draft);
  }

  @override
  Future<int> updateCourseColorByTitle({
    required String title,
    required ItemColorOption color,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      return 0;
    }

    var updatedCount = 0;
    final targets = [
      for (final item in _repository.items)
        if (item.type == ItemType.course && item.title.trim() == normalizedTitle) item,
    ];
    for (final item in targets) {
      await _repository.updateItem(
        item.id,
        item.toDraft().copyWith(color: color),
      );
      updatedCount++;
    }
    return updatedCount;
  }
}

final itemEditorRepositoryProvider = Provider<ItemEditorRepository>((ref) {
  final repository = ref.read(agendaItemRepositoryProvider.notifier);
  return SharedItemEditorRepository(repository);
});

