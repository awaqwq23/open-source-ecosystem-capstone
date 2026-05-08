import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';

extension AppNavigatorX on BuildContext {
  Future<T?> openSecondary<T>(
    String path, {
    Object? extra,
  }) {
    return push<T>(path, extra: extra);
  }

  Future<T?> openModal<T>(
    String path, {
    Object? extra,
  }) {
    return push<T>(path, extra: extra);
  }

  Future<T?> openItemEditorFlow<T>({
    Object? extra,
    bool showTypePickerOnLaunch = false,
    String? presetType,
  }) {
    final query = <String, String>{
      if (showTypePickerOnLaunch) 'showTypePicker': '1',
      if (presetType != null && presetType.trim().isNotEmpty) 'presetType': presetType.trim(),
    };
    final uri = Uri(
      path: AppRoutePaths.itemEditorFlow,
      queryParameters: query.isEmpty ? null : query,
    );
    return openSecondary<T>(uri.toString(), extra: extra);
  }
}
