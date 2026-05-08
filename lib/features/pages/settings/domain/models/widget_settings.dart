import 'package:flutter/foundation.dart';

enum WidgetRefreshInterval {
  minutes30,
  hour1,
  hours3,
}

@immutable
class WidgetSettings {
  const WidgetSettings({
    required this.enabled,
    required this.refreshInterval,
    required this.gridShowThisWeek,
    required this.listShowTodayAndPending,
    required this.followAppLanguage,
    required this.followAppTheme,
  });

  const WidgetSettings.defaults()
      : enabled = true,
        refreshInterval = WidgetRefreshInterval.hour1,
        gridShowThisWeek = true,
        listShowTodayAndPending = true,
        followAppLanguage = true,
        followAppTheme = true;

  final bool enabled;
  final WidgetRefreshInterval refreshInterval;
  final bool gridShowThisWeek;
  final bool listShowTodayAndPending;
  final bool followAppLanguage;
  final bool followAppTheme;

  WidgetSettings copyWith({
    bool? enabled,
    WidgetRefreshInterval? refreshInterval,
    bool? gridShowThisWeek,
    bool? listShowTodayAndPending,
    bool? followAppLanguage,
    bool? followAppTheme,
  }) {
    return WidgetSettings(
      enabled: enabled ?? this.enabled,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      gridShowThisWeek: gridShowThisWeek ?? this.gridShowThisWeek,
      listShowTodayAndPending: listShowTodayAndPending ?? this.listShowTodayAndPending,
      followAppLanguage: followAppLanguage ?? this.followAppLanguage,
      followAppTheme: followAppTheme ?? this.followAppTheme,
    );
  }
}
