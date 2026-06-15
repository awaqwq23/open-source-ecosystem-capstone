import 'package:flutter/foundation.dart';

enum MiddleTabMode { forum, ai }

@immutable
class NavigationSettings {
  const NavigationSettings({
    required this.showLabels,
    required this.middleTabMode,
    required this.defaultTab,
  });

  const NavigationSettings.defaults()
      : showLabels = false,
        middleTabMode = MiddleTabMode.forum,
        defaultTab = '/';

  final bool showLabels;
  final MiddleTabMode middleTabMode;
  final String defaultTab;

  NavigationSettings copyWith({
    bool? showLabels,
    MiddleTabMode? middleTabMode,
    String? defaultTab,
  }) {
    return NavigationSettings(
      showLabels: showLabels ?? this.showLabels,
      middleTabMode: middleTabMode ?? this.middleTabMode,
      defaultTab: defaultTab ?? this.defaultTab,
    );
  }
}
