class TermInfo {
  const TermInfo({
    required this.weekDay,
    required this.termCode,
    required this.schoolYear,
    required this.currentWeek,
    required this.maxWeek,
    required this.termName,
  });

  final String weekDay;
  final String termCode;
  final String schoolYear;
  final String currentWeek;
  final String maxWeek;
  final String termName;

  factory TermInfo.fromJson(Map<String, dynamic> json) {
    return TermInfo(
      weekDay: '${json['weekDay'] ?? ''}',
      termCode: json['xqm'] as String? ?? '',
      schoolYear: json['xnmc'] as String? ?? '',
      currentWeek: '${json['dqzc'] ?? ''}',
      maxWeek: '${json['zdzc'] ?? ''}',
      termName: '${json['xqmc'] ?? ''}',
    );
  }
}

class Building {
  const Building({
    required this.code,
    required this.name,
    required this.campus,
  });

  final String code;
  final String name;
  final String campus;

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      code: json['jxldm'] as String? ?? '',
      name: json['jxlmc'] as String? ?? '',
      campus: json['xqmc'] as String? ?? '',
    );
  }
}

class CampusBuilding {
  const CampusBuilding({required this.campus, required this.buildings});

  final String campus;
  final List<Building> buildings;

  factory CampusBuilding.fromJson(Map<String, dynamic> json) {
    final rawFloors = json['floors'];
    final buildings = rawFloors is List
        ? rawFloors
              .whereType<Map<String, dynamic>>()
              .map(Building.fromJson)
              .toList()
        : <Building>[];
    return CampusBuilding(
      campus: json['campus'] as String? ?? '',
      buildings: buildings,
    );
  }
}

class EmptyClassroom {
  const EmptyClassroom({
    required this.name,
    required this.building,
    required this.type,
    required this.totalSeats,
    required this.availableSeats,
    required this.availableSections,
    required this.floor,
  });

  final String name;
  final String building;
  final String type;
  final int totalSeats;
  final int availableSeats;
  final List<int> availableSections;
  final String floor;

  factory EmptyClassroom.fromJson(Map<String, dynamic> json) {
    final rawSections = json['jc'] as String? ?? '';
    final sections =
        rawSections.isEmpty
              ? <int>[]
              : rawSections
                    .split(',')
                    .map((value) => int.tryParse(value.trim()) ?? 0)
                    .where((value) => value > 0)
                    .toList()
          ..sort();
    return EmptyClassroom(
      name: json['cdmc'] as String? ?? '',
      building: json['jxl'] as String? ?? '',
      type: json['cdlb'] as String? ?? '',
      totalSeats: int.tryParse('${json['zws'] ?? ''}') ?? 0,
      availableSeats: int.tryParse('${json['kszws'] ?? ''}') ?? 0,
      availableSections: sections,
      floor: json['lh'] as String? ?? '',
    );
  }
}
