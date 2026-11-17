enum SportsCheckoutOutcome {
  completed,
  orderChanged,
  dismissed,
  authorizationExpired,
  failed,
}

class SportsCheckoutResult {
  const SportsCheckoutResult({
    required this.outcome,
    this.orderNo,
    this.message = '',
    this.suppressFeedback = false,
  });

  const SportsCheckoutResult.completed({
    this.orderNo,
    this.message = '',
    this.suppressFeedback = false,
  }) : outcome = SportsCheckoutOutcome.completed;

  const SportsCheckoutResult.orderChanged({
    this.orderNo,
    this.message = '',
    this.suppressFeedback = false,
  }) : outcome = SportsCheckoutOutcome.orderChanged;

  const SportsCheckoutResult.dismissed({
    this.message = '',
    this.suppressFeedback = false,
  }) : outcome = SportsCheckoutOutcome.dismissed,
       orderNo = null;

  const SportsCheckoutResult.authorizationExpired({
    this.message = '',
    this.suppressFeedback = false,
  }) : outcome = SportsCheckoutOutcome.authorizationExpired,
       orderNo = null;

  const SportsCheckoutResult.failed({
    this.message = '',
    this.suppressFeedback = false,
  }) : outcome = SportsCheckoutOutcome.failed,
       orderNo = null;

  const SportsCheckoutResult.silentOrderChanged({
    this.orderNo,
    this.message = '',
  }) : outcome = SportsCheckoutOutcome.orderChanged,
       suppressFeedback = true;

  SportsCheckoutResult withSuppressedFeedback() {
    if (suppressFeedback) {
      return this;
    }
    return SportsCheckoutResult(
      outcome: outcome,
      orderNo: orderNo,
      message: message,
      suppressFeedback: true,
    );
  }

  SportsCheckoutResult withFallbackOrderNo(String fallbackOrderNo) {
    if (orderNo != null || fallbackOrderNo.isEmpty) {
      return this;
    }
    return SportsCheckoutResult(
      outcome: outcome,
      orderNo: fallbackOrderNo,
      message: message,
      suppressFeedback: suppressFeedback,
    );
  }

  final SportsCheckoutOutcome outcome;
  final String? orderNo;
  final String message;
  final bool suppressFeedback;

  bool get shouldRefreshOrders {
    return outcome == SportsCheckoutOutcome.completed ||
        outcome == SportsCheckoutOutcome.orderChanged;
  }

  bool get shouldRefreshAvailability => shouldRefreshOrders;

  bool get shouldReauthorize {
    return outcome == SportsCheckoutOutcome.authorizationExpired;
  }
}
