class PullRequest {
  const PullRequest({
    required this.trigger,
    required this.scopes,
    required this.clientState,
  });

  final String trigger;
  final List<String> scopes;
  final PullClientState clientState;

  Map<String, dynamic> toJson() {
    return {
      'trigger': trigger,
      'scopes': scopes,
      'client_state': clientState.toJson(),
    };
  }
}

class PullClientState {
  const PullClientState({
    this.weatherCachedAt,
    this.notificationLatestId = '',
    this.hotUpdateScripts = const {},
    this.syncCursor,
  });

  final int? weatherCachedAt;
  final String notificationLatestId;
  final Map<String, ClientScriptState> hotUpdateScripts;
  final int? syncCursor;

  Map<String, dynamic> toJson() {
    return {
      if (weatherCachedAt != null) 'weather_cached_at': weatherCachedAt,
      if (notificationLatestId.isNotEmpty)
        'notification_latest_id': notificationLatestId,
      if (hotUpdateScripts.isNotEmpty)
        'hot_update_scripts': {
          for (final entry in hotUpdateScripts.entries)
            entry.key: entry.value.toJson(),
        },
      if (syncCursor != null) 'sync_cursor': syncCursor,
    };
  }
}

class ClientScriptState {
  const ClientScriptState({required this.version, required this.checksum});

  final int version;
  final String checksum;

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'checksum': checksum,
    };
  }
}
