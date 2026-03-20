import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';

abstract class AiService {
  Future<AiChatMessage> sendMessage({
    required String message,
    required List<AgendaItem> items,
  });
}
