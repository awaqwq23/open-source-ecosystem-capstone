import 'package:flutter/material.dart';

IconData pluginIcon(String name) => switch (name) {
  'timer' => Icons.timer_outlined,
  'tune' => Icons.tune,
  'home' => Icons.home_outlined,
  'list' => Icons.list_alt,
  'forum' => Icons.forum_outlined,
  'school' => Icons.school_outlined,
  'settings' => Icons.settings_outlined,
  'book' => Icons.menu_book,
  'calendar' => Icons.calendar_month,
  'star' => Icons.auto_awesome_outlined,
  'code' => Icons.code,
  'cloud' => Icons.cloud_outlined,
  'chart' => Icons.bar_chart,
  _ => Icons.info_outline,
};

Color pluginColor(String name) => switch (name) {
  'blue' => Colors.blue,
  'green' => Colors.green,
  'amber' => Colors.amber,
  'purple' => Colors.purple,
  'pink' => Colors.pink,
  'slate' => Colors.blueGrey,
  _ => const Color(0xFF4DA3FF),
};
