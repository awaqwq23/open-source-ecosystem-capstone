import 'dart:convert';

import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_stream_event.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_chat_repository.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_service.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final aiChatBootstrapMessagesProvider = Provider<List<AiChatMessage>>((ref) {
  return const [];
});

class InMemoryAiChatRepository extends Notifier<List<AiChatMessage>>
    implements AiChatRepository {
  @override
  List<AiChatMessage> build() {
    return ref.read(aiChatBootstrapMessagesProvider);
  }

  @override
  List<AiChatMessage> getAll() => state;

  @override
  List<AiChatMessage> getByRange(DateTimeRangeValue range) {
    return [
      for (final message in state)
        if (!message.createdAt.isBefore(range.start) &&
            message.createdAt.isBefore(range.end))
          message,
    ];
  }

  @override
  Future<void> append(AiChatMessage message) async {
    state = [...state, message];
    await _prefs?.setString(
      AppBootstrapStorageKeys.aiMessages,
      jsonEncode([
        for (final item in state)
          {
            'id': item.id,
            'content': item.content,
            'createdAt': item.createdAt.toIso8601String(),
            'role': item.role.name,
          },
      ]),
    );
  }

  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider);
}

class OpenAiConfigurationException implements Exception {
  const OpenAiConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OpenAiCompatibleAiService implements AiService {
  const OpenAiCompatibleAiService(this._ref);

  final Ref _ref;

  @override
  Stream<AiStreamEvent> sendMessage({
    required String message,
    required List<AgendaItem> items,
  }) async* {
    final settings = _ref.read(appAiSettingsProvider);
    final client = _buildClient(settings);

    final systemPrompt = _buildSystemPrompt(
      basePrompt: settings.systemPrompt,
      items: items,
    );

    final buffer = StringBuffer();

    try {
      yield const AiStreamStarted();
      final stream = client.chat.completions.createStream(
        ChatCompletionCreateRequest(
          model: settings.model.trim(),
          messages: [
            ChatMessage.system(systemPrompt),
            ChatMessage.user(message),
          ],
        ),
      );

      await for (final event in stream) {
        final delta = event.textDelta;
        if (delta == null || delta.isEmpty) {
          continue;
        }
        buffer.write(delta);
        yield AiStreamDelta(delta);
      }

      yield AiStreamCompleted(buffer.toString().trim());
    } finally {
      client.close();
    }
  }

  @override
  Future<void> validateConnection({
    required AiSettings settings,
  }) async {
    final client = _buildClient(settings);

    try {
      await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: settings.model.trim(),
          messages: [
            ChatMessage.user('Ping'),
          ],
          maxTokens: 1,
        ),
      );
    } finally {
      client.close();
    }
  }

  OpenAIClient _buildClient(AiSettings settings) {
    if (!settings.isConfigured) {
      throw const OpenAiConfigurationException('请先填写完整的 AI 地址、密钥和模型。');
    }

    return OpenAIClient(
      config: OpenAIConfig(
        authProvider: ApiKeyProvider(settings.apiKey.trim()),
        baseUrl: settings.baseUrl.trim(),
      ),
    );
  }

  String _buildSystemPrompt({
    required String basePrompt,
    required List<AgendaItem> items,
  }) {
    final cleanedBasePrompt = basePrompt.trim();
    if (items.isEmpty) {
      return '$cleanedBasePrompt\n\n当前没有可参考的事项数据。';
    }

    final summary = items
        .map(
          (item) => [
            '类型:${item.type.name}',
            '标题:${item.title}',
            if (item.details.trim().isNotEmpty) '详情:${item.details.trim()}',
            '开始:${item.startAt.toIso8601String()}',
            '结束:${item.endAt.toIso8601String()}',
            if (item.deadline != null) '截止:${item.deadline!.toIso8601String()}',
            if (item.location.trim().isNotEmpty) '地点:${item.location.trim()}',
            '重要:${item.isImportant ? '是' : '否'}',
            '完成:${item.isCompleted ? '是' : '否'}',
          ].join('；'),
        )
        .join('\n');

    return '$cleanedBasePrompt\n\n以下是当前事项摘要，请仅以这些信息为依据回答：\n$summary';
  }
}

final aiChatRepositoryProvider =
    NotifierProvider<InMemoryAiChatRepository, List<AiChatMessage>>(
  InMemoryAiChatRepository.new,
);

final aiChatRepositoryNotifierProvider = Provider<AiChatRepository>((ref) {
  return ref.read(aiChatRepositoryProvider.notifier);
});

final aiServiceProvider = Provider<AiService>((ref) {
  return OpenAiCompatibleAiService(ref);
});

