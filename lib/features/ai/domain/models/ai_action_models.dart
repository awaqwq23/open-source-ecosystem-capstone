import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';

enum AiResolvedIntentType {
  createItem,
  answer,
  fallback,
}

class AiDraftConflict {
  const AiDraftConflict({
    required this.itemId,
    required this.title,
    required this.overlapStart,
    required this.overlapEnd,
  });

  final String itemId;
  final String title;
  final DateTime overlapStart;
  final DateTime overlapEnd;
}

class AiCreateItemDraft {
  const AiCreateItemDraft({
    required this.draft,
    required this.isImportant,
    this.missingRequired = const <String>[],
    this.conflicts = const <AiDraftConflict>[],
  });

  final ItemDraft draft;
  final bool isImportant;
  final List<String> missingRequired;
  final List<AiDraftConflict> conflicts;
}

class AiResolvedMessage {
  const AiResolvedMessage({
    required this.intent,
    required this.reply,
    this.createItemDraft,
    this.citations = const <AiCitation>[],
  });

  final AiResolvedIntentType intent;
  final String reply;
  final AiCreateItemDraft? createItemDraft;
  final List<AiCitation> citations;
}
