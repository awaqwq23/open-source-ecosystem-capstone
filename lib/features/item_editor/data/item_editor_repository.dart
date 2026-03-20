import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';

abstract class ItemEditorRepository {
  Future<void> createItem(ItemDraft draft);
}

class StubItemEditorRepository implements ItemEditorRepository {
  @override
  Future<void> createItem(ItemDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }
}

final itemEditorRepositoryProvider = Provider<ItemEditorRepository>((ref) {
  return StubItemEditorRepository();
});
