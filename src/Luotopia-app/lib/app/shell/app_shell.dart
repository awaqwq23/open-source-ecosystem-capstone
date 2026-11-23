import 'package:flutter/gestures.dart';
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
    final visibleCount = ref
        .watch(appNavigationSettingsProvider)
        .visibleCount
        .clamp(4, 8);
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = destinations.length < visibleCount
            ? destinations.length
            : visibleCount;
        final itemWidth = constraints.maxWidth / (count == 0 ? 1 : count);
        final navIconSize =
            (showLabels ? 24.0 : 28.0) * (5 / visibleCount).clamp(0.7, 1.0);
        return SizedBox(
          height: compactNavBarHeight,
          child: _NavigationScroll(
            overflow: destinations.length > visibleCount,
            builder: (scrollState) => ReorderableListView.builder(
              scrollController: scrollState.controller,
              key: const ValueKey('compact-navigation-strip'),
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              autoScrollerVelocityScalar: 20,
              itemCount: destinations.length,
              onReorderStart: (_) => scrollState.dragRevision = ref
                  .read(pluginManagerProvider)
                  .revision,
              onReorder: (oldIndex, newIndex) async {
                final revision = scrollState.dragRevision;
                scrollState.dragRevision = null;
                try {
                  final manager = ref.read(pluginManagerProvider);
                  if (revision == null ||
                      manager.revision != revision ||
                      oldIndex < 0 ||
                      oldIndex >= destinations.length ||
                      newIndex < 0 ||
                      newIndex > destinations.length) {
                    throw StateError('Navigation changed during drag');
                  }
                  if (newIndex > oldIndex) newIndex--;
                  final order = destinations.map((entry) => entry.key).toList();
                  order.insert(newIndex, order.removeAt(oldIndex));
                  await manager.reorder(
                    ContributionSlot.navigation,
                    order,
                    expectedRevision: revision,
                  );
                } catch (_) {
                  if (context.mounted) {
                    ui.showToast(
                      context: context,
                      location: ui.ToastLocation.bottomCenter,
                      builder: (_, _) => const ui.Alert(
                        title: Text(
                          '导航排序保存失败，请重试 / Could not save navigation order',
                        ),
                      ),
                    );
                  }
                }
              },
              proxyDecorator: (child, index, animation) => child,
              itemBuilder: (context, index) {
                final destination = destinations[index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey('navigation-drag-${destination.key}'),
                  index: index,
                  child: SizedBox(
                    width: itemWidth,
                    child: ui.NavigationBar(
                      alignment: ui.NavigationBarAlignment.spaceEvenly,
                      labelType: showLabels
                          ? ui.NavigationLabelType.all
                          : ui.NavigationLabelType.none,
                      expanded: showLabels,
                      expandedSize: compactNavBarHeight,
                      padding: showLabels
                          ? const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            )
                          : const EdgeInsets.fromLTRB(4, 8, 4, 12),
                      selectedKey: current == null
                          ? null
                          : ValueKey(current.key),
                      onSelected: (_) => _onTap(context, destination, ref),
                      children: [
                        ui.NavigationItem(
                          key: ValueKey(destination.key),
                          label: Text(
                            _label(context, destination, ref),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          child: Icon(
                            _icon(
                              destination,
                              destination.key == current?.key,
                              ref,
                            ),
                            size: navIconSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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

class _NavigationScroll extends StatefulWidget {
  const _NavigationScroll({required this.overflow, required this.builder});
  final bool overflow;
  final Widget Function(_NavigationScrollState) builder;
  @override
  State<_NavigationScroll> createState() => _NavigationScrollState();
}

class _NavigationScrollState extends State<_NavigationScroll> {
  final controller = ScrollController();
  int? dragRevision;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(
      scrollbars: false,
      dragDevices: {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      },
    ),
    child: Scrollbar(
      controller: controller,
      thumbVisibility: widget.overflow,
      child: widget.builder(this),
    ),
  );
}
