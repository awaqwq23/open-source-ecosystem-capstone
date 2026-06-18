import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/data/whu_empty_room_service.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository.dart';
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

class WhuEmptyClassroomRepository implements EmptyClassroomRepository {
  WhuEmptyClassroomRepository({required this.authGateway});

  final WhuAuthGateway authGateway;
  EmptyClassroomFilters? _cachedFilters;

  @override
  Future<EmptyClassroomFilters> loadFilters() async {
    final cached = _cachedFilters;
    if (cached != null) {
      return cached;
    }

    final client = await authGateway.authorizeService(
      WhuEmptyRoomService.smartCampusServiceRequest,
    );
    try {
      final service = WhuEmptyRoomService(client: client);
      await service.prepareSession();
      final results = await Future.wait([
        service.getTerm(),
        service.getFloor(),
      ]);
      final filters = EmptyClassroomFilters(
        termInfo: results[0] as TermInfo,
        campuses: results[1] as List<CampusBuilding>,
      );
      _cachedFilters = filters;
      return filters;
    } finally {
      client.close();
    }
  }

  @override
  Future<List<EmptyClassroom>> queryRooms(EmptyClassroomQuery query) async {
    final client = await authGateway.authorizeService(
      WhuEmptyRoomService.smartCampusServiceRequest,
    );
    try {
      final service = WhuEmptyRoomService(client: client);
      await service.prepareSession();
      return service.getEmptyRoom(
        campus: query.campus,
        schoolYear: query.schoolYear,
        term: query.term,
        week: query.week,
        weekDay: query.weekDay,
        teachingBuilding: query.teachingBuilding,
      );
    } finally {
      client.close();
    }
  }
}

final emptyClassroomRepositoryProvider = Provider<EmptyClassroomRepository>((
  ref,
) {
  return WhuEmptyClassroomRepository(
    authGateway: ref.read(whuAuthGatewayProvider),
  );
});
