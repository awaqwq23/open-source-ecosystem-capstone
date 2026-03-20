import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

final appThemeModeProvider = StateProvider<ui.ThemeMode>((ref) {
  return ui.ThemeMode.system;
});
