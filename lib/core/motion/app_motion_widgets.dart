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
        if (currentChild != null) currentChild,
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

class AppCollapsibleFieldGroup extends StatefulWidget {
  const AppCollapsibleFieldGroup({
    required this.visible,
    required this.child,
    super.key,
    this.fadeDuration = const Duration(milliseconds: 120),
    this.sizeDuration = const Duration(milliseconds: 180),
  });

  final bool visible;
  final Widget child;
  final Duration fadeDuration;
  final Duration sizeDuration;

  @override
  State<AppCollapsibleFieldGroup> createState() => _AppCollapsibleFieldGroupState();
}

class _AppCollapsibleFieldGroupState extends State<AppCollapsibleFieldGroup> {
  Widget? _retainedChild;
  bool _includeChild = false;
  bool _showSize = false;
  bool _showOpacity = false;
  int _animationGeneration = 0;

  @override
  void initState() {
    super.initState();
    _retainedChild = widget.child;
    _includeChild = widget.visible;
    _showSize = widget.visible;
    _showOpacity = widget.visible;
  }

  @override
  void didUpdateWidget(covariant AppCollapsibleFieldGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final disableLocalTransition = _isLocalFieldTransitionDisabled(context);

    if (disableLocalTransition) {
      _snapToTarget();
      return;
    }

    if (widget.visible) {
      _retainedChild = widget.child;
    } else if (oldWidget.visible) {
      _retainedChild = oldWidget.child;
    }

    if (oldWidget.visible == widget.visible) {
      if (widget.visible) {
        _retainedChild = widget.child;
      }
      return;
    }

    if (widget.visible) {
      _expandThenFadeIn();
      return;
    }

    _fadeOutThenCollapse();
  }

  @override
  Widget build(BuildContext context) {
    final disableLocalTransition =
        AppSchemaTransition.maybeDisableLocalFieldTransitions(context);
    if (disableLocalTransition) {
      return widget.visible ? widget.child : const SizedBox.shrink();
    }

    if (!_includeChild || _retainedChild == null) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: IgnorePointer(
        ignoring: !_showOpacity || !_showSize,
        child: ExcludeSemantics(
          excluding: !_showOpacity || !_showSize,
          child: AnimatedSize(
            duration: widget.sizeDuration,
            curve: AppMotion.emphasizedCurve,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              duration: widget.fadeDuration,
              curve: _showOpacity ? AppMotion.enterCurve : AppMotion.exitCurve,
              opacity: _showOpacity ? 1 : 0,
              child: _showSize ? _retainedChild! : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  void _snapToTarget() {
    _animationGeneration++;
    _retainedChild = widget.child;
    _includeChild = widget.visible;
    _showSize = widget.visible;
    _showOpacity = widget.visible;
  }

  void _expandThenFadeIn() {
    final generation = ++_animationGeneration;
    setState(() {
      _retainedChild = widget.child;
      _includeChild = true;
      _showSize = true;
      _showOpacity = false;
    });

    Future<void>.delayed(widget.sizeDuration, () {
      if (!mounted || generation != _animationGeneration) {
        return;
      }
      setState(() {
        _showOpacity = true;
      });
    });
  }

  void _fadeOutThenCollapse() {
    final generation = ++_animationGeneration;
    setState(() {
      _includeChild = true;
      _showSize = true;
      _showOpacity = false;
    });

    Future<void>.delayed(widget.fadeDuration, () {
      if (!mounted || generation != _animationGeneration) {
        return;
      }
      setState(() {
        _showSize = false;
      });
    });

    Future<void>.delayed(widget.fadeDuration + widget.sizeDuration, () {
      if (!mounted || generation != _animationGeneration) {
        return;
      }
      setState(() {
        _includeChild = false;
        _retainedChild = null;
      });
    });
  }
}

bool _isLocalFieldTransitionDisabled(BuildContext context) {
  final scope = context
      .getElementForInheritedWidgetOfExactType<_AppSchemaTransitionScope>()
      ?.widget;
  return scope is _AppSchemaTransitionScope &&
      scope.disableLocalFieldTransitions;
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
