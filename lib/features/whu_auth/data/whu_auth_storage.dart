import 'dart:convert';

import 'package:luotopia/features/whu_auth/domain/models/whu_auth_snapshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhuAuthStorage {
  const WhuAuthStorage();

  static const _snapshotKey = 'whu_auth.snapshot';

  WhuAuthSnapshot? readSnapshot(SharedPreferences? preferences) {
    final raw = preferences?.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return null;
      }
      final snapshot = WhuAuthSnapshot.fromJson(json);
      if (snapshot.casCookieHeader.trim().isEmpty) {
        return null;
      }
      return snapshot;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeSnapshot(
    SharedPreferences? preferences,
    WhuAuthSnapshot snapshot,
  ) async {
    await preferences?.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> clear(SharedPreferences? preferences) async {
    await preferences?.remove(_snapshotKey);
  }
}
