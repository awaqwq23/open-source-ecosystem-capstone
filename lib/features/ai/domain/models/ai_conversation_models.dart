import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.role,
    this.kind = AiMessageKind.chat,
    this.citations = const <AiCitation>[],
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final AiChatRole role;
  final AiMessageKind kind;
  final List<AiCitation> citations;
}

enum AiChatRole {
  user,
  assistant,
}

enum AiMessageKind {
  chat,
  answer,
  system,
}

class AiCitation {
  const AiCitation({
    required this.itemId,
    required this.title,
    required this.type,
    this.startAt,
    this.endAt,
    this.reason,
  });

  final String itemId;
  final String title;
  final ItemType type;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? reason;
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
