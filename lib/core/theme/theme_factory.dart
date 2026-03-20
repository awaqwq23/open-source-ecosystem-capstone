import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

abstract final class AppThemeFactory {
  static ui.ThemeData light() {
    return const ui.ThemeData(
      colorScheme: ui.ColorSchemes.lightSlate,
      radius: 0.95,
      scaling: 1,
      surfaceOpacity: 0.82,
      surfaceBlur: 10,
    );
  }

  static ui.ThemeData dark() {
    return const ui.ThemeData.dark(
      colorScheme: ui.ColorSchemes.darkSlate,
      radius: 0.95,
      scaling: 1,
      surfaceOpacity: 0.74,
      surfaceBlur: 18,
    );
  }
}
