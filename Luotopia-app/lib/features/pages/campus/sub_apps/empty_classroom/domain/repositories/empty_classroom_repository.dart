import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';

class EmptyClassroomFilters {
  const EmptyClassroomFilters({required this.termInfo, required this.campuses});

  final TermInfo termInfo;
  final List<CampusBuilding> campuses;

  Map<String, dynamic> toJson() {
    return {
      'termInfo': termInfo.toJson(),
      'campuses': campuses.map((c) => c.toJson()).toList(),
    };
  }

  factory EmptyClassroomFilters.fromJson(Map<String, dynamic> json) {
    final rawCampuses = json['campuses'];
    return EmptyClassroomFilters(
      termInfo: TermInfo.fromJson(
        (json['termInfo'] as Map<String, dynamic>?) ?? {},
      ),
      campuses: rawCampuses is List
          ? rawCampuses
                .whereType<Map<String, dynamic>>()
                .map(CampusBuilding.fromJson)
                .toList()
          : const [],
    );
  }
}

class EmptyClassroomQuery {
  const EmptyClassroomQuery({
    required this.campus,
    required this.schoolYear,
    required this.term,
    required this.week,
    required this.weekDay,
    this.teachingBuilding,
  });

  final String campus;
  final String schoolYear;
  final String term;
  final String week;
  final String weekDay;
  final String? teachingBuilding;
}

abstract class EmptyClassroomRepository {
  EmptyClassroomFilters? getCachedFilters();
  Future<EmptyClassroomFilters> loadFilters();

  Future<List<EmptyClassroom>> queryRooms(EmptyClassroomQuery query);
}
