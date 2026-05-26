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

  const NotificationState({
    this.latestId,
    this.title,
    this.content,
    this.hasNew = false,
    this.count = 0,
    this.loading = false,
  });
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
        );
      }
    } catch (_) {
      // Silently fail
    }
  }

  Future<void> loadDetail() async {
    final id = state.latestId;
    if (id == null || id.isEmpty || state.content != null) {
      return;
    }
    final data = await _api.getById(id);
    state = NotificationState(
      latestId: id,
      title: data['title'] as String? ?? state.title,
      content: data['content'] as String? ?? '',
      hasNew: state.hasNew,
      count: state.count,
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
