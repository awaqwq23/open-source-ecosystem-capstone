import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

/// 基础 AppBar 工厂 — 统一视觉参数（背景、模糊、透明度、内边距），
/// 不预设 leading/trailing/child 内容。各页面按需传入。
ui.AppBar buildAppBar({
  String? title,
  Widget? titleWidget,
  Widget? child,
  List<Widget> leading = const [],
  List<Widget> trailing = const [],
}) {
  return ui.AppBar(
    title: titleWidget ?? (title != null ? Text(title) : null),
    leading: leading,
    trailing: trailing,
    child: child,
  );
}
