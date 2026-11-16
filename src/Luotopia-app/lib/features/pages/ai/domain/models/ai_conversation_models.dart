import 'package:luotopia/shared/enums/item_type.dart';

class AiChatMessage {
  const AiChatMessage({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.createdAt,
    required this.role,
    this.kind = AiMessageKind.chat,
    this.citations = const <AiCitation>[],
  });

  final String id;
  final String sessionId;
  final String content;
  final DateTime createdAt;
  final AiChatRole role;
  final AiMessageKind kind;
  final List<AiCitation> citations;
}

enum AiChatRole { user, assistant }

enum AiMessageKind { chat, answer, system }

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

class AiChatSession {
  const AiChatSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    this.title,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AiChatMessage> messages;
  final String? title;

  bool get isEmpty => messages.isEmpty;

  AiChatSession copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AiChatMessage>? messages,
    String? title,
    bool clearTitle = false,
  }) {
    return AiChatSession(
      id: id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      title: clearTitle ? null : (title ?? this.title),
    );
  }
}

class AiChatSessionStore {
  const AiChatSessionStore({
    required this.sessions,
    required this.activeSessionId,
  });

  final List<AiChatSession> sessions;
  final String activeSessionId;

  AiChatSession? get activeSession {
    for (final session in sessions) {
      if (session.id == activeSessionId) {
        return session;
      }
    }
    return sessions.isEmpty ? null : sessions.first;
  }

  String? get resolvedActiveSessionId => activeSession?.id;

  AiChatSessionStore copyWith({
    List<AiChatSession>? sessions,
    String? activeSessionId,
  }) {
    return AiChatSessionStore(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
    );
  }
}
