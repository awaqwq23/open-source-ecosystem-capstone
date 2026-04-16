import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';

abstract class CourseTimetableRepository {
  CourseTimetableStore get store;

  CourseTimetable? findById(String id);

  Future<CourseTimetable> createTimetable({
    required String name,
    required CourseTimetableSource source,
    String termLabel,
  });

  Future<void> renameTimetable(String id, String newName);

  Future<void> setActiveTimetable(String? timetableId);

  Future<void> deleteTimetable(String id);
}
