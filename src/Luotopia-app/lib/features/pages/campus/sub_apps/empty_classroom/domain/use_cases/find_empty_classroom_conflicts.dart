import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/use_cases/build_empty_classroom_agenda_draft.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/enums/item_type.dart';

class FindEmptyClassroomConflictsUseCase {
  const FindEmptyClassroomConflictsUseCase({
    this.draftBuilder = const BuildEmptyClassroomAgendaDraftUseCase(),
  });

  final BuildEmptyClassroomAgendaDraftUseCase draftBuilder;

  List<int> call({
    required Iterable<AgendaItem> agendaItems,
    required Iterable<int> sections,
    required EmptyClassroomAgendaDraftContext context,
    required DateTime now,
  }) {
    final conflicts = <int>[];
    for (final section in sections) {
      final range = draftBuilder.sectionRange(
        context: context,
        section: section,
        now: now,
      );
      final hasConflict = agendaItems.any((item) {
        if (item.type == ItemType.memo) {
          return false;
        }
        final start = item.timelineStartAt;
        final end = item.timelineEndAt;
        return start != null &&
            end != null &&
            range.start.isBefore(end) &&
            range.end.isAfter(start);
      });
      if (hasConflict) {
        conflicts.add(section);
      }
    }
    return conflicts;
  }
}
