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
  const AiStreamCompleted(this.text);

  final String text;
}
