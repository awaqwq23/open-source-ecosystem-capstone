import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/data/sports_reservation_data.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';
import 'package:luotopia/features/whu_auth/domain/exceptions/whu_auth_exception.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';

typedef SportsReservationServiceFactory =
    SportsReservationService Function(SportsReservationSession session);

final sportsReservationAuthServiceProvider =
    Provider<SportsReservationAuthService>((ref) {
      return SportsReservationAuthService(
        gateway: ref.watch(whuAuthGatewayProvider),
      );
    });

final sportsReservationServiceFactoryProvider =
    Provider<SportsReservationServiceFactory>((ref) {
      return (session) => SportsReservationService(session: session);
    });

final sportsReservationViewModelProvider =
    NotifierProvider<SportsReservationViewModel, SportsReservationState>(
      SportsReservationViewModel.new,
    );

class SportsReservationViewModel extends Notifier<SportsReservationState> {
  SportsReservationSession? _session;
  SportsReservationService? _service;
  var _disposeRegistered = false;
  var _operationSerial = 0;

  @override
  SportsReservationState build() {
    _operationSerial += 1;
    if (!_disposeRegistered) {
      ref.onDispose(_disposeService);
      _disposeRegistered = true;
    }

    final initial = SportsReservationState.initial(_dateOnly(DateTime.now()));
    final whuAuth = ref.watch(whuAuthProvider);
    if (!whuAuth.isAuthenticated) {
      _disposeService();
      return initial.copyWith(
        status: SportsReservationViewStatus.unauthenticated,
      );
    }
    return initial;
  }

  bool get hasGymSession => _session != null && _service != null;

  SportsReservationWebSession? webSessionFor({Uri? launchUri}) {
    final session = _session;
    if (session == null) {
      return null;
    }
    return SportsReservationWebSession.fromSession(
      session,
      launchUri: launchUri,
    );
  }

  void useSession(SportsReservationSession session) {
    _disposeService();
    _session = session;
    _service = ref.read(sportsReservationServiceFactoryProvider)(session);
    state = state.copyWith(clearError: true, clearSubmitError: true);
  }

  void clearGymSession() {
    _disposeService();
  }

  Future<void> loadInitial({bool forceSession = false}) async {
    final operation = _nextOperation();
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }

    // 缓存优先：若有持久缓存则立即展示筛选器
    final cache = ref.read(sportsReservationCacheProvider);
    final cachedTypes = cache.readSportsTypes();
    final cachedVenues = cache.readVenues();
    final hasCachedData =
        cachedTypes != null &&
        cachedTypes.isNotEmpty &&
        cachedVenues != null &&
        cachedVenues.isNotEmpty;

    if (hasCachedData) {
      final selectedProject = _selectProjectFrom(
        cachedTypes,
        state.selectedProject,
      );
      final selectedVenue = _selectVenueFrom(cachedVenues, state.selectedVenue);
      state = state.copyWith(
        status: SportsReservationViewStatus.refreshing,
        projects: cachedTypes,
        venues: cachedVenues,
        selectedProject: selectedProject,
        selectedVenue: selectedVenue,
        clearSelectedProject: selectedProject == null,
        clearSelectedVenue: selectedVenue == null,
        clearError: true,
        clearSubmitError: true,
      );
    } else {
      state = state.copyWith(
        status: SportsReservationViewStatus.loading,
        availability: const [],
        areaAvailability: const [],
        clearSelectedAvailability: true,
        clearSelectedWindow: true,
        clearError: true,
        clearSubmitError: true,
      );
    }

