import 'models/sports_appointment_window.dart';
import 'models/sports_area_availability.dart';
import 'models/sports_blacklist_status.dart';
import 'models/sports_bulletin.dart';
import 'models/sports_checkout_args.dart';
import 'models/sports_checkout_result.dart';
import 'models/sports_project.dart';
import 'models/sports_reservation.dart';
import 'models/sports_venue.dart';
import 'models/sports_venue_availability.dart';

enum SportsReservationViewStatus {
  initial,
  unauthenticated,
  loading,
  refreshing,
  ready,
  empty,
  submitting,
  submitFailed,
  refreshFailed,
  authorizationExpired,
}

class SportsReservationState {
  const SportsReservationState({
    required this.selectedDate,
    this.status = SportsReservationViewStatus.initial,
    this.projects = const [],
    this.venues = const [],
    this.availability = const [],
    this.areaAvailability = const [],
    this.reservations = const [],
    this.orders = const [],
    this.bulletins = const [],
    this.appointmentRules = '',
    this.blacklistStatus,
    this.selectedProject,
    this.selectedVenue,
    this.selectedAvailability,
    this.selectedWindow,
    this.pendingCheckout,
    this.lastCheckoutResult,
    this.selectedOrderDetail,
    this.orderActionOrderNo,
    this.orderErrorMessage,
    this.errorMessage,
    this.submitErrorMessage,
  });

  factory SportsReservationState.initial(DateTime selectedDate) {
    return SportsReservationState(
      selectedDate: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      ),
    );
  }

  final SportsReservationViewStatus status;
  final List<SportsProject> projects;
  final List<SportsVenue> venues;
  final List<SportsVenueAvailability> availability;
  final List<SportsAreaAvailability> areaAvailability;
  final List<SportsReservation> reservations;
  final List<SportsReservation> orders;
  final List<SportsBulletin> bulletins;
  final String appointmentRules;
  final SportsBlacklistStatus? blacklistStatus;
  final SportsProject? selectedProject;
  final SportsVenue? selectedVenue;
  final DateTime selectedDate;
  final SportsVenueAvailability? selectedAvailability;
  final SportsAppointmentWindow? selectedWindow;
  final SportsCheckoutArgs? pendingCheckout;
  final SportsCheckoutResult? lastCheckoutResult;
  final SportsReservation? selectedOrderDetail;
  final String? orderActionOrderNo;
  final String? orderErrorMessage;
  final String? errorMessage;
  final String? submitErrorMessage;

  bool get isBusy =>
      status == SportsReservationViewStatus.loading ||
      status == SportsReservationViewStatus.refreshing ||
      status == SportsReservationViewStatus.submitting;

  bool get isSubmitting => status == SportsReservationViewStatus.submitting;

  bool get isAuthenticated =>
      status != SportsReservationViewStatus.unauthenticated &&
      status != SportsReservationViewStatus.authorizationExpired;

  bool get hasAvailability =>
      availability.any((item) => item.hasReservableWindow);

  SportsReservationState copyWith({
    SportsReservationViewStatus? status,
    List<SportsProject>? projects,
    List<SportsVenue>? venues,
    List<SportsVenueAvailability>? availability,
    List<SportsAreaAvailability>? areaAvailability,
    List<SportsReservation>? reservations,
    List<SportsReservation>? orders,
    List<SportsBulletin>? bulletins,
    String? appointmentRules,
    SportsBlacklistStatus? blacklistStatus,
    SportsProject? selectedProject,
    SportsVenue? selectedVenue,
    DateTime? selectedDate,
    SportsVenueAvailability? selectedAvailability,
    SportsAppointmentWindow? selectedWindow,
    SportsCheckoutArgs? pendingCheckout,
    SportsCheckoutResult? lastCheckoutResult,
    SportsReservation? selectedOrderDetail,
    String? orderActionOrderNo,
    String? orderErrorMessage,
    String? errorMessage,
    String? submitErrorMessage,
    bool clearSelectedProject = false,
    bool clearSelectedVenue = false,
    bool clearSelectedAvailability = false,
    bool clearSelectedWindow = false,
    bool clearPendingCheckout = false,
    bool clearLastCheckoutResult = false,
    bool clearSelectedOrderDetail = false,
    bool clearOrderAction = false,
    bool clearOrderError = false,
    bool clearBlacklistStatus = false,
    bool clearError = false,
    bool clearSubmitError = false,
  }) {
    return SportsReservationState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      venues: venues ?? this.venues,
      availability: availability ?? this.availability,
      areaAvailability: areaAvailability ?? this.areaAvailability,
      reservations: reservations ?? this.reservations,
      orders: orders ?? this.orders,
      bulletins: bulletins ?? this.bulletins,
      appointmentRules: appointmentRules ?? this.appointmentRules,
      blacklistStatus: clearBlacklistStatus
          ? null
          : blacklistStatus ?? this.blacklistStatus,
      selectedProject: clearSelectedProject
          ? null
          : selectedProject ?? this.selectedProject,
      selectedVenue: clearSelectedVenue
          ? null
          : selectedVenue ?? this.selectedVenue,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedAvailability: clearSelectedAvailability
          ? null
          : selectedAvailability ?? this.selectedAvailability,
      selectedWindow: clearSelectedWindow
          ? null
          : selectedWindow ?? this.selectedWindow,
      pendingCheckout: clearPendingCheckout
          ? null
          : pendingCheckout ?? this.pendingCheckout,
      lastCheckoutResult: clearLastCheckoutResult
          ? null
          : lastCheckoutResult ?? this.lastCheckoutResult,
      selectedOrderDetail: clearSelectedOrderDetail
          ? null
          : selectedOrderDetail ?? this.selectedOrderDetail,
      orderActionOrderNo: clearOrderAction
          ? null
          : orderActionOrderNo ?? this.orderActionOrderNo,
      orderErrorMessage: clearOrderError
          ? null
          : orderErrorMessage ?? this.orderErrorMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      submitErrorMessage: clearSubmitError
          ? null
          : submitErrorMessage ?? this.submitErrorMessage,
    );
  }
}
