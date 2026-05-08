import 'package:luotopia/features/pages/item_editor/domain/repositories/item_editor_repository.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

class SaveItemDraftUseCase {
  const SaveItemDraftUseCase(this._repository);

  final ItemEditorRepository _repository;

  Future<void> call({
    required String? itemId,
    required ItemDraft draft,
    required bool isImportant,
  }) async {
    if (itemId == null) {
      await _repository.createItem(draft, isImportant: isImportant);
      return;
    }
    await _repository.updateItem(
      itemId,
      draft,
      isImportant: isImportant,
    );
  }
}

