import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';

abstract final class AppRouteTransitions {
  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      child: child,
      transitionDuration: AppMotion.slow,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> sharedAxis<T>({
    required LocalKey key,
    required Widget child,
    SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
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
          fillColor: Colors.transparent,
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeUpwards<T>({
    required LocalKey key,
    required Widget child,
    String? name,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      child: child,
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.enterCurve,
          reverseCurve: AppMotion.exitCurve,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: AppMotion.pageOffset,
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeThroughPage<T>(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return fadeThrough<T>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      child: child,
    );
  }

  static CustomTransitionPage<T> sharedAxisPage<T>(
    BuildContext context,
    GoRouterState state,
    Widget child, {
    SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
  }) {
    return sharedAxis<T>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      child: child,
      type: type,
    );
  }
}
