import 'package:flutter/material.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';

enum AppShellDestination {
  home(
    route: AppRoutePaths.home,
    icon: AppIcons.homeOutlined,
    selectedIcon: AppIcons.homeFilled,
  ),
  list(
    route: AppRoutePaths.list,
    icon: AppIcons.listOutlined,
    selectedIcon: AppIcons.listFilled,
  ),
  forum(
    route: AppRoutePaths.forum,
    icon: AppIcons.forumOutlined,
    selectedIcon: AppIcons.forumFilled,
  ),
  campus(
    route: AppRoutePaths.campus,
    icon: AppIcons.campusOutlined,
    selectedIcon: AppIcons.campusFilled,
  ),
  settings(
    route: AppRoutePaths.settings,
    icon: AppIcons.settingsOutlined,
    selectedIcon: AppIcons.settingsFilled,
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
