import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/score/domain/models/score_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreCache {
  const ScoreCache(this._preferences);

  static const _key = 'score_list';

  final SharedPreferences? _preferences;

  List<ScoreEntity>? read() {
    final raw = _preferences?.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ScoreListResult.fromJson(decoded).scores;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  Future<void> write(List<ScoreEntity> scores) async {
    final result = ScoreListResult(scores: scores);
    await _preferences?.setString(_key, jsonEncode(result.toJson()));
  }
}

final scoreCacheProvider = Provider<ScoreCache>((ref) {
  return ScoreCache(ref.read(sharedPreferencesProvider));
});
