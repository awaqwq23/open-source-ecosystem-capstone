import 'package:flutter/material.dart'
    hide AppBar, NavigationBar, NavigationRail, Scaffold;
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/shell/app_shell_destination.dart';
import 'package:huajuan_agenda/core/motion/app_motion.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppShell extends ConsumerWidget {
  static const _compactNavBarHeightWithLabels = 84.0;
  static const _compactNavBarHeightIconsOnly = 72.0;

  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = AppShellDestination.values;
    final current = destinations[navigationShell.currentIndex];
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final showLabels = ref.watch(appNavigationSettingsProvider).showLabels;

    if (isCompact) {
      return ui.Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        footers: [_buildNavigationBar(context, destinations, current, showLabels)],
        child: _buildAnimatedContent(current),
      );
    }

    return ui.Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNavigationSidebar(
              context,
              destinations,
              current,
              showLabels,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ui.Card(
                child: SizedBox.expand(child: _buildAnimatedContent(current)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContent(AppShellDestination current) {
    return PageTransitionSwitcher(
      duration: AppMotion.slow,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(current.route),
        child: navigationShell,
      ),
    );
  }

  ui.NavigationBar _buildNavigationBar(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
    bool showLabels,
  ) {
    final compactNavBarHeight =
        showLabels ? _compactNavBarHeightWithLabels : _compactNavBarHeightIconsOnly;
    final navIconSize = showLabels ? 24.0 : 28.0;
    final compactNavBarPadding = showLabels
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.fromLTRB(8, 8, 8, 12);

    return ui.NavigationBar(
      alignment: ui.NavigationBarAlignment.spaceEvenly,
      labelType:
          showLabels ? ui.NavigationLabelType.all : ui.NavigationLabelType.none,
      expanded: showLabels,
      expandedSize: compactNavBarHeight,
      padding: compactNavBarPadding,
      spacing: showLabels ? 4 : 0,
      selectedKey: ValueKey(current.route),
      onSelected: (key) {
        final index = destinations.indexWhere(
          (destination) => ValueKey(destination.route) == key,
        );
        if (index >= 0) {
          _onTap(index);
        }
      },
      children: [
        for (final destination in destinations)
          ui.NavigationItem(
            key: ValueKey(destination.route),
            label: Text(destination.label(context)),
            child: Icon(
              destination.route == current.route
                  ? destination.selectedIcon
                  : destination.icon,
              size: navIconSize,
            ),
          ),
      ],
    );
  }

  ui.NavigationSidebar _buildNavigationSidebar(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
    bool showLabels,
  ) {
    final navIconSize = showLabels ? 24.0 : 28.0;

    return ui.NavigationSidebar(
      selectedKey: ValueKey(current.route),
      labelType: showLabels
          ? ui.NavigationLabelType.expanded
          : ui.NavigationLabelType.none,
      onSelected: (key) {
        final index = destinations.indexWhere(
          (destination) => ValueKey(destination.route) == key,
        );
        if (index >= 0) {
          _onTap(index);
        }
      },
      children: [
        for (final destination in destinations)
          ui.NavigationItem(
            key: ValueKey(destination.route),
            label: Text(destination.label(context)),
            child: Icon(
              destination.route == current.route
                  ? destination.selectedIcon
                  : destination.icon,
              size: navIconSize,
            ),
          ),
      ],
    );
  }
}
