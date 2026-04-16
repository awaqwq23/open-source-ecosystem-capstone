import 'package:huajuan_agenda/core/localization/generated/app_localizations.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_validator.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';

class ValidateItemDraftUseCase {
  const ValidateItemDraftUseCase();

  ItemEditorValidationErrors call(
    ItemDraft draft,
    AppLocalizations l10n,
  ) {
    return ItemEditorValidator.validate(draft, l10n);
  }
}

