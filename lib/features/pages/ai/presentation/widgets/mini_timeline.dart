import 'package:flutter/material.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/shared/enums/item_type.dart';

Color _colorForType(ItemType type, Brightness brightness) {
  const light = <ItemType, Color>{
    ItemType.schedule: Color(0xFF4DA3FF),
    ItemType.task: Color(0xFF2FA572),
    ItemType.memo: Color(0xFFB26AF3),
    ItemType.course: Color(0xFFF4B400),
  };
  const dark = <ItemType, Color>{
    ItemType.schedule: Color(0xFF7AB8FF),
    ItemType.task: Color(0xFF59C98F),
    ItemType.memo: Color(0xFFCA98FF),
    ItemType.course: Color(0xFFF8C84B),
  };
  return (brightness == Brightness.dark ? dark : light)[type] ?? Colors.grey;
}

class MiniTimeline extends StatelessWidget {
  const MiniTimeline({
    required this.citations,
    super.key,
  });

  final List<AiCitation> citations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // 过滤出有起止时间的事项
    final timed = citations.where((c) => c.startAt != null && c.endAt != null).toList();
    if (timed.length < 2) {
      return const SizedBox.shrink();
    }

    final minTime = timed.map((c) => c.startAt!).reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );
    final maxTime = timed.map((c) => c.endAt!).reduce(
      (a, b) => a.isAfter(b) ? a : b,
    );

    // 将时间轴对齐到小时
    final axisStart = DateTime(minTime.year, minTime.month, minTime.day, minTime.hour);
    final axisEnd = DateTime(
      maxTime.year, maxTime.month, maxTime.day, maxTime.hour + (maxTime.minute > 0 ? 1 : 0),
    );
    final totalMinutes = axisEnd.difference(axisStart).inMinutes;

    if (totalMinutes <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间线',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: timed.length * 28.0 + 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth - 42;
                return Stack(
                  children: [
                    // 时间轴竖线
                    Positioned(
                      left: 38,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 1,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    // 各项
                    for (var i = 0; i < timed.length; i++)
                      _buildTimelineRow(
                        context,
                        citation: timed[i],
                        index: i,
                        axisStart: axisStart,
                        totalMinutes: totalMinutes,
                        availableWidth: availableWidth,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
    BuildContext context, {
    required AiCitation citation,
    required int index,
    required DateTime axisStart,
    required int totalMinutes,
    required double availableWidth,
  }) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final color = _colorForType(citation.type, brightness);

    final startOffset = citation.startAt!.difference(axisStart).inMinutes;
    final duration = citation.endAt!.difference(citation.startAt!).inMinutes;
    final left = (startOffset / totalMinutes) * availableWidth;
    final width = (duration / totalMinutes) * availableWidth;

    return Positioned(
      top: index * 28.0,
      left: 0,
      right: 0,
      height: 22,
      child: Row(
        children: [
          // 时间标签
          SizedBox(
            width: 36,
            child: Text(
              '${citation.startAt!.hour.toString().padLeft(2, '0')}:${citation.startAt!.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          // 时间轴点 + 横条
          Stack(
            children: [
              Container(
                margin: EdgeInsets.only(left: left.clamp(0, availableWidth)),
                width: width.clamp(4, availableWidth - left),
                height: 18,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: color, width: 1),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  citation.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
              // 起始点
              Positioned(
                left: left.clamp(0, availableWidth) - 3,
                top: 5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
