import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';

abstract class AgendaItemRepository {
  List<AgendaItem> get items;
  AgendaItem? findById(String id);
  Future<AgendaItem> createItem(
    ItemDraft draft, {
    bool isImportant = false,
  });
  Future<AgendaItem?> updateItem(
    String id,
    ItemDraft draft, {
    bool? isImportant,
  });
  Future<void> deleteItem(String id);
  Future<AgendaItem?> toggleCompleted(String id);
  Future<AgendaItem?> toggleImportant(String id);
  Future<void> reorderItems(List<String> orderedIds);
}

class InMemoryAgendaItemRepository extends Notifier<List<AgendaItem>>
    implements AgendaItemRepository {
  var _idSeed = 0;

  @override
  List<AgendaItem> build() {
    return const [];
  }

  @override
  List<AgendaItem> get items => state;

  @override
  AgendaItem? findById(String id) {
    for (final item in state) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<AgendaItem> createItem(
    ItemDraft draft, {
    bool isImportant = false,
  }) async {
    final now = DateTime.now();
    final nextOrder = state.isEmpty
        ? 0.0
        : state
                .map((item) => item.manualOrder)
                .reduce((value, element) => value > element ? value : element) +
            1;
    final item = AgendaItem.fromDraft(
      id: 'item_${_idSeed++}',
      draft: draft,
      createdAt: now,
      manualOrder: nextOrder,
      isImportant: isImportant,
    );
    state = [...state, item];
    return item;
  }

  @override
  Future<AgendaItem?> updateItem(
    String id,
    ItemDraft draft, {
    bool? isImportant,
  }) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    final current = state[index];
    final updated = current.copyWith(
      type: draft.type,
      title: draft.title.trim(),
      details: draft.details.trim(),
      location: draft.location.trim(),
      color: draft.color,
      isAllDay: draft.isAllDay,
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      startAt: draft.startAt,
      endAt: draft.endAt,
      deadline: draft.deadline,
      clearDeadline: draft.deadline == null,
      targetDate: draft.targetDate,
      estimatedDuration: draft.estimatedDuration,
      isImportant: isImportant ?? current.isImportant,
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    return updated;
  }

  @override
  Future<void> deleteItem(String id) async {
    state = state.where((item) => item.id != id).toList(growable: false);
  }

  @override
  Future<AgendaItem?> toggleCompleted(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    final current = state[index];
    final completed = !current.isCompleted;
    final updated = current.copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
      clearCompletedAt: !completed,
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    return updated;
  }

  @override
  Future<AgendaItem?> toggleImportant(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    final current = state[index];
    final updated = current.copyWith(isImportant: !current.isImportant);
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    return updated;
  }

  @override
  Future<void> reorderItems(List<String> orderedIds) async {
    final orderMap = <String, double>{};
    for (var index = 0; index < orderedIds.length; index++) {
      orderMap[orderedIds[index]] = index.toDouble();
    }

    state = [
      for (final item in state)
        item.copyWith(
          manualOrder: orderMap[item.id] ?? item.manualOrder,
        ),
    ];
  }
}

final agendaItemRepositoryProvider =
    NotifierProvider<InMemoryAgendaItemRepository, List<AgendaItem>>(
  InMemoryAgendaItemRepository.new,
);

final agendaItemByIdProvider = Provider.family<AgendaItem?, String>((ref, id) {
  final items = ref.watch(agendaItemRepositoryProvider);
  for (final item in items) {
    if (item.id == id) {
      return item;
    }
  }
  return null;
});
