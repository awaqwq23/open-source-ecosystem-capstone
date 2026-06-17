import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyClassroomFilterSnapshot {
  const EmptyClassroomFilterSnapshot({
    required this.campus,
    required this.building,
    required this.week,
    required this.weekDay,
  });

  final String? campus;
  final String? building;
  final String? week;
  final String? weekDay;

  Map<String, dynamic> toJson() {
    return {
      'campus': campus,
      'building': building,
      'week': week,
      'weekDay': weekDay,
    };
  }

  factory EmptyClassroomFilterSnapshot.fromJson(Map<String, dynamic> json) {
    return EmptyClassroomFilterSnapshot(
      campus: json['campus'] as String?,
      building: json['building'] as String?,
      week: json['week'] as String?,
      weekDay: json['weekDay'] as String?,
    );
  }
}

class EmptyClassroomFilterPreferences {
  const EmptyClassroomFilterPreferences(this._preferences);

  static const _key = 'empty_classroom_filter_snapshot';

  final SharedPreferences? _preferences;

  EmptyClassroomFilterSnapshot? read() {
    final raw = _preferences?.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return EmptyClassroomFilterSnapshot.fromJson(decoded);
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> write(EmptyClassroomFilterSnapshot snapshot) async {
    await _preferences?.setString(_key, jsonEncode(snapshot.toJson()));
  }
}

final emptyClassroomFilterPreferencesProvider =
    Provider<EmptyClassroomFilterPreferences>((ref) {
      return EmptyClassroomFilterPreferences(
        ref.read(sharedPreferencesProvider),
      );
    });
