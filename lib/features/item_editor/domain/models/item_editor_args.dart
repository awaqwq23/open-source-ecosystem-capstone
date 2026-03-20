import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';

class ItemEditorArgs {
  const ItemEditorArgs({
    this.itemId,
    this.prefill,
  });

  final String? itemId;
  final ItemEditorPrefill? prefill;

  bool get isEditing => itemId != null;
}
