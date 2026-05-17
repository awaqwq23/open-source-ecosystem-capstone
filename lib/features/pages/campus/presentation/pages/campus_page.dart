import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/components/wallpaper/presentation/widgets/app_wallpaper_background.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CampusPage extends StatelessWidget {
  const CampusPage({super.key});

  static const _gridApps = <_CampusApp>[
    _CampusApp(icon: Icons.table_chart_outlined, name: '课程表', colorAssoc: ItemColorOption.sky),
    _CampusApp(icon: Icons.event_seat, name: '自习预约', colorAssoc: ItemColorOption.indigo),
    _CampusApp(icon: Icons.local_library, name: '图书借阅', colorAssoc: ItemColorOption.amber),
    _CampusApp(icon: Icons.sports_soccer, name: '运动场馆', colorAssoc: ItemColorOption.lime),
    _CampusApp(icon: Icons.credit_card, name: '珞珈E卡', colorAssoc: ItemColorOption.sky),
    _CampusApp(icon: Icons.qr_code, name: 'E卡付款码', colorAssoc: ItemColorOption.jade),
    _CampusApp(icon: Icons.grading, name: '成绩', colorAssoc: ItemColorOption.coral),
    _CampusApp(icon: Icons.meeting_room, name: '空闲教室', colorAssoc: ItemColorOption.teal),
    _CampusApp(icon: Icons.school, name: '蹭课', colorAssoc: ItemColorOption.rose),
    _CampusApp(icon: Icons.calendar_month, name: '全校课表', colorAssoc: ItemColorOption.violet),
    _CampusApp(icon: Icons.assignment, name: '课程给分', colorAssoc: ItemColorOption.orchid),
    _CampusApp(icon: Icons.rate_review, name: '课程评价', colorAssoc: ItemColorOption.crimson),
    _CampusApp(icon: Icons.folder, name: '学习资料共享', colorAssoc: ItemColorOption.slate),
  ];

  @override
  Widget build(BuildContext context) {
    return ui.Scaffold(
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: AppWallpaperBackground()),
          ),
          // Slight dark overlay for readability over bright images
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.10)),
          ),
          // Scrollable content
          SafeArea(
            child: BackdropGroup(
              child: CustomScrollView(
                slivers: [
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    sliver: SliverToBoxAdapter(child: _WeatherCard()),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: _AppGrid(apps: _gridApps),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _CampusGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main weather info: single row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny, size: 48, color: Colors.orange.shade300),
              const SizedBox(width: 14),
              Text(
                '28°',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              // Middle: condition + feels-like + today's range
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '晴 · 18°/30°',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '武汉大学',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // AQI compact card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.air, size: 16, color: Colors.green.shade400),
                        const SizedBox(width: 4),
                        Text(
                          '优',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AQI 25',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Hourly forecast (no divider) ──
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _mockHourly.length,
              separatorBuilder: (_, _) => const SizedBox(width: 2),
              itemBuilder: (context, index) {
                final h = _mockHourly[index];
                final isNow = h.time == '现在';
                return Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: isNow ? colors.primary.withValues(alpha: 0.10) : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isNow
                        ? Border.all(color: colors.primary.withValues(alpha: 0.2))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        h.time,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11,
                          color: isNow
                              ? colors.primary
                              : colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),

                      const SizedBox(height: 4),
                      Icon(h.icon, size: 20, color: Colors.orange.shade300),
                      const SizedBox(height: 4),
                      Text(
                        h.temp,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: colors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── App feature reminders ──
          _ReminderTile(
            icon: Icons.school,
            iconColor: Colors.indigo.shade300,
            text: '下午没课，试试一节「古代汉语」？',
            onTap: () => _showInteraction(context, '蹭课推荐'),
          ),
          const SizedBox(height: 8),
          _ReminderTile(
            icon: Icons.newspaper,
            iconColor: Colors.blue.shade400,
            text: '校园新闻：五一调休通知新鲜出炉',
            onTap: () => _showInteraction(context, '校园新闻'),
          ),
          const SizedBox(height: 8),
          _ReminderTile(
            icon: Icons.local_library,
            iconColor: Colors.teal.shade300,
            text: '图书馆：《罪与罚》借阅将在三天后到期',
            onTap: () => _showInteraction(context, '借阅详情'),
          ),
        ],
      ),
    );
  }

  void _showInteraction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Compact single-line reminder tile
class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.onSurface.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.75),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: colors.onSurface.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// Mock hourly forecast data
class _HourForecast {
  const _HourForecast({required this.time, required this.icon, required this.temp});
  final String time;
  final IconData icon;
  final String temp;
}

const _mockHourly = <_HourForecast>[
  _HourForecast(time: '现在', icon: Icons.wb_sunny, temp: '28℃'),
  _HourForecast(time: '10:00', icon: Icons.wb_sunny, temp: '29℃'),
  _HourForecast(time: '11:00', icon: Icons.wb_sunny, temp: '30℃'),
  _HourForecast(time: '12:00', icon: Icons.wb_cloudy, temp: '31℃'),
  _HourForecast(time: '13:00', icon: Icons.cloud, temp: '30℃'),
  _HourForecast(time: '14:00', icon: Icons.water_drop, temp: '27℃'),
  _HourForecast(time: '15:00', icon: Icons.wb_sunny, temp: '28℃'),
];

class _AppGrid extends StatelessWidget {
  const _AppGrid({required this.apps});

  final List<_CampusApp> apps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final accent = app.colorAssoc.resolve(theme.brightness);
        return _CampusGlassCard(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openApp(context, app.name),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    app.icon,
                    size: 26,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  app.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openApp(BuildContext context, String name) {
    switch (name) {
      case '课程表':
        context.push(AppRoutePaths.campusTimetable);
        return;
      case '成绩':
        context.push(AppRoutePaths.campusScore);
        return;
      case '自习预约':
        context.push(AppRoutePaths.campusSeatReservation);
        return;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name 功能正在开发中'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

class _CampusGlassCard extends StatelessWidget {
  const _CampusGlassCard({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  static final _blurFilter = dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10);

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final shadTheme = ui.Theme.of(context);
    final borderRadius = shadTheme.borderRadiusXl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter.grouped(
        filter: _blurFilter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: shadTheme.colorScheme.card.withValues(alpha: 0.82),
            borderRadius: borderRadius,
            border: Border.all(color: shadTheme.colorScheme.muted),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _CampusApp {
  const _CampusApp({
    required this.icon,
    required this.name,
    required this.colorAssoc,
  });

  final IconData icon;
  final String name;
  final ItemColorOption colorAssoc;
}
