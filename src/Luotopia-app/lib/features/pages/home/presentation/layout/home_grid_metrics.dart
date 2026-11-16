import 'dart:math' as math;

abstract final class HomeGridMetrics {
  static const timelineWidthFactor = 0.7;
  static const timelineCompactHeight = 34.0;
  static const timelineHorizontalPadding = 2.0;
  static const timelineCompactHorizontalPadding = 1.0;
  static const timelineCompactFontSize = 10.0;
  static const timelineFontSize = 10.5;
  static const timelineLineHeight = 0.92;
  static const timelineCompactLineHeight = 0.92;
  static const timelineDividerWidth = 14.0;

  static double computeColumnWidth({
    required double availableWidth,
    required int columnCount,
    required double columnGap,
    required double minimumColumnWidth,
  }) {
    final safeColumnCount = math.max(1, columnCount);
    final usableWidth = math.max(0.0, availableWidth - columnGap * safeColumnCount);
    final calculatedWidth = usableWidth / (safeColumnCount + timelineWidthFactor);
    return math.max(minimumColumnWidth, calculatedWidth);
  }

  static double computeTimelineWidth({
    required double cellWidth,
  }) {
    return cellWidth * timelineWidthFactor;
  }
}
