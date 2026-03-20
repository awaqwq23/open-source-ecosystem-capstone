import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:huajuan_agenda/core/localization/generated/app_localizations.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_defaults.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_validator.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';

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

    test('任务 ddl 早于开始时间时返回错误', () {
      final start = DateTime(2026, 3, 20, 10);
      final draft = ItemEditorDefaults.createDraft().copyWith(
        type: ItemType.task,
        title: '任务',
        startAt: start,
        endAt: start.add(const Duration(hours: 1)),
        deadline: start.subtract(const Duration(minutes: 30)),
      );

      final errors = ItemEditorValidator.validate(
        draft,
        lookupAppLocalizations(const Locale('zh')),
      );

      expect(errors.deadline, isNotNull);
    });

    test('备忘预计时长大于零时通过校验', () {
      final date = DateTime(2026, 3, 20);
      final draft = ItemEditorDefaults.createDraft().copyWith(
        type: ItemType.memo,
        title: '备忘',
        targetDate: date,
        estimatedDuration: const Duration(minutes: 30),
      );

      final errors = ItemEditorValidator.validate(
        draft,
        lookupAppLocalizations(const Locale('zh')),
      );

      expect(errors.hasErrors, isFalse);
    });
  });
}
