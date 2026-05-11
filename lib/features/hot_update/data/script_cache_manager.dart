import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/hot_update/data/default_scripts.dart';
import 'package:luotopia/features/hot_update/domain/models/script_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 脚本缓存管理器
/// 负责：脚本下载、本地缓存、版本检查、回退默认
class ScriptCacheManager {
  static const _manifestKey = 'hot_update.manifest';
  static const _scriptDir = 'hot_update_scripts';

  /// 远程配置地址（可指向 Luotopia 服务器或 GitHub）
  /// 默认使用与 ham-rn 相同的 GitHub 组织
  static const _defaultManifestUrl =
      'https://raw.githubusercontent.com/whu-ham/LuotopiaScripts/main/manifest.json';

  ScriptInfo? _cachedManifest;

  // ── 内置默认脚本 ── //

  static const _defaultScripts = <String, String>{
    ParserNames.course: DefaultScripts.course,
    ParserNames.score: DefaultScripts.score,
  };

  String _defaultScript(String name) => _defaultScripts[name] ?? '';

  // ── 路径 ── //

  Future<Directory> _getScriptDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_scriptDir');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _scriptPath(String name) => '$_scriptDir/$name.js';

  // ── 核心操作 ── //

  /// 获取脚本源码：优先返回缓存的远程脚本，其次返回默认内置脚本
  Future<String> getScript(String name) async {
    // 1. 尝试读取本地缓存
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/${_scriptPath(name)}');
      if (await file.exists()) {
        final cached = await file.readAsString();
        if (cached.isNotEmpty) {
          return cached;
        }
      }
    } catch (_) {}

    // 2. 回退到内置默认
    final fallback = _defaultScript(name);
    if (fallback.isNotEmpty) {
      return fallback;
    }

    throw Exception('找不到脚本：$name（无默认实现）');
  }

  /// 尝试从远程拉取并更新清单
  Future<ScriptManifest> fetchManifest({
    String? manifestUrl,
  }) async {
    final url = manifestUrl ?? _defaultManifestUrl;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final manifest =
            ScriptManifest.fromJson(jsonDecode(response.body));
        _cachedManifest = null;
        return manifest;
      }
    } catch (_) {}
    return const ScriptManifest(scripts: []);
  }

  /// 下载并缓存单个脚本
  Future<ScriptInfo> downloadScript(ScriptInfo info) async {
    if (info.url.isEmpty) {
      throw Exception('脚本 ${info.name} 无下载地址');
    }

    final response = await http
        .get(Uri.parse(info.url))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('下载脚本失败：HTTP ${response.statusCode}');
    }

    final dir = await _getScriptDir();
    final file = File('${dir.path}/${info.name}.js');
    await file.writeAsString(response.body);

    return info.copyWith(localPath: file.path, isDefault: false);
  }

  /// 检查所有脚本更新
  /// 返回需要更新的脚本列表（调用方决定是否执行）
  Future<List<ScriptInfo>> checkUpdates({
    String? manifestUrl,
  }) async {
    final manifest = await fetchManifest(manifestUrl: manifestUrl);
    final updated = <ScriptInfo>[];

    for (final remote in manifest.scripts) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final file = File('${appDir.path}/${_scriptPath(remote.name)}');
        final localVersion = await _readLocalVersion(remote.name);

        if (remote.version > localVersion || !await file.exists()) {
          updated.add(remote);
        }
      } catch (_) {
        updated.add(remote);
      }
    }

    return updated;
  }

  /// 更新所有过时脚本
  Future<int> updateAll({
    String? manifestUrl,
    Future<void> Function(String name)? onProgress,
  }) async {
    final pending = await checkUpdates(manifestUrl: manifestUrl);
    var count = 0;
    for (final script in pending) {
      try {
        await downloadScript(script);
        await _saveLocalVersion(script.name, script.version);
        count++;
        await onProgress?.call(script.name);
      } catch (_) {}
    }
    return count;
  }

  /// 是否有缓存的远程版本
  Future<bool> hasCachedRemote(String name) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/${_scriptPath(name)}');
      if (!await file.exists()) {
        return false;
      }
      final localVersion = await _readLocalVersion(name);
      return localVersion > 0;
    } catch (_) {
      return false;
    }
  }

  // ── 版本记录 ── //

  Future<int> _readLocalVersion(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('hot_update.v.$name') ?? 0;
  }

  Future<void> _saveLocalVersion(String name, int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hot_update.v.$name', version);
  }
}
