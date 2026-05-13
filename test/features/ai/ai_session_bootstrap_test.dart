import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/core/storage/shared_preferences_provider.dart';
import 'package:luotopia/features/pages/ai/data/ai_chat_session_storage_mapper.dart';
import 'package:luotopia/features/pages/ai/data/ai_in_memory_data_source.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AI session bootstrap', () {
    test('restores sessions and active session id from preferences', () async {
      final older = DateTime(2026, 5, 1, 8);
      final newer = DateTime(2026, 5, 2, 8);
      SharedPreferences.setMockInitialValues({
        AppBootstrapStorageKeys.aiSessions: jsonEncode([
          _sessionJson(id: 'session_older', updatedAt: older),
          _sessionJson(id: 'session_newer', updatedAt: newer),
        ]),
        AppBootstrapStorageKeys.activeAiSessionId: 'session_older',
      });
      final prefs = await SharedPreferences.getInstance();

      final bootstrap = await AppBootstrapLoader.load(prefs);

      expect(bootstrap.aiChatSessionStore.sessions, hasLength(2));
      expect(bootstrap.aiChatSessionStore.activeSessionId, 'session_older');
      expect(bootstrap.aiChatSessionStore.activeSession?.id, 'session_older');
    });

    test(
      'uses newest session when stored active session id is stale',
      () async {
        final older = DateTime(2026, 5, 1, 8);
        final newer = DateTime(2026, 5, 2, 8);
        SharedPreferences.setMockInitialValues({
          AppBootstrapStorageKeys.aiSessions: jsonEncode([
            _sessionJson(id: 'session_older', updatedAt: older),
            _sessionJson(id: 'session_newer', updatedAt: newer),
          ]),
          AppBootstrapStorageKeys.activeAiSessionId: 'missing',
        });
        final prefs = await SharedPreferences.getInstance();

        final bootstrap = await AppBootstrapLoader.load(prefs);

        expect(bootstrap.aiChatSessionStore.activeSessionId, 'session_newer');
        expect(bootstrap.aiChatSessionStore.sessions.first.id, 'session_newer');
      },
    );

    test(
      'falls back to one empty session when stored JSON is invalid',
      () async {
        SharedPreferences.setMockInitialValues({
          AppBootstrapStorageKeys.aiSessions: '{',
          AppBootstrapStorageKeys.activeAiSessionId: 'missing',
        });
        final prefs = await SharedPreferences.getInstance();

        final bootstrap = await AppBootstrapLoader.load(prefs);

        expect(bootstrap.aiChatSessionStore.sessions, hasLength(1));
        expect(bootstrap.aiChatSessionStore.activeSession, isNotNull);
        expect(bootstrap.aiChatSessionStore.activeSession!.messages, isEmpty);
      },
    );

    test('deleting active session selects remaining newest session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = AiChatSessionStore(
        sessions: [
          _session(id: 'session_newer', updatedAt: DateTime(2026, 5, 2, 8)),
          _session(id: 'session_older', updatedAt: DateTime(2026, 5, 1, 8)),
        ],
        activeSessionId: 'session_newer',
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          aiChatBootstrapSessionStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(aiChatRepositoryNotifierProvider)
          .deleteSession('session_newer');

      final next = container.read(aiChatRepositoryProvider);
      expect(next.sessions.map((session) => session.id), ['session_older']);
      expect(next.activeSessionId, 'session_older');
      expect(
        prefs.getString(AppBootstrapStorageKeys.activeAiSessionId),
        'session_older',
      );
    });

    test('clearing sessions creates a persisted empty session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final store = AiChatSessionStore(
        sessions: [
          _session(id: 'session_a', updatedAt: DateTime(2026, 5, 2, 8)),
        ],
        activeSessionId: 'session_a',
      );
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          aiChatBootstrapSessionStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      await container.read(aiChatRepositoryNotifierProvider).clearSessions();

      final next = container.read(aiChatRepositoryProvider);
      expect(next.sessions, hasLength(1));
      expect(next.activeSessionId, next.sessions.first.id);
      expect(next.sessions.first.messages, isEmpty);
      expect(
        prefs.getString(AppBootstrapStorageKeys.activeAiSessionId),
        next.sessions.first.id,
      );
    });
  });
}

Map<String, Object?> _sessionJson({
  required String id,
  required DateTime updatedAt,
}) {
  return AiChatSessionStorageMapper.sessionToJson(
    _session(
      id: id,
      updatedAt: updatedAt,
      messages: [
        AiChatMessage(
          id: 'message_$id',
          sessionId: id,
          content: 'hello from $id',
          createdAt: updatedAt,
          role: AiChatRole.user,
        ),
      ],
    ),
  );
}

AiChatSession _session({
  required String id,
  required DateTime updatedAt,
  List<AiChatMessage> messages = const [],
}) {
  return AiChatSession(
    id: id,
    createdAt: updatedAt.subtract(const Duration(minutes: 1)),
    updatedAt: updatedAt,
    messages: messages,
  );
}
