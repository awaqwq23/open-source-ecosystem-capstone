import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CampusPage extends StatelessWidget {
  const CampusPage({super.key});

  static const _gridApps = <_CampusApp>[
    _CampusApp(icon: Icons.local_library, name: '图书馆', colorAssoc: ItemColorOption.indigo),
    _CampusApp(icon: Icons.sports_soccer, name: '运动', colorAssoc: ItemColorOption.lime),
    _CampusApp(icon: Icons.grading, name: '成绩', colorAssoc: ItemColorOption.amber),
    _CampusApp(icon: Icons.directions_bus, name: '校巴', colorAssoc: ItemColorOption.teal),
    _CampusApp(icon: Icons.credit_card, name: 'E卡', colorAssoc: ItemColorOption.sky),
    _CampusApp(icon: Icons.qr_code, name: '付款码', colorAssoc: ItemColorOption.jade),
    _CampusApp(icon: Icons.assignment, name: '给分', colorAssoc: ItemColorOption.coral),
    _CampusApp(icon: Icons.rate_review, name: '评价', colorAssoc: ItemColorOption.orchid),
    _CampusApp(icon: Icons.school, name: '蹭课', colorAssoc: ItemColorOption.rose),
    _CampusApp(icon: Icons.menu_book, name: '讲义', colorAssoc: ItemColorOption.slate),
    _CampusApp(icon: Icons.quiz, name: '试卷', colorAssoc: ItemColorOption.crimson),
    _CampusApp(icon: Icons.auto_awesome, name: '自动化', colorAssoc: ItemColorOption.violet),
  ];

  @override
  Widget build(BuildContext context) {
    return ui.Scaffold(
      child: Stack(
        children: [
          // Full-screen Bing wallpaper — orientation-aware
          Positioned.fill(child: _BingWallpaper()),
          // Slight dark overlay for readability over bright images
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.10)),
          ),
          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  _WeatherCard(),
                  const SizedBox(height: 16),
                  _AppGrid(apps: _gridApps),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BingWallpaper extends StatefulWidget {
  @override
  State<_BingWallpaper> createState() => _BingWallpaperState();
}

class _BingWallpaperState extends State<_BingWallpaper> {
  String? _landscapeUrl;
  String? _portraitUrl;

  @override
  void initState() {
    super.initState();
    _fetchBingImage();
  }

  Future<void> _fetchBingImage() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final url = data['images'][0]['url'] as String;
        final base = 'https://www.bing.com$url';
        if (mounted) {
          setState(() {
            _landscapeUrl = base;
            _portraitUrl = base.replaceAll('_1920x1080', '_1080x1920');
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_landscapeUrl == null || _portraitUrl == null) {
      return _buildFallback(context);
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final imageUrl = orientation == Orientation.landscape
            ? _landscapeUrl!
            : _portraitUrl!;
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => _buildFallback(context),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _buildFallback(context);
          },
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ui.Card(
      surfaceBlur: 10,
      surfaceOpacity: 0.82,
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
                '28℃',
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
                    '晴 · 体感 31℃',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '今日 18℃ ~ 30℃',
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
                      'PM2.5 10',
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
            title: '蹭课推荐',
            subtitle: '下午没课 · 王力 古代汉语 · 教三301 14:00',
            onTap: () => _showInteraction(context, '蹭课详情：王力老师古代汉语'),
          ),
          const SizedBox(height: 8),
          _ReminderTile(
            icon: Icons.newspaper,
            iconColor: Colors.blue.shade400,
            title: '今日校园',
            subtitle: '图书馆B区自习室临时关闭改造至6月',
            onTap: () => _showInteraction(context, '查看详情'),
          ),
          const SizedBox(height: 8),
          _ReminderTile(
            icon: Icons.local_library,
            iconColor: Colors.teal.shade300,
            title: '图书到期',
            subtitle: '《数据结构与算法》将于3天后到期，请及时归还',
            onTap: () => _showInteraction(context, '查看借阅详情'),
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

/// Compact reminder tile with chevron affordance
class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
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
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
        return ui.Card(
          surfaceBlur: 10,
          surfaceOpacity: 0.82,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name 功能正在开发中'),
        behavior: SnackBarBehavior.floating,
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
