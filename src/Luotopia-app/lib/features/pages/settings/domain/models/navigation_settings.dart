import 'package:flutter/foundation.dart';

enum MiddleTabMode { forum, ai }

@immutable
class NavigationSettings {
  const NavigationSettings({
    required this.showLabels,
    required this.middleTabMode,
    required this.defaultTab,
    this.visibleCount = 5,
  });

  const NavigationSettings.defaults()
    : showLabels = false,
      middleTabMode = MiddleTabMode.forum,
      defaultTab = '/',
      visibleCount = 5;

  final int visibleCount;
  final bool showLabels;
  final MiddleTabMode middleTabMode;
  final String defaultTab;

  NavigationSettings copyWith({
    bool? showLabels,
    int? visibleCount,
    MiddleTabMode? middleTabMode,
    String? defaultTab,
  }) {
    return NavigationSettings(
      showLabels: showLabels ?? this.showLabels,
      visibleCount: (visibleCount ?? this.visibleCount).clamp(4, 8),
      middleTabMode: middleTabMode ?? this.middleTabMode,
      defaultTab: defaultTab ?? this.defaultTab,
    );
  }
}
