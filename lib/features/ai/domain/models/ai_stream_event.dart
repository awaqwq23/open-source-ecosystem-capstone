import 'package:huajuan_agenda/features/ai/domain/models/ai_action_models.dart';

sealed class AiStreamEvent {
  const AiStreamEvent();
}

class AiStreamStarted extends AiStreamEvent {
  const AiStreamStarted();
}

class AiStreamDelta extends AiStreamEvent {
  const AiStreamDelta(this.text);

  final String text;
}

class AiStreamCompleted extends AiStreamEvent {
  const AiStreamCompleted(this.fullText, this.result);

  final String fullText;
  final AiResolvedMessage result;
}
