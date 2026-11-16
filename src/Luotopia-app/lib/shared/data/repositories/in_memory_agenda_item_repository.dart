import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/mutations/user_data_mutation_service.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/repositories/agenda_item_repository.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

class InMemoryAgendaItemRepository extends Notifier<List<AgendaItem>>
    implements AgendaItemRepository {
  late AppDatabase _db;
  late UserDataMutationService _mutations;

  @override
  List<AgendaItem> build() {
    _db = ref.read(appDatabaseProvider);
    _mutations = ref.read(userDataMutationServiceProvider);
    final query =
        _db.select(_db.agendaItemRows).join([
            leftOuterJoin(
              _db.scheduleItemDetailRows,
              _db.scheduleItemDetailRows.itemId.equalsExp(
                _db.agendaItemRows.id,
              ),
            ),
            leftOuterJoin(
              _db.taskItemDetailRows,
              _db.taskItemDetailRows.itemId.equalsExp(_db.agendaItemRows.id),
            ),
            leftOuterJoin(
              _db.courseItemDetailRows,
              _db.courseItemDetailRows.itemId.equalsExp(_db.agendaItemRows.id),
            ),
          ])
          ..where(_db.agendaItemRows.deletedAt.isNull())
          ..orderBy([
            OrderingTerm(expression: _db.agendaItemRows.sortOrder),
            OrderingTerm(expression: _db.agendaItemRows.createdAt),
          ]);
    final subscription = query.watch().listen((rows) {
      state = rows.map(_fromJoinedRow).toList(growable: false);
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

  Future<void> autoCompleteDueSchedules(DateTime now) {
    return _mutations.autoCompleteDueSchedules(now);
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
      _ =>
        item.timelineEndAt != null &&
            item.timelineStartAt != null &&
            item.timelineEndAt!.isAfter(range.start) &&
            item.timelineStartAt!.isBefore(range.end),
    };
  }

  AgendaItem _fromJoinedRow(TypedResult row) {
    final item = row.readTable(_db.agendaItemRows);
    return _fromRow(
      item,
      scheduleDetails: row.readTableOrNull(_db.scheduleItemDetailRows),
      taskDetails: row.readTableOrNull(_db.taskItemDetailRows),
      courseDetails: row.readTableOrNull(_db.courseItemDetailRows),
    );
  }

  AgendaItem _fromRow(
    AgendaItemRow row, {
    ScheduleItemDetailRow? scheduleDetails,
    TaskItemDetailRow? taskDetails,
    CourseItemDetailRow? courseDetails,
  }) {
    return AgendaItem(
      id: row.id,
      type: _enumByName(ItemType.values, row.type) ?? ItemType.task,
      title: row.title,
      notes: row.notes,
      location: row.location,
      color:
          _enumByName(ItemColorOption.values, row.color) ?? ItemColorOption.sky,
      reminder:
          _enumByName(ReminderOption.values, row.reminder) ??
          ReminderOption.none,
      repeatRule:
          _enumByName(RepeatRule.values, row.repeatRule) ?? RepeatRule.none,
      details: _detailsForRow(
        row,
        scheduleDetails: scheduleDetails,
        taskDetails: taskDetails,
        courseDetails: courseDetails,
      ),
      isCompleted: row.isCompleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      completedAt: row.completedAt,
      sortOrder: row.sortOrder,
      sourceKind:
          _enumByName(AgendaItemSourceKind.values, row.sourceKind) ??
          AgendaItemSourceKind.manual,
      sourceRef: row.sourceRef,
    );
  }

  AgendaItemDetails _detailsForRow(
    AgendaItemRow row, {
    ScheduleItemDetailRow? scheduleDetails,
    TaskItemDetailRow? taskDetails,
    CourseItemDetailRow? courseDetails,
  }) {
    final type = _enumByName(ItemType.values, row.type) ?? ItemType.task;
    return switch (type) {
      ItemType.schedule => _scheduleDetails(row.id, scheduleDetails),
      ItemType.task => _taskDetails(row.id, taskDetails),
      ItemType.memo => const MemoItemDetails(),
      ItemType.course => _courseDetails(row.id, courseDetails),
    };
  }

  ScheduleItemDetails _scheduleDetails(
    String itemId,
    ScheduleItemDetailRow? row,
  ) {
    if (row == null) {
      throw StateError('事项 $itemId 缺少日程详情');
    }
    return ScheduleItemDetails(
      startAt: row.startAt,
      endAt: row.endAt,
      isAllDay: row.isAllDay,
      countdownEnabled: row.countdownEnabled,
      autoCompletedOnceAt: row.autoCompletedOnceAt,
    );
  }

  TaskItemDetails _taskDetails(String itemId, TaskItemDetailRow? row) {
    if (row == null) {
      throw StateError('事项 $itemId 缺少任务详情');
    }
    return TaskItemDetails(deadlineAt: row.deadlineAt);
  }

  CourseAgendaItemDetails _courseDetails(
    String itemId,
    CourseItemDetailRow? row,
  ) {
    if (row == null) {
      throw StateError('事项 $itemId 缺少课程详情');
    }
    return CourseAgendaItemDetails(
      startAt: row.startAt,
      endAt: row.endAt,
      isAllDay: row.isAllDay,
      course: ItemCourseDetails(
        timetableId: row.timetableId,
        sourceKind:
            _enumByName(CourseItemSourceKind.values, row.sourceKind) ??
            CourseItemSourceKind.manual,
        sourceCourseId: row.sourceCourseId,
        courseNature: row.courseNature,
        instructor: row.instructor,
        weekMeta: row.weekMeta,
        termCourseId: row.termCourseId,
        offeringId: row.offeringId,
        teacherId: row.teacherId,
        occurrenceId: row.occurrenceId,
      ),
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

final agendaItemRepositoryNotifierProvider = Provider<AgendaItemRepository>((
  ref,
) {
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
