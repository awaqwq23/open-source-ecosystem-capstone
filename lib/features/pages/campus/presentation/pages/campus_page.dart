import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/core/localization/locale_extensions.dart';
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
    final theme = Theme.of(context);
    final headerHeight = MediaQuery.of(context).size.height * 0.25;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          title: Text(context.l10n.campusTitle),
        ),
      ],
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surfaceContainerLowest,
                ],
              ),
            ),
          ),
          // Bing header image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: _BingHeaderImage(),
          ),
          // Smooth gradient transition at header bottom
          Positioned(
            top: headerHeight - 80,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Scrollable content
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: headerHeight),
                  // Weather card: shifted up so its midline aligns with header bottom
                  FractionalTranslation(
                    translation: const Offset(0, -0.5),
                    child: _WeatherCard(),
                  ),
                  // Compensate for the upward shift of the weather card
                  Transform.translate(
                    offset: const Offset(0, -70),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        _AppGrid(apps: _gridApps),
                        const SizedBox(height: 32),
                      ],
                    ),
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

class _BingHeaderImage extends StatefulWidget {
  @override
  State<_BingHeaderImage> createState() => _BingHeaderImageState();
}

class _BingHeaderImageState extends State<_BingHeaderImage> {
  String? _imageUrl;

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
        if (mounted) setState(() => _imageUrl = 'https://www.bing.com$url');
      }
    } catch (_) {
      // 加载失败时使用 fallback 渐变背景
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageUrl != null) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _buildFallback(context),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildFallback(context);
        },
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const weatherIcon = Icons.wb_sunny;
    const temperature = '28°C';
    const condition = '晴';
    const suggestion = '阳光正好，适合户外运动或图书馆自习';

    return ui.Card(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                weatherIcon,
                size: 40,
                color: theme.colorScheme.primary,
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
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
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  suggestion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        childAspectRatio: 1.1,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final accent = app.colorAssoc.resolve(theme.brightness);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openApp(context, app.name),
            splashColor: accent.withValues(alpha: 0.10),
            highlightColor: accent.withValues(alpha: 0.05),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
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
