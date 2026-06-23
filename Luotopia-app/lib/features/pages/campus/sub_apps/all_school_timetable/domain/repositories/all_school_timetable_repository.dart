import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/models/all_school_timetable_models.dart';
import 'dart:io';

abstract class AllSchoolTimetableRepository {
  Future<void> ensureLocalDataReady();

  Future<void> replaceTermFromHtmlRows({
    required String termKey,
    required String schoolYear,
    required String term,
    required String sourceVersion,
    required List<Map<String, String>> rows,
  });

  Future<void> replaceTermFromArtifactFile({
    required File gzipFile,
    required String termKey,
    required int version,
    required String checksum,
    required int rowCount,
  });

  Future<void> retainActiveTerms(Set<String> termKeys);

  Future<List<SchoolTimetableTerm>> loadTerms();

  Future<List<SchoolCourseHead>> searchCourseHeads(
    AllSchoolTimetableQuery query,
  );

  Future<SchoolCourseHead?> findCourseHead({
    required String termKey,
    required String id,
  });

  Future<List<SchoolTeachingClass>> loadTeachingClasses({
    required String termKey,
    required String courseHeadId,
  });

  Future<SchoolTeachingClass?> findTeachingClass({
    required String termKey,
    required String id,
  });

  Future<List<SchoolClassMeeting>> loadMeetings({
    required String termKey,
    required String teachingClassId,
  });

  Future<CourseEntityLink> matchPersonalCourse(PersonalCourseMatchQuery query);
}
