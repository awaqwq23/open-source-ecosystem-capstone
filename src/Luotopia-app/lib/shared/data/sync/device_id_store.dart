import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final syncDeviceIdStoreProvider = Provider<SyncDeviceIdStore>((ref) {
  return SyncDeviceIdStore(ref.read(sharedPreferencesProvider));
});

class SyncDeviceIdStore {
  const SyncDeviceIdStore(this._preferences);

  static const _key = 'sync.deviceId';
  static const _uuid = Uuid();

  final SharedPreferences? _preferences;

  Future<String> getOrCreate() async {
    final preferences = _preferences;
    final existing = preferences?.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = 'device_${_uuid.v4()}';
    await preferences?.setString(_key, id);
    return id;
  }
}
