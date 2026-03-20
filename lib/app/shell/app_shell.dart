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
    final theme = Theme.of(context);
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);

    if (isCompact) {
      return ui.Scaffold(
        backgroundColor: theme.colorScheme.surface,
        headers: [
          ui.AppBar(
            leading: const [Icon(Icons.rice_bowl_outlined)],
            title: Text(current.label(context)),
            subtitle: Text(context.l10n.appTitle),
            trailing: [
              ui.GhostButton(
                onPressed: () => context.go(AppShellDestination.settings.route),
                density: ui.ButtonDensity.icon,
                child: const Icon(Icons.tune),
              ),
            ],
          ),
          const ui.Divider(),
        ],
        footers: [
          const ui.Divider(),
          ui.NavigationBar(
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
          ),
        ],
        child: navigationShell,
      );
    }

    return ui.Scaffold(
      backgroundColor: theme.colorScheme.surface,
      headers: [
        ui.AppBar(
          leading: const [Icon(Icons.rice_bowl_outlined)],
          header: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              context.l10n.appTitle,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(current.label(context)),
          subtitle: const Text('MVVM workspace'),
        ),
        const ui.Divider(),
      ],
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ui.NavigationRail(
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
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.84),
                  ],
                ),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.6),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
