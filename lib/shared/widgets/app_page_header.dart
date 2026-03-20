import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.leading = const <Widget>[],
    this.trailing = const <Widget>[],
    this.centerTitleWhenCompact = false,
    this.centerTitleWhenExpanded = false,
    this.padding,
    super.key,
  });

  final Widget title;
  final List<Widget> leading;
  final List<Widget> trailing;
  final bool centerTitleWhenCompact;
  final bool centerTitleWhenExpanded;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final centerTitle =
        isCompact ? centerTitleWhenCompact : centerTitleWhenExpanded;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            centerTitle
                ? _CenteredHeaderRow(
                    title: title,
                    leading: leading,
                    trailing: trailing,
                  )
                : _InlineHeaderRow(
                    title: title,
                    leading: leading,
                    trailing: trailing,
                  ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class AppPageHeaderTitle extends StatelessWidget {
  const AppPageHeaderTitle({
    required this.text,
    this.onPressed,
    this.showDropdownIndicator = false,
    this.center = false,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool showDropdownIndicator;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (showDropdownIndicator) ...[
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ],
    );

    if (onPressed == null) {
      return titleWidget;
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      child: titleWidget,
    );
  }
}

class _CenteredHeaderRow extends StatelessWidget {
  const _CenteredHeaderRow({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final Widget title;
  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: leading,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: IconTheme.merge(
              data: IconThemeData(
                color: Theme.of(context).colorScheme.onSurface,
                size: 18,
              ),
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
                child: title,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: trailing,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineHeaderRow extends StatelessWidget {
  const _InlineHeaderRow({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final Widget title;
  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          ...leading,
          if (leading.isNotEmpty) const SizedBox(width: 8),
          Expanded(
            child: IconTheme.merge(
              data: IconThemeData(
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
              child: DefaultTextStyle.merge(
                style: theme.textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
                child: title,
              ),
            ),
          ),
          if (trailing.isNotEmpty) const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: trailing,
          ),
        ],
      ),
    );
  }
}
