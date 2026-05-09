import 'package:flutter/material.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

/// 一级 Tab 页面标准 AppBar（ForumPage, CampusPage, ListPage, SettingsPage, AiPage）
ui.AppBar buildTabAppBar({
  required String title,
  List<Widget> trailing = const [],
}) {
  return ui.AppBar(
    title: Text(title),
    trailing: trailing,
  );
}

/// 二级页面标准 AppBar（带返回按钮）
ui.AppBar buildSecondaryAppBar(
  BuildContext context, {
  required String title,
  List<Widget> trailing = const [],
  VoidCallback? onBack,
}) {
  return ui.AppBar(
    leading: [
      ui.IconButton.ghost(
        icon: const Icon(AppIcons.back),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
    ],
    title: Text(title),
    trailing: trailing,
  );
}

/// HomePage 专用 AppBar（透明背景 + 自定义 child 布局）
ui.AppBar buildHomeAppBar({
  required Widget child,
}) {
  return ui.AppBar(
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    surfaceBlur: 0,
    surfaceOpacity: 0,
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
    child: SizedBox(height: 72, child: child),
  );
}
