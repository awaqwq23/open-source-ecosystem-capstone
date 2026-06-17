import 'package:flutter/material.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class EmptyClassroomCard extends StatelessWidget {
  const EmptyClassroomCard({
    required this.classroom,
    required this.isExpanded,
    required this.formatSections,
    required this.groupSections,
    required this.conflictingSections,
    required this.onSectionTap,
    required this.onSectionGroupTap,
    required this.onToggleExpanded,
    super.key,
  });

  final EmptyClassroom classroom;
  final bool isExpanded;
  final String Function(List<int> sections) formatSections;
  final List<List<int>> Function(List<int> sections) groupSections;
  final Set<String> conflictingSections;
  final ValueChanged<int> onSectionTap;
  final ValueChanged<List<int>> onSectionGroupTap;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final sectionGroups = groupSections(
      classroom.availableSections,
    ).where((group) => group.length > 1).toList();
    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    classroom.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (classroom.type.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      classroom.type,
                      style: const TextStyle(fontSize: 11, color: Colors.blue),
                    ),
                  ),
                const Spacer(),
                if (classroom.availableSections.isNotEmpty)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.emptyClassroomFloorSeats(
              classroom.floor,
              classroom.availableSeats,
              classroom.totalSeats,
            ),
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          if (isExpanded && classroom.availableSections.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.emptyClassroomSectionHint,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            _SectionButtons(
              classroom: classroom,
              conflictingSections: conflictingSections,
              onSectionTap: onSectionTap,
            ),
            if (sectionGroups.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SectionGroupButtons(
                groups: sectionGroups,
                formatSections: formatSections,
                onSectionGroupTap: onSectionGroupTap,
              ),
            ],
          ] else ...[
            const SizedBox(height: 4),
            Text(
              formatSections(classroom.availableSections),
              style: TextStyle(
                fontSize: 12,
                color: colors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionGroupButtons extends StatelessWidget {
  const _SectionGroupButtons({
    required this.groups,
    required this.formatSections,
    required this.onSectionGroupTap,
  });

  final List<List<int>> groups;
  final String Function(List<int> sections) formatSections;
  final ValueChanged<List<int>> onSectionGroupTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: groups.map((group) {
        return OutlinedButton.icon(
          onPressed: () => onSectionGroupTap(group),
          icon: const Icon(Icons.add, size: 16),
          label: Text('添加${formatSections(group)}'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary.withValues(alpha: 0.36)),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }
}

class _SectionButtons extends StatelessWidget {
  const _SectionButtons({
    required this.classroom,
    required this.conflictingSections,
    required this.onSectionTap,
  });

  final EmptyClassroom classroom;
  final Set<String> conflictingSections;
  final ValueChanged<int> onSectionTap;

  static const _availableColor = Color(0xFF22C55E);
  static const _conflictColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: classroom.availableSections.map((section) {
        final conflicted = conflictingSections.contains(section.toString());
        final color = conflicted ? _conflictColor : _availableColor;
        return Material(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () => onSectionTap(section),
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Center(
                child: Text(
                  '$section',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
