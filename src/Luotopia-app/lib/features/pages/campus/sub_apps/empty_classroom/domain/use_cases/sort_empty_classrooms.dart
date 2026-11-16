import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';

class SortEmptyClassroomsUseCase {
  const SortEmptyClassroomsUseCase();

  List<EmptyClassroom> call(List<EmptyClassroom> classrooms) {
    return [...classrooms]..sort(_compare);
  }

  int _compare(EmptyClassroom left, EmptyClassroom right) {
    final buildingOrder = left.building.compareTo(right.building);
    if (buildingOrder != 0) {
      return buildingOrder;
    }

    final floorOrder = _floorNumber(
      left.floor,
    ).compareTo(_floorNumber(right.floor));
    if (floorOrder != 0) {
      return floorOrder;
    }

    final nameOrder = left.name.compareTo(right.name);
    if (nameOrder != 0) {
      return nameOrder;
    }

    return right.availableSeats.compareTo(left.availableSeats);
  }

  int _floorNumber(String floor) {
    return int.tryParse(floor) ?? 0;
  }
}
