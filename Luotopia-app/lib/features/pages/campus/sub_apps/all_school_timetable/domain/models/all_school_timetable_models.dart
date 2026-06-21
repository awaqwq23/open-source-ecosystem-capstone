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

enum AllSchoolTimetableQueryMode { lightweight, professional }

class AllSchoolTimetableQuery {
  const AllSchoolTimetableQuery({
    this.termKey,
    this.keyword = '',
    this.mode = AllSchoolTimetableQueryMode.lightweight,
    this.openCollege = '',
    this.grade = '',
    this.major = '',
    this.weekday,
    this.building = '',
  });

  final String? termKey;
  final String keyword;
  final AllSchoolTimetableQueryMode mode;
  final String openCollege;
  final String grade;
  final String major;
  final int? weekday;
  final String building;

  bool get hasProfessionalFilters {
    return openCollege.isNotEmpty ||
        grade.isNotEmpty ||
        major.isNotEmpty ||
        weekday != null ||
        building.isNotEmpty;
  }

  AllSchoolTimetableQuery copyWith({
    String? termKey,
    String? keyword,
    AllSchoolTimetableQueryMode? mode,
    String? openCollege,
    String? grade,
    String? major,
    int? weekday,
    String? building,
    bool clearWeekday = false,
  }) {
    return AllSchoolTimetableQuery(
      termKey: termKey ?? this.termKey,
      keyword: keyword ?? this.keyword,
      mode: mode ?? this.mode,
      openCollege: openCollege ?? this.openCollege,
      grade: grade ?? this.grade,
      major: major ?? this.major,
      weekday: clearWeekday ? null : weekday ?? this.weekday,
      building: building ?? this.building,
    );
  }
}

class SchoolCourseHead {
  const SchoolCourseHead({
    required this.id,
    required this.termKey,
    required this.catalogId,
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
  final String catalogId;
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
    required this.catalogId,
    required this.instructorCourseId,
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
    required this.otherTeachers,
    required this.textbook,
    required this.publisher,
    required this.scheduleSummary,
    required this.weekdaySummary,
    required this.originalFields,
  });

  final String id;
  final String termKey;
  final String sourceKey;
  final String termCourseId;
  final String catalogId;
  final String instructorCourseId;
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
  final String instructor;
  final String title;
  final int? capacity;
  final int? selectedCount;
  final String peopleRaw;
  final int? theoryHours;
  final int? computerHours;
  final int? experimentHours;
  final int? practiceHours;
  final String remark;
  final String otherTeachers;
  final String textbook;
  final String publisher;
  final String scheduleSummary;
  final String weekdaySummary;
  final Map<String, String> originalFields;
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
    required this.building,
    required this.room,
  });

  final String id;
  final String offeringId;
  final int weekday;
  final String weekdayLabel;
  final String rawText;
  final String weekText;
  final String sectionText;
  final String locationText;
  final String building;
  final String room;
}
