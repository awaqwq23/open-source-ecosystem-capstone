import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.role,
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final AiChatRole role;
}

enum AiChatRole {
  user,
  assistant,
}

class AiConversationGroup {
  const AiConversationGroup({
    required this.label,
    required this.range,
    required this.messages,
  });

  final String label;
  final DateTimeRangeValue range;
  final List<AiChatMessage> messages;
}
