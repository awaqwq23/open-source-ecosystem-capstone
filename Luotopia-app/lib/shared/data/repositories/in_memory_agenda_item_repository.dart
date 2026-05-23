import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/id/app_id_generator.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/repositories/agenda_item_repository.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class InMemoryAgendaItemRepository extends Notifier<List<AgendaItem>>
    implements AgendaItemRepository {
  late final AppDatabase _db;

  @override
  List<AgendaItem> build() {
    _db = ref.read(appDatabaseProvider);
    final subscription = (_db.select(_db.agendaItemRows)
          ..where((row) => row.deletedAt.isNull())
          ..orderBy([
            (row) => OrderingTerm(expression: row.sortOrder),
            (row) => OrderingTerm(expression: row.startAt),
          ]))
        .watch()
        .listen((rows) {
      state = rows.map(_fromRow).toList(growable: false);
    });
    ref.onDispose(subscription.cancel);
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
  List<AgendaItem> findByRange(DateTimeRangeValue range) {
    return [
      for (final item in state)
        if (_matchesRange(item, range)) item,
    ];
  }

  @override
  Future<AgendaItem> createItem(ItemDraft draft) async {
    final now = DateTime.now();
    final nextOrder = state.isEmpty
        ? 0.0
        : state
                .map((item) => item.sortOrder)
                .reduce((value, element) => value > element ? value : element) +
            1;
    final item = _normalizeCompletionByType(
      AgendaItem.fromDraft(
        id: _createUniqueAgendaItemId(),
        draft: draft,
        createdAt: now,
        updatedAt: now,
        sortOrder: nextOrder,
      ),
    );
    await _db.into(_db.agendaItemRows).insert(_toCompanion(item));
    return item;
  }

  @override
  Future<AgendaItem?> updateItem(String id, ItemDraft draft) async {
    final current = findById(id);
    if (current == null) {
      return null;
    }

    final updated = _normalizeCompletionByType(current.copyWith(
      type: draft.type,
      title: draft.title.trim(),
      notes: draft.notes.trim(),
      location: draft.location.trim(),
      color: draft.color,
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      startAt: draft.startAt,
      endAt: draft.endAt,
      isAllDay: draft.isAllDay,
      taskDetails: draft.taskDetails,
      courseDetails: draft.courseDetails,
      updatedAt: DateTime.now(),
      sourceKind: draft.sourceKind,
      sourceRef: draft.sourceRef.trim(),
    ));
    await (_db.update(_db.agendaItemRows)..where((row) => row.id.equals(id)))
        .write(_toCompanion(updated));
    return updated;
  }

  @override
  Future<void> deleteItem(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.agendaItemRows)..where((row) => row.id.equals(id))).write(
        AgendaItemRowsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
      await _db.into(_db.syncTombstoneRows).insertOnConflictUpdate(
            SyncTombstoneRowsCompanion.insert(
              entityType: 'agenda_item',
              entityId: id,
              deletedAt: now,
              dirty: const Value(true),
            ),
          );
    });
  }

  @override
  Future<AgendaItem?> toggleCompleted(String id) async {
    final current = findById(id);
    if (current == null) {
      return null;
    }

    final completed = !current.isCompleted;
    final updated = current.copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
      clearCompletedAt: !completed,
      updatedAt: DateTime.now(),
    );
    await (_db.update(_db.agendaItemRows)..where((row) => row.id.equals(id)))
        .write(_toCompanion(updated));
    return updated;
  }

  @override
  Future<void> reorderItems(List<String> orderedIds) async {
    await _db.transaction(() async {
      final now = DateTime.now();
      for (var index = 0; index < orderedIds.length; index++) {
        await (_db.update(_db.agendaItemRows)
              ..where((row) => row.id.equals(orderedIds[index])))
            .write(
          AgendaItemRowsCompanion(
            sortOrder: Value(index.toDouble()),
            updatedAt: Value(now),
            dirty: const Value(true),
          ),
        );
      }
    });
  }

  Future<void> replaceItemsByIdPrefix({
    required String idPrefix,
    required List<AgendaItem> items,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.agendaItemRows)
            ..where((row) => row.id.like('$idPrefix%')))
          .write(
        AgendaItemRowsCompanion(
          deletedAt: Value(DateTime.now()),
          dirty: const Value(true),
        ),
      );
      for (final item in items) {
        await _db.into(_db.agendaItemRows).insertOnConflictUpdate(_toCompanion(item));
      }
    });
  }

  bool _matchesRange(AgendaItem item, DateTimeRangeValue range) {
    return switch (item.type) {
      ItemType.memo => true,
      _ => item.endAt.isAfter(range.start) && item.startAt.isBefore(range.end),
    };
  }

  AgendaItem _normalizeCompletionByType(AgendaItem item) {
    return item;
  }

  String _createUniqueAgendaItemId() {
    final existingIds = state.map((item) => item.id).toSet();
    final generator = ref.read(appIdGeneratorProvider);
    var id = generator.newAgendaItemId();
    while (existingIds.contains(id)) {
      id = generator.newAgendaItemId();
    }
    return id;
  }

  AgendaItemRowsCompanion _toCompanion(AgendaItem item) {
    return AgendaItemRowsCompanion.insert(
      id: item.id,
      type: item.type.name,
      title: item.title,
      notes: Value(item.notes),
      location: Value(item.location),
      color: item.color.name,
      reminder: item.reminder.name,
      repeatRule: item.repeatRule.name,
      startAt: item.startAt,
      endAt: item.endAt,
      isAllDay: Value(item.isAllDay),
      deadline: Value(item.deadline),
      estimatedDurationMinutes: Value(item.estimatedDuration.inMinutes),
      isCompleted: Value(item.isCompleted),
      completedAt: Value(item.completedAt),
      sortOrder: Value(item.sortOrder),
      sourceKind: Value(item.sourceKind.name),
      sourceRef: Value(item.sourceRef),
      courseTimetableId: Value(item.courseDetails.timetableId),
      courseSourceKind: Value(item.courseDetails.sourceKind.name),
      courseSourceCourseId: Value(item.courseDetails.sourceCourseId),
      courseNature: Value(item.courseDetails.courseNature),
      instructor: Value(item.courseDetails.instructor),
      weekMeta: Value(item.courseDetails.weekMeta),
      dirty: const Value(true),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  AgendaItem _fromRow(AgendaItemRow row) {
    return AgendaItem(
      id: row.id,
      type: _enumByName(ItemType.values, row.type) ?? ItemType.task,
      title: row.title,
      notes: row.notes,
      location: row.location,
      color: _enumByName(ItemColorOption.values, row.color) ?? ItemColorOption.sky,
      reminder: _enumByName(ReminderOption.values, row.reminder) ??
          ReminderOption.none,
      repeatRule:
          _enumByName(RepeatRule.values, row.repeatRule) ?? RepeatRule.none,
      startAt: row.startAt,
      endAt: row.endAt,
      isAllDay: row.isAllDay,
      taskDetails: ItemTaskDetails(
        deadline: row.deadline,
        estimatedDuration: Duration(minutes: row.estimatedDurationMinutes),
      ),
      courseDetails: ItemCourseDetails(
        timetableId: row.courseTimetableId,
        sourceKind: _enumByName(CourseItemSourceKind.values, row.courseSourceKind) ??
            CourseItemSourceKind.manual,
        sourceCourseId: row.courseSourceCourseId,
        courseNature: row.courseNature,
        instructor: row.instructor,
        weekMeta: row.weekMeta,
      ),
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
      sortOrder: row.sortOrder,
      sourceKind: _enumByName(AgendaItemSourceKind.values, row.sourceKind) ??
          AgendaItemSourceKind.manual,
      sourceRef: row.sourceRef,
    );
  }

  T? _enumByName<T extends Enum>(List<T> values, String name) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
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
  final items = ref.watch(agendaItemRepositoryProvider);
  try {
    return items.firstWhere((item) => item.id == id);
  } catch (_) {
    return null;
  }
});
