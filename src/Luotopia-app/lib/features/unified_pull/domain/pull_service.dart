import 'dart:async';
import 'dart:io';

import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart'
    as timetable;
import 'package:luotopia/features/pages/campus/sub_apps/all_school_timetable/domain/repositories/all_school_timetable_repository.dart';
import 'package:luotopia/features/hot_update/data/hot_update_cache.dart';
import 'package:luotopia/features/unified_pull/data/pull_client.dart';
import 'package:luotopia/features/unified_pull/data/pull_request.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/data/pull_state_store.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';
import 'package:path_provider/path_provider.dart';

class UnifiedPullService {
  UnifiedPullService({
    required PullClient pullClient,
    required PullStateStore stateStore,
    required HotUpdateCache hotUpdateCache,
    required SyncCursorStore syncCursorStore,
    required AllSchoolTimetableRepository allSchoolTimetableRepository,
    this.coldStartCooldown = const Duration(seconds: 30),
    this.foregroundCooldown = const Duration(seconds: 10),
  }) : _pullClient = pullClient,
       _stateStore = stateStore,
       _hotUpdateCache = hotUpdateCache,
       _syncCursorStore = syncCursorStore,
       _allSchoolTimetableRepository = allSchoolTimetableRepository;

  final PullClient _pullClient;
  final PullStateStore _stateStore;
  final HotUpdateCache _hotUpdateCache;
  final SyncCursorStore _syncCursorStore;
  final AllSchoolTimetableRepository _allSchoolTimetableRepository;
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

  Future<PullResult> pullPublicColdStart({
    List<String> scopes = const ['weather', 'notification', 'school_timetable'],
  }) async {
    if (_isColdStartCooldown) {
      return PullResult(throttled: true);
    }
    _lastColdStartPull = DateTime.now();
    return pullPublicScoped(trigger: 'cold_start', scopes: scopes);
  }

  Future<PullResult?> pullPublicSilent({
    List<String> scopes = const ['weather', 'notification', 'school_timetable'],
  }) async {
    if (_isForegroundCooldown) {
      return null;
    }
    _lastForegroundPull = DateTime.now();
    try {
      return await pullPublicScoped(trigger: 'foreground', scopes: scopes);
    } catch (_) {
      return null;
    }
  }

  Future<PullResult> pullScoped({
    required String trigger,
    required List<String> scopes,
  }) {
    return _doPull(trigger: trigger, scopes: scopes);
  }

  Future<PullResult> pullPublicScoped({
    required String trigger,
    required List<String> scopes,
  }) async {
    try {
      final schoolTimetableVersion = await _allSchoolTimetableRepository
          .readDatasetVersion();
      final response = await _pullClient.pullPublic(
        PullRequest(
          trigger: trigger,
          scopes: scopes,
          clientState: PullClientState(
            weatherCachedAt: trigger == 'manual' && scopes.contains('weather')
                ? null
                : _stateStore.readWeatherCachedAt(),
            notificationLatestId: _stateStore.readNotificationLatestId(),
            schoolTimetableVersion: schoolTimetableVersion,
          ),
        ),
      );
      await _applySchoolTimetableChanges(response);
      await _stateStore.apply(response);
      return PullResult(response: response);
    } catch (e) {
      return PullResult(error: e);
    }
  }

  Future<PullResult> pullPublicNotification({String trigger = 'public'}) async {
    return pullPublicScoped(trigger: trigger, scopes: const ['notification']);
  }

  Future<PullResult> _doPull({
    required String trigger,
    List<String> scopes = const [],
  }) async {
    try {
      final schoolTimetableVersion = await _allSchoolTimetableRepository
          .readDatasetVersion();
      final response = await _pullClient.pull(
        PullRequest(
          trigger: trigger,
          scopes: scopes,
          clientState: PullClientState(
            weatherCachedAt: _stateStore.readWeatherCachedAt(),
            notificationLatestId: _stateStore.readNotificationLatestId(),
            hotUpdateScripts: _hotUpdateCache.readClientState(),
            schoolTimetableVersion: schoolTimetableVersion,
            syncCursor: _syncCursorStore.read(),
          ),
        ),
      );
      await _cacheChangedScripts(response);
      await _applySchoolTimetableChanges(response);
      await _stateStore.apply(response);
      return PullResult(response: response);
    } catch (e) {
      return PullResult(error: e);
    }
  }

  Future<void> _applySchoolTimetableChanges(PullResponse response) async {
    final block = response.schoolTimetable;
    if (block == null || !block.changed || block.latestVersion <= 0) {
      return;
    }
    if (block.syncMode == SchoolTimetableSyncMode.bundle) {
      final bundle = block.bundle;
      if (bundle == null || bundle.href.isEmpty || bundle.checksum.isEmpty) {
        throw StateError('全校课表 bundle 信息缺失');
      }
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}${Platform.pathSeparator}school-timetable-v${bundle.version}.sqlite.gz',
      );
      final download = await _pullClient.downloadSchoolTimetableBundle(
        bundle.href,
        file,
      );
      if (download.checksum != bundle.checksum) {
        throw StateError('全校课表 bundle 校验失败');
      }
      try {
        await _allSchoolTimetableRepository.replaceFromBundle(
          version: block.latestVersion,
          checksum: block.checksum,
          sqliteGzipFile: file,
        );
      } finally {
        if (await file.exists()) {
          await file.delete();
        }
      }
      return;
    }
    if (block.changes.isEmpty) {
      throw StateError('全校课表增量为空，拒绝推进版本');
    }
    await _allSchoolTimetableRepository.applyChanges(
      version: block.latestVersion,
      checksum: block.checksum,
      changes: [
        for (final change in block.changes)
          timetable.SchoolTimetableChange(
            version: change.version,
            sequence: change.sequence,
            operation: change.operation,
            entityType: change.entityType,
            entityId: change.entityId,
            termKey: change.termKey,
            payload: change.payload,
          ),
      ],
    );
  }

  Future<void> _cacheChangedScripts(PullResponse response) async {
    final scripts = response.hotUpdate?.scripts ?? const {};
    for (final entry in scripts.entries) {
      final script = entry.value;
      final contentHref = script.links['content']?.href ?? '';
      if (!script.changed || contentHref.isEmpty) {
        continue;
      }
      try {
        final content = await _pullClient.downloadScript(contentHref);
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
