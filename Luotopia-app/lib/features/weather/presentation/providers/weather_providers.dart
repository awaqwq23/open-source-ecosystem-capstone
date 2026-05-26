import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/domain/pull_service.dart';
import 'package:luotopia/features/unified_pull/data/pull_state_store.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';

class WeatherState {
  final WeatherBlock? weather;
  final bool loading;
  final bool isMock;

  const WeatherState({this.weather, this.loading = false, this.isMock = false});

  WeatherState copyWith({WeatherBlock? weather, bool? loading, bool? isMock}) {
    return WeatherState(
      weather: weather ?? this.weather,
      loading: loading ?? this.loading,
      isMock: isMock ?? this.isMock,
    );
  }
}

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  final pullService = ref.read(unifiedPullServiceProvider);
  final stateStore = ref.read(pullStateStoreProvider);
  return WeatherNotifier(pullService, stateStore);
});

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this._pullService, this._stateStore)
      : super(WeatherState(weather: _stateStore.readWeather()));

  final UnifiedPullService _pullService;
  final PullStateStore _stateStore;

  Future<void> refresh() async {
    state = WeatherState(weather: state.weather, loading: true);
    final result = await _pullService.pullScoped(
      trigger: 'manual',
      scopes: const ['weather'],
    );
    if (result.isSuccess && result.response?.weather?.data != null) {
      state = WeatherState(weather: result.response!.weather);
    } else {
      state = WeatherState(weather: _stateStore.readWeather(), loading: false);
    }
  }
}
