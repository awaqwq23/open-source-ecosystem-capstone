import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final appIdGeneratorProvider = Provider<AppIdGenerator>((ref) {
  return const AppIdGenerator();
});

class AppIdGenerator {
  const AppIdGenerator();

  static const _uuid = Uuid();

  String newAgendaItemId() {
    return 'item_${_uuid.v4()}';
  }

  String newCourseTimetableId() {
    return 'timetable_${_uuid.v4()}';
  }
}
