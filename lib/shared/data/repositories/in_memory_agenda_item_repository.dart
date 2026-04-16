import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/mappers/agenda_item_storage_mapper.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';
import 'package:huajuan_agenda/shared/domain/repositories/agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

final agendaItemsBootstrapProvider = Provider<List<AgendaItem>>((ref) {
  return const [];
});

class InMemoryAgendaItemRepository extends Notifier<List<AgendaItem>>
    implements AgendaItemRepository {
  var _idSeed = 0;

  @override
  List<AgendaItem> build() {
    final items = ref.read(agendaItemsBootstrapProvider);
    _idSeed = items.length;
    return items;
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
  List<AgendaItem> findByRange(DateTimeRangeValue range) {
    return [
      for (final item in state)
        if (_matchesRange(item, range)) item,
    ];
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
    await _persist();
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
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      scheduleDetails: draft.scheduleDetails,
      taskDetails: draft.taskDetails,
      memoDetails: draft.memoDetails,
      courseDetails: draft.courseDetails,
      isImportant: isImportant ?? current.isImportant,
      updatedAt: DateTime.now(),
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    await _persist();
    return updated;
  }

  @override
  Future<void> deleteItem(String id) async {
    state = state.where((item) => item.id != id).toList(growable: false);
    await _persist();
  }

  @override
  Future<AgendaItem?> toggleCompleted(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    final current = state[index];
    if (current.type == ItemType.course) {
      return current;
    }
    final completed = !current.isCompleted;
    final updated = current.copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
      clearCompletedAt: !completed,
      updatedAt: DateTime.now(),
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    await _persist();
    return updated;
  }

  @override
  Future<AgendaItem?> toggleImportant(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    final current = state[index];
    final updated = current.copyWith(
      isImportant: !current.isImportant,
      updatedAt: DateTime.now(),
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    await _persist();
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
          updatedAt: DateTime.now(),
        ),
    ];
    await _persist();
  }

  Future<void> replaceItemsByIdPrefix({
    required String idPrefix,
    required List<AgendaItem> items,
  }) async {
    final preservedItems = [
      for (final item in state)
        if (!item.id.startsWith(idPrefix)) item,
    ];
    state = [
      ...preservedItems,
      ...items,
    ];
    _idSeed = state.length;
    await _persist();
  }

  Future<void> _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs?.setString(
          AppBootstrapStorageKeys.agendaItems,
          jsonEncode([
            for (final item in state) AgendaItemStorageMapper.toJson(item),
          ]),
        ) ??
        Future<void>.value();
  }

  bool _matchesRange(AgendaItem item, DateTimeRangeValue range) {
    return switch (item.type) {
      ItemType.memo =>
        !item.targetDate.isBefore(range.start) &&
            !item.targetDate.isAfter(range.end),
      _ => item.endAt.isAfter(range.start) && item.startAt.isBefore(range.end),
    };
  }
}

final agendaItemRepositoryProvider =
    NotifierProvider<InMemoryAgendaItemRepository, List<AgendaItem>>(
  InMemoryAgendaItemRepository.new,
);

final agendaItemRepositoryNotifierProvider = Provider<AgendaItemRepository>((ref) {
  return ref.read(agendaItemRepositoryProvider.notifier);
});

final agendaItemByIdProvider = Provider.family<AgendaItem?, String>((ref, id) {
  final repository = ref.watch(agendaItemRepositoryProvider.notifier);
  return repository.findById(id);
});
