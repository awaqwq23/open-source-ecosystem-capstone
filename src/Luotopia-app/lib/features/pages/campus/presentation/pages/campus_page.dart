import 'package:flutter/foundation.dart' show listEquals;
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
  PluginContribution? _lifted;
  Offset _finger = Offset.zero, _anchor = Offset.zero;
  double _weatherHeight = 300;
  final _viewport = GlobalKey();
  List<String> _startingOrder = [];
  bool _saving = false;
  int _edgeDirection = 0;

  RenderBox get _box =>
      _viewport.currentContext!.findRenderObject() as RenderBox;
  double get _small => (_box.size.width - 56) / 3;

  // In content coordinates, independent of the scrolling viewport and animation.
  Map<String, Rect> _slots(List<PluginContribution> entries) {
    final result = <String, Rect>{};
    double y = 16;
    var column = 0;
    for (final e in entries) {
      if (e.size == 'wide') {
        if (column != 0) y += _small + 12;
        final h = e.pluginId == 'luotopia.campus-info'
            ? _weatherHeight
            : _small;
        result[e.key] = Rect.fromLTWH(16, y, _box.size.width - 32, h);
        y += h + 16;
        column = 0;
      } else {
        result[e.key] = Rect.fromLTWH(
          16 + column * (_small + 12),
          y,
          _small,
          _small,
        );
        if (++column == 3) {
          column = 0;
          y += _small + 12;
        }
      }
    }
    return result;
  }

  void _start(LongPressStartDetails d) {
    if (_saving) return;
    final manager = ref.read(pluginManagerProvider);
    final entries = _packedEntries(
      manager.entries(ContributionSlot.campusCard),
    );
    PluginContribution? lifted;
    for (final e in entries) {
      final box =
          _cardKeys[e.key]?.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.attached || !box.hasSize) continue;
      if (e.pluginId == 'luotopia.campus-info') {
        _weatherHeight = box.size.height;
      }
      final local = box.globalToLocal(d.globalPosition);
      if ((Offset.zero & box.size).contains(local)) {
        lifted = e;
        _anchor = local;
      }
    }
    if (lifted == null) return;
    setState(() {
      _lifted = lifted;
      _finger = _box.globalToLocal(d.globalPosition);
      _dragRevision = manager.revision;
      _dragEntries = entries;
      _startingOrder = entries.map((e) => e.key).toList();
    });
  }

  void _preview(Offset finger) {
    final entries = _dragEntries;
    final lifted = _lifted;
    if (entries == null || lifted == null || _saving) return;
    final point = finger + Offset(0, _scroll.offset);
    final slots = _slots(entries);
    setState(() {
      _finger = finger;
      if (slots[lifted.key]!.inflate(4).contains(point)) return;
      PluginContribution? target;
      double distance = double.infinity;
      for (final e in entries) {
        if (e.key == lifted.key) continue;
        final r = slots[e.key]!;
        final dx = point.dx - point.dx.clamp(r.left, r.right);
        final dy = point.dy - point.dy.clamp(r.top, r.bottom);
        final ds = dx * dx + dy * dy;
        if (ds < distance) {
          distance = ds;
          target = e;
        }
      }
      if (target == null) return;
      final t = target;
      final rect = slots[t.key]!;
      final from = entries.indexOf(lifted);
      final to = entries.indexOf(t);
      final delta = t.size == 'wide'
          ? point.dy - rect.center.dy
          : point.dx - rect.center.dx;
      final after = delta.abs() < 4 ? from < to : delta > 0;
      final next = entries.toList()..removeAt(from);
      var index = next.indexOf(t) + (after ? 1 : 0);
      if (lifted.size == 'wide' && t.size != 'wide') {
        final sameRow = next.where((e) => slots[e.key]!.top == rect.top);
        index = point.dy < rect.center.dy
            ? next.indexOf(sameRow.first)
            : next.indexOf(sameRow.last) + 1;
      }
      next.insert(index, lifted);
      _dragEntries = _packedEntries(next);
    });
  }

  @override
  void dispose() {
    _edgeTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollAt(Offset globalPosition) {
    final y = _box.globalToLocal(globalPosition).dy;
    final direction = y < 80
        ? -1
        : y > _box.size.height - 80
        ? 1
        : 0;
    if (direction == _edgeDirection) return;
    _edgeDirection = direction;
    _edgeTimer?.cancel();
    if (direction == 0) return;
    _edgeTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_scroll.hasClients) {
        final old = _scroll.offset;
        _scroll.jumpTo(
          (_scroll.offset + direction * 12).clamp(
            0.0,
            _scroll.position.maxScrollExtent,
          ),
        );
        if (_scroll.offset != old) _preview(_finger);
      }
    });
  }

  void _cancelDrag() {
    if (_lifted == null) return;
    _edgeTimer?.cancel();
    if (mounted) {
      setState(() {
        _lifted = null;
        _saving = false;
        _edgeDirection = 0;
        _dragEntries = null;
        _dragRevision = null;
      });
    }
  }

  Future<void> _drop(LongPressEndDetails d) async {
    final entries = _dragEntries;
    final revision = _dragRevision;
    if (entries == null || _saving) return;
    _edgeTimer?.cancel();
    if (!(Offset.zero & _box.size).contains(
          _box.globalToLocal(d.globalPosition),
        ) ||
        listEquals(entries.map((e) => e.key).toList(), _startingOrder)) {
      _cancelDrag();
      return;
    }
    _saving = true;
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

  Widget _restingCard(PluginContribution entry) {
    return Semantics(
      key: _cardKeys.putIfAbsent(entry.key, GlobalKey.new),
      label: entry.title,
      hint: '长按拖到两张卡片之间以插入',
      child: _card(entry),
    );
  }

  Widget _previewGrid(List<PluginContribution> entries) {
    final slots = _slots(entries);
    final bottom = slots.values
        .map((r) => r.bottom)
        .reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: bottom + 32,
      child: Stack(
        children: [
          for (final e in entries)
            AnimatedPositioned.fromRect(
              key: ValueKey('moving-${e.key}'),
              rect: slots[e.key]!,
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOutCubic,
              child: e.key == _lifted?.key
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .38),
                        ),
                      ),
                    )
                  : KeyedSubtree(key: ValueKey(e.key), child: _card(e)),
            ),
        ],
      ),
    );
  }

  // Fill a partial row before placing the next full-width card.
  List<PluginContribution> _packedEntries(List<PluginContribution> entries) {
    final remaining = entries.toList();
    final packed = <PluginContribution>[];
    var column = 0;
    while (remaining.isNotEmpty) {
      var index = 0;
      if (column > 0 && remaining.first.size == 'wide') {
        final small = remaining.indexWhere((entry) => entry.size != 'wide');
        if (small >= 0) index = small;
      }
      final entry = remaining.removeAt(index);
      packed.add(entry);
      column = entry.size == 'wide' ? 0 : (column + 1) % 3;
    }
    return packed;
  }

  @override
  Widget build(BuildContext context) {
    final registered = ref
        .watch(pluginManagerProvider)
        .entries(ContributionSlot.campusCard);
    final entries = _dragEntries ?? _packedEntries(registered);
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
                  for (var i = 0; _lifted == null && i < entries.length;) {
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
                          child: _restingCard(entry),
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
                            child: _restingCard(cell),
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
                  final lifted = _lifted;
                  final dragSize = lifted == null
                      ? null
                      : _slots(entries)[lifted.key]!.size;
                  return GestureDetector(
                    key: _viewport,
                    behavior: HitTestBehavior.translucent,
                    onLongPressStart: _start,
                    onLongPressMoveUpdate: (d) {
                      if (_lifted == null) return;
                      _preview(_box.globalToLocal(d.globalPosition));
                      _scrollAt(d.globalPosition);
                    },
                    onLongPressCancel: _cancelDrag,
                    onLongPressEnd: _drop,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ListView(
                            controller: _scroll,
                            padding: lifted == null
                                ? const EdgeInsets.fromLTRB(16, 16, 16, 32)
                                : EdgeInsets.zero,
                            children: lifted != null
                                ? [_previewGrid(entries)]
                                : [
                                    for (var i = 0; i < rows.length; i++) ...[
                                      if (i > 0) SizedBox(height: gaps[i - 1]),
                                      rows[i],
                                    ],
                                  ],
                          ),
                        ),
                        if (lifted != null)
                          Positioned(
                            left: _finger.dx - _anchor.dx,
                            top: _finger.dy - _anchor.dy,
                            width: dragSize!.width,
                            height: dragSize.height,
                            child: IgnorePointer(
                              child: Transform.scale(
                                scale: 1.035,
                                child: Material(
                                  type: MaterialType.transparency,
                                  child: Opacity(
                                    opacity: .94,
                                    child: _card(lifted),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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

class _CampusTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
          } else if (ref
                  .read(pluginManagerProvider)
                  .details(entry.pluginId)
                  .script !=
              null) {
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
