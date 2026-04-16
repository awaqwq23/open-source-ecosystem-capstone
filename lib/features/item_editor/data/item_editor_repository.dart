import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/item_editor/domain/repositories/item_editor_repository.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';

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

