import 'package:huajuan_agenda/shared/domain/entities/course_timetable.dart';

class CourseTimetableStorageMapper {
  const CourseTimetableStorageMapper._();

  static Map<String, dynamic> toJson(CourseTimetable timetable) {
    return {
      'id': timetable.id,
      'name': timetable.name,
      'source': timetable.source.name,
      'termLabel': timetable.termLabel,
      'createdAt': timetable.createdAt.toIso8601String(),
      'updatedAt': timetable.updatedAt?.toIso8601String(),
    };
  }

  static CourseTimetable? fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '');
    if (id == null || id.isEmpty || name == null || name.isEmpty || createdAt == null) {
      return null;
    }
    return CourseTimetable(
      id: id,
      name: name,
      source: _enumByName(
            CourseTimetableSource.values,
            json['source'] as String?,
          ) ??
          CourseTimetableSource.manual,
      termLabel: json['termLabel'] as String? ?? '',
      createdAt: createdAt,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}
