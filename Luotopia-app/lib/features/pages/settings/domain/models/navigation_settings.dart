import 'package:flutter/foundation.dart';

enum MiddleTabMode { forum, ai }

@immutable
class NavigationSettings {
  const NavigationSettings({
    required this.showLabels,
    required this.middleTabMode,
  });

  const NavigationSettings.defaults()
      : showLabels = false,
        middleTabMode = MiddleTabMode.forum;

  final bool showLabels;
  final MiddleTabMode middleTabMode;

  NavigationSettings copyWith({
    bool? showLabels,
    MiddleTabMode? middleTabMode,
  }) {
    return NavigationSettings(
      showLabels: showLabels ?? this.showLabels,
      middleTabMode: middleTabMode ?? this.middleTabMode,
    );
  }
}
