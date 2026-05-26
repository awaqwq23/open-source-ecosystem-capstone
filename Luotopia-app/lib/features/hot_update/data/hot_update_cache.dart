import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/unified_pull/data/pull_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';

final hotUpdateCacheProvider = Provider<HotUpdateCache>((ref) {
  return HotUpdateCache(ref.read(sharedPreferencesProvider));
});

class HotUpdateCache {
  const HotUpdateCache(this._preferences);

  static const _manifestKey = 'hotUpdate.manifest';

  final SharedPreferences? _preferences;

  Map<String, ClientScriptState> readClientState() {
    final manifest = _readManifest();
    return {
      for (final entry in manifest.entries)
        entry.key: ClientScriptState(
          version: entry.value.version,
          checksum: entry.value.checksum,
        ),
    };
  }

  Future<void> cacheScript({
    required String name,
    required int version,
    required String checksum,
    required String content,
  }) async {
    final actual = sha256.convert(utf8.encode(content)).toString();
    if (actual != checksum) {
      throw StateError('脚本校验失败：$name');
    }
    final directory = await _scriptDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$name.js');
    await file.writeAsString(content);
    final manifest = _readManifest();
    manifest[name] = CachedScript(
      version: version,
      checksum: checksum,
      path: file.path,
    );
    await _writeManifest(manifest);
  }

  Map<String, CachedScript> _readManifest() {
    final raw = _preferences?.getString(_manifestKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in data.entries)
          if (entry.value is Map<String, dynamic>)
            entry.key: CachedScript.fromJson(entry.value as Map<String, dynamic>),
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeManifest(Map<String, CachedScript> manifest) async {
    await _preferences?.setString(
      _manifestKey,
      jsonEncode({
        for (final entry in manifest.entries) entry.key: entry.value.toJson(),
      }),
    );
  }

  Future<Directory> _scriptDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${base.path}${Platform.pathSeparator}hot_update_scripts',
    );
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}

class CachedScript {
  const CachedScript({
    required this.version,
    required this.checksum,
    required this.path,
  });

  final int version;
  final String checksum;
  final String path;

  factory CachedScript.fromJson(Map<String, dynamic> json) {
    return CachedScript(
      version: json['version'] as int? ?? 0,
      checksum: json['checksum'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'checksum': checksum,
      'path': path,
    };
  }
}
