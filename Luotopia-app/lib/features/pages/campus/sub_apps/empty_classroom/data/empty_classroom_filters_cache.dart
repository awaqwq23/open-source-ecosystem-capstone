import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/repositories/empty_classroom_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyClassroomFiltersCache {
  const EmptyClassroomFiltersCache(this._preferences);

  static const _key = 'empty_classroom_filters';

  final SharedPreferences? _preferences;

  EmptyClassroomFilters? read() {
    final raw = _preferences?.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return EmptyClassroomFilters.fromJson(decoded);
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> write(EmptyClassroomFilters filters) async {
    await _preferences?.setString(_key, jsonEncode(filters.toJson()));
  }
}

final emptyClassroomFiltersCacheProvider =
    Provider<EmptyClassroomFiltersCache>((ref) {
  return EmptyClassroomFiltersCache(ref.read(sharedPreferencesProvider));
});
