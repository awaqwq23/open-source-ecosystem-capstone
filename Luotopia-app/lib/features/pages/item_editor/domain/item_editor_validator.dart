import 'package:luotopia/core/localization/generated/app_localizations.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

class ItemEditorValidationErrors {
  const ItemEditorValidationErrors({
    this.title,
    this.timeRange,
    this.deadline,
  });

  final String? title;
  final String? timeRange;
  final String? deadline;

  bool get hasErrors {
    return title != null ||
        timeRange != null ||
        deadline != null;
  }
}

class ItemEditorValidator {
  const ItemEditorValidator._();

  static ItemEditorValidationErrors validate(
    ItemDraft draft,
    AppLocalizations l10n,
  ) {
    String? titleError;
    String? timeRangeError;
    String? deadlineError;

    if (draft.title.trim().isEmpty) {
      titleError = l10n.editorErrorTitleRequired;
    }

    final start = draft.timelineStartAt;
    final end = draft.timelineEndAt;
    if ((draft.type == ItemType.course || draft.type == ItemType.schedule) &&
        start != null &&
        end != null &&
        end.isBefore(start)) {
      timeRangeError = l10n.editorErrorEndBeforeStart;
    }

    if (draft.type == ItemType.task && draft.deadlineAt == null) {
      deadlineError = l10n.editorErrorDeadlineBeforeStart;
    }

    return ItemEditorValidationErrors(
      title: titleError,
      timeRange: timeRangeError,
      deadline: deadlineError,
    );
  }
}

