import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';

class AppEntrance extends StatelessWidget {
  const AppEntrance({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.offset = AppMotion.contentOffset,
    this.duration = AppMotion.medium,
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          delay: delay,
          duration: duration,
          curve: AppMotion.enterCurve,
        )
        .slide(
          begin: offset,
          end: Offset.zero,
          delay: delay,
          duration: duration,
          curve: AppMotion.enterCurve,
        );
  }
}

class AppSheetEntrance extends StatelessWidget {
  const AppSheetEntrance({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppEntrance(
      duration: AppMotion.fast,
      offset: AppMotion.sectionOffset,
      child: child,
    );
  }
}

class AppSwitchingContent extends StatelessWidget {
  const AppSwitchingContent({
    required this.child,
    required this.contentKey,
    super.key,
  });

  final Widget child;
  final Object contentKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.medium,
      reverseDuration: AppMotion.fast,
      switchInCurve: AppMotion.enterCurve,
      switchOutCurve: AppMotion.exitCurve,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppMotion.enterCurve,
          reverseCurve: AppMotion.exitCurve,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: AppMotion.sectionOffset,
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(contentKey),
        child: child,
      ),
    );
  }
}
