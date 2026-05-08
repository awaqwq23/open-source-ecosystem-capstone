import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';

abstract class AiChatRepository {
  List<AiChatSession> getSessions();
  AiChatSession? getActiveSession();
  Future<AiChatSession> createSession();
  Future<void> selectSession(String sessionId);
  Future<void> appendToActiveSession(AiChatMessage message);
}
