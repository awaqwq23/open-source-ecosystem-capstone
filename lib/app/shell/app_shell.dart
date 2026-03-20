import 'package:flutter/material.dart'
    hide AppBar, NavigationBar, NavigationRail, Scaffold;
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/shell/app_shell_destination.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppShell extends StatelessWidget {
  static const _compactNavBarHeight = 72.0;

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
  Widget build(BuildContext context) {
    final destinations = AppShellDestination.values;
    final current = destinations[navigationShell.currentIndex];
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    if (isCompact) {
      return ui.Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        footers: [
          const ui.Divider(),
          _buildNavigationBar(context, destinations, current),
        ],
        child: navigationShell,
      );
    }

    return ui.Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNavigationSidebar(context, destinations, current),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ui.Card(
                child: SizedBox.expand(child: navigationShell),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ui.NavigationBar _buildNavigationBar(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
  ) {
    return ui.NavigationBar(
      alignment: ui.NavigationBarAlignment.spaceEvenly,
      labelType: ui.NavigationLabelType.all,
      expanded: true,
      expandedSize: _compactNavBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      spacing: 4,
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
            ),
          ),
      ],
    );
  }

  ui.NavigationSidebar _buildNavigationSidebar(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
  ) {
    return ui.NavigationSidebar(
      selectedKey: ValueKey(current.route),
      labelType: ui.NavigationLabelType.expanded,
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
            ),
          ),
      ],
    );
  }
}
