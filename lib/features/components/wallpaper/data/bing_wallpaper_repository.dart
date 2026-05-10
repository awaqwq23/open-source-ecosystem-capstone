import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';
import 'package:luotopia/features/components/wallpaper/domain/repositories/wallpaper_repository.dart';
import 'package:path_provider/path_provider.dart';

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  final repository = BingWallpaperRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final todayWallpaperProvider = FutureProvider<TodayWallpaper?>((ref) {
  return ref.watch(wallpaperRepositoryProvider).loadTodayWallpaper();
});

class BingWallpaperRepository implements WallpaperRepository {
  BingWallpaperRepository({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _archiveUri = Uri.parse(
    'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1',
  );

  final http.Client _client;

  void dispose() {
    _client.close();
  }

  @override
  Future<TodayWallpaper?> loadTodayWallpaper() async {
    final dateKey = _dateKey(DateTime.now());
    final directory = await _wallpaperDirectory();
    await _clearHistoricalWallpapers(directory, todayKey: dateKey);

    final landscapeFile = File(_wallpaperPath(directory, dateKey, 'landscape'));
    final portraitFile = File(_wallpaperPath(directory, dateKey, 'portrait'));
    if (await landscapeFile.exists() && await portraitFile.exists()) {
      return _wallpaper(dateKey, landscapeFile, portraitFile);
    }

    final urls = await _fetchTodayImageUrls();
    if (urls == null) {
      return null;
    }

    if (!await landscapeFile.exists()) {
      await _downloadImage(urls.landscapeUrl, landscapeFile);
    }
    if (!await portraitFile.exists()) {
      await _downloadImage(urls.portraitUrl, portraitFile);
    }

    if (await landscapeFile.exists() && await portraitFile.exists()) {
      return _wallpaper(dateKey, landscapeFile, portraitFile);
    }
    return null;
  }

  Future<_BingWallpaperUrls?> _fetchTodayImageUrls() async {
    try {
      final response = await _client.get(_archiveUri);
      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final images = data['images'] as List<dynamic>;
      final image = images.first as Map<String, dynamic>;
      final url = image['url'] as String;
      final landscapeUrl = 'https://www.bing.com$url';
      final portraitUrl = landscapeUrl.replaceAll('_1920x1080', '_1080x1920');
      return _BingWallpaperUrls(
        landscapeUrl: Uri.parse(landscapeUrl),
        portraitUrl: Uri.parse(portraitUrl),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _downloadImage(Uri url, File target) async {
    try {
      final response = await _client.get(url);
      if (response.statusCode != 200) {
        return;
      }
      await target.writeAsBytes(response.bodyBytes, flush: true);
    } catch (_) {}
  }

  Future<Directory> _wallpaperDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}wallpapers',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<void> _clearHistoricalWallpapers(
    Directory directory, {
    required String todayKey,
  }) async {
    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }
      final name = entity.uri.pathSegments.last;
      if (!name.startsWith('bing-')) {
        continue;
      }
      if (name.startsWith('bing-$todayKey-')) {
        continue;
      }
      try {
        await entity.delete();
      } catch (_) {}
    }
  }

  TodayWallpaper _wallpaper(
    String dateKey,
    File landscapeFile,
    File portraitFile,
  ) {
    return TodayWallpaper(
      source: WallpaperSource.bing,
      dateKey: dateKey,
      landscapePath: landscapeFile.path,
      portraitPath: portraitFile.path,
    );
  }

  String _wallpaperPath(Directory directory, String dateKey, String orientation) {
    return '${directory.path}${Platform.pathSeparator}bing-$dateKey-$orientation.jpg';
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _BingWallpaperUrls {
  const _BingWallpaperUrls({
    required this.landscapeUrl,
    required this.portraitUrl,
  });

  final Uri landscapeUrl;
  final Uri portraitUrl;
}
