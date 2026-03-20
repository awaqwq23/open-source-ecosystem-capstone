import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_chat_repository.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_service.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

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

class PlaceholderAiService implements AiService {
  const PlaceholderAiService();

  @override
  Future<AiChatMessage> sendMessage({
    required String message,
    required List<AgendaItem> items,
  }) async {
    final summary = items.isEmpty ? '当前没有事项数据。' : '当前共有 ${items.length} 个事项可供参考。';
    return AiChatMessage(
      id: 'assistant_${DateTime.now().microsecondsSinceEpoch}',
      content: '占位 AI 响应：$summary 你发送的是“$message”。后续可接入用户配置的 API。',
      createdAt: DateTime.now(),
      role: AiChatRole.assistant,
    );
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
  return const PlaceholderAiService();
});
