import 'package:flutter/material.dart';
import 'package:huajuan_agenda/app/router/app_route_paths.dart';

enum AppShellDestination {
  home(
    route: AppRoutePaths.home,
    icon: Icons.calendar_view_week_outlined,
    selectedIcon: Icons.calendar_view_week,
  ),
  list(
    route: AppRoutePaths.list,
    icon: Icons.checklist_rtl_outlined,
    selectedIcon: Icons.checklist_rtl,
  ),
  ai(
    route: AppRoutePaths.ai,
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome,
  ),
  itemEditor(
    route: AppRoutePaths.itemEditor,
    icon: Icons.add_box_outlined,
    selectedIcon: Icons.add_box,
  ),
  settings(
    route: AppRoutePaths.settings,
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  );

  const AppShellDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });

  final String route;
  final IconData icon;
  final IconData selectedIcon;
}
