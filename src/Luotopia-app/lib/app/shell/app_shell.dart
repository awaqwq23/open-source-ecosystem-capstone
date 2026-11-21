import 'package:flutter/material.dart'
    hide AppBar, NavigationBar, NavigationRail, Scaffold;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/shell/app_shell_destination.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/features/plugins/presentation/plugin_icons.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppShell extends ConsumerWidget {
  static const _compactNavBarHeightWithLabels = 84.0;
  static const _compactNavBarHeightIconsOnly = 72.0;

  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, PluginContribution entry, WidgetRef ref) {
    final branch = AppShellDestination.values.indexWhere(
      (d) => d.route == entry.route,
    );
    if (branch < 0) {
      context.go(entry.route);
      return;
    }
    if (entry.route == '/ai' && navigationShell.currentIndex != branch) {
      ref.read(aiPageActivationProvider.notifier).state++;
    }
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  String _label(BuildContext context, PluginContribution entry, WidgetRef ref) {
    final destination = AppShellDestination.values
        .where((d) => d.route == entry.route)
        .firstOrNull;
    return destination != null &&
            !ref
                .read(pluginManagerProvider)
                .hasPresentationOverride(entry.key, 'title')
        ? destination.label(context)
        : entry.title;
  }

  IconData _icon(PluginContribution entry, bool selected, WidgetRef ref) {
    final destination = AppShellDestination.values
        .where((d) => d.route == entry.route)
        .firstOrNull;
    if (destination != null &&
        !ref
            .read(pluginManagerProvider)
            .hasPresentationOverride(entry.key, 'icon')) {
      return selected ? destination.selectedIcon : destination.icon;
    }
    return pluginIcon(entry.icon);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navSettings = ref.watch(appNavigationSettingsProvider);
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final showLabels = navSettings.showLabels;
    final visibleDestinations = ref
        .watch(pluginManagerProvider)
        .entries(ContributionSlot.navigation);
    final location = GoRouterState.of(context).uri.path;
    final current = visibleDestinations
        .where(
          (c) =>
              c.route == location ||
              (c.nativeRoute == null &&
                  location.startsWith('/plugins/${c.pluginId}/${c.id}/')) ||
              (c.route != '/' && location.startsWith('${c.route}/')),
        )
        .firstOrNull;

    if (isCompact) {
      return ui.Scaffold(
        backgroundColor: ui.Theme.of(context).colorScheme.background,
        footers: [
          _buildNavigationBar(
            context,
            visibleDestinations,
            current,
            showLabels,
            ref,
          ),
        ],
        child: navigationShell,
      );
    }

    return ui.Scaffold(
      backgroundColor: ui.Theme.of(context).colorScheme.background,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildNavigationSidebar(
              context,
              visibleDestinations,
              current,
              showLabels,
              ref,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ui.Card(child: SizedBox.expand(child: navigationShell)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar(
    BuildContext context,
    List<PluginContribution> destinations,
    PluginContribution? current,
    bool showLabels,
    WidgetRef ref,
  ) {
    final compactNavBarHeight = showLabels
        ? _compactNavBarHeightWithLabels
        : _compactNavBarHeightIconsOnly;
    final navIconSize = showLabels ? 24.0 : 28.0;
    final compactNavBarPadding = showLabels
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.fromLTRB(8, 8, 8, 12);

    Widget bar(List<PluginContribution> destinations) => ui.NavigationBar(
      alignment: ui.NavigationBarAlignment.spaceEvenly,
      labelType: showLabels
          ? ui.NavigationLabelType.all
          : ui.NavigationLabelType.none,
      expanded: showLabels,
      expandedSize: compactNavBarHeight,
      padding: compactNavBarPadding,
      spacing: showLabels ? 4 : 0,
      selectedKey: current == null ? null : ValueKey(current.key),
      onSelected: (key) {
        final visibleIndex = destinations.indexWhere(
          (d) => ValueKey(d.key) == key,
        );
        if (visibleIndex >= 0) {
          _onTap(context, destinations[visibleIndex], ref);
        }
      },
      children: [
        for (final destination in destinations)
          ui.NavigationItem(
            key: ValueKey(destination.key),
            label: Text(_label(context, destination, ref)),
            child: Icon(
              _icon(destination, destination.key == current?.key, ref),
              size: navIconSize,
            ),
          ),
      ],
    );
    if (destinations.length <= 5) return bar(destinations);
    return SizedBox(
      height: compactNavBarHeight,
      child: Row(
        children: [
          SizedBox(width: 72, child: bar([destinations.first])),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: (destinations.length - 3) * 76.0,
                child: bar(destinations.sublist(1, destinations.length - 2)),
              ),
            ),
          ),
          SizedBox(
            width: 144,
            child: bar(destinations.sublist(destinations.length - 2)),
          ),
        ],
      ),
    );
  }

  ui.NavigationSidebar _buildNavigationSidebar(
    BuildContext context,
    List<PluginContribution> destinations,
    PluginContribution? current,
    bool showLabels,
    WidgetRef ref,
  ) {
    final navIconSize = showLabels ? 24.0 : 28.0;

    return ui.NavigationSidebar(
      selectedKey: current == null ? null : ValueKey(current.key),
      labelType: showLabels
          ? ui.NavigationLabelType.expanded
          : ui.NavigationLabelType.none,
      onSelected: (key) {
        final visibleIndex = destinations.indexWhere(
          (d) => ValueKey(d.key) == key,
        );
        if (visibleIndex >= 0) {
          _onTap(context, destinations[visibleIndex], ref);
        }
      },
      children: [
        for (final destination in destinations)
          ui.NavigationItem(
            key: ValueKey(destination.key),
            label: Text(_label(context, destination, ref)),
            child: Icon(
              _icon(destination, destination.key == current?.key, ref),
              size: navIconSize,
            ),
          ),
      ],
    );
  }
}
