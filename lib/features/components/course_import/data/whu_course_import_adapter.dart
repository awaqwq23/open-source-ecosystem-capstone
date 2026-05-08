import 'package:luotopia/features/components/course_import/domain/models/course_import_models.dart';
import 'package:luotopia/shared/domain/entities/course_timetable.dart';

class WhuCourseImportAdapter implements CourseImportAdapter {
  const WhuCourseImportAdapter();

  @override
  CourseTimetableSource get source => CourseTimetableSource.whuJw;

  @override
  Future<CourseImportResult> import(CourseImportRequest request) async {
    return const CourseImportResult(
      success: false,
      message: '武汉大学教务导入解析器正在接入中，当前版本先提供流程入口。',
    );
  }
}
