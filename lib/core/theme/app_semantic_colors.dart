import 'package:flutter/material.dart';

abstract final class AppSemanticColors {
  static Color settingsSectionBackground(ThemeData theme) {
    return theme.colorScheme.surfaceContainerLowest;
  }

  static Color settingsSectionDivider(ThemeData theme) {
    final alpha = theme.brightness == Brightness.dark ? 0.46 : 0.28;
    return Color.alphaBlend(
      theme.colorScheme.outlineVariant.withValues(alpha: alpha),
      theme.colorScheme.surfaceContainerLowest,
    );
  }

  static Color listSwipeBackground(ThemeData theme) {
    final alpha = theme.brightness == Brightness.dark ? 0.42 : 0.24;
    return Color.alphaBlend(
      theme.colorScheme.outlineVariant.withValues(alpha: alpha),
      theme.colorScheme.surfaceContainerHighest,
    );
  }

  static Color listSwipeEditAction(ThemeData theme) {
    return theme.colorScheme.primary;
  }

  static Color listSwipeDeleteAction(ThemeData theme) {
    return theme.colorScheme.error;
  }

  static Color listImportantStar(ThemeData theme) {
    return theme.colorScheme.tertiary;
  }

  static Color listSwipePassiveIcon(ThemeData theme) {
    return theme.colorScheme.onSurfaceVariant;
  }

  static Color aiConnectionSuccessText(ThemeData theme) {
    return theme.colorScheme.tertiary;
  }

  static Color onAgendaAccent(Color accent) {
    final brightness = ThemeData.estimateBrightnessForColor(accent);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
