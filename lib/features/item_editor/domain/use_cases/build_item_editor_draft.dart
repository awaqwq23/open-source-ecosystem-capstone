import 'package:huajuan_agenda/features/item_editor/domain/item_editor_defaults.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';

class BuildItemEditorDraftUseCase {
  const BuildItemEditorDraftUseCase();

  ItemDraft call([ItemEditorPrefill? prefill]) {
    return ItemEditorDefaults.createDraft(prefill);
  }
}
