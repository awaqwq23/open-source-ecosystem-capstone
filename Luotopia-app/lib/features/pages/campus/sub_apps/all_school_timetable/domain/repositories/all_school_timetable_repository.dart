import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';

abstract class AllSchoolTimetableRepository {
  Future<void> ensureLocalDataReady();

  Future<void> replaceTermFromHtmlRows({
    required String termKey,
    required String schoolYear,
    required String term,
    required String sourceVersion,
    required List<Map<String, String>> rows,
  });

  Future<void> replaceTermFromPackageBytes({
    required List<int> bytes,
    required String sourceVersion,
  });

  Future<List<SchoolTimetableTerm>> loadTerms();

  Future<List<SchoolCourseHead>> searchCourseHeads(
    AllSchoolTimetableQuery query,
  );

  Future<SchoolCourseHead?> findCourseHead(String id);

  Future<List<SchoolTeachingClass>> loadTeachingClasses(String courseHeadId);

  Future<SchoolTeachingClass?> findTeachingClass(String id);

  Future<List<SchoolClassMeeting>> loadMeetings(String teachingClassId);

  Future<CourseEntityLink> matchPersonalCourse(PersonalCourseMatchQuery query);
}
