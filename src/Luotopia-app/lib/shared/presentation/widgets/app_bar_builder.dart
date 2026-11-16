import 'package:flutter/material.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

/// 一级 Tab 页面标准 AppBar（ForumPage, CampusPage, ListPage, SettingsPage, AiPage）
///
/// 固定高度 56px，统一内边距，视觉参数一致。
/// 毛玻璃效果由 shadcn theme 中的 surfaceBlur / surfaceOpacity 提供。
ui.AppBar buildTabAppBar({
  required String title,
  List<Widget> trailing = const [],
}) {
  return ui.AppBar(
    title: Text(title),
    trailing: trailing,
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  );
}

/// 二级页面标准 AppBar（带返回按钮）
///
/// 适用于 Settings 子页面、ItemEditor、ItemDetail 等详情/编辑页面。
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
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  );
}