    try {
      final service = await _ensureService(force: forceSession);
      final results = await Future.wait<Object>([
        service.fetchSportsTypes(),
        service.fetchVenues(),
      ]);
      if (!_isCurrentOperation(operation)) {
        return;
      }

      final projects = results[0] as List<SportsProject>;
      final venues = results[1] as List<SportsVenue>;

      // 网络成功后写缓存（不等待）
      unawaited(cache.writeSportsTypes(projects));
      unawaited(cache.writeVenues(venues));

      final selectedProject = _selectProjectFrom(
        projects,
        state.selectedProject,
      );
      final selectedVenue = _selectVenueFrom(venues, state.selectedVenue);

      final List<Object> dataResults;
      if (selectedProject == null) {
        final results = await Future.wait<Object>([
          service.fetchRecentlyStartReservations(),
          service.fetchOrderList().then((r) => r.items),
        ]);
        dataResults = [
          const <SportsVenueAvailability>[],
          results[0],
          results[1],
        ];
      } else {
        dataResults = await Future.wait<Object>([
          service.fetchAppointmentList(
            SportsReservationQuery(
              sportsTypeId: selectedProject.id,
              appointmentDate: state.selectedDate,
              venueId: selectedVenue?.id,
            ),
          ),
          service.fetchRecentlyStartReservations(),
          service.fetchOrderList().then((r) => r.items),
        ]);
      }
      final appointmentList = selectedProject == null
          ? null
          : dataResults[0] as SportsAppointmentListResult;
      final availability = appointmentList?.items ?? const [];
      final reservations = dataResults[1] as List<SportsReservation>;
      final orders = dataResults[2] as List<SportsReservation>;
      if (!_isCurrentOperation(operation)) {
        return;
      }

      state = state.copyWith(
        status: availability.isEmpty
            ? SportsReservationViewStatus.empty
            : SportsReservationViewStatus.ready,
        projects: projects,
        venues: venues,
        availability: availability,
        reservations: reservations,
        orders: orders,
        advanceAppointmentDayCount: appointmentList?.advanceAppointmentDayCount,
        advanceAppointmentStartTime:
            appointmentList?.advanceAppointmentStartTime,
        areaAvailability: const [],
        selectedProject: selectedProject,
        selectedVenue: selectedVenue,
        clearSelectedProject: selectedProject == null,
        clearSelectedVenue: selectedVenue == null,
        clearSelectedAvailability: true,
        clearSelectedWindow: true,
        clearError: true,
        clearSubmitError: true,
      );
    } catch (error) {
      if (!_isCurrentOperation(operation)) {
        return;
      }
      _handleLoadError(error);
    }
  }

  Future<void> refreshAvailability({bool forceSession = false}) async {
    final operation = _nextOperation();
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }

    final selectedProject = state.selectedProject;
    if (selectedProject == null) {
      await loadInitial(forceSession: forceSession);
      return;
    }

    state = state.copyWith(
      status: state.availability.isEmpty
          ? SportsReservationViewStatus.loading
          : SportsReservationViewStatus.refreshing,
      areaAvailability: const [],
      clearSelectedAvailability: true,
      clearSelectedWindow: true,
      clearError: true,
      clearSubmitError: true,
    );

    try {
      final service = await _ensureService(force: forceSession);
      final results = await Future.wait<Object>([
        service.fetchAppointmentList(
          SportsReservationQuery(
            sportsTypeId: selectedProject.id,
            appointmentDate: state.selectedDate,
            venueId: state.selectedVenue?.id,
          ),
        ),
        service.fetchRecentlyStartReservations(),
        service.fetchOrderList(),
      ]);
      final result = results[0] as SportsAppointmentListResult;
      final reservations = results[1] as List<SportsReservation>;
      final orders = (results[2] as SportsReservationOrderListResult).items;
      if (!_isCurrentOperation(operation)) {
        return;
      }
      state = state.copyWith(
        status: result.items.isEmpty
            ? SportsReservationViewStatus.empty
            : SportsReservationViewStatus.ready,
        availability: result.items,
        reservations: reservations,
        orders: orders,
        advanceAppointmentDayCount: result.advanceAppointmentDayCount,
        advanceAppointmentStartTime: result.advanceAppointmentStartTime,
        areaAvailability: const [],
        clearSelectedAvailability: true,
        clearSelectedWindow: true,
        clearError: true,
      );
    } catch (error) {
      if (!_isCurrentOperation(operation)) {
        return;
      }
      _handleLoadError(error);
    }
  }

  Future<void> selectProject(SportsProject project) async {
    state = state.copyWith(
      selectedProject: project,
      availability: const [],
      areaAvailability: const [],
      clearSelectedAvailability: true,
      clearSelectedWindow: true,
      clearError: true,
      clearSubmitError: true,
    );
    await refreshAvailability();
  }

  Future<void> selectVenue(SportsVenue? venue) async {
    state = state.copyWith(
      selectedVenue: venue,
      availability: const [],
      areaAvailability: const [],
      clearSelectedVenue: venue == null,
      clearSelectedAvailability: true,
      clearSelectedWindow: true,
      clearError: true,
      clearSubmitError: true,
    );
    await refreshAvailability();
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: _clampReservableDate(date),
      availability: const [],
      areaAvailability: const [],
      clearSelectedAvailability: true,
      clearSelectedWindow: true,
      clearError: true,
      clearSubmitError: true,
    );
    await refreshAvailability();
  }

  Future<void> loadAreaAvailability({
    required SportsVenueAvailability availability,
    required SportsAppointmentWindow window,
  }) async {
    final operation = _nextOperation();
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }

    state = state.copyWith(
      status: SportsReservationViewStatus.refreshing,
      selectedAvailability: availability,
      selectedWindow: window,
      areaAvailability: const [],
      clearError: true,
      clearSubmitError: true,
    );

    try {
      final service = await _ensureService();
      final areas = await service.fetchAppointmentAreaList(
        stadiumsAreaId: availability.stadiumsAreaId,
        appointmentDate: state.selectedDate,
      );
      if (!_isCurrentOperation(operation)) {
        return;
      }
      state = state.copyWith(
        status: SportsReservationViewStatus.ready,
        areaAvailability: areas,
        selectedAvailability: availability,
        selectedWindow: window,
        clearError: true,
      );
    } catch (error) {
      if (!_isCurrentOperation(operation)) {
        return;
      }
      _handleLoadError(error);
    }
  }

  Future<void> loadRecentlyStartReservations() async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }
    try {
      final service = await _ensureService();
      final reservations = await service.fetchRecentlyStartReservations();
      state = state.copyWith(reservations: reservations, clearError: true);
    } catch (error) {
      _handleLoadError(error);
    }
  }

  Future<void> loadOrders({bool forceSession = false}) async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }
    try {
      final service = await _ensureService(force: forceSession);
      final result = await service.fetchOrderList();
      state = state.copyWith(orders: result.items, clearOrderError: true);
    } catch (error) {
      state = state.copyWith(orderErrorMessage: error.toString());
      _handleLoadError(error);
    }
  }

  Future<SportsReservation?> loadOrderDetail(String orderNo) async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return null;
    }
    state = state.copyWith(clearOrderError: true);
    try {
      final service = await _ensureService();
      final detail = await service.fetchOrderDetail(orderNo);
      state = state.copyWith(selectedOrderDetail: detail);
      return detail;
    } catch (error) {
      state = state.copyWith(orderErrorMessage: error.toString());
      _handleLoadError(error);
      return null;
    }
  }

  Future<bool> cancelOrder(String orderNo) {
    return _runOrderAction(
      orderNo: orderNo,
      action: (service) => service.cancelOrder(orderNo),
    );
  }

  Future<bool> applyRefund(String orderNo) {
    return _runOrderAction(
      orderNo: orderNo,
      action: (service) => service.applyRefund(orderNo),
    );
  }

  Future<bool> deleteOrder(String orderNo) {
    return _runOrderAction(
      orderNo: orderNo,
      action: (service) => service.deleteOrder(orderNo),
    );
  }

  Future<void> loadAppointmentRules() async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }
    try {
      final service = await _ensureService();
      final rules = await service.fetchAppointmentRules();
      state = state.copyWith(appointmentRules: rules, clearError: true);
    } catch (error) {
      _handleLoadError(error);
    }
  }

  Future<void> checkBlacklist() async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }
    try {
      final service = await _ensureService();
      final blacklistStatus = await service.checkBlacklist();
      state = state.copyWith(
        blacklistStatus: blacklistStatus,
        clearError: true,
      );
    } catch (error) {
      _handleLoadError(error);
    }
  }

  Future<void> loadBulletins({int page = 1, int pageSize = 10}) async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return;
    }
    try {
      final service = await _ensureService();
      final result = await service.fetchBulletins(
        page: page,
        pageSize: pageSize,
      );
      state = state.copyWith(bulletins: result.items, clearError: true);
    } catch (error) {
      _handleLoadError(error);
    }
  }

  void clearAreaSelection() {
    state = state.copyWith(
      areaAvailability: const [],
      clearSelectedAvailability: true,
      clearSelectedWindow: true,
      clearSubmitError: true,
    );
  }

  SportsCheckoutArgs? prepareCheckout(SportsAreaAvailability area) {
    final availability = state.selectedAvailability;
    final window = state.selectedWindow;
    if (availability == null || window == null) {
      state = state.copyWith(submitErrorMessage: '请先选择可预约的场馆和时段。');
      return null;
    }

    final args = SportsCheckoutArgs(
      appointmentDate: state.selectedDate,
      availability: availability,
      area: area,
      window: window,
    );
    if (!args.canStartCheckout) {
      state = state.copyWith(submitErrorMessage: '当前场地或时段不可预约，请重新选择。');
      return null;
    }

    state = state.copyWith(
      pendingCheckout: args,
      clearLastCheckoutResult: true,
      clearSubmitError: true,
    );
    return args;
  }

  Future<void> handleCheckoutResult(SportsCheckoutResult result) async {
    state = state.copyWith(
      lastCheckoutResult: result,
      clearPendingCheckout: true,
      submitErrorMessage: result.outcome == SportsCheckoutOutcome.failed
          ? result.message
          : null,
      clearSubmitError: result.outcome != SportsCheckoutOutcome.failed,
    );

    if (result.shouldReauthorize) {
      _disposeService();
      state = state.copyWith(
        status: SportsReservationViewStatus.authorizationExpired,
        errorMessage: result.message.isEmpty ? '运动场馆系统登录已失效。' : result.message,
      );
      return;
    }

    if (result.shouldRefreshAvailability) {
      await refreshAvailability();
    }
  }

  Future<bool> _runOrderAction({
    required String orderNo,
    required Future<void> Function(SportsReservationService service) action,
  }) async {
    if (!_isWhuAuthenticated()) {
      _markUnauthenticated();
      return false;
    }
    state = state.copyWith(
      status: SportsReservationViewStatus.submitting,
      orderActionOrderNo: orderNo,
      clearOrderError: true,
      clearSubmitError: true,
    );

    final SportsReservationService service;
    try {
      service = await _ensureService();
      await action(service);
    } catch (error) {
      state = state.copyWith(
        status: SportsReservationViewStatus.submitFailed,
        orderErrorMessage: error.toString(),
        submitErrorMessage: error.toString(),
        clearOrderAction: true,
      );
      return false;
    }

    // The action has already committed on the server. A failure while
    // refreshing the local state must not be reported as an action failure,
    // otherwise the user may retry an operation that already succeeded.
    try {
      await _refreshRemoteState(service);
    } catch (error) {
      _handleLoadError(error);
    } finally {
      state = state.copyWith(clearOrderAction: true);
    }
    return true;
  }

  Future<void> _refreshRemoteState(SportsReservationService service) async {
    final selectedProject = state.selectedProject;
    final results = await Future.wait<Object>([
      if (selectedProject != null)
        service.fetchAppointmentList(
          SportsReservationQuery(
            sportsTypeId: selectedProject.id,
            appointmentDate: state.selectedDate,
            venueId: state.selectedVenue?.id,
          ),
        ),
      service.fetchRecentlyStartReservations(),
      service.fetchOrderList(),
    ]);
    var index = 0;
    final appointmentList = selectedProject == null
        ? null
        : results[index++] as SportsAppointmentListResult;
    final reservations = results[index++] as List<SportsReservation>;
    final orders = (results[index] as SportsReservationOrderListResult).items;
    state = state.copyWith(
      status: appointmentList == null
          ? SportsReservationViewStatus.ready
          : appointmentList.items.isEmpty
          ? SportsReservationViewStatus.empty
          : SportsReservationViewStatus.ready,
      availability: appointmentList?.items,
      reservations: reservations,
      orders: orders,
      advanceAppointmentDayCount: appointmentList?.advanceAppointmentDayCount,
      advanceAppointmentStartTime: appointmentList?.advanceAppointmentStartTime,
      clearOrderError: true,
      clearSubmitError: true,
    );
  }

  Future<SportsReservationService> _ensureService({bool force = false}) async {
    if (force) {
      _disposeService();
    }
    final existing = _service;
    if (existing != null) {
      return existing;
    }
    throw const SportsReservationAuthException('请先授权运动场馆系统。');
  }

  void _handleLoadError(Object error) {
    final status = _statusForError(error);
    if (status == SportsReservationViewStatus.unauthenticated) {
      _disposeService();
    }
    if (status == SportsReservationViewStatus.authorizationExpired) {
      _disposeService();
    }
    state = state.copyWith(status: status, errorMessage: error.toString());
  }

  SportsReservationViewStatus _statusForError(Object error) {
    if (error is WhuAuthException) {
      return error.code == WhuAuthExceptionCode.loginRequired
          ? SportsReservationViewStatus.unauthenticated
          : SportsReservationViewStatus.authorizationExpired;
    }
    if (error is SportsReservationAuthException) {
      return SportsReservationViewStatus.authorizationExpired;
    }
    if (error is SportsReservationApiException &&
        (error.statusCode == 401 || error.statusCode == 403)) {
      return SportsReservationViewStatus.authorizationExpired;
    }
    return SportsReservationViewStatus.refreshFailed;
  }

  SportsProject? _selectProjectFrom(
    List<SportsProject> projects,
    SportsProject? preferred,
  ) {
    if (projects.isEmpty) {
      return null;
    }
    final preferredId = preferred?.id;
    if (preferredId != null) {
      for (final project in projects) {
        if (project.id == preferredId) {
          return project;
        }
      }
    }
    return projects.first;
  }

  SportsVenue? _selectVenueFrom(
    List<SportsVenue> venues,
    SportsVenue? preferred,
  ) {
    final preferredId = preferred?.id;
    if (preferredId == null) {
      return null;
    }
    for (final venue in venues) {
      if (venue.id == preferredId) {
        return venue;
      }
    }
    return null;
  }

  bool _isWhuAuthenticated() => ref.read(whuAuthProvider).isAuthenticated;

  void _markUnauthenticated() {
    _disposeService();
    state = state.copyWith(
      status: SportsReservationViewStatus.unauthenticated,
      errorMessage: '请先登录武大统一认证。',
    );
  }

  int _nextOperation() {
    _operationSerial += 1;
    return _operationSerial;
  }

  bool _isCurrentOperation(int operation) => operation == _operationSerial;

  void _disposeService() {
    _service?.close();
    _service = null;
    _session = null;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _clampReservableDate(DateTime date) {
    final target = _dateOnly(date);
    final today = _dateOnly(DateTime.now());
    final maxDate = _maxReservableDate(today);
    if (target.isBefore(today)) {
      return today;
    }
    if (target.isAfter(maxDate)) {
      return maxDate;
    }
    return target;
  }

  DateTime _maxReservableDate(DateTime today) {
    final dayCount = state.advanceAppointmentDayCount;
    if (dayCount <= 0) {
      return today;
    }
    final hasReachedStartTime = _hasReachedAdvanceStartTime(DateTime.now());
    final offset = hasReachedStartTime ? dayCount : dayCount - 1;
    return today.add(Duration(days: offset < 0 ? 0 : offset));
  }

  bool _hasReachedAdvanceStartTime(DateTime now) {
    final start = _parseClockTime(state.advanceAppointmentStartTime);
    if (start == null) {
      return true;
    }
    return now.hour > start.$1 ||
        now.hour == start.$1 && now.minute >= start.$2;
  }

  (int, int)? _parseClockTime(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) {
      return null;
    }
    final hour = int.tryParse(digits.substring(0, 2));
    final minute = int.tryParse(digits.substring(2, 4));
    if (hour == null || minute == null) {
      return null;
    }
    return (hour, minute);
  }
}
