import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';

abstract class AllSchoolTimetableRepository {
  Future<void> ensureMockDataLoaded();

  Future<List<SchoolTimetableTerm>> loadTerms();

  Future<List<SchoolCourseHead>> searchCourseHeads(
    AllSchoolTimetableQuery query,
  );

  Future<SchoolCourseHead?> findCourseHead(String id);

  Future<List<SchoolTeachingClass>> loadTeachingClasses(String courseHeadId);

  Future<SchoolTeachingClass?> findTeachingClass(String id);

  Future<List<SchoolClassMeeting>> loadMeetings(String teachingClassId);
}
