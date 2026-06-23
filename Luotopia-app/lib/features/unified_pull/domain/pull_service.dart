import 'dart:async';
import 'dart:io';

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
      final response = await _pullClient.pullPublic(
        PullRequest(
          trigger: trigger,
          scopes: scopes,
          clientState: PullClientState(
            weatherCachedAt: trigger == 'manual' && scopes.contains('weather')
                ? null
                : _stateStore.readWeatherCachedAt(),
            notificationLatestId: _stateStore.readNotificationLatestId(),
            schoolTimetableTerms: _stateStore.readSchoolTimetableTerms(),
          ),
        ),
      );
      await _cacheChangedSchoolTimetableTerms(response);
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
      final response = await _pullClient.pull(
        PullRequest(
          trigger: trigger,
          scopes: scopes,
          clientState: PullClientState(
            weatherCachedAt: _stateStore.readWeatherCachedAt(),
            notificationLatestId: _stateStore.readNotificationLatestId(),
            hotUpdateScripts: _hotUpdateCache.readClientState(),
            schoolTimetableTerms: _stateStore.readSchoolTimetableTerms(),
            syncCursor: _syncCursorStore.read(),
          ),
        ),
      );
      await _cacheChangedScripts(response);
      await _cacheChangedSchoolTimetableTerms(response);
      await _stateStore.apply(response);
      return PullResult(response: response);
    } catch (e) {
      return PullResult(error: e);
    }
  }

  Future<void> _cacheChangedSchoolTimetableTerms(PullResponse response) async {
    final activeTerms =
        response.schoolTimetable?.activeTerms.toSet() ?? const <String>{};
    final terms = response.schoolTimetable?.terms ?? const [];
    for (final term in terms) {
      final artifactHref = term.links['artifact']?.href ?? '';
      if (artifactHref.isEmpty || term.checksum.isEmpty) {
        continue;
      }
      if (term.artifactType != 'school_timetable_sqlite_gzip' ||
          term.schemaVersion != 6) {
        throw StateError('全校课表 ${term.termKey} 快照格式不受支持');
      }
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}${Platform.pathSeparator}school-timetable-${_safeName(term.termKey)}-${term.version}.sqlite.gz',
      );
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      final download = await _pullClient.downloadSchoolTimetableArtifact(
        artifactHref,
        tempFile,
      );
      if (term.artifactSize > 0 && download.bytesWritten != term.artifactSize) {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        throw StateError('全校课表 ${term.termKey} 快照大小不匹配');
      }
      if (download.checksum != term.checksum) {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        throw StateError('全校课表 ${term.termKey} 快照校验失败');
      }
      try {
        await _allSchoolTimetableRepository.replaceTermFromArtifactFile(
          gzipFile: tempFile,
          termKey: term.termKey,
          version: term.version,
          checksum: term.checksum,
          rowCount: term.rowCount,
        );
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    }
    if (activeTerms.isNotEmpty) {
      await _allSchoolTimetableRepository.retainActiveTerms(activeTerms);
    }
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

  String _safeName(String value) {
    final sanitized = value
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return sanitized.isEmpty ? 'unknown' : sanitized;
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
