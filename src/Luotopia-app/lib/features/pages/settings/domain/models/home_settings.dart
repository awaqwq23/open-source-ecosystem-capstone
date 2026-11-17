import 'package:flutter/material.dart';

enum HomeWideLayoutScope {
  week,
  month,
}

enum HomeGridMode {
  timeGrid,
  courseGrid,
}

enum FirstDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
  today,
}

extension FirstDayOfWeekX on FirstDayOfWeek {
  int? get weekdayValue => switch (this) {
    FirstDayOfWeek.monday => DateTime.monday,
    FirstDayOfWeek.tuesday => DateTime.tuesday,
    FirstDayOfWeek.wednesday => DateTime.wednesday,
    FirstDayOfWeek.thursday => DateTime.thursday,
    FirstDayOfWeek.friday => DateTime.friday,
    FirstDayOfWeek.saturday => DateTime.saturday,
    FirstDayOfWeek.sunday => DateTime.sunday,
    FirstDayOfWeek.today => null,
  };
}

@immutable
class HomeSettings {
  const HomeSettings({
    required this.dayStartTime,
    required this.blockDurationMinutes,
    required this.blockGapMinutes,
    required this.blockCount,
    required this.wideLayoutScope,
    required this.gridMode,
    required this.itemOpacityPercent,
    required this.firstDayOfWeek,
  });

  const HomeSettings.defaults()
      : dayStartTime = const TimeOfDay(hour: 8, minute: 0),
        blockDurationMinutes = 60,
        blockGapMinutes = 0,
        blockCount = 12,
        wideLayoutScope = HomeWideLayoutScope.month,
        gridMode = HomeGridMode.courseGrid,
        itemOpacityPercent = 25,
        firstDayOfWeek = FirstDayOfWeek.monday;

  final TimeOfDay dayStartTime;
  final int blockDurationMinutes;
  final int blockGapMinutes;
  final int blockCount;
  final HomeWideLayoutScope wideLayoutScope;
  final HomeGridMode gridMode;
  final int itemOpacityPercent;
  final FirstDayOfWeek firstDayOfWeek;

  HomeSettings copyWith({
    TimeOfDay? dayStartTime,
    int? blockDurationMinutes,
    int? blockGapMinutes,
    int? blockCount,
    HomeWideLayoutScope? wideLayoutScope,
    HomeGridMode? gridMode,
    int? itemOpacityPercent,
    FirstDayOfWeek? firstDayOfWeek,
  }) {
    return HomeSettings(
      dayStartTime: dayStartTime ?? this.dayStartTime,
      blockDurationMinutes: blockDurationMinutes ?? this.blockDurationMinutes,
      blockGapMinutes: blockGapMinutes ?? this.blockGapMinutes,
      blockCount: blockCount ?? this.blockCount,
      wideLayoutScope: wideLayoutScope ?? this.wideLayoutScope,
      gridMode: gridMode ?? this.gridMode,
      itemOpacityPercent: itemOpacityPercent ?? this.itemOpacityPercent,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }
}
