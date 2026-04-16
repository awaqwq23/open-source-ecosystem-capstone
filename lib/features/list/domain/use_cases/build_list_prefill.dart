import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/features/list/domain/models/list_filters.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';

class BuildListPrefillUseCase {
  const BuildListPrefillUseCase();

  ItemEditorPrefill call(ListHeaderTab tab, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (tab) {
      ListHeaderTab.myDay => ItemEditorPrefill(
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
          targetDate: today,
        ),
      ListHeaderTab.allItems => const ItemEditorPrefill(),
      ListHeaderTab.tasks => ItemEditorPrefill(
          type: ItemType.task,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
          deadline: today.add(const Duration(hours: 18)),
        ),
      ListHeaderTab.schedules => ItemEditorPrefill(
          type: ItemType.schedule,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
        ),
      ListHeaderTab.memos => ItemEditorPrefill(
          type: ItemType.memo,
          targetDate: today,
          estimatedDuration: const Duration(hours: 1),
        ),
      ListHeaderTab.important => ItemEditorPrefill(
          isImportant: true,
          startAt: today.add(const Duration(hours: 9)),
          endAt: today.add(const Duration(hours: 10)),
          targetDate: today,
        ),
    };
  }
}
