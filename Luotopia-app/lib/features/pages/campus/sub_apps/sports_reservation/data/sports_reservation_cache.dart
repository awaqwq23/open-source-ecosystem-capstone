import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/models/sports_project.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/models/sports_venue.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SportsReservationCache {
  const SportsReservationCache(this._preferences);

  static const _typesKey = 'sports_reservation_types';
  static const _venuesKey = 'sports_reservation_venues';

  final SharedPreferences? _preferences;

  List<SportsProject>? readSportsTypes() {
    final raw = _preferences?.getString(_typesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(SportsProject.fromJson)
            .toList();
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> writeSportsTypes(List<SportsProject> types) async {
    final json = types.map((t) => t.toJson()).toList();
    await _preferences?.setString(_typesKey, jsonEncode(json));
  }

  List<SportsVenue>? readVenues() {
    final raw = _preferences?.getString(_venuesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(SportsVenue.fromJson)
            .toList();
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> writeVenues(List<SportsVenue> venues) async {
    final json = venues.map((v) => v.toJson()).toList();
    await _preferences?.setString(_venuesKey, jsonEncode(json));
  }
}

final sportsReservationCacheProvider = Provider<SportsReservationCache>((ref) {
  return SportsReservationCache(ref.read(sharedPreferencesProvider));
});
