import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';

abstract class WallpaperRepository {
  TodayWallpaper? readCachedTodayWallpaper();

  Future<TodayWallpaper?> loadTodayWallpaper();
}
