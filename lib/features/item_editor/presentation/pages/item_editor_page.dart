import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/core/localization/locale_extensions.dart';
import 'package:huajuan_agenda/features/item_editor/presentation/viewmodels/item_editor_header_view_model.dart';
import 'package:huajuan_agenda/shared/widgets/app_page_header.dart';
import 'package:huajuan_agenda/shared/widgets/app_sheet_scaffold.dart';
import 'package:huajuan_agenda/shared/widgets/app_placeholder_page.dart';

class ItemEditorPage extends ConsumerWidget {
  const ItemEditorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itemEditorHeaderViewModelProvider);

    return AppPlaceholderPage(
      title: context.l10n.editorTitle,
      description: context.l10n.editorDescription,
      icon: Icons.add_box,
      header: AppPageHeader(
        centerTitleWhenCompact: true,
        title: AppPageHeaderTitle(
          text: _typeLabel(context.l10n, state.type),
          center: true,
          showDropdownIndicator: true,
          onPressed: () => _showTypePicker(context, ref),
        ),
      ),
      primaryActionLabel: context.l10n.placeholderOpenPicker,
      onPrimaryAction: () => _showTypePicker(context, ref),
    );
  }

  String _typeLabel(AppLocalizations l10n, ItemEditorType type) {
    return switch (type) {
      ItemEditorType.task => l10n.editorTypeTask,
      ItemEditorType.schedule => l10n.editorTypeSchedule,
      ItemEditorType.memo => l10n.editorTypeMemo,
    };
  }

  Future<void> _showTypePicker(BuildContext context, WidgetRef ref) {
    final state = ref.read(itemEditorHeaderViewModelProvider);
    final l10n = context.l10n;

    return showAppSheetScaffold(
      context: context,
      title: l10n.editorTypePickerTitle,
      child: RadioGroup<ItemEditorType>(
        groupValue: state.type,
        onChanged: (value) {
          if (value == null) return;
          ref.read(itemEditorHeaderViewModelProvider.notifier).select(value);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ItemEditorType>(
              value: ItemEditorType.task,
              title: Text(l10n.editorTypeTask),
            ),
            RadioListTile<ItemEditorType>(
              value: ItemEditorType.schedule,
              title: Text(l10n.editorTypeSchedule),
            ),
            RadioListTile<ItemEditorType>(
              value: ItemEditorType.memo,
              title: Text(l10n.editorTypeMemo),
            ),
          ],
        ),
      ),
    );
  }
}
