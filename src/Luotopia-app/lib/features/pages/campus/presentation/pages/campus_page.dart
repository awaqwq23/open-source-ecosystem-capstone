import 'dart:async';
import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/features/plugins/application/plugin_manager.dart';
import 'package:luotopia/features/plugins/domain/plugin_manifest.dart';
import 'package:luotopia/features/plugins/presentation/plugin_icons.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/features/components/wallpaper/presentation/widgets/app_wallpaper_background.dart';
import 'package:luotopia/features/weather/presentation/providers/weather_providers.dart';
import 'package:luotopia/features/weather/presentation/widgets/qweather_icon.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CampusPage extends ConsumerStatefulWidget {
  const CampusPage({super.key});

  @override
  ConsumerState<CampusPage> createState() => _CampusPageState();
}

class _CampusPageState extends ConsumerState<CampusPage> {
  final _scroll = ScrollController();
  final _cardKeys = <String, GlobalKey>{};
  Timer? _edgeTimer;
  List<PluginContribution>? _dragEntries;
  int? _dragRevision;

  @override
  void dispose() {
    _edgeTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollAt(Offset globalPosition) {
    _edgeTimer?.cancel();
    final box = context.findRenderObject() as RenderBox;
    final y = box.globalToLocal(globalPosition).dy;
    final direction = y < 80
        ? -1
        : y > box.size.height - 80
        ? 1
        : 0;
    if (direction == 0) return;
    _edgeTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(
          (_scroll.offset + direction * 12).clamp(
            0.0,
            _scroll.position.maxScrollExtent,
          ),
        );
      }
    });
  }

  void _cancelDrag() {
    _edgeTimer?.cancel();
    if (mounted) {
      setState(() {
        _dragEntries = null;
        _dragRevision = null;
      });
    }
  }

  Future<void> _drop() async {
    final entries = _dragEntries;
    final revision = _dragRevision;
    if (entries == null) return;
    try {
      await ref
          .read(pluginManagerProvider)
          .reorder(
            ContributionSlot.campusCard,
            entries.map((c) => c.key).toList(),
            expectedRevision: revision,
          );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('布局保存失败，请重试')));
      }
    } finally {
      _cancelDrag();
    }
  }

  static const _gridApps = <_CampusApp>[
    _CampusApp(
      icon: Icons.table_chart_outlined,
      name: '课程表',
      colorAssoc: ItemColorOption.sky,
    ),
    _CampusApp(
      icon: Icons.event_seat,
      name: '自习预约',
      colorAssoc: ItemColorOption.indigo,
    ),
    _CampusApp(
      icon: Icons.local_library,
      name: '图书借阅',
      colorAssoc: ItemColorOption.amber,
    ),
    _CampusApp(
      icon: Icons.sports_soccer,
      name: '运动场馆',
      colorAssoc: ItemColorOption.lime,
    ),
    _CampusApp(
      icon: Icons.credit_card,
      name: '珞珈E卡',
      colorAssoc: ItemColorOption.sky,
    ),
    _CampusApp(
      icon: Icons.qr_code,
      name: 'E卡付款码',
      colorAssoc: ItemColorOption.jade,
    ),
    _CampusApp(
      icon: Icons.grading,
      name: '成绩',
      colorAssoc: ItemColorOption.coral,
    ),
    _CampusApp(
      icon: Icons.meeting_room,
      name: '空闲教室',
      colorAssoc: ItemColorOption.teal,
    ),
    _CampusApp(
      icon: Icons.school,
      name: '蹭课',
      colorAssoc: ItemColorOption.rose,
    ),
    _CampusApp(
      icon: Icons.calendar_month,
      name: '全校课表',
      colorAssoc: ItemColorOption.violet,
    ),
    _CampusApp(
      icon: Icons.assignment,
      name: '课程给分',
      colorAssoc: ItemColorOption.orchid,
    ),
    _CampusApp(
      icon: Icons.rate_review,
      name: '课程评价',
      colorAssoc: ItemColorOption.crimson,
    ),
    _CampusApp(
      icon: Icons.folder,
      name: '学习资料共享',
      colorAssoc: ItemColorOption.slate,
    ),
  ];

  Widget _card(PluginContribution entry) {
    if (entry.pluginId == 'luotopia.campus-info') {
      final weather = ref.watch(weatherProvider);
      return _CampusInfoCard(
        weather: weather.weather,
        loading: weather.loading,
        isMock: weather.isMock,
      );
    }
    const ids = [
      'timetable',
      'seat-reservation',
      'library',
      'sports-reservation',
      'luojia-ecard',
      'ecard-payment-code',
      'score',
      'empty-classroom',
      'audit-course',
      'all-school-timetable',
      'grading',
      'course-review',
      'study-materials',
    ];
    final index = ids.indexOf(entry.pluginId.replaceFirst('luotopia.', ''));
    return _CampusTile(
      entry: entry,
      app: index < 0 ? null : _gridApps[index],
      customIcon: ref
          .read(pluginManagerProvider)
          .hasPresentationOverride(entry.key, 'icon'),
      customColor: ref
          .read(pluginManagerProvider)
          .hasPresentationOverride(entry.key, 'color'),
    );
  }

  Widget _draggable(PluginContribution entry, double width, double height) {
    return DragTarget<String>(
      key: _cardKeys.putIfAbsent(entry.key, GlobalKey.new),
      onWillAcceptWithDetails: (details) => details.data != entry.key,
      onMove: (details) {
        final entries = _dragEntries;
        if (entries == null) return;
        final from = entries.indexWhere((c) => c.key == details.data);
        final to = entries.indexWhere((c) => c.key == entry.key);
        if (from >= 0 && to >= 0 && from != to) {
          setState(() {
            entries.insert(to, entries.removeAt(from));
          });
        }
      },
      onAcceptWithDetails: (_) => _drop(),
      builder: (context, candidates, rejected) => LongPressDraggable<String>(
        data: entry.key,
        onDragStarted: () => setState(() {
          final manager = ref.read(pluginManagerProvider);
          _dragEntries = manager.entries(ContributionSlot.campusCard).toList();
          _dragRevision = manager.revision;
        }),
        onDragUpdate: (details) => _scrollAt(details.globalPosition),
        onDraggableCanceled: (_, _) => _cancelDrag(),
        onDragEnd: (_) => _edgeTimer?.cancel(),
        feedback: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: width,
            height: height,
            child: Opacity(opacity: 0.9, child: _card(entry)),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.25, child: _card(entry)),
        child: Semantics(
          label: entry.title,
          hint: '长按拖动以调整顺序',
          child: _card(entry),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registered = ref
        .watch(pluginManagerProvider)
        .entries(ContributionSlot.campusCard);
    final entries = _dragEntries ?? registered;
    return ui.Scaffold(
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: AppWallpaperBackground()),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.10)),
          ),
          SafeArea(
            child: BackdropGroup(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final smallWidth = (constraints.maxWidth - 56) / 3;
                  final rows = <Widget>[];
                  final gaps = <double>[];
                  for (var i = 0; i < entries.length;) {
                    final entry = entries[i];
                    if (entry.size == 'wide') {
                      gaps.add(16);
                      rows.add(
                        SizedBox(
                          key: ValueKey(entry.key),
                          width: double.infinity,
                          height: entry.pluginId == 'luotopia.campus-info'
                              ? null
                              : smallWidth,
                          child: _draggable(
                            entry,
                            constraints.maxWidth - 32,
                            entry.pluginId == 'luotopia.campus-info'
                                ? 300
                                : smallWidth,
                          ),
                        ),
                      );
                      i++;
                    } else {
                      gaps.add(12);
                      final cells = <Widget>[];
                      while (i < entries.length &&
                          entries[i].size != 'wide' &&
                          cells.length < 3) {
                        final cell = entries[i++];
                        cells.add(
                          SizedBox(
                            key: ValueKey(cell.key),
                            width: smallWidth,
                            height: smallWidth,
                            child: _draggable(cell, smallWidth, smallWidth),
                          ),
                        );
                      }
                      rows.add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var c = 0; c < cells.length; c++) ...[
                              if (c > 0) const SizedBox(width: 12),
                              cells[c],
                            ],
                          ],
                        ),
                      );
                    }
                  }
                  return ListView.separated(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: rows.length,
                    separatorBuilder: (_, index) =>
                        SizedBox(height: gaps[index]),
                    itemBuilder: (_, index) => rows[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampusInfoCard extends StatelessWidget {
  const _CampusInfoCard({
    required this.weather,
    required this.loading,
    this.isMock = false,
  });

  final WeatherBlock? weather;
  final bool loading;
  final bool isMock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (loading && weather == null) {
      return _CampusGlassCard(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 286,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final temp = weather?.data?['temperature'];
    final feelsLike = weather?.data?['feels_like'];
    final tempHigh = weather?.data?['temp_high'];
    final tempLow = weather?.data?['temp_low'];
    final condition = weather?.data?['condition'] as String? ?? '--';
    final aqi = weather?.data?['aqi'] as int? ?? 0;
    final iconCode = weather?.data?['icon'] as String?;
    final conditionLine = '武汉大学·$condition';
    final metaLine = [
      '${_formatTemp(tempLow)}/${_formatTemp(tempHigh)}',
      '体感${_formatTemp(feelsLike)}',
      if (isMock) '待更新',
    ].join('·');

    return _CampusGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Main weather info: single row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              QWeatherIcon(
                code: iconCode,
                size: 48,
                color: _weatherIconColor(iconCode),
              ),
              const SizedBox(width: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 76),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatTemp(temp),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      conditionLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isMock
                            ? Colors.orange.shade400
                            : colors.onSurface.withValues(alpha: 0.55),
                        fontWeight: isMock ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // AQI compact card
              if (aqi > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_aqiIcon(aqi), size: 16, color: _aqiColor(aqi)),
                          const SizedBox(width: 4),
                          Text(
                            _aqiLabel(aqi),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _aqiColor(aqi),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AQI $aqi',
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

          // ── Hourly forecast ──
          if (weather?.data?['hourly_forecast'] is List)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: (weather!.data!['hourly_forecast'] as List).length,
                separatorBuilder: (_, _) => const SizedBox(width: 2),
                itemBuilder: (context, index) {
                  final h =
                      (weather!.data!['hourly_forecast'] as List)[index]
                          as Map<String, dynamic>;
                  final hTemp = h['temp'];
                  final hIconCode = h['icon'] as String?;
                  return Container(
                    width: 58,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatHour(h),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        QWeatherIcon(
                          code: hIconCode,
                          size: 20,
                          color: _weatherIconColor(hIconCode),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTemp(hTemp, fallback: '--'),
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
          const SizedBox(height: 12),
          const _CampusNoticeSection(),
        ],
      ),
    );
  }

  String _formatHour(Map<String, dynamic> hour) {
    final fxTime = hour['fx_time'];
    if (fxTime is! String || fxTime.isEmpty) return '--';
    return _formatQWeatherHour(fxTime);
  }

  Color _aqiColor(int aqi) {
    if (aqi <= 50) return Colors.green.shade400;
    if (aqi <= 100) return Colors.yellow.shade700;
    if (aqi <= 150) return Colors.orange.shade400;
    if (aqi <= 200) return Colors.red.shade400;
    return Colors.purple.shade400;
  }

  String _aqiLabel(int aqi) {
    if (aqi <= 50) return '优';
    if (aqi <= 100) return '良';
    if (aqi <= 150) return '轻度';
    if (aqi <= 200) return '中度';
    return '重度';
  }

  IconData _aqiIcon(int aqi) {
    if (aqi <= 50) return Icons.eco;
    if (aqi <= 100) return Icons.air;
    if (aqi <= 150) return Icons.warning_amber;
    if (aqi <= 200) return Icons.error_outline;
    return Icons.dangerous_outlined;
  }
}

class _CampusNoticeSection extends StatelessWidget {
  const _CampusNoticeSection();

  @override
  Widget build(BuildContext context) {
    const notices = [
      _NoticeItem(
        icon: Icons.school,
        iconColor: Colors.indigo,
        text: '下午没课，试试一节「古代汉语」？',
        action: '蹭课推荐',
      ),
      _NoticeItem(
        icon: Icons.newspaper,
        iconColor: Colors.blue,
        text: '校园新闻：五一调休通知新鲜出炉',
        action: '校园新闻',
      ),
      _NoticeItem(
        icon: Icons.local_library,
        iconColor: Colors.teal,
        text: '图书馆：《罪与罚》借阅将在三天后到期',
        action: '借阅详情',
      ),
    ];

    if (notices.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < notices.length; i++) ...[
          _ReminderTile(
            icon: notices[i].icon,
            iconColor: notices[i].iconColor,
            text: notices[i].text,
            onTap: () => _showInteraction(context, notices[i].action),
          ),
          if (i != notices.length - 1) const SizedBox(height: 8),
        ],
      ],
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

class _NoticeItem {
  const _NoticeItem({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final String action;
}

String _formatTemp(Object? value, {String fallback = '--°'}) {
  final number = _asNum(value);
  if (number == null) return fallback;
  return '${number.round()}°';
}

num? _asNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

String _formatQWeatherHour(String value) {
  if (value.length >= 16) return value.substring(11, 16);
  return '--';
}

Color _weatherIconColor(String? code) {
  final id = int.tryParse(code ?? '');
  if (id == null || id == 999) return Colors.grey.shade400;
  if (id >= 200 && id < 300) return Colors.blueGrey.shade300;
  if (id >= 300 && id < 400) return Colors.blue.shade400;
  if (id >= 400 && id < 500) return Colors.lightBlue.shade200;
  if (id == 502 || (id >= 511 && id <= 513)) return Colors.grey.shade600;
  if (id == 503 || id == 504 || id == 507 || id == 508) {
    return Colors.amber.shade700;
  }
  if (id >= 500 && id < 600) return Colors.blueGrey.shade300;
  if (id == 900) return Colors.deepOrange.shade300;
  if (id == 901) return Colors.lightBlue.shade200;
  if (id >= 150 && id <= 153) return Colors.indigo.shade200;
  if (id == 104 || id == 154) return Colors.blueGrey.shade300;
  if (id >= 101 && id <= 103) return Colors.amber.shade200;
  return Colors.orange.shade300;
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

class _CampusTile extends StatelessWidget {
  const _CampusTile({
    required this.entry,
    this.app,
    required this.customIcon,
    required this.customColor,
  });
  final bool customIcon, customColor;
  final PluginContribution entry;
  final _CampusApp? app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = !customColor && app != null
        ? app!.colorAssoc.resolve(theme.brightness)
        : pluginColor(entry.color);
    return _CampusGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (entry.nativeRoute != null) {
            context.openSecondary(entry.nativeRoute!);
          } else if (!entry.pluginId.startsWith('luotopia.')) {
            context.go(entry.route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${entry.title} 功能正在开发中'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
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
                !customIcon && app != null ? app!.icon : pluginIcon(entry.icon),
                size: 26,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              entry.title,
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
  }
}

class _CampusGlassCard extends StatelessWidget {
  const _CampusGlassCard({required this.child, this.padding = EdgeInsets.zero});

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
            child: Padding(padding: padding, child: child),
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
