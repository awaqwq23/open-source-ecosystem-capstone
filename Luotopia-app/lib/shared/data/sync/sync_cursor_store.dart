import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final syncCursorStoreProvider = Provider<SyncCursorStore>((ref) {
  return SyncCursorStore(ref.read(sharedPreferencesProvider));
});

class SyncCursorStore {
  const SyncCursorStore(this._preferences);

  static const _key = 'sync.cursor';
  static const _lastSyncedAtKey = 'sync.lastSyncedAt';

  final SharedPreferences? _preferences;

  int read() {
    return _preferences?.getInt(_key) ?? 0;
  }

  Future<void> write(int cursor) async {
    if (cursor < 0) {
      return;
    }
    await _preferences?.setInt(_key, cursor);
  }

  DateTime? readLastSyncedAt() {
    final raw = _preferences?.getString(_lastSyncedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> writeLastSyncedAt(DateTime value) async {
    await _preferences?.setString(_lastSyncedAtKey, value.toIso8601String());
  }
}
