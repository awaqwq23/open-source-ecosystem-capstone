import 'package:huajuan_agenda/features/ai/domain/models/ai_action_models.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';

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
  });

  Future<void> validateConnection({
    required AiSettings settings,
  });
}

