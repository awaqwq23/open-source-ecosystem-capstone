import 'package:luotopia/core/localization/generated/app_localizations.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_validator.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';

class ValidateItemDraftUseCase {
  const ValidateItemDraftUseCase();

  ItemEditorValidationErrors call(
    ItemDraft draft,
    AppLocalizations l10n,
  ) {
    return ItemEditorValidator.validate(draft, l10n);
  }
}

