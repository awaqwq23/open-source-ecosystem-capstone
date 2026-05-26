import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/mutations/user_data_mutation_service.dart';
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
  late final UserDataMutationService _mutations;

  @override
  List<AgendaItem> build() {
    _db = ref.read(appDatabaseProvider);
    _mutations = ref.read(userDataMutationServiceProvider);
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
    return _mutations.createItem(draft);
  }

  @override
  Future<AgendaItem?> updateItem(String id, ItemDraft draft) async {
    return _mutations.updateItem(id, draft);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _mutations.deleteItem(id);
  }

  @override
  Future<AgendaItem?> toggleCompleted(String id) async {
    return _mutations.toggleCompleted(id);
  }

  @override
  Future<void> reorderItems(List<String> orderedIds) async {
    await _mutations.reorderItems(orderedIds);
  }

  Future<void> replaceItemsByIdPrefix({
    required String idPrefix,
    required List<AgendaItem> items,
  }) async {
    await _mutations.replaceItemsByIdPrefix(idPrefix: idPrefix, items: items);
  }

  bool _matchesRange(AgendaItem item, DateTimeRangeValue range) {
    return switch (item.type) {
      ItemType.memo => true,
      _ => item.endAt.isAfter(range.start) && item.startAt.isBefore(range.end),
    };
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
