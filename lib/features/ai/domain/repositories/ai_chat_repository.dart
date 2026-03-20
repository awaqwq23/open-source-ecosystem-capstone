import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

abstract class AiChatRepository {
  List<AiChatMessage> getAll();
  List<AiChatMessage> getByRange(DateTimeRangeValue range);
  Future<void> append(AiChatMessage message);
}
