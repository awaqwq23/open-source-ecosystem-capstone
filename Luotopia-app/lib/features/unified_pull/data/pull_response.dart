class PullResponse {
  final DateTime? serverTime;
  final WeatherBlock? weather;
  final NotificationBlock? notification;
  final HotUpdateBlock? hotUpdate;
  final SyncBlock? sync;
  final SchoolTimetableBlock? schoolTimetable;

  const PullResponse({
    this.serverTime,
    this.weather,
    this.notification,
    this.hotUpdate,
    this.sync,
    this.schoolTimetable,
  });

  factory PullResponse.fromJson(Map<String, dynamic> json) {
    return PullResponse(
      serverTime: DateTime.tryParse(json['server_time'] as String? ?? ''),
      weather: json['weather'] != null
          ? WeatherBlock.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
      notification: json['notification'] != null
          ? NotificationBlock.fromJson(
              json['notification'] as Map<String, dynamic>,
            )
          : null,
      hotUpdate: json['hot_update'] != null
          ? HotUpdateBlock.fromJson(json['hot_update'] as Map<String, dynamic>)
          : null,
      sync: json['sync'] != null
          ? SyncBlock.fromJson(json['sync'] as Map<String, dynamic>)
          : null,
      schoolTimetable: json['school_timetable'] != null
          ? SchoolTimetableBlock.fromJson(
              json['school_timetable'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class WeatherBlock {
  final bool changed;
  final Map<String, dynamic>? data;
  final int? cachedAt;

  const WeatherBlock({this.changed = false, this.data, this.cachedAt});

  factory WeatherBlock.fromJson(Map<String, dynamic> json) {
    return WeatherBlock(
      changed: json['changed'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      cachedAt: json['cached_at'] as int?,
    );
  }
}

class NotificationBlock {
  final bool changed;
  final String latestId;
  final bool hasNew;
  final int count;
  final String title;
  final String icon;
  final DateTime? publishedAt;

  const NotificationBlock({
    this.changed = false,
    required this.latestId,
    required this.hasNew,
    required this.count,
    this.title = '',
    this.icon = '',
    this.publishedAt,
  });

  factory NotificationBlock.fromJson(Map<String, dynamic> json) {
    return NotificationBlock(
      changed: json['changed'] as bool? ?? false,
      latestId: json['latest_id'] as String? ?? '',
      hasNew: json['has_new'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'changed': changed,
      'latest_id': latestId,
      'has_new': hasNew,
      'count': count,
      'title': title,
      'icon': icon,
      'published_at': publishedAt?.toIso8601String(),
    };
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

class ApiLink {
  final String href;

  const ApiLink({required this.href});

  factory ApiLink.fromJson(Map<String, dynamic> json) {
    return ApiLink(href: json['href'] as String? ?? '');
  }
}

Map<String, ApiLink> _linksFromJson(Object? raw) {
  if (raw is! Map<String, dynamic>) {
    return const {};
  }
  return {
    for (final entry in raw.entries)
      if (entry.value is Map<String, dynamic>)
        entry.key: ApiLink.fromJson(entry.value as Map<String, dynamic>),
  };
}

class ScriptVersion {
  final bool changed;
  final int latestVersion;
  final String checksum;
  final Map<String, ApiLink> links;

  const ScriptVersion({
    this.changed = false,
    required this.latestVersion,
    required this.checksum,
    this.links = const {},
  });

  factory ScriptVersion.fromJson(Map<String, dynamic> json) {
    return ScriptVersion(
      changed: json['changed'] as bool? ?? false,
      latestVersion: json['latest_version'] as int? ?? 0,
      checksum: json['checksum'] as String? ?? '',
      links: _linksFromJson(json['links']),
    );
  }
}

class SyncBlock {
  final bool enabled;
  final bool hasChanges;
  final int? latestCursor;

  const SyncBlock({
    required this.enabled,
    this.hasChanges = false,
    this.latestCursor,
  });

  factory SyncBlock.fromJson(Map<String, dynamic> json) {
    return SyncBlock(
      enabled: json['enabled'] as bool? ?? false,
      hasChanges: json['has_changes'] as bool? ?? false,
      latestCursor: (json['latest_cursor'] as num?)?.toInt(),
    );
  }
}

class SchoolTimetableBlock {
  final bool changed;
  final List<SchoolTimetableTermUpdate> terms;

  const SchoolTimetableBlock({this.changed = false, this.terms = const []});

  factory SchoolTimetableBlock.fromJson(Map<String, dynamic> json) {
    final rawTerms = json['terms'] as List? ?? const [];
    return SchoolTimetableBlock(
      changed: json['changed'] as bool? ?? false,
      terms: [
        for (final item in rawTerms)
          if (item is Map<String, dynamic>)
            SchoolTimetableTermUpdate.fromJson(item),
      ],
    );
  }
}

class SchoolTimetableTermUpdate {
  final String termKey;
  final String schoolYear;
  final String term;
  final String firstWeekMonday;
  final int version;
  final String checksum;
  final String artifactType;
  final int schemaVersion;
  final int artifactSize;
  final int rowCount;
  final Map<String, ApiLink> links;
  final DateTime? publishedAt;

  const SchoolTimetableTermUpdate({
    required this.termKey,
    required this.schoolYear,
    required this.term,
    required this.firstWeekMonday,
    required this.version,
    required this.checksum,
    required this.artifactType,
    required this.schemaVersion,
    required this.artifactSize,
    required this.rowCount,
    required this.links,
    this.publishedAt,
  });

  factory SchoolTimetableTermUpdate.fromJson(Map<String, dynamic> json) {
    return SchoolTimetableTermUpdate(
      termKey: json['term_key'] as String? ?? '',
      schoolYear: json['school_year'] as String? ?? '',
      term: json['term'] as String? ?? '',
      firstWeekMonday: json['first_week_monday'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String? ?? '',
      artifactType: json['artifact_type'] as String? ?? '',
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 0,
      artifactSize: (json['artifact_size'] as num?)?.toInt() ?? 0,
      rowCount: (json['row_count'] as num?)?.toInt() ?? 0,
      links: _linksFromJson(json['links']),
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    );
  }
}
