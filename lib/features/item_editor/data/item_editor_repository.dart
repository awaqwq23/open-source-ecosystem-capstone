import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/shared/data/agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';

abstract class ItemEditorRepository {
  Future<AgendaItem> createItem(
    ItemDraft draft, {
    bool isImportant = false,
  });
  Future<AgendaItem?> updateItem(
    String id,
    ItemDraft draft, {
    bool? isImportant,
  });
}

class SharedItemEditorRepository implements ItemEditorRepository {
  const SharedItemEditorRepository(this._repository);

  final AgendaItemRepository _repository;

  @override
  Future<AgendaItem> createItem(
    ItemDraft draft, {
    bool isImportant = false,
  }) {
    return _repository.createItem(draft, isImportant: isImportant);
  }

  @override
  Future<AgendaItem?> updateItem(
    String id,
    ItemDraft draft, {
    bool? isImportant,
  }) {
    return _repository.updateItem(id, draft, isImportant: isImportant);
  }
}

final itemEditorRepositoryProvider = Provider<ItemEditorRepository>((ref) {
  final repository = ref.read(agendaItemRepositoryProvider.notifier);
  return SharedItemEditorRepository(repository);
});
