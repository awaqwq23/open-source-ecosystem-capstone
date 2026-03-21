import 'package:flutter/material.dart';

enum HomeWideLayoutScope {
  week,
  month,
}

@immutable
class HomeSettings {
  const HomeSettings({
    required this.dayStartTime,
    required this.blockDurationMinutes,
    required this.blockGapMinutes,
    required this.blockCount,
    required this.wideLayoutScope,
  });

  const HomeSettings.defaults()
      : dayStartTime = const TimeOfDay(hour: 8, minute: 0),
        blockDurationMinutes = 60,
        blockGapMinutes = 0,
        blockCount = 12,
        wideLayoutScope = HomeWideLayoutScope.week;

  final TimeOfDay dayStartTime;
  final int blockDurationMinutes;
  final int blockGapMinutes;
  final int blockCount;
  final HomeWideLayoutScope wideLayoutScope;

  HomeSettings copyWith({
    TimeOfDay? dayStartTime,
    int? blockDurationMinutes,
    int? blockGapMinutes,
    int? blockCount,
    HomeWideLayoutScope? wideLayoutScope,
  }) {
    return HomeSettings(
      dayStartTime: dayStartTime ?? this.dayStartTime,
      blockDurationMinutes: blockDurationMinutes ?? this.blockDurationMinutes,
      blockGapMinutes: blockGapMinutes ?? this.blockGapMinutes,
      blockCount: blockCount ?? this.blockCount,
      wideLayoutScope: wideLayoutScope ?? this.wideLayoutScope,
    );
  }
}
