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
  final int latestVersion;
  final String checksum;
  final int schemaVersion;
  final List<String> terms;
  final SchoolTimetableSyncMode syncMode;
  final SchoolTimetableBundle? bundle;
  final List<SchoolTimetableChangeUpdate> changes;
  final DateTime? publishedAt;

  const SchoolTimetableBlock({
    this.changed = false,
    this.latestVersion = 0,
    this.checksum = '',
    this.schemaVersion = 0,
    this.terms = const [],
    this.syncMode = SchoolTimetableSyncMode.changes,
    this.bundle,
    this.changes = const [],
    this.publishedAt,
  });

  factory SchoolTimetableBlock.fromJson(Map<String, dynamic> json) {
    final rawTerms = json['terms'] as List? ?? const [];
    final rawChanges = json['changes'] as List? ?? const [];
    return SchoolTimetableBlock(
      changed: json['changed'] as bool? ?? false,
      latestVersion: (json['latest_version'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String? ?? '',
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 0,
      syncMode: SchoolTimetableSyncModeX.fromWire(
        json['sync_mode'] as String? ?? 'changes',
      ),
      bundle: json['bundle'] is Map<String, dynamic>
          ? SchoolTimetableBundle.fromJson(
              json['bundle'] as Map<String, dynamic>,
            )
          : null,
      terms: [
        for (final item in rawTerms) item?.toString() ?? '',
      ].where((value) => value.isNotEmpty).toList(growable: false),
      changes: [
        for (final item in rawChanges)
          if (item is Map<String, dynamic>)
            SchoolTimetableChangeUpdate.fromJson(item),
      ],
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    );
  }
}

enum SchoolTimetableSyncMode { changes, bundle }

extension SchoolTimetableSyncModeX on SchoolTimetableSyncMode {
  static SchoolTimetableSyncMode fromWire(String value) {
    return switch (value) {
      'bundle' => SchoolTimetableSyncMode.bundle,
      _ => SchoolTimetableSyncMode.changes,
    };
  }
}

class SchoolTimetableBundle {
  const SchoolTimetableBundle({
    required this.version,
    required this.href,
    required this.size,
    required this.checksum,
  });

  final int version;
  final String href;
  final int size;
  final String checksum;

  factory SchoolTimetableBundle.fromJson(Map<String, dynamic> json) {
    return SchoolTimetableBundle(
      version: (json['version'] as num?)?.toInt() ?? 0,
      href: json['href'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
      checksum: json['checksum'] as String? ?? '',
    );
  }
}

class SchoolTimetableChangeUpdate {
  final int version;
  final int sequence;
  final String operation;
  final String entityType;
  final String entityId;
  final String termKey;
  final Map<String, dynamic> payload;

  const SchoolTimetableChangeUpdate({
    required this.version,
    required this.sequence,
    required this.operation,
    required this.entityType,
    required this.entityId,
    required this.termKey,
    required this.payload,
  });

  factory SchoolTimetableChangeUpdate.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return SchoolTimetableChangeUpdate(
      version: (json['version'] as num?)?.toInt() ?? 0,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      operation: json['operation'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id'] as String? ?? '',
      termKey: json['term_key'] as String? ?? '',
      payload: payload is Map<String, dynamic> ? payload : const {},
    );
  }
}
