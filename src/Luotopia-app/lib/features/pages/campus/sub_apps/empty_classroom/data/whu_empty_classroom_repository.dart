import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/data/empty_classroom_filters_cache.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/data/whu_empty_room_service.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository.dart';
import 'package:luotopia/features/whu_auth/domain/repositories/whu_auth_gateway.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

class WhuEmptyClassroomRepository implements EmptyClassroomRepository {
  WhuEmptyClassroomRepository({
    required this.authGateway,
    required this.filtersCache,
  });

  final WhuAuthGateway authGateway;
  final EmptyClassroomFiltersCache filtersCache;
  EmptyClassroomFilters? _cachedFilters;

  @override
  EmptyClassroomFilters? getCachedFilters() {
    final mem = _cachedFilters;
    if (mem != null) {
      return mem;
    }
    final persisted = filtersCache.read();
    if (persisted != null) {
      _cachedFilters = persisted;
    }
    return persisted;
  }

  @override
  Future<EmptyClassroomFilters> loadFilters() async {
    final filters = await _fetchFiltersFromNetwork();
    _cachedFilters = filters;
    await filtersCache.write(filters);
    return filters;
  }

  Future<EmptyClassroomFilters> _fetchFiltersFromNetwork() async {
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
      return EmptyClassroomFilters(
        termInfo: results[0] as TermInfo,
        campuses: results[1] as List<CampusBuilding>,
      );
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
      return await service.getEmptyRoom(
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
    filtersCache: ref.read(emptyClassroomFiltersCacheProvider),
  );
});
