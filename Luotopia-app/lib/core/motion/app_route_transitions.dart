import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/core/motion/app_motion.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

abstract final class AppRouteTransitions {
  static CustomTransitionPage<T> sharedAxis<T>({
    required LocalKey key,
    required Widget child,
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      child: child,
      transitionDuration: AppMotion.slow,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: type,
          // 必须使用不透明背景兜底：SharedAxisTransition 进出场是错峰
          // 淡入淡出，过渡中段两页都接近全透明，若 fillColor 透明会穿透到
          // 底层（留白处发黑）。这里填入 shadcn 的页面背景色。
          fillColor: ui.Theme.of(context).colorScheme.background,
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> sharedAxisPage<T>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
  }) {
    return sharedAxis<T>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      child: child,
      type: type,
    );
  }
}
