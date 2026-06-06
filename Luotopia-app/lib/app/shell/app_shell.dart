import 'package:flutter/material.dart'
    hide AppBar, NavigationBar, NavigationRail, Scaffold;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/shell/app_shell_destination.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:luotopia/features/pages/home/presentation/viewmodels/home_header_view_model.dart';
import 'package:luotopia/features/pages/settings/domain/models/navigation_settings.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AppShell extends ConsumerWidget {
  static const _compactNavBarHeightWithLabels = 84.0;
  static const _compactNavBarHeightIconsOnly = 72.0;

  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onTap(int visibleIndex, List<int> branchIndices, WidgetRef ref) {
    final branchIndex = branchIndices[visibleIndex];
    // 从其他标签页切换到 AI 页时，触发新 session 创建
    final allDestinations = AppShellDestination.values;
    final targetDestination = allDestinations[branchIndex];
    final currentDestination = allDestinations[navigationShell.currentIndex];
    if (targetDestination == AppShellDestination.home &&
        currentDestination != AppShellDestination.home) {
      ref.read(homeHeaderViewModelProvider.notifier).showCurrentWeek();
    }
    if (targetDestination == AppShellDestination.ai &&
        currentDestination != AppShellDestination.ai) {
      ref.read(aiPageActivationProvider.notifier).state++;
    }
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navSettings = ref.watch(appNavigationSettingsProvider);
    final middleTabMode = navSettings.middleTabMode;
    final isCompact = !ResponsiveBreakpoints.of(context).largerThan(MOBILE);
    final showLabels = navSettings.showLabels;

    final branchIndices = switch (middleTabMode) {
      MiddleTabMode.forum => const [0, 1, 2, 4, 5],
      MiddleTabMode.ai => const [0, 1, 3, 4, 5],
    };
    final allDestinations = AppShellDestination.values;
    final visibleDestinations = branchIndices
        .map((i) => allDestinations[i])
        .toList(growable: false);
    final current = allDestinations[navigationShell.currentIndex];

    if (isCompact) {
      return ui.Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        footers: [
          _buildNavigationBar(
            context,
            visibleDestinations,
            current,
            showLabels,
            branchIndices,
            ref,
          ),
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
            child: _buildNavigationSidebar(
              context,
              visibleDestinations,
              current,
              showLabels,
              branchIndices,
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

  ui.NavigationBar _buildNavigationBar(
    BuildContext context,
    List<AppShellDestination> destinations,
    AppShellDestination current,
    bool showLabels,
    List<int> branchIndices,
    WidgetRef ref,
  ) {
    final compactNavBarHeight = showLabels
        ? _compactNavBarHeightWithLabels
        : _compactNavBarHeightIconsOnly;
    final navIconSize = showLabels ? 24.0 : 28.0;
    final compactNavBarPadding = showLabels
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.fromLTRB(8, 8, 8, 12);

    return ui.NavigationBar(
      alignment: ui.NavigationBarAlignment.spaceEvenly,
      labelType: showLabels
          ? ui.NavigationLabelType.all
          : ui.NavigationLabelType.none,
      expanded: showLabels,
      expandedSize: compactNavBarHeight,
      padding: compactNavBarPadding,
      spacing: showLabels ? 4 : 0,
      selectedKey: ValueKey(current.route),
      onSelected: (key) {
        final visibleIndex = destinations.indexWhere(
          (d) => ValueKey(d.route) == key,
        );
        if (visibleIndex >= 0) {
          _onTap(visibleIndex, branchIndices, ref);
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
    List<int> branchIndices,
    WidgetRef ref,
  ) {
    final navIconSize = showLabels ? 24.0 : 28.0;

    return ui.NavigationSidebar(
      selectedKey: ValueKey(current.route),
      labelType: showLabels
          ? ui.NavigationLabelType.expanded
          : ui.NavigationLabelType.none,
      onSelected: (key) {
        final visibleIndex = destinations.indexWhere(
          (d) => ValueKey(d.route) == key,
        );
        if (visibleIndex >= 0) {
          _onTap(visibleIndex, branchIndices, ref);
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
