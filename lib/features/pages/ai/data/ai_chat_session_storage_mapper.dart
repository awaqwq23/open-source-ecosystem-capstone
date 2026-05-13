import 'dart:convert';

import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/shared/enums/item_type.dart';

abstract final class AiChatSessionStorageMapper {
  static AiChatSessionStore emptyStore({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    final session = AiChatSession(
      id: 'session_initial',
      createdAt: timestamp,
      updatedAt: timestamp,
      messages: const [],
    );
    return AiChatSessionStore(sessions: [session], activeSessionId: session.id);
  }

  static AiChatSessionStore fromStorage({
    required String? sessionsRaw,
    required String? activeSessionId,
    DateTime? now,
  }) {
    if (sessionsRaw == null || sessionsRaw.trim().isEmpty) {
      return emptyStore(now: now);
    }

    try {
      final decoded = jsonDecode(sessionsRaw);
      if (decoded is! List) {
        return emptyStore(now: now);
      }
      final sessions =
          decoded
              .whereType<Map<String, dynamic>>()
              .map(_sessionFromJson)
              .whereType<AiChatSession>()
              .toList(growable: true)
            ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
      if (sessions.isEmpty) {
        return emptyStore(now: now);
      }

      final requestedActiveId = activeSessionId?.trim();
      final resolvedActiveId =
          sessions.any((session) => session.id == requestedActiveId)
          ? requestedActiveId!
          : sessions.first.id;
      return AiChatSessionStore(
        sessions: sessions,
        activeSessionId: resolvedActiveId,
      );
    } catch (_) {
      return emptyStore(now: now);
    }
  }

  static String encodeSessions(List<AiChatSession> sessions) {
    return jsonEncode([for (final session in sessions) sessionToJson(session)]);
  }

  static Map<String, dynamic> sessionToJson(AiChatSession session) {
    return {
      'id': session.id,
      'title': session.title,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
      'messages': [
        for (final message in session.messages) messageToJson(message),
      ],
    };
  }

  static Map<String, dynamic> messageToJson(AiChatMessage item) {
    return {
      'id': item.id,
      'sessionId': item.sessionId,
      'content': item.content,
      'createdAt': item.createdAt.toIso8601String(),
      'role': item.role.name,
      'kind': item.kind.name,
      'citations': [
        for (final citation in item.citations)
          {
            'itemId': citation.itemId,
            'title': citation.title,
            'type': citation.type.name,
            'startAt': citation.startAt?.toIso8601String(),
            'endAt': citation.endAt?.toIso8601String(),
            'reason': citation.reason,
          },
      ],
    };
  }

  static AiChatSession? _sessionFromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String? ?? '').trim();
    if (id.isEmpty) {
      return null;
    }
    final fallbackDate = DateTime.now();
    final messages = (json['messages'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((item) => _messageFromJson(item, fallbackSessionId: id))
        .whereType<AiChatMessage>()
        .toList(growable: false);
    return AiChatSession(
      id: id,
      title: _nullableTrimmed(json['title'] as String?),
      createdAt: _dateFromJson(json['createdAt'], fallbackDate),
      updatedAt: _dateFromJson(json['updatedAt'], fallbackDate),
      messages: messages,
    );
  }

  static AiChatMessage? _messageFromJson(
    Map<String, dynamic> json, {
    required String fallbackSessionId,
  }) {
    final id = (json['id'] as String? ?? '').trim();
    final content = (json['content'] as String? ?? '').trim();
    if (id.isEmpty) {
      return null;
    }
    return AiChatMessage(
      id: id,
      sessionId:
          _nullableTrimmed(json['sessionId'] as String?) ?? fallbackSessionId,
      content: content,
      createdAt: _dateFromJson(json['createdAt'], DateTime.now()),
      role: _roleFromJson(json['role'] as String?),
      kind: _kindFromJson(json['kind'] as String?),
      citations: _citationsFromJson(json['citations'] as List<dynamic>?),
    );
  }

  static DateTime _dateFromJson(Object? raw, DateTime fallback) {
    if (raw is String) {
      return DateTime.tryParse(raw) ?? fallback;
    }
    return fallback;
  }

  static AiChatRole _roleFromJson(String? raw) {
    return switch (raw) {
      'assistant' => AiChatRole.assistant,
      _ => AiChatRole.user,
    };
  }

  static AiMessageKind _kindFromJson(String? raw) {
    return switch (raw) {
      'answer' => AiMessageKind.answer,
      'system' => AiMessageKind.system,
      _ => AiMessageKind.chat,
    };
  }

  static List<AiCitation> _citationsFromJson(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(_citationFromJson)
        .whereType<AiCitation>()
        .toList(growable: false);
  }

  static AiCitation? _citationFromJson(Map<String, dynamic> json) {
    final itemId = (json['itemId'] as String? ?? '').trim();
    final title = (json['title'] as String? ?? '').trim();
    if (itemId.isEmpty || title.isEmpty) {
      return null;
    }
    return AiCitation(
      itemId: itemId,
      title: title,
      type: _itemTypeFromJson(json['type'] as String?),
      startAt: _optionalDate(json['startAt']),
      endAt: _optionalDate(json['endAt']),
      reason: _nullableTrimmed(json['reason'] as String?),
    );
  }

  static ItemType _itemTypeFromJson(String? raw) {
    return switch (raw) {
      'task' => ItemType.task,
      'memo' => ItemType.memo,
      'course' => ItemType.course,
      _ => ItemType.schedule,
    };
  }

  static DateTime? _optionalDate(Object? raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static String? _nullableTrimmed(String? raw) {
    final value = raw?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
