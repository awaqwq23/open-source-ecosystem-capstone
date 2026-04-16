import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';

class ItemEditorArgs {
  const ItemEditorArgs({
    this.itemId,
    this.prefill,
    this.showTypePickerOnLaunch = false,
  });

  final String? itemId;
  final ItemEditorPrefill? prefill;
  final bool showTypePickerOnLaunch;

  bool get isEditing => itemId != null;

  ItemEditorArgs copyWith({
    String? itemId,
    ItemEditorPrefill? prefill,
    bool? showTypePickerOnLaunch,
  }) {
    return ItemEditorArgs(
      itemId: itemId ?? this.itemId,
      prefill: prefill ?? this.prefill,
      showTypePickerOnLaunch: showTypePickerOnLaunch ?? this.showTypePickerOnLaunch,
    );
  }
}
