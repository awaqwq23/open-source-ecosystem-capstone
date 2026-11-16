import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/features/pages/list/domain/models/list_filters.dart';
import 'package:luotopia/shared/enums/item_type.dart';

class BuildListPrefillUseCase {
  const BuildListPrefillUseCase();

  ItemEditorPrefill call(ListHeaderTab tab, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (tab) {
      ListHeaderTab.myDay => ItemEditorPrefill(
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
        ),
      ListHeaderTab.allItems => const ItemEditorPrefill(),
      ListHeaderTab.tasks => ItemEditorPrefill(
          type: ItemType.task,
          deadlineAt: today.add(const Duration(hours: 18)),
        ),
      ListHeaderTab.schedules => ItemEditorPrefill(
          type: ItemType.schedule,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
        ),
      ListHeaderTab.memos => ItemEditorPrefill(
          type: ItemType.memo,
        ),
    };
  }
}
