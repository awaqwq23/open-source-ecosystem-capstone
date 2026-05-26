import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import 'package:luotopia/shared/data/sync/local_sync_store.dart';
import 'package:luotopia/shared/data/sync/sync_cursor_store.dart';
import 'package:luotopia/shared/data/sync/sync_service.dart';

final syncCapabilityProvider = FutureProvider.autoDispose<bool>((ref) async {
  final auth = ref.watch(luotopiaAuthProvider);
  final token = auth.accessToken;
  if (auth.status != LuotopiaAuthStatus.authenticated ||
      token == null ||
      token.isEmpty) {
    ref.read(agendaSyncServiceProvider).resetCapability();
    return false;
  }
  return ref.read(agendaSyncServiceProvider).ensureCapability(token);
});

final pendingSyncChangeCountProvider = FutureProvider.autoDispose<int>((ref) {
  ref.watch(agendaItemRepositoryProvider);
  ref.watch(courseTimetableRepositoryProvider);
  return ref.read(localSyncStoreProvider).pendingChangeCount();
});

final lastSyncTimeProvider = Provider.autoDispose<DateTime?>((ref) {
  return ref.read(syncCursorStoreProvider).readLastSyncedAt();
});
