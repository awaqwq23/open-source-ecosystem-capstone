enum WallpaperSource {
  bing,
}

class TodayWallpaper {
  const TodayWallpaper({
    required this.source,
    required this.dateKey,
    required this.landscapePath,
    required this.portraitPath,
  });

  final WallpaperSource source;
  final String dateKey;
  final String landscapePath;
  final String portraitPath;
}
