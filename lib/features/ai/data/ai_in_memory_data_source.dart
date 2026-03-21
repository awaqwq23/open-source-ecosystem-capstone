import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_stream_event.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_chat_repository.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_service.dart';
import 'package:huajuan_agenda/features/settings/data/settings_repository_impl.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:openai_dart/openai_dart.dart';

class InMemoryAiChatRepository extends Notifier<List<AiChatMessage>>
    implements AiChatRepository {
  @override
  List<AiChatMessage> build() {
    return const [];
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
  }
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
    if (!settings.isConfigured) {
      throw const OpenAiConfigurationException('请先在设置页填写 AI 的 API 地址、密钥和模型。');
    }

    final client = OpenAIClient(
      config: OpenAIConfig(
        authProvider: ApiKeyProvider(settings.apiKey.trim()),
        baseUrl: settings.baseUrl.trim(),
      ),
    );

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
