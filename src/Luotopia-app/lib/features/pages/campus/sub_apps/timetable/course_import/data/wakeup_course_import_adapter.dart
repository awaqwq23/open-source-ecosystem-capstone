import 'package:luotopia/features/pages/campus/sub_apps/timetable/course_import/domain/models/course_import_models.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';

class WakeupCourseImportAdapter implements CourseImportAdapter {
  const WakeupCourseImportAdapter();

  @override
  CourseTimetableSource get source => CourseTimetableSource.wakeup;

  @override
  Future<CourseImportResult> import(CourseImportRequest request) async {
    return const CourseImportResult(
      success: false,
      message: 'Wakeup 分享口令/链接解析器待接入，当前版本先提供导入流程占位。',
    );
  }
}
