import 'dart:async';

import 'package:luotopia/features/hot_update/data/hot_update_cache.dart';
import 'package:luotopia/features/unified_pull/data/pull_client.dart';
import 'package:luotopia/features/unified_pull/data/pull_request.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/data/pull_state_store.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';

class UnifiedPullService {
  UnifiedPullService({
    required PullClient pullClient,
    required PullStateStore stateStore,
    required HotUpdateCache hotUpdateCache,
    required SyncCursorStore syncCursorStore,
    this.coldStartCooldown = const Duration(seconds: 30),
    this.foregroundCooldown = const Duration(seconds: 10),
  })  : _pullClient = pullClient,
        _stateStore = stateStore,
        _hotUpdateCache = hotUpdateCache,
        _syncCursorStore = syncCursorStore;

  final PullClient _pullClient;
  final PullStateStore _stateStore;
  final HotUpdateCache _hotUpdateCache;
  final SyncCursorStore _syncCursorStore;
  final Duration coldStartCooldown;
  final Duration foregroundCooldown;

  DateTime? _lastColdStartPull;
  DateTime? _lastForegroundPull;

  /// 检查冷启动节流
  bool get _isColdStartCooldown =>
      _lastColdStartPull != null &&
      DateTime.now().difference(_lastColdStartPull!) < coldStartCooldown;

  /// 检查前台恢复节流
  bool get _isForegroundCooldown =>
      _lastForegroundPull != null &&
      DateTime.now().difference(_lastForegroundPull!) < foregroundCooldown;

  /// 完整拉取（冷启动时调用）
  Future<PullResult> pullFull() async {
    if (_isColdStartCooldown) {
      return PullResult(throttled: true);
    }
    _lastColdStartPull = DateTime.now();
    return _doPull(trigger: 'cold_start');
  }

  /// 静默拉取（前台恢复时调用，吞掉非关键错误）
  Future<PullResult?> pullSilent() async {
    if (_isForegroundCooldown) {
      return null;
    }
    _lastForegroundPull = DateTime.now();
    try {
      return await _doPull(trigger: 'foreground');
    } catch (_) {
      // 静默模式下吞掉错误
      return null;
    }
  }

  Future<PullResult> pullScoped({
    required String trigger,
    required List<String> scopes,
  }) {
    return _doPull(trigger: trigger, scopes: scopes);
  }

  Future<PullResult> pullPublicNotification({String trigger = 'public'}) async {
    try {
      final response = await _pullClient.pullPublic(
        PullRequest(
          trigger: trigger,
          scopes: const ['notification'],
          clientState: PullClientState(
            notificationLatestId: _stateStore.readNotificationLatestId(),
          ),
        ),
      );
      await _stateStore.apply(response);
      return PullResult(response: response);
    } catch (e) {
      return PullResult(error: e);
    }
  }

  Future<PullResult> _doPull({
    required String trigger,
    List<String> scopes = const [],
  }) async {
    try {
      final response = await _pullClient.pull(
        PullRequest(
          trigger: trigger,
          scopes: scopes,
          clientState: PullClientState(
            weatherCachedAt: _stateStore.readWeatherCachedAt(),
            notificationLatestId: _stateStore.readNotificationLatestId(),
            hotUpdateScripts: _hotUpdateCache.readClientState(),
            syncCursor: _syncCursorStore.read(),
          ),
        ),
      );
      await _stateStore.apply(response);
      await _cacheChangedScripts(response);
      return PullResult(response: response);
    } catch (e) {
      return PullResult(error: e);
    }
  }

  Future<void> _cacheChangedScripts(PullResponse response) async {
    final scripts = response.hotUpdate?.scripts ?? const {};
    for (final entry in scripts.entries) {
      final script = entry.value;
      if (!script.changed || script.downloadUrl.isEmpty) {
        continue;
      }
      try {
        final content = await _pullClient.downloadScript(script.downloadUrl);
        await _hotUpdateCache.cacheScript(
          name: entry.key,
          version: script.latestVersion,
          checksum: script.checksum,
          content: content,
        );
      } catch (_) {
        continue;
      }
    }
  }

  void resetThrottle() {
    _lastColdStartPull = null;
    _lastForegroundPull = null;
  }
}

class PullResult {
  final PullResponse? response;
  final Object? error;
  final bool throttled;

  const PullResult({this.response, this.error, this.throttled = false});

  bool get isSuccess => response != null && !throttled;
  bool get isError => error != null;
}
