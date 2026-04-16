import 'package:huajuan_agenda/core/localization/generated/app_localizations.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';

class ItemEditorValidationErrors {
  const ItemEditorValidationErrors({
    this.title,
    this.timeRange,
    this.deadline,
    this.estimatedDuration,
  });

  final String? title;
  final String? timeRange;
  final String? deadline;
  final String? estimatedDuration;

  bool get hasErrors {
    return title != null ||
        timeRange != null ||
        deadline != null ||
        estimatedDuration != null;
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
    String? estimatedDurationError;

    if (draft.title.trim().isEmpty) {
      titleError = l10n.editorErrorTitleRequired;
    }

    if (draft.type != ItemType.memo && draft.endAt.isBefore(draft.startAt)) {
      timeRangeError = l10n.editorErrorEndBeforeStart;
    }

    if (draft.type == ItemType.task &&
        draft.deadline != null &&
        draft.deadline!.isBefore(draft.startAt)) {
      deadlineError = l10n.editorErrorDeadlineBeforeStart;
    }

    if (draft.type == ItemType.memo &&
        draft.estimatedDuration <= Duration.zero) {
      estimatedDurationError = l10n.editorErrorDurationPositive;
    }

    return ItemEditorValidationErrors(
      title: titleError,
      timeRange: timeRangeError,
      deadline: deadlineError,
      estimatedDuration: estimatedDurationError,
    );
  }
}

