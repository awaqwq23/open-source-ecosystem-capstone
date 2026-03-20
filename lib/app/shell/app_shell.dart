import 'package:flutter/material.dart'
    hide AppBar, NavigationBar, NavigationRail, Scaffold;
import 'package:go_router/go_router.dart';
import 'package:huajuan_agenda/app/shell/app_shell_destination.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppShell extends StatelessWidget {
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
        headers: [
          _buildAppBar(context, current),
          const ui.Divider(),
        ],
        footers: [
          const ui.Divider(),
          _buildNavigationBar(context, destinations, current),
        ],
        child: navigationShell,
      );
    }

    return ui.Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      headers: [
        _buildAppBar(context, current),
        const ui.Divider(),
      ],
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNavigationRail(context, destinations, current),
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

  ui.AppBar _buildAppBar(
    BuildContext context,
    AppShellDestination current,
  ) {
    return ui.AppBar(
      title: Text(current.label(context)),
      trailing: [
        ui.GhostButton(
          onPressed: () => context.go(AppShellDestination.settings.route),
          density: ui.ButtonDensity.icon,
          child: const Icon(Icons.tune),
        ),
      ],
    );
  }

  ui.NavigationBar _buildNavigationBar(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
  ) {
    return ui.NavigationBar(
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

  ui.NavigationRail _buildNavigationRail(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
  ) {
    return ui.NavigationRail(
      selectedKey: ValueKey(current.route),
      expanded: true,
      labelType: ui.NavigationLabelType.all,
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
