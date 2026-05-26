class PullResponse {
  final WeatherBlock? weather;
  final NotificationBlock? notification;
  final HotUpdateBlock? hotUpdate;
  final SyncBlock? sync;

  const PullResponse({this.weather, this.notification, this.hotUpdate, this.sync});

  factory PullResponse.fromJson(Map<String, dynamic> json) {
    return PullResponse(
      weather: json['weather'] != null
          ? WeatherBlock.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
      notification: json['notification'] != null
          ? NotificationBlock.fromJson(json['notification'] as Map<String, dynamic>)
          : null,
      hotUpdate: json['hot_update'] != null
          ? HotUpdateBlock.fromJson(json['hot_update'] as Map<String, dynamic>)
          : null,
      sync: json['sync'] != null
          ? SyncBlock.fromJson(json['sync'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WeatherBlock {
  final Map<String, dynamic>? data;
  final int? cachedAt;

  const WeatherBlock({this.data, this.cachedAt});

  factory WeatherBlock.fromJson(Map<String, dynamic> json) {
    return WeatherBlock(
      data: json['data'] as Map<String, dynamic>?,
      cachedAt: json['cached_at'] as int?,
    );
  }
}

class NotificationBlock {
  final String latestId;
  final bool hasNew;
  final int count;

  const NotificationBlock({
    required this.latestId,
    required this.hasNew,
    required this.count,
  });

  factory NotificationBlock.fromJson(Map<String, dynamic> json) {
    return NotificationBlock(
      latestId: json['latest_id'] as String? ?? '',
      hasNew: json['has_new'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
    );
  }
}

class HotUpdateBlock {
  final Map<String, ScriptVersion> scripts;

  const HotUpdateBlock({required this.scripts});

  factory HotUpdateBlock.fromJson(Map<String, dynamic> json) {
    final raw = json['scripts'] as Map<String, dynamic>? ?? {};
    final scripts = <String, ScriptVersion>{};
    raw.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        scripts[key] = ScriptVersion.fromJson(value);
      }
    });
    return HotUpdateBlock(scripts: scripts);
  }
}

class ScriptVersion {
  final int latestVersion;
  final String checksum;

  const ScriptVersion({required this.latestVersion, required this.checksum});

  factory ScriptVersion.fromJson(Map<String, dynamic> json) {
    return ScriptVersion(
      latestVersion: json['latest_version'] as int? ?? 0,
      checksum: json['checksum'] as String? ?? '',
    );
  }
}

class SyncBlock {
  final bool enabled;

  const SyncBlock({required this.enabled});

  factory SyncBlock.fromJson(Map<String, dynamic> json) {
    return SyncBlock(enabled: json['enabled'] as bool? ?? false);
  }
}
