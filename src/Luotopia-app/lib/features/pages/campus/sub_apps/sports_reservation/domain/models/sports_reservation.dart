enum SportsReservationStatus {
  unknown,
  pendingPayment,
  reserved,
  cancelled,
  completed,
  refunded,
}

enum SportsReservationPaymentStatus { unknown, unpaid, paid, refunded }

class SportsReservation {
  const SportsReservation({
    required this.id,
    required this.venueTitle,
    required this.sportsTypeTitle,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.paymentStatus,
    this.venueId,
    this.stadiumsAreaId,
    this.areaNo,
    this.createdAt,
    this.paymentStartTime,
    this.paymentDeadlineTime,
    this.paymentTime,
    this.refundDeadlineTime,
    this.cancelTime,
    this.refundTime,
    this.amount,
    this.totalAmount,
    this.discountAmount,
    this.refundAmount,
    this.realName = '',
    this.studentWorkNo = '',
    this.cancelRemark = '',
    this.rawStatus = '',
  });

  final String id;
  final int? venueId;
  final int? stadiumsAreaId;
  final int? areaNo;
  final String venueTitle;
  final String sportsTypeTitle;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final SportsReservationStatus status;
  final SportsReservationPaymentStatus paymentStatus;
  final DateTime? createdAt;
  final DateTime? paymentStartTime;
  final DateTime? paymentDeadlineTime;
  final DateTime? paymentTime;
  final DateTime? refundDeadlineTime;
  final DateTime? cancelTime;
  final DateTime? refundTime;
  final double? amount;
  final double? totalAmount;
  final double? discountAmount;
  final double? refundAmount;
  final String realName;
  final String studentWorkNo;
  final String cancelRemark;
  final String rawStatus;

  bool get canCancel =>
      status == SportsReservationStatus.pendingPayment ||
      status == SportsReservationStatus.reserved;

  bool get canPay =>
      status == SportsReservationStatus.pendingPayment &&
      (paymentDeadlineTime == null ||
          paymentDeadlineTime!.isAfter(DateTime.now()));

  bool get canApplyRefund =>
      status == SportsReservationStatus.reserved &&
      amount != null &&
      amount! > 0 &&
      refundDeadlineTime != null &&
      refundDeadlineTime!.isAfter(DateTime.now());

  bool get canDelete =>
      status == SportsReservationStatus.cancelled ||
      status == SportsReservationStatus.completed ||
      status == SportsReservationStatus.refunded;
}
