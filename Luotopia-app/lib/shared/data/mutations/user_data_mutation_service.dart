import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/id/app_id_generator.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/item_course_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

final userDataMutationServiceProvider = Provider<UserDataMutationService>((ref) {
  return UserDataMutationService(
    db: ref.read(appDatabaseProvider),
    idGenerator: ref.read(appIdGeneratorProvider),
  );
});

class UserDataMutationService {
  const UserDataMutationService({
    required AppDatabase db,
    required AppIdGenerator idGenerator,
  })  : _db = db,
        _idGenerator = idGenerator;

  final AppDatabase _db;
  final AppIdGenerator _idGenerator;

  Future<AgendaItem> createItem(ItemDraft draft) async {
    final now = DateTime.now();
    final rows = await (_db.select(_db.agendaItemRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final nextOrder = rows.isEmpty
        ? 0.0
        : rows.map((row) => row.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
    final item = AgendaItem.fromDraft(
      id: await _createUniqueAgendaItemId(),
      draft: draft,
      createdAt: now,
      updatedAt: now,
      sortOrder: nextOrder,
    );
    await _db.into(_db.agendaItemRows).insert(_agendaItemCompanion(item));
    return item;
  }

  Future<AgendaItem?> updateItem(String id, ItemDraft draft) async {
    final row = await (_db.select(_db.agendaItemRows)
          ..where((table) => table.id.equals(id) & table.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final current = _agendaItemFromRow(row);
    final updated = current.copyWith(
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
    );
    await (_db.update(_db.agendaItemRows)..where((table) => table.id.equals(id)))
        .write(_agendaItemCompanion(updated));
    return updated;
  }

  Future<void> deleteItem(String id) {
    return _markDeleted(entityType: 'agenda_item', entityId: id);
  }

  Future<AgendaItem?> toggleCompleted(String id) async {
    final row = await (_db.select(_db.agendaItemRows)
          ..where((table) => table.id.equals(id) & table.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    final current = _agendaItemFromRow(row);
    final completed = !current.isCompleted;
    final updated = current.copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
      clearCompletedAt: !completed,
      updatedAt: DateTime.now(),
    );
    await (_db.update(_db.agendaItemRows)..where((table) => table.id.equals(id)))
        .write(_agendaItemCompanion(updated));
    return updated;
  }

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
      final rows = await (_db.select(_db.agendaItemRows)
            ..where((row) => row.id.like('$idPrefix%') & row.deletedAt.isNull()))
          .get();
      for (final row in rows) {
        await _markDeletedInTransaction(entityType: 'agenda_item', entityId: row.id);
      }
      for (final item in items) {
        await _db
            .into(_db.agendaItemRows)
            .insertOnConflictUpdate(_agendaItemCompanion(item));
      }
    });
  }

  Future<CourseTimetable> createTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel = '',
  }) async {
    final now = DateTime.now();
    final rows = await (_db.select(_db.courseTimetableRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    final timetable = CourseTimetable(
      id: await _createUniqueCourseTimetableId(),
      name: name.trim().isEmpty ? '课程表 ${rows.length + 1}' : name.trim(),
      source: source,
      termLabel: termLabel.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _db.transaction(() async {
      await _db.into(_db.courseTimetableRows).insert(_courseTimetableCompanion(timetable));
      await _upsertSelectedTimetable(
        timetableId: timetable.id,
        sortOrder: await _nextSelectedSortOrder(),
        updatedAt: now,
      );
    });
    return timetable;
  }

  Future<void> renameTimetable(String id, String newName) async {
    final normalized = newName.trim();
    if (normalized.isEmpty) {
      return;
    }
    await (_db.update(_db.courseTimetableRows)..where((row) => row.id.equals(id)))
        .write(
      CourseTimetableRowsCompanion(
        name: Value(normalized),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      ),
    );
  }

  Future<void> setSelectedTimetables(Set<String> ids) async {
    await _db.transaction(() async {
      final activeTimetables = await (_db.select(_db.courseTimetableRows)
            ..where((row) => row.deletedAt.isNull()))
          .get();
      final validIds = activeTimetables.map((row) => row.id).toSet();
      final nextIds = ids.where(validIds.contains).toList(growable: false);
      final existing = await (_db.select(_db.selectedCourseTimetableRows)
            ..where((row) => row.deletedAt.isNull()))
          .get();
      final nextSet = nextIds.toSet();
      final now = DateTime.now();
      for (final row in existing) {
        if (!nextSet.contains(row.timetableId)) {
          await _markDeletedInTransaction(
            entityType: 'selected_course_timetable',
            entityId: row.timetableId,
          );
        }
      }
      for (var index = 0; index < nextIds.length; index++) {
        await _upsertSelectedTimetable(
          timetableId: nextIds[index],
          sortOrder: index.toDouble(),
          updatedAt: now,
        );
      }
    });
  }

  Future<void> deleteTimetable(String id) async {
    await _db.transaction(() async {
      final courseItems = await (_db.select(_db.agendaItemRows)
            ..where((row) => row.courseTimetableId.equals(id) & row.deletedAt.isNull()))
          .get();
      for (final item in courseItems) {
        await _markDeletedInTransaction(entityType: 'agenda_item', entityId: item.id);
      }
      await _markDeletedInTransaction(entityType: 'selected_course_timetable', entityId: id);
      await _markDeletedInTransaction(entityType: 'course_timetable', entityId: id);
    });
  }

  Future<void> _markDeleted({
    required String entityType,
    required String entityId,
  }) async {
    await _db.transaction(() async {
      await _markDeletedInTransaction(entityType: entityType, entityId: entityId);
    });
  }

  Future<void> _markDeletedInTransaction({
    required String entityType,
    required String entityId,
  }) async {
    final now = DateTime.now();
    if (entityType == 'agenda_item') {
      await (_db.update(_db.agendaItemRows)..where((row) => row.id.equals(entityId)))
          .write(
        AgendaItemRowsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
    } else if (entityType == 'course_timetable') {
      await (_db.update(_db.courseTimetableRows)..where((row) => row.id.equals(entityId)))
          .write(
        CourseTimetableRowsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
    } else if (entityType == 'selected_course_timetable') {
      await (_db.update(_db.selectedCourseTimetableRows)
            ..where((row) => row.timetableId.equals(entityId)))
          .write(
        SelectedCourseTimetableRowsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          dirty: const Value(true),
        ),
      );
    }
    await _db.into(_db.syncTombstoneRows).insertOnConflictUpdate(
          SyncTombstoneRowsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            deletedAt: now,
            dirty: const Value(true),
          ),
        );
  }

  Future<void> _upsertSelectedTimetable({
    required String timetableId,
    required double sortOrder,
    required DateTime updatedAt,
  }) {
    return _db.into(_db.selectedCourseTimetableRows).insertOnConflictUpdate(
          SelectedCourseTimetableRowsCompanion.insert(
            timetableId: timetableId,
            sortOrder: Value(sortOrder),
            dirty: const Value(true),
            deletedAt: const Value(null),
            updatedAt: updatedAt,
          ),
        );
  }

  Future<double> _nextSelectedSortOrder() async {
    final rows = await (_db.select(_db.selectedCourseTimetableRows)
          ..where((row) => row.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) {
      return 0;
    }
    return rows.map((row) => row.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<String> _createUniqueAgendaItemId() async {
    final rows = await _db.select(_db.agendaItemRows).get();
    final existingIds = rows.map((row) => row.id).toSet();
    var id = _idGenerator.newAgendaItemId();
    while (existingIds.contains(id)) {
      id = _idGenerator.newAgendaItemId();
    }
    return id;
  }

  Future<String> _createUniqueCourseTimetableId() async {
    final rows = await _db.select(_db.courseTimetableRows).get();
    final existingIds = rows.map((row) => row.id).toSet();
    var id = _idGenerator.newCourseTimetableId();
    while (existingIds.contains(id)) {
      id = _idGenerator.newCourseTimetableId();
    }
    return id;
  }

  AgendaItemRowsCompanion _agendaItemCompanion(AgendaItem item) {
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
      deletedAt: const Value(null),
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  CourseTimetableRowsCompanion _courseTimetableCompanion(CourseTimetable timetable) {
    return CourseTimetableRowsCompanion.insert(
      id: timetable.id,
      name: timetable.name,
      source: timetable.source.name,
      termLabel: Value(timetable.termLabel),
      dirty: const Value(true),
      deletedAt: const Value(null),
      createdAt: timetable.createdAt,
      updatedAt: timetable.updatedAt ?? timetable.createdAt,
    );
  }

  AgendaItem _agendaItemFromRow(AgendaItemRow row) {
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
