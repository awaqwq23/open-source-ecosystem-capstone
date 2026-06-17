class SportsChargeRange {
  const SportsChargeRange({required this.lowPrice, required this.highPrice});

  final double lowPrice;
  final double highPrice;

  bool get isFree => lowPrice == 0 && highPrice == 0;
}
