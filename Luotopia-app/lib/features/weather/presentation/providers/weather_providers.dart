import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/domain/pull_service.dart';
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
  return WeatherNotifier(pullService);
});

const _mockWeatherData = {
  'temperature': 28.0,
  'condition': '晴',
  'aqi': 25,
  'humidity': 60,
  'wind_speed': 12.0,
  'hourly_forecast': [
    {'temp': 28.0, 'time': '2026-05-26T09:00:00+08:00'},
    {'temp': 29.0, 'time': '2026-05-26T10:00:00+08:00'},
    {'temp': 30.0, 'time': '2026-05-26T11:00:00+08:00'},
    {'temp': 31.0, 'time': '2026-05-26T12:00:00+08:00'},
    {'temp': 30.0, 'time': '2026-05-26T13:00:00+08:00'},
    {'temp': 27.0, 'time': '2026-05-26T14:00:00+08:00'},
    {'temp': 28.0, 'time': '2026-05-26T15:00:00+08:00'},
  ],
};

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this._pullService) : super(WeatherState(
    weather: WeatherBlock(data: Map<String, dynamic>.from(_mockWeatherData)),
    isMock: true,
  ));

  final UnifiedPullService _pullService;

  Future<void> refresh() async {
    state = WeatherState(weather: state.weather, loading: true);
    final result = await _pullService.pullFull();
    if (result.isSuccess && result.response?.weather?.data != null) {
      state = WeatherState(weather: result.response!.weather);
    } else {
      state = WeatherState(weather: WeatherBlock(data: Map<String, dynamic>.from(_mockWeatherData)), isMock: true, loading: false);
    }
  }
}
