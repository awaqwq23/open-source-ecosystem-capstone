import 'package:flutter/foundation.dart';

@immutable
class NavigationSettings {
  const NavigationSettings({
    required this.showLabels,
  });

  const NavigationSettings.defaults() : showLabels = false;

  final bool showLabels;

  NavigationSettings copyWith({
    bool? showLabels,
  }) {
    return NavigationSettings(
      showLabels: showLabels ?? this.showLabels,
    );
  }
}
