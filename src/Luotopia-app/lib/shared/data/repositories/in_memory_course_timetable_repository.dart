import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/shared/data/database/app_database.dart';
import 'package:luotopia/shared/data/mutations/user_data_mutation_service.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/repositories/course_timetable_repository.dart';

class InMemoryCourseTimetableRepository extends Notifier<CourseTimetableStore>
    implements CourseTimetableRepository {
  late AppDatabase _db;
  late UserDataMutationService _mutations;

  @override
  CourseTimetableStore build() {
    _db = ref.read(appDatabaseProvider);
    _mutations = ref.read(userDataMutationServiceProvider);
    List<CourseTimetableRow> timetableRows = const [];
    List<SelectedCourseTimetableRow> selectedRows = const [];

    void publish() {
      final timetables = timetableRows.map(_fromRow).toList(growable: false);
      final validIds = timetables.map((timetable) => timetable.id).toSet();
      final selected = {
        for (final row in selectedRows)
          if (validIds.contains(row.timetableId)) row.timetableId,
      };
      state = CourseTimetableStore(
        timetables: timetables,
        selectedTimetableIds: selected,
      );
    }

    final timetableSub =
        (_db.select(_db.courseTimetableRows)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm(expression: row.createdAt)]))
            .watch()
            .listen((rows) {
              timetableRows = rows;
              publish();
            });
    final selectedSub =
        (_db.select(_db.selectedCourseTimetableRows)
              ..where((row) => row.deletedAt.isNull())
              ..orderBy([(row) => OrderingTerm(expression: row.sortOrder)]))
            .watch()
            .listen((rows) {
              selectedRows = rows;
              publish();
            });
    ref.onDispose(() {
      timetableSub.cancel();
      selectedSub.cancel();
    });
    return const CourseTimetableStore(timetables: []);
  }

  @override
  CourseTimetableStore get store => state;

  @override
  CourseTimetable? findById(String id) {
    for (final timetable in state.timetables) {
      if (timetable.id == id) {
        return timetable;
      }
    }
    return null;
  }

  @override
  Future<CourseTimetable> createTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel = '',
  }) async {
    return _mutations.createTimetable(
      name: name,
      source: source,
      termLabel: termLabel,
    );
  }

  @override
  Future<CourseTimetable> importCourseTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel = '',
    required List<ItemDraft> items,
  }) async {
    return _mutations.importCourseTimetable(
      name: name,
      source: source,
      termLabel: termLabel,
      items: items,
    );
  }

  @override
  Future<void> renameTimetable(String id, String newName) async {
    await _mutations.renameTimetable(id, newName);
  }

  @override
  Future<void> setSelectedTimetables(Set<String> ids) async {
    await _mutations.setSelectedTimetables(ids);
  }

  @override
  Future<void> deleteTimetable(String id) async {
    await _mutations.deleteTimetable(id);
  }

  CourseTimetable _fromRow(CourseTimetableRow row) {
    return CourseTimetable(
      id: row.id,
      name: row.name,
      source:
          _enumByName(CourseTimetableSource.values, row.source) ??
          CourseTimetableSource.manual,
      termLabel: row.termLabel,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
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

final courseTimetableRepositoryProvider =
    NotifierProvider<InMemoryCourseTimetableRepository, CourseTimetableStore>(
      InMemoryCourseTimetableRepository.new,
    );

final courseTimetableRepositoryNotifierProvider =
    Provider<CourseTimetableRepository>((ref) {
      return ref.read(courseTimetableRepositoryProvider.notifier);
    });
