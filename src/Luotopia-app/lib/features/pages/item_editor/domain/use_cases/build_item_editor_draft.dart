import 'package:luotopia/features/pages/item_editor/domain/item_editor_defaults.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

class BuildItemEditorDraftUseCase {
  const BuildItemEditorDraftUseCase();

  ItemDraft call([ItemEditorPrefill? prefill]) {
    return ItemEditorDefaults.createDraft(prefill);
  }
}

