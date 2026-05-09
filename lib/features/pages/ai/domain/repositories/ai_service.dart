import 'package:luotopia/features/pages/ai/domain/models/ai_action_models.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_stream_event.dart';
import 'package:luotopia/features/pages/settings/domain/models/ai_settings.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';

enum AiServiceErrorCode {
  configuration,
  network,
  parse,
  validation,
}

class AiServiceException implements Exception {
  const AiServiceException({
    required this.code,
    required this.message,
  });

  final AiServiceErrorCode code;
  final String message;

  @override
  String toString() => message;
}

abstract class AiService {
  Future<AiResolvedMessage> resolveMessage({
    required String message,
    required List<AgendaItem> items,
    List<AiChatMessage> history = const [],
  });

  Stream<AiStreamEvent> streamMessage({
    required String message,
    required List<AgendaItem> items,
    List<AiChatMessage> history = const [],
  });

  Future<void> validateConnection({
    required AiSettings settings,
  });
}

