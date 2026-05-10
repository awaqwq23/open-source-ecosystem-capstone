import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';

abstract class WallpaperRepository {
  Future<TodayWallpaper?> loadTodayWallpaper();
}
