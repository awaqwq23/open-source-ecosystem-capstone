import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/notification/data/notification_api.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/data/pull_state_store.dart';
import 'package:luotopia/features/unified_pull/domain/pull_service.dart';
import 'package:luotopia/features/unified_pull/presentation/providers/pull_providers.dart';

class NotificationState {
  final String? latestId;
  final String? title;
  final String? content;
  final bool hasNew;
  final int count;
  final bool loading;
  final List<NotificationSummary> items;

  const NotificationState({
    this.latestId,
    this.title,
    this.content,
    this.hasNew = false,
    this.count = 0,
    this.loading = false,
    this.items = const [],
  });

  NotificationState copyWith({
    String? latestId,
    String? title,
    String? content,
    bool? hasNew,
    int? count,
    bool? loading,
    List<NotificationSummary>? items,
  }) {
    return NotificationState(
      latestId: latestId ?? this.latestId,
      title: title ?? this.title,
      content: content ?? this.content,
      hasNew: hasNew ?? this.hasNew,
      count: count ?? this.count,
      loading: loading ?? this.loading,
      items: items ?? this.items,
    );
  }
}

class NotificationSummary {
  const NotificationSummary({
    required this.id,
    required this.title,
    this.priority = '',
    this.createdAt,
  });

  final String id;
  final String title;
  final String priority;
  final DateTime? createdAt;

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

final notificationApiProvider = Provider<NotificationAPI>((ref) {
  return NotificationAPI(apiClient: ref.read(apiClientProvider));
});

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final api = ref.read(notificationApiProvider);
  final stateStore = ref.read(pullStateStoreProvider);
  return NotificationNotifier(
    api: api,
    pullService: ref.read(unifiedPullServiceProvider),
    stateStore: stateStore,
  );
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier({
    required NotificationAPI api,
    required UnifiedPullService pullService,
    required PullStateStore stateStore,
  })  : _api = api,
        _pullService = pullService,
        _stateStore = stateStore,
        super(_stateFromBlock(stateStore.readNotification()));

  final NotificationAPI _api;
  final UnifiedPullService _pullService;
  final PullStateStore _stateStore;

  Future<void> checkLatest() async {
    try {
      final result = await _pullService.pullPublicNotification(trigger: 'manual');
      if (result.isSuccess) {
        state = _stateFromBlock(
          result.response?.notification ?? _stateStore.readNotification(),
        ).copyWith(items: state.items);
      }
    } catch (_) {
      // Silently fail
    }
  }

  Future<void> loadList() async {
    state = state.copyWith(loading: true);
    try {
      final data = await _api.getList();
      final rawItems = data['items'];
      final items = rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(NotificationSummary.fromJson)
              .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
              .toList(growable: false)
          : const <NotificationSummary>[];
      state = state.copyWith(
        loading: false,
        count: (data['total'] as num?)?.toInt() ?? items.length,
        items: items,
      );
    } catch (_) {
      state = state.copyWith(loading: false);
    }
  }

  Future<NotificationDetail?> loadDetail(String id) async {
    if (id.isEmpty) {
      return null;
    }
    final data = await _api.getById(id);
    return NotificationDetail(
      id: id,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
    );
  }

  static NotificationState _stateFromBlock(NotificationBlock? block) {
    if (block == null || block.latestId.isEmpty) {
      return const NotificationState();
    }
    return NotificationState(
      latestId: block.latestId,
      title: block.title.isEmpty ? null : block.title,
      hasNew: block.hasNew,
      count: block.count,
    );
  }
}

class NotificationDetail {
  const NotificationDetail({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;
  final String title;
  final String content;
}
