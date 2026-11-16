import 'package:luotopia/shared/domain/entities/course_timetable.dart';

class CourseImportResult {
  const CourseImportResult({
    required this.success,
    required this.message,
    this.createdItemCount = 0,
    this.timetableId,
  });

  final bool success;
  final String message;
  final int createdItemCount;
  final String? timetableId;
}

class CourseImportRequest {
  const CourseImportRequest({
    required this.timetableName,
    this.termLabel = '',
    this.payload = '',
  });

  final String timetableName;
  final String termLabel;
  final String payload;
}

abstract class CourseImportAdapter {
  CourseTimetableSource get source;

  Future<CourseImportResult> import(CourseImportRequest request);
}
