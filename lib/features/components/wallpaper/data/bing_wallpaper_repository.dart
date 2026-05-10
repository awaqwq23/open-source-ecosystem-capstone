import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:luotopia/features/components/wallpaper/domain/models/today_wallpaper.dart';
import 'package:luotopia/features/components/wallpaper/domain/repositories/wallpaper_repository.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  final repository = BingWallpaperRepository(
    preferences: ref.watch(sharedPreferencesProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final todayWallpaperProvider =
    NotifierProvider<TodayWallpaperNotifier, AsyncValue<TodayWallpaper?>>(
  TodayWallpaperNotifier.new,
);

class TodayWallpaperNotifier extends Notifier<AsyncValue<TodayWallpaper?>> {
  bool _refreshing = false;

  @override
  AsyncValue<TodayWallpaper?> build() {
    final repository = ref.watch(wallpaperRepositoryProvider);
    final cached = repository.readCachedTodayWallpaper();
    unawaited(_refresh(repository));
    return cached == null ? const AsyncValue.loading() : AsyncValue.data(cached);
  }

  Future<void> _refresh(WallpaperRepository repository) async {
    if (_refreshing) {
      return;
    }
    _refreshing = true;
    try {
      final wallpaper = await repository.loadTodayWallpaper();
      state = AsyncValue.data(wallpaper);
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncValue.error(error, stackTrace);
      }
    } finally {
      _refreshing = false;
    }
  }
}

class BingWallpaperRepository implements WallpaperRepository {
  BingWallpaperRepository({
    SharedPreferences? preferences,
    http.Client? client,
  })  : _preferences = preferences,
        _client = client ?? http.Client();

  static final Uri _archiveUri = Uri.parse(
    'https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1',
  );
  static const String _dateKeyPreference = 'wallpaper.bing.dateKey';
  static const String _landscapePathPreference = 'wallpaper.bing.landscapePath';
  static const String _portraitPathPreference = 'wallpaper.bing.portraitPath';

  final SharedPreferences? _preferences;
  final http.Client _client;

  void dispose() {
    _client.close();
  }

  @override
  TodayWallpaper? readCachedTodayWallpaper() {
    final preferences = _preferences;
    if (preferences == null) {
      return null;
    }

    final dateKey = _dateKey(DateTime.now());
    if (preferences.getString(_dateKeyPreference) != dateKey) {
      return null;
    }

    final landscapePath = preferences.getString(_landscapePathPreference);
    final portraitPath = preferences.getString(_portraitPathPreference);
    if (landscapePath == null || portraitPath == null) {
      return null;
    }
    if (!File(landscapePath).existsSync() || !File(portraitPath).existsSync()) {
      return null;
    }

    return TodayWallpaper(
      source: WallpaperSource.bing,
      dateKey: dateKey,
      landscapePath: landscapePath,
      portraitPath: portraitPath,
    );
  }

  @override
  Future<TodayWallpaper?> loadTodayWallpaper() async {
    final dateKey = _dateKey(DateTime.now());
    final directory = await _wallpaperDirectory();
    await _clearHistoricalWallpapers(directory, todayKey: dateKey);

    final landscapeFile = File(_wallpaperPath(directory, dateKey, 'landscape'));
    final portraitFile = File(_wallpaperPath(directory, dateKey, 'portrait'));
    if (await landscapeFile.exists() && await portraitFile.exists()) {
      return await _cacheWallpaper(dateKey, landscapeFile, portraitFile);
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
      return await _cacheWallpaper(dateKey, landscapeFile, portraitFile);
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

  Future<TodayWallpaper> _cacheWallpaper(
    String dateKey,
    File landscapeFile,
    File portraitFile,
  ) async {
    await _persistWallpaper(
      dateKey: dateKey,
      landscapePath: landscapeFile.path,
      portraitPath: portraitFile.path,
    );
    return TodayWallpaper(
      source: WallpaperSource.bing,
      dateKey: dateKey,
      landscapePath: landscapeFile.path,
      portraitPath: portraitFile.path,
    );
  }

  Future<void> _persistWallpaper({
    required String dateKey,
    required String landscapePath,
    required String portraitPath,
  }) async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    await preferences.setString(_dateKeyPreference, dateKey);
    await preferences.setString(_landscapePathPreference, landscapePath);
    await preferences.setString(_portraitPathPreference, portraitPath);
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
