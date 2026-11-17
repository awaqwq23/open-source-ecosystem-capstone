import 'dart:io';

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

  Future<int> readDatasetVersion();

  Future<void> applyChanges({
    required int version,
    required String checksum,
    required List<SchoolTimetableChange> changes,
  });

  Future<void> replaceFromBundle({
    required int version,
    required String checksum,
    required File sqliteGzipFile,
  });

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

class SchoolTimetableChange {
  const SchoolTimetableChange({
    required this.version,
    required this.sequence,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.termKey,
    required this.payload,
  });

  final int version;
  final int sequence;
  final String operation;
  final String entityType;
  final String entityId;
  final String termKey;
  final Map<String, dynamic> payload;
}
