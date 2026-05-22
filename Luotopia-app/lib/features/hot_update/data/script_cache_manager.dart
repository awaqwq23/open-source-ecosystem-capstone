import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/hot_update/data/default_scripts.dart';
import 'package:luotopia/features/hot_update/domain/models/script_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 脚本缓存管理器
class ScriptCacheManager {
  static const _manifestUrl =
      'https://raw.githubusercontent.com/whu-ham/LuotopiaScripts/main/manifest.json';

  static const _defaultScripts = <String, String>{
    ParserNames.course: DefaultScripts.course,
    ParserNames.score: DefaultScripts.score,
  };

  Directory? _cachedAppDir;

  String _defaultScript(String name) => _defaultScripts[name] ?? '';

  Future<Directory> _appDir() async {
    if (_cachedAppDir == null) {
      final appDir = await getApplicationDocumentsDirectory();
      _cachedAppDir = Directory('${appDir.path}/hot_update_scripts');
      await _cachedAppDir!.create(recursive: true);
    }
    return _cachedAppDir!;
  }

  /// 获取脚本源码：优先远程缓存，其次内置默认
  Future<String> getScript(String name) async {
    try {
      final dir = await _appDir();
      final file = File('${dir.path}/$name.js');
      if (await file.exists()) {
        final cached = await file.readAsString();
        if (cached.isNotEmpty) {
          return cached;
        }
      }
    } catch (_) {}

    final fallback = _defaultScript(name);
    if (fallback.isNotEmpty) {
      return fallback;
    }
    throw Exception('找不到脚本：$name');
  }

  /// 从远程拉取脚本清单
  Future<ScriptManifest> fetchManifest() async {
    try {
      final response =
          await http.get(Uri.parse(_manifestUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return ScriptManifest.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return const ScriptManifest(scripts: []);
  }

  /// 下载并缓存单个脚本
  Future<ScriptInfo> downloadScript(ScriptInfo info) async {
    if (info.url.isEmpty) {
      throw Exception('脚本 ${info.name} 无下载地址');
    }
    final response =
        await http.get(Uri.parse(info.url)).timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw Exception('下载脚本失败：HTTP ${response.statusCode}');
    }
    final dir = await _appDir();
    await File('${dir.path}/${info.name}.js').writeAsString(response.body);
    return info.copyWith(localPath: '${dir.path}/${info.name}.js', isDefault: false);
  }

  /// 检查并返回待更新脚本列表
  Future<List<ScriptInfo>> checkUpdates() async {
    final manifest = await fetchManifest();
    if (manifest.scripts.isEmpty) {
      return [];
    }

    final prefs = await SharedPreferences.getInstance();
    final dir = await _appDir();
    final updated = <ScriptInfo>[];

    for (final remote in manifest.scripts) {
      try {
        final file = File('${dir.path}/${remote.name}.js');
        final localVersion = prefs.getInt('hot_update.v.${remote.name}') ?? 0;
        if (remote.version > localVersion || !await file.exists()) {
          updated.add(remote);
        }
      } catch (_) {
        updated.add(remote);
      }
    }
    return updated;
  }

  /// 更新所有过时脚本（并行下载，每日最多执行一次）
  Future<int> updateAll() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt('hot_update.lastCheck') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now - lastCheck < 86400) {
      return 0; // 一天检查一次
    }

    final pending = await checkUpdates();
    if (pending.isEmpty) {
      await prefs.setInt('hot_update.lastCheck', now);
      return 0;
    }

    final results = await Future.wait(pending.map((script) async {
      try {
        await downloadScript(script);
        await prefs.setInt('hot_update.v.${script.name}', script.version);
        return 1;
      } catch (_) {
        return 0;
      }
    }));
    final count = results.fold<int>(0, (a, b) => a + b);
    await prefs.setInt('hot_update.lastCheck', now);
    return count;
  }

  /// 是否有缓存的远程版本
  Future<bool> hasCachedRemote(String name) async {
    try {
      final dir = await _appDir();
      final file = File('${dir.path}/$name.js');
      if (!await file.exists()) {
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      return (prefs.getInt('hot_update.v.$name') ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }
}
