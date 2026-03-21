import 'package:huajuan_agenda/features/ai/domain/models/ai_stream_event.dart';
import 'package:huajuan_agenda/shared/models/agenda_item.dart';

abstract class AiService {
  Stream<AiStreamEvent> sendMessage({
    required String message,
    required List<AgendaItem> items,
  });
}
