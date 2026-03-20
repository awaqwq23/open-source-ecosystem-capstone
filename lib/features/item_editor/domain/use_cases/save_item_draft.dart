import 'package:huajuan_agenda/features/item_editor/data/item_editor_repository.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';

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
