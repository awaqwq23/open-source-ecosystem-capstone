import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/components/wallpaper/data/bing_wallpaper_repository.dart';

class AppWallpaperBackground extends ConsumerWidget {
  const AppWallpaperBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallpaper = ref.watch(todayWallpaperProvider);
    return wallpaper.when(
      data: (value) {
        if (value == null) {
          return const _WallpaperFallback();
        }
        return OrientationBuilder(
          builder: (context, orientation) {
            final path = orientation == Orientation.landscape
                ? value.landscapePath
                : value.portraitPath;
            return Image.file(
              File(path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => const _WallpaperFallback(),
            );
          },
        );
      },
      error: (_, _) => const _WallpaperFallback(),
      loading: () => const _WallpaperFallback(),
    );
  }
}

class _WallpaperFallback extends StatelessWidget {
  const _WallpaperFallback();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
    );
  }
}
