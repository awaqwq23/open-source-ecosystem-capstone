import 'sports_reservation.dart';

class SportsReservationOrderListResult {
  const SportsReservationOrderListResult({
    required this.items,
    this.page = 1,
    this.pageCount = 1,
    this.totalCount = 0,
    this.pageSize = 10,
  });

  final List<SportsReservation> items;
  final int page;
  final int pageCount;
  final int totalCount;
  final int pageSize;

  bool get hasMore => page < pageCount;
}
