import 'package:flutter/material.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/features/pages/ai/presentation/widgets/citation_card.dart';
import 'package:luotopia/features/pages/ai/presentation/widgets/mini_timeline.dart';

class AiItemVisualizer extends StatelessWidget {
  const AiItemVisualizer({
    required this.citations,
    super.key,
  });

  final List<AiCitation> citations;

  @override
  Widget build(BuildContext context) {
    if (citations.isEmpty) {
      return const SizedBox.shrink();
    }

    // 如果有 ≥2 个带时间的事项，显示时间线 + 引用卡片
    final timedCount = citations.where((c) => c.startAt != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (timedCount >= 2) MiniTimeline(citations: citations),
        const SizedBox(height: 4),
        for (final citation in citations) CitationCard(citation: citation),
      ],
    );
  }
}
