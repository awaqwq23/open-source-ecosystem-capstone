import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luotopia/core/motion/app_motion.dart';

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

class AppSchemaTransition extends StatefulWidget {
  const AppSchemaTransition({
    required this.child,
    required this.schemaKey,
    super.key,
    this.duration = AppMotion.medium,
    this.reverseDuration = AppMotion.fast,
  });

  final Widget child;
  final Object schemaKey;
  final Duration duration;
  final Duration reverseDuration;

  static bool maybeDisableLocalFieldTransitions(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_AppSchemaTransitionScope>()
            ?.disableLocalFieldTransitions ??
        false;
  }

  @override
  State<AppSchemaTransition> createState() => _AppSchemaTransitionState();
}

class _AppSchemaTransitionState extends State<AppSchemaTransition> {
  late Object _currentSchemaKey = widget.schemaKey;
  bool _disableLocalFieldTransitions = false;
  int _transitionGeneration = 0;

  @override
  void didUpdateWidget(covariant AppSchemaTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schemaKey == widget.schemaKey) {
      return;
    }

    _currentSchemaKey = widget.schemaKey;
    _disableLocalFieldTransitions = true;
    final generation = ++_transitionGeneration;
    Future<void>.delayed(widget.duration, () {
      if (!mounted || generation != _transitionGeneration) {
        return;
      }
      setState(() {
        _disableLocalFieldTransitions = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: widget.duration,
        curve: AppMotion.emphasizedCurve,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: widget.duration,
          reverseDuration: widget.reverseDuration,
          switchInCurve: AppMotion.enterCurve,
          switchOutCurve: AppMotion.exitCurve,
          layoutBuilder: _topStackLayout,
          transitionBuilder: _fadeSlideTransition,
          child: _AppSchemaTransitionScope(
            key: ValueKey(_currentSchemaKey),
            disableLocalFieldTransitions: _disableLocalFieldTransitions,
            child: KeyedSubtree(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  static Widget _topStackLayout(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      alignment: Alignment.topCenter,
      fit: StackFit.passthrough,
      children: [
        ...previousChildren,
        ?currentChild,
      ],
    );
  }

  static Widget _fadeSlideTransition(Widget child, Animation<double> animation) {
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
  }
}

class AppCollapsibleFieldGroup extends StatelessWidget {
  const AppCollapsibleFieldGroup({
    required this.visible,
    required this.child,
    super.key,
    this.fadeDuration = AppMotion.micro,
    this.sizeDuration = AppMotion.brisk,
  });

  final bool visible;
  final Widget child;
  final Duration fadeDuration;
  final Duration sizeDuration;

  @override
  Widget build(BuildContext context) {
    final disableLocalTransition =
        AppSchemaTransition.maybeDisableLocalFieldTransitions(context);
    if (disableLocalTransition) {
      return visible ? child : const SizedBox.shrink();
    }

    return ClipRect(
      child: AnimatedSwitcher(
        duration: sizeDuration,
        reverseDuration: sizeDuration,
        switchInCurve: AppMotion.enterCurve,
        switchOutCurve: AppMotion.exitCurve,
        transitionBuilder: (child, animation) {
          final fadeFraction =
              (fadeDuration.inMicroseconds / sizeDuration.inMicroseconds)
                  .clamp(0.0, 1.0)
                  .toDouble();
          final opacity = CurvedAnimation(
            parent: animation,
            curve: Interval(
              0,
              fadeFraction,
              curve: AppMotion.enterCurve,
            ),
            reverseCurve: AppMotion.exitCurve,
          );
          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: FadeTransition(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: visible
            ? KeyedSubtree(
                key: const ValueKey('app-collapsible-field-visible'),
                child: child,
              )
            : const SizedBox.shrink(
                key: ValueKey('app-collapsible-field-hidden'),
              ),
      ),
    );
  }
}

class _AppSchemaTransitionScope extends InheritedWidget {
  const _AppSchemaTransitionScope({
    required this.disableLocalFieldTransitions,
    required super.child,
    super.key,
  });

  final bool disableLocalFieldTransitions;

  @override
  bool updateShouldNotify(_AppSchemaTransitionScope oldWidget) {
    return oldWidget.disableLocalFieldTransitions != disableLocalFieldTransitions;
  }
}
