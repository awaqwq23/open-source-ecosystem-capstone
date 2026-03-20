import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AiHeaderPeriod {
  day,
  week,
  month,
}

class AiHeaderState {
  const AiHeaderState({
    required this.period,
    required this.anchor,
  });

  final AiHeaderPeriod period;
  final DateTime anchor;
}

class AiHeaderViewModel extends Notifier<AiHeaderState> {
  @override
  AiHeaderState build() {
    return AiHeaderState(
      period: AiHeaderPeriod.day,
      anchor: DateTime(2026, 3, 20),
    );
  }

  void select(AiHeaderPeriod period) {
    state = AiHeaderState(period: period, anchor: state.anchor);
  }
}

final aiHeaderViewModelProvider =
    NotifierProvider<AiHeaderViewModel, AiHeaderState>(
  AiHeaderViewModel.new,
);
