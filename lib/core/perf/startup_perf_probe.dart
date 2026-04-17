import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class StartupPerfProbe {
  StartupPerfProbe._();

  static final StartupPerfProbe instance = StartupPerfProbe._();

  static const MethodChannel _startupChannel = MethodChannel('huajuan/startup_timing');

  final Stopwatch _sinceMain = Stopwatch();
  final Set<String> _onceEvents = <String>{};

  bool _enabled = kDebugMode || kProfileMode;
  bool _frameObserverInstalled = false;
  bool _summaryEmitted = false;

  int? _androidToMainUs;
  int? _androidStartNs;

  String? _sessionId;
  String get sessionId => _sessionId ??= DateTime.now().microsecondsSinceEpoch.toString();

  final Map<String, int> _marksUs = <String, int>{};
  final Map<String, int> _stageStartsUs = <String, int>{};
  final Map<String, int> _counters = <String, int>{};

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void startMainStopwatchIfNeeded() {
    if (!_enabled) {
      return;
    }
    if (!_sinceMain.isRunning) {
      _sinceMain.start();
    }
  }

  Future<void> bootstrapAndroidStart() async {
    if (!_enabled) {
      return;
    }
    try {
      final result = await _startupChannel.invokeMapMethod<String, Object?>('getStartupTiming');
      if (result == null) {
        return;
      }
      final startNs = _toInt(result['androidStartElapsedRealtimeNanos']);
      final nowNs = _toInt(result['androidNowElapsedRealtimeNanos']);
      if (startNs != null && nowNs != null && nowNs >= startNs) {
        _androidStartNs = startNs;
        _androidToMainUs = ((nowNs - startNs) / 1000).round();
        markOnce(
          'android_start_bridge_ready',
          extras: <String, Object?>{
            'android_to_main_ms': _toMsString(_androidToMainUs!),
          },
        );
      }
    } catch (_) {
      markOnce('android_start_bridge_unavailable');
    }
  }

  void installFrameTimingObserver() {
    if (!_enabled || _frameObserverInstalled) {
      return;
    }
    _frameObserverInstalled = true;
    SchedulerBinding.instance.addTimingsCallback((timings) {
      if (timings.isEmpty) {
        return;
      }
      final first = timings.first;
      markOnce(
        'first_frame_timing',
        extras: <String, Object?>{
          'build_ms': _toMsString(first.buildDuration.inMicroseconds),
          'raster_ms': _toMsString(first.rasterDuration.inMicroseconds),
          'vsync_overhead_ms': _toMsString(first.vsyncOverhead.inMicroseconds),
          'total_span_ms': _toMsString(first.totalSpan.inMicroseconds),
        },
      );
    });
  }

  void mark(String event, {Map<String, Object?> extras = const <String, Object?>{}}) {
    if (!_enabled) {
      return;
    }
    startMainStopwatchIfNeeded();
    final elapsedUs = _sinceMain.elapsedMicroseconds;
    _marksUs[event] = elapsedUs;

    final payload = <String, Object?>{
      'session': sessionId,
      'event': event,
      't_ms': _toMsString(elapsedUs),
      ...extras,
    };
    final line = '[STARTUP] ${jsonEncode(payload)}';
    debugPrint(line);
    developer.log(line, name: 'startup.perf');
  }

  void markOnce(String event, {Map<String, Object?> extras = const <String, Object?>{}}) {
    if (!_onceEvents.add(event)) {
      return;
    }
    mark(event, extras: extras);
  }

  int nextSequence(String key) {
    final next = (_counters[key] ?? 0) + 1;
    _counters[key] = next;
    return next;
  }

  void startStage(
    String stage, {
    Map<String, Object?> extras = const <String, Object?>{},
  }) {
    if (!_enabled) {
      return;
    }
    startMainStopwatchIfNeeded();
    _stageStartsUs[stage] = _sinceMain.elapsedMicroseconds;
    mark(
      'stage_start',
      extras: <String, Object?>{
        'stage': stage,
        ...extras,
      },
    );
  }

  void endStage(
    String stage, {
    Map<String, Object?> extras = const <String, Object?>{},
  }) {
    if (!_enabled) {
      return;
    }
    startMainStopwatchIfNeeded();
    final nowUs = _sinceMain.elapsedMicroseconds;
    final startUs = _stageStartsUs.remove(stage);
    mark(
      'stage_end',
      extras: <String, Object?>{
        'stage': stage,
        'duration_ms': startUs == null ? null : _toMsString(nowUs - startUs),
        ...extras,
      },
    );
  }

  void emitSummary({
    required String endEvent,
    Map<String, Object?> extras = const <String, Object?>{},
  }) {
    if (!_enabled || _summaryEmitted) {
      return;
    }
    final endUs = _marksUs[endEvent];
    if (endUs == null) {
      return;
    }
    _summaryEmitted = true;
    final mainToEndUs = endUs;
    final totalUs = _androidToMainUs == null ? null : _androidToMainUs! + mainToEndUs;
    mark(
      'startup_summary',
      extras: <String, Object?>{
        'android_to_main_ms': _androidToMainUs == null ? null : _toMsString(_androidToMainUs!),
        'main_to_target_ms': _toMsString(mainToEndUs),
        'total_from_android_start_ms': totalUs == null ? null : _toMsString(totalUs),
        'target_event': endEvent,
        'android_start_ns': _androidStartNs,
        ...extras,
      },
    );
  }

  int? _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String _toMsString(int us) {
    return (us / 1000).toStringAsFixed(3);
  }
}
