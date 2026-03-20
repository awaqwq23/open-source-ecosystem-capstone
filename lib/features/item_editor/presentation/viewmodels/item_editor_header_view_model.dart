import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ItemEditorType {
  task,
  schedule,
  memo,
}

class ItemEditorHeaderState {
  const ItemEditorHeaderState(this.type);

  final ItemEditorType type;
}

class ItemEditorHeaderViewModel extends Notifier<ItemEditorHeaderState> {
  @override
  ItemEditorHeaderState build() {
    return const ItemEditorHeaderState(ItemEditorType.task);
  }

  void select(ItemEditorType type) {
    state = ItemEditorHeaderState(type);
  }
}

final itemEditorHeaderViewModelProvider =
    NotifierProvider<ItemEditorHeaderViewModel, ItemEditorHeaderState>(
  ItemEditorHeaderViewModel.new,
);
