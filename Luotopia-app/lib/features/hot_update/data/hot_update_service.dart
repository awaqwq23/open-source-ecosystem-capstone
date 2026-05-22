import 'dart:async';
import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:luotopia/features/hot_update/data/default_scripts.dart';
import 'package:luotopia/features/hot_update/data/script_cache_manager.dart';
import 'package:luotopia/features/hot_update/domain/models/script_info.dart';

/// 热更新解析服务
/// 提供两级解析策略：JS 脚本（可热更新）→ Dart 回退
class HotUpdateService {
  final ScriptCacheManager _cacheManager = ScriptCacheManager();
  JavascriptRuntime? _runtime;
  bool _initialized = false;

  /// 初始化：启用后台脚本更新检查（不阻塞）
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    unawaited(_cacheManager.updateAll().catchError((_) {}));
  }

  JavascriptRuntime _getRuntime() {
    _runtime ??= getJavascriptRuntime();
    return _runtime!;
  }

  /// 同步解析：优先 JS 引擎 → Dart 回退
  /// [parserName] 脚本名称（course-parser / score-parser）
  /// [rawData] 原始 API 响应 Map
  /// [dartParser] Dart 回退解析函数
  T parse<T>({
    required String parserName,
    required Map<String, dynamic> rawData,
    required T Function(Map<String, dynamic> json) dartParser,
  }) {
    // 尝试 JS 解析
    try {
      final runtime = _getRuntime();
      final inputJson = jsonEncode(rawData);
      final defaultSource = _builtinSource(parserName);

      if (defaultSource.isEmpty) {
        return dartParser(rawData);
      }

      final wrapped = '$defaultSource\nparse($inputJson);';
      final result = runtime.evaluate(wrapped);
      final output = result.rawResult;

      if (output != null && output.isNotEmpty && output != 'undefined') {
        final decoded = jsonDecode(output);
        if (decoded is Map<String, dynamic>) {
          return dartParser(decoded);
        }
      }
    } catch (_) {}

    // 回退到 Dart
    return dartParser(rawData);
  }

  /// 异步解析：使用缓存或内置默认，失败回退
  Future<T> parseAsync<T>({
    required String parserName,
    required String rawJson,
    required Future<T> Function(Map<String, dynamic> json) dartFallback,
  }) async {
    try {
      final script = await _cacheManager.getScript(parserName);
      final runtime = _getRuntime();
      final wrapped = '$script\nparse($rawJson);';
      final result = runtime.evaluate(wrapped);
      final output = result.rawResult;

      if (output != null && output.isNotEmpty && output != 'undefined') {
        final decoded = jsonDecode(output) as Map<String, dynamic>;
        return await dartFallback(decoded);
      }
    } catch (_) {}

    return dartFallback(jsonDecode(rawJson));
  }

  /// 释放运行时
  void dispose() {
    _runtime?.dispose();
    _runtime = null;
  }

  String _builtinSource(String name) {
    switch (name) {
      case ParserNames.course:
        return DefaultScripts.course;
      case ParserNames.score:
        return DefaultScripts.score;
      default:
        return '';
    }
  }
}
