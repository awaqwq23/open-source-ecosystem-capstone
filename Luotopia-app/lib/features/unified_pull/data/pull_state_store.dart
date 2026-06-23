import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/unified_pull/data/pull_request.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pullStateStoreProvider = Provider<PullStateStore>((ref) {
  return PullStateStore(ref.read(sharedPreferencesProvider));
});

class PullStateStore {
  const PullStateStore(this._preferences);

  static const _weatherDataKey = 'pull.weather.data';
  static const _weatherCachedAtKey = 'pull.weather.cachedAt';
  static const _notificationKey = 'pull.notification.latest';
  static const _schoolTimetableKey = 'pull.school_timetable.terms';

  final SharedPreferences? _preferences;

  WeatherBlock? readWeather() {
    final raw = _preferences?.getString(_weatherDataKey);
    final cachedAt = _preferences?.getInt(_weatherCachedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      if (!_isCurrentWeatherData(data)) {
        return null;
      }
      return WeatherBlock(changed: false, data: data, cachedAt: cachedAt);
    } catch (_) {
      return null;
    }
  }

  int? readWeatherCachedAt() {
    return _preferences?.getInt(_weatherCachedAtKey);
  }

  NotificationBlock? readNotification() {
    final raw = _preferences?.getString(_notificationKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return NotificationBlock.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  String readNotificationLatestId() {
    return readNotification()?.latestId ?? '';
  }

  Map<String, ClientTermState> readSchoolTimetableTerms() {
    final raw = _preferences?.getString(_schoolTimetableKey);
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in json.entries)
          entry.key: ClientTermState.fromJson(
            entry.value as Map<String, dynamic>,
          ),
      };
    } catch (_) {
      return const {};
    }
  }

  Future<void> apply(PullResponse response) async {
    final weather = response.weather;
    if (weather != null && weather.changed && weather.data != null) {
      await _preferences?.setString(_weatherDataKey, jsonEncode(weather.data));
      if (weather.cachedAt != null) {
        await _preferences?.setInt(_weatherCachedAtKey, weather.cachedAt!);
      }
    }
    final notification = response.notification;
    if (notification != null && notification.latestId.isNotEmpty) {
      await _preferences?.setString(
        _notificationKey,
        jsonEncode(notification.toJson()),
      );
    }
    final schoolTimetable = response.schoolTimetable;
    if (schoolTimetable != null &&
        (schoolTimetable.activeTerms.isNotEmpty ||
            schoolTimetable.terms.isNotEmpty)) {
      final activeSet = schoolTimetable.activeTerms.toSet();
      final terms = readSchoolTimetableTerms();
      final updated = {
        for (final entry in terms.entries)
          if (activeSet.isEmpty || activeSet.contains(entry.key))
            entry.key: {
              'version': entry.value.version,
              'checksum': entry.value.checksum,
            },
        for (final term in schoolTimetable.terms)
          term.termKey: {'version': term.version, 'checksum': term.checksum},
      };
      await _preferences?.setString(_schoolTimetableKey, jsonEncode(updated));
    }
  }
}

bool _isCurrentWeatherData(Map<String, dynamic> data) {
  final hourly = data['hourly_forecast'];
  if (hourly is! List || hourly.isEmpty) {
    return true;
  }
  return hourly.every((item) {
    return item is Map && item['fx_time'] is String;
  });
}
