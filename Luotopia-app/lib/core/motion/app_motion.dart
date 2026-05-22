import 'package:flutter/widgets.dart';

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 160);
  static const medium = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 320);

  static const pageOffset = Offset(0, 0.04);
  static const contentOffset = Offset(0, 0.03);
  static const sectionOffset = Offset(0, 0.02);

  static const enterCurve = Curves.easeOutCubic;
  static const exitCurve = Curves.easeInCubic;
  static const emphasizedCurve = Curves.easeInOutCubicEmphasized;
}
