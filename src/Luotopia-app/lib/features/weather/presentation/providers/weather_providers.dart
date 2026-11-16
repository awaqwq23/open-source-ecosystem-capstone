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

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((
  ref,
) {
  final pullService = ref.read(unifiedPullServiceProvider);
  final stateStore = ref.read(pullStateStoreProvider);
  return WeatherNotifier(pullService, stateStore);
});

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this._pullService, this._stateStore)
    : super(_stateFromCache(_stateStore.readWeather()));

  final UnifiedPullService _pullService;
  final PullStateStore _stateStore;

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final result = await _pullService.pullPublicScoped(
      trigger: 'manual',
      scopes: const ['weather'],
    );
    if (result.isSuccess && result.response?.weather?.data != null) {
      state = WeatherState(weather: result.response!.weather, loading: false);
    } else {
      state = _stateFromCache(_stateStore.readWeather());
    }
  }

  static WeatherState _stateFromCache(WeatherBlock? cached) {
    if (cached != null && cached.data != null) {
      return WeatherState(weather: cached);
    }
    return WeatherState(weather: _mockWeather(), isMock: true);
  }

  static WeatherBlock _mockWeather() {
    return const WeatherBlock(
      data: {
        'temperature': 28.0,
        'condition': '晴',
        'condition_code': 100,
        'feels_like': 29.0,
        'temp_high': 30.0,
        'temp_low': 18.0,
        'aqi': 25,
        'humidity': 58,
        'wind_speed': 9.0,
        'wind_dir': '东风',
        'icon': '100',
        'hourly_forecast': [
          {
            'fx_time': '2026-05-27T09:00+08:00',
            'temp': 28.0,
            'condition': '晴',
            'icon': '100',
          },
          {
            'fx_time': '2026-05-27T10:00+08:00',
            'temp': 29.0,
            'condition': '晴',
            'icon': '100',
          },
          {
            'fx_time': '2026-05-27T11:00+08:00',
            'temp': 30.0,
            'condition': '晴',
            'icon': '100',
          },
          {
            'fx_time': '2026-05-27T12:00+08:00',
            'temp': 31.0,
            'condition': '多云',
            'icon': '101',
          },
          {
            'fx_time': '2026-05-27T13:00+08:00',
            'temp': 30.0,
            'condition': '多云',
            'icon': '101',
          },
        ],
      },
    );
  }
}
