import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/core/localization/generated/app_localizations.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_defaults.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_validator.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';

void main() {
  group('ItemEditorValidator', () {
    test('标题为空时返回标题错误', () {
      final draft = ItemEditorDefaults.createDraft().copyWith(title: '   ');

      final errors = ItemEditorValidator.validate(
        draft,
        lookupAppLocalizations(const Locale('zh')),
      );

      expect(errors.title, isNotNull);
      expect(errors.hasErrors, isTrue);
    });

    test('任务缺少截止时间时返回错误', () {
      final draft = ItemEditorDefaults.createDraft().copyWith(
        type: ItemType.task,
        title: '任务',
        details: const MemoItemDetails(),
      );

      final errors = ItemEditorValidator.validate(
        draft,
        lookupAppLocalizations(const Locale('zh')),
      );

      expect(errors.deadline, isNotNull);
    });

    test('备忘不需要时间属性时通过校验', () {
      final draft = ItemEditorDefaults.createDraft().copyWith(
        type: ItemType.memo,
        title: '备忘',
      );

      final errors = ItemEditorValidator.validate(
        draft,
        lookupAppLocalizations(const Locale('zh')),
      );

      expect(errors.hasErrors, isFalse);
    });
  });
}
