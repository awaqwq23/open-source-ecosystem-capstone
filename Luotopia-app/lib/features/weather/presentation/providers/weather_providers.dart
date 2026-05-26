import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/domain/pull_service.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';

class WeatherState {
  final WeatherBlock? weather;
  final bool loading;

  const WeatherState({this.weather, this.loading = false});
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final pullService = ref.read(unifiedPullServiceProvider);
  return WeatherNotifier(pullService);
});

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this._pullService) : super(const WeatherState());

  final UnifiedPullService _pullService;

  Future<void> refresh() async {
    state = WeatherState(weather: state.weather, loading: true);
    final result = await _pullService.pullFull();
    if (result.isSuccess && result.response?.weather != null) {
      state = WeatherState(weather: result.response!.weather);
    } else {
      state = WeatherState(weather: state.weather, loading: false);
    }
  }
}
