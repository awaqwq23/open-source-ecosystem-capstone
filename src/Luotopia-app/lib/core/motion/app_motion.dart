import 'package:flutter/widgets.dart';

abstract final class AppMotion {
  /// 微交互动画：字段组淡入 / 淡出等极短过渡。120ms。
  static const micro = Duration(milliseconds: 120);

  /// 快速动画：退出、Sheet 弹出、设置面板容器过渡等。160ms。
  static const fast = Duration(milliseconds: 160);

  /// 稍快动画：字段组尺寸展开、内容视图切换等。200ms。
  static const brisk = Duration(milliseconds: 200);

  /// 中速动画：页面内容入场。240ms。
  static const medium = Duration(milliseconds: 240);

  /// 慢速动画：整页路由转场。320ms。
  static const slow = Duration(milliseconds: 320);

  /// 页面转场偏移（Shared Axis 等路由级转场不适用）。
  static const pageOffset = Offset(0, 0.04);

  /// 内容入场偏移（AppEntrance 默认）。
  static const contentOffset = Offset(0, 0.03);

  /// 局部区域偏移（Sheet / 字段组等）。
  static const sectionOffset = Offset(0, 0.02);

  /// 入场缓动曲线。
  static const enterCurve = Curves.easeOutCubic;

  /// 出场缓动曲线。
  static const exitCurve = Curves.easeInCubic;

  /// 强调缓动曲线（尺寸变化等）。
  static const emphasizedCurve = Curves.easeInOutCubicEmphasized;
}
