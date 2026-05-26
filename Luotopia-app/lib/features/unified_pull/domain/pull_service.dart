import 'dart:async';

import 'package:luotopia/features/unified_pull/data/pull_client.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';

class UnifiedPullService {
  UnifiedPullService({
    required PullClient pullClient,
    this.coldStartCooldown = const Duration(seconds: 30),
    this.foregroundCooldown = const Duration(seconds: 10),
  }) : _pullClient = pullClient;

  final PullClient _pullClient;
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
    return _doPull();
  }

  /// 静默拉取（前台恢复时调用，吞掉非关键错误）
  Future<void> pullSilent() async {
    if (_isForegroundCooldown) {
      return;
    }
    _lastForegroundPull = DateTime.now();
    try {
      await _doPull();
    } catch (_) {
      // 静默模式下吞掉错误
    }
  }

  Future<PullResult> _doPull() async {
    try {
      final response = await _pullClient.pull();
      return PullResult(response: response);
    } catch (e) {
      return PullResult(error: e);
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
