import 'package:flutter/material.dart';

abstract final class AppSemanticColors {
  static Color settingsSectionBackground(ThemeData theme) {
    return theme.colorScheme.surfaceContainerLowest;
  }

  static Color settingsSectionDivider(ThemeData theme) {
    return Color.alphaBlend(
      theme.colorScheme.outlineVariant.withValues(alpha: 0.28),
      theme.colorScheme.surfaceContainerLowest,
    );
  }

  static Color listSwipeBackground(ThemeData theme) {
    return Color.alphaBlend(
      theme.colorScheme.outlineVariant.withValues(alpha: 0.24),
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

  static Color onAgendaAccent(ThemeData theme, Color accent) {
    return ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
  }
}
