class AiSettings {
  const AiSettings({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    required this.systemPrompt,
  });

  const AiSettings.defaults()
      : baseUrl = '',
        apiKey = '',
        model = 'gpt-4o-mini',
        systemPrompt =
            '你是花卷日程的 AI 助手。你只会基于当前用户消息和提供的事项摘要回答，不引用历史对话。优先帮助用户创建事项、整理安排、回答日程问题。';

  final String baseUrl;
  final String apiKey;
  final String model;
  final String systemPrompt;

  bool get isConfigured =>
      baseUrl.trim().isNotEmpty &&
      apiKey.trim().isNotEmpty &&
      model.trim().isNotEmpty;

  AiSettings copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    String? systemPrompt,
  }) {
    return AiSettings(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }
}
