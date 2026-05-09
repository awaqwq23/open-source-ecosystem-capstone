import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CampusPage extends StatelessWidget {
  const CampusPage({super.key});

  static const _gridApps = <_CampusApp>[
    _CampusApp(icon: Icons.local_library, name: '图书馆'),
    _CampusApp(icon: Icons.sports_soccer, name: '运动'),
    _CampusApp(icon: Icons.grading, name: '成绩'),
    _CampusApp(icon: Icons.directions_bus, name: '校巴'),
    _CampusApp(icon: Icons.credit_card, name: 'E卡'),
    _CampusApp(icon: Icons.qr_code, name: '付款码'),
    _CampusApp(icon: Icons.assignment, name: '给分'),
    _CampusApp(icon: Icons.rate_review, name: '评价'),
    _CampusApp(icon: Icons.school, name: '蹭课'),
    _CampusApp(icon: Icons.menu_book, name: '讲义'),
    _CampusApp(icon: Icons.quiz, name: '试卷'),
    _CampusApp(icon: Icons.auto_awesome, name: '自动化'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(context.l10n.campusTitle),
        ),
      ],
      child: Stack(
        children: [
          // Background layer
          Container(color: theme.colorScheme.surface),
          // Decorative header layer — provides visual interest for frosted glass
          const _HeaderDecoration(),
          // Content layer
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: const Column(
                children: [
                  _WeatherCard(),
                  SizedBox(height: 16),
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

class _HeaderDecoration extends StatelessWidget {
  const _HeaderDecoration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        // Primary tone glow — top-left
        Positioned(
          top: -size.width * 0.2,
          left: -size.width * 0.05,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  theme.colorScheme.primary.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Tertiary tone glow — top-right, slightly lower
        Positioned(
          top: -size.width * 0.02,
          right: -size.width * 0.18,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [
                  theme.colorScheme.tertiary.withValues(alpha: 0.08),
                  theme.colorScheme.tertiary.withValues(alpha: 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Secondary tone accent — center-right
        Positioned(
          top: size.width * 0.18,
          right: -size.width * 0.02,
          child: Container(
            width: size.width * 0.35,
            height: size.width * 0.35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.6,
                colors: [
                  theme.colorScheme.secondary.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Small warm accent — for cherry blossom feel
        Positioned(
          top: size.width * 0.35,
          left: size.width * 0.08,
          child: Container(
            width: size.width * 0.15,
            height: size.width * 0.15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.5,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const weatherIcon = Icons.wb_sunny;
    const temperature = '28°C';
    const condition = '晴';
    const suggestion = '阳光正好，适合户外运动或图书馆自习';

    // Workaround: read shadcn theme to determine if glass should be applied.
    // On first build in dev, the shadcn theme might not be fully initialized,
    // so we provide safe fallbacks.
    final shadTheme = ui.Theme.of(context);
    final effectiveBlur = (shadTheme.surfaceBlur ?? 10.0);
    final effectiveOpacity = (shadTheme.surfaceOpacity ?? 0.82);

    return ui.Card(
      surfaceBlur: effectiveBlur,
      surfaceOpacity: effectiveOpacity,
      filled: true,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(20),
      borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
      borderWidth: 0.5,
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withValues(alpha: 0.09),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  weatherIcon,
                  size: 40,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temperature,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      condition,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.air,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '优',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassAppTile extends StatefulWidget {
  const _GlassAppTile({
    required this.app,
    required this.onTap,
  });

  final _CampusApp app;
  final VoidCallback onTap;

  @override
  State<_GlassAppTile> createState() => _GlassAppTileState();
}

class _GlassAppTileState extends State<_GlassAppTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = widget.app;
    final shadTheme = ui.Theme.of(context);
    final effectiveBlur = (shadTheme.surfaceBlur ?? 10.0);
    final effectiveOpacity = (shadTheme.surfaceOpacity ?? 0.82);

    return AnimatedScale(
      scale: _isPressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: ui.Card(
          surfaceBlur: effectiveBlur,
          surfaceOpacity: effectiveOpacity,
          filled: true,
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(16),
          borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.18),
          borderWidth: 0.5,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          child: SizedBox(
            height: 92,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    app.icon,
                    size: 24,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    app.name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppGrid extends StatelessWidget {
  const _AppGrid({required this.apps});

  final List<_CampusApp> apps;

  @override
  Widget build(BuildContext context) {
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
        return _GlassAppTile(
          app: app,
          onTap: () => _openApp(context, app.name),
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
  });

  final IconData icon;
  final String name;
}
