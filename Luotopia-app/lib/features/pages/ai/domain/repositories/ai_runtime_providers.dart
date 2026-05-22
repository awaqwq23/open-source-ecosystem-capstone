import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:luotopia/features/pages/ai/data/ai_in_memory_data_source.dart'
    show
        OpenAiConfigurationException,
        aiChatRepositoryNotifierProvider,
        aiChatRepositoryProvider,
        aiServiceProvider;
export 'package:luotopia/features/pages/ai/domain/repositories/ai_service.dart'
    show AiServiceException, AiServiceErrorCode;

/// 每次 AI 标签页被激活时递增，用于触发 AiPage 重建 session
final aiPageActivationProvider = StateProvider<int>((ref) => 0);
