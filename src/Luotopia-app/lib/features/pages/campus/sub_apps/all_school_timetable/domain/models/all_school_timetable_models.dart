class SchoolTimetableTerm {
  const SchoolTimetableTerm({
    required this.termKey,
    required this.schoolYear,
    required this.term,
    required this.firstWeekMonday,
    required this.sourceVersion,
    required this.rowCount,
    required this.importedAt,
    required this.updatedAt,
  });

  final String termKey;
  final String schoolYear;
  final String term;
  final String firstWeekMonday;
  final String sourceVersion;
  final int rowCount;
  final DateTime importedAt;
  final DateTime updatedAt;
}

class AllSchoolTimetableQuery {
  const AllSchoolTimetableQuery({
    this.termKey,
    this.keyword = '',
    this.courseName = '',
    this.teacher = '',
    this.teachingClass = '',
    this.openDepartment = '',
    this.studentCollege = '',
    this.grade = '',
    this.major = '',
    this.courseCategory = '',
    this.departmentOrCollege = '',
    this.openType = '',
    this.courseNature = '',
  });

  final String? termKey;
  final String keyword;
  final String courseName;
  final String teacher;
  final String teachingClass;
  final String openDepartment;
  final String studentCollege;
  final String grade;
  final String major;
  final String courseCategory;
  final String departmentOrCollege;
  final String openType;
  final String courseNature;

  bool get hasAdvancedFilters {
    return courseName.isNotEmpty ||
        teacher.isNotEmpty ||
        teachingClass.isNotEmpty ||
        openDepartment.isNotEmpty ||
        studentCollege.isNotEmpty ||
        grade.isNotEmpty ||
        major.isNotEmpty ||
        courseCategory.isNotEmpty ||
        departmentOrCollege.isNotEmpty ||
        openType.isNotEmpty ||
        courseNature.isNotEmpty;
  }

  AllSchoolTimetableQuery copyWith({
    String? termKey,
    String? keyword,
    String? courseName,
    String? teacher,
    String? teachingClass,
    String? openDepartment,
    String? studentCollege,
    String? grade,
    String? major,
    String? courseCategory,
    String? departmentOrCollege,
    String? openType,
    String? courseNature,
  }) {
    return AllSchoolTimetableQuery(
      termKey: termKey ?? this.termKey,
      keyword: keyword ?? this.keyword,
      courseName: courseName ?? this.courseName,
      teacher: teacher ?? this.teacher,
      teachingClass: teachingClass ?? this.teachingClass,
      openDepartment: openDepartment ?? this.openDepartment,
      studentCollege: studentCollege ?? this.studentCollege,
      grade: grade ?? this.grade,
      major: major ?? this.major,
      courseCategory: courseCategory ?? this.courseCategory,
      departmentOrCollege: departmentOrCollege ?? this.departmentOrCollege,
      openType: openType ?? this.openType,
      courseNature: courseNature ?? this.courseNature,
    );
  }
}

/// 全校课表搜索结果中的「课程头」：某课程（按 term_course_id 分组）在某学期的聚合。
/// teaching_class_count / teacher_summary / weekday_summary 均由查询时从 offerings 聚合得到。
class SchoolCourseHead {
  const SchoolCourseHead({
    required this.id,
    required this.termKey,
    required this.courseId,
    required this.courseNo,
    required this.courseName,
    required this.openCollege,
    required this.credits,
    required this.courseNature,
    required this.courseCategory,
    required this.openType,
    required this.teachingClassCount,
    required this.teacherSummary,
    required this.weekdaySummary,
  });

  final String id;
  final String termKey;
  final String courseId;
  final String courseNo;
  final String courseName;
  final String openCollege;
  final double? credits;
  final String courseNature;
  final String courseCategory;
  final String openType;
  final int teachingClassCount;
  final String teacherSummary;
  final String weekdaySummary;
}

class SchoolTeachingClass {
  const SchoolTeachingClass({
    required this.id,
    required this.termKey,
    required this.sourceKey,
    required this.termCourseId,
    required this.courseId,
    required this.teachingClassName,
    required this.courseNo,
    required this.courseName,
    required this.openCollege,
    required this.planCollege,
    required this.credits,
    required this.courseNature,
    required this.courseCategory,
    required this.openType,
    required this.grade,
    required this.major,
    required this.instructor,
    required this.title,
    required this.capacity,
    required this.selectedCount,
    required this.peopleRaw,
    required this.theoryHours,
    required this.computerHours,
    required this.experimentHours,
    required this.practiceHours,
    required this.remark,
    required this.note,
    required this.otherTeachers,
    required this.textbook,
    required this.publisher,
    required this.scheduleSummary,
    required this.weekdaySummary,
  });

  final String id;
  final String termKey;
  final String sourceKey;
  final String termCourseId;
  final String courseId;
  final String teachingClassName;
  final String courseNo;
  final String courseName;
  final String openCollege;
  final String planCollege;
  final double? credits;
  final String courseNature;
  final String courseCategory;
  final String openType;
  final String grade;
  final String major;

  /// 主讲教师名（由 offering_teacher→teacher 聚合得到）。
  final String instructor;

  /// 主讲教师职称。
  final String title;
  final int? capacity;
  final int? selectedCount;
  final String peopleRaw;
  final int? theoryHours;
  final int? computerHours;
  final int? experimentHours;
  final int? practiceHours;
  final String remark;
  final String note;
  final String otherTeachers;
  final String textbook;
  final String publisher;

  /// 排课摘要，由查询时从 meetings 拼接。
  final String scheduleSummary;

  /// 上课星期摘要，由查询时从 meetings 聚合。
  final String weekdaySummary;
}

class SchoolClassMeeting {
  const SchoolClassMeeting({
    required this.id,
    required this.offeringId,
    required this.weekday,
    required this.weekdayLabel,
    required this.rawText,
    required this.weekText,
    required this.sectionText,
    required this.locationText,
    required this.weekIndexes,
  });

  final String id;
  final String offeringId;
  final int weekday;
  final String weekdayLabel;
  final String rawText;
  final String weekText;
  final String sectionText;
  final String locationText;
  final List<int> weekIndexes;
}

class PersonalCourseMatchQuery {
  const PersonalCourseMatchQuery({
    required this.termKey,
    required this.courseNo,
    required this.courseName,
    required this.teachingClassName,
    required this.instructor,
    required this.weekday,
    required this.sectionText,
    required this.locationText,
    required this.date,
  });

  final String termKey;
  final String courseNo;
  final String courseName;
  final String teachingClassName;
  final String instructor;
  final int weekday;
  final String sectionText;
  final String locationText;
  final DateTime date;
}

class CourseEntityLink {
  const CourseEntityLink({
    this.termCourseId = '',
    this.offeringId = '',
    this.teacherId = '',
    this.occurrenceId = '',
  });

  final String termCourseId;
  final String offeringId;
  final String teacherId;
  final String occurrenceId;

  bool get hasCourse => termCourseId.isNotEmpty;
  bool get hasOffering => offeringId.isNotEmpty;
  bool get hasOccurrence => occurrenceId.isNotEmpty;
}
