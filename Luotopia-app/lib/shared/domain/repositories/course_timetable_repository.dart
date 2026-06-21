import 'package:luotopia/shared/domain/entities/course_timetable.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

abstract class CourseTimetableRepository {
  CourseTimetableStore get store;

  CourseTimetable? findById(String id);

  Future<CourseTimetable> createTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel,
  });

  Future<CourseTimetable> importCourseTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel,
    required List<ItemDraft> items,
  });

  Future<void> renameTimetable(String id, String newName);

  Future<void> setSelectedTimetables(Set<String> ids);

  Future<void> deleteTimetable(String id);
}
