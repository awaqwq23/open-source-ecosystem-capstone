import 'package:flutter/material.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:intl/intl.dart';

Color _colorForType(ItemType type, Brightness brightness) {
  const light = <ItemType, Color>{
    ItemType.schedule: Color(0xFF4DA3FF),
    ItemType.task: Color(0xFF2FA572),
    ItemType.memo: Color(0xFFB26AF3),
  };
  const dark = <ItemType, Color>{
    ItemType.schedule: Color(0xFF7AB8FF),
    ItemType.task: Color(0xFF59C98F),
    ItemType.memo: Color(0xFFCA98FF),
  };
  return (brightness == Brightness.dark ? dark : light)[type] ?? Colors.grey;
}

IconData _iconForType(ItemType type) {
  return switch (type) {
    ItemType.schedule => Icons.calendar_month_outlined,
    ItemType.task => Icons.check_circle_outline,
    ItemType.memo => Icons.sticky_note_2_outlined,
    ItemType.course => Icons.school_outlined,
  };
}

class CitationCard extends StatelessWidget {
  const CitationCard({
    required this.citation,
    super.key,
  });

  final AiCitation citation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final accent = _colorForType(citation.type, brightness);
    final locale = Localizations.localeOf(context).toLanguageTag();

    String? timeLabel;
    if (citation.startAt != null) {
      if (citation.endAt != null) {
        timeLabel =
            '${DateFormat.Hm(locale).format(citation.startAt!)}–${DateFormat.Hm(locale).format(citation.endAt!)}';
      } else {
        timeLabel = DateFormat.Hm(locale).format(citation.startAt!);
      }
    }

    final typeLabel = switch (citation.type) {
      ItemType.schedule => '日程',
      ItemType.task => '任务',
      ItemType.memo => '备忘',
      ItemType.course => '课程',
    };

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // 未来：导航到事项详情页
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: accent, width: 3),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconForType(citation.type), size: 16, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            typeLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              citation.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (timeLabel != null)
                            Text(
                              timeLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      if (citation.reason != null && citation.reason!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(
                            citation.reason!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
