import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/item_editor/data/item_editor_repository.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_defaults.dart';
import 'package:huajuan_agenda/features/item_editor/domain/item_editor_validator.dart';
import 'package:huajuan_agenda/features/item_editor/domain/models/item_editor_prefill.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/models/item_draft.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';

class ItemEditorPageState {
  const ItemEditorPageState({
    required this.draft,
    this.errors = const ItemEditorValidationErrors(),
    this.isSubmitting = false,
    this.submitSucceeded = false,
  });

  final ItemDraft draft;
  final ItemEditorValidationErrors errors;
  final bool isSubmitting;
  final bool submitSucceeded;

  bool get canSubmit => !isSubmitting;

  ItemEditorPageState copyWith({
    ItemDraft? draft,
    ItemEditorValidationErrors? errors,
    bool? isSubmitting,
    bool? submitSucceeded,
  }) {
    return ItemEditorPageState(
      draft: draft ?? this.draft,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }
}

class ItemEditorPageController extends AutoDisposeNotifier<ItemEditorPageState> {
  ItemEditorPrefill? _prefill;

  @override
  ItemEditorPageState build() {
    return ItemEditorPageState(
      draft: ItemEditorDefaults.createDraft(),
    );
  }

  void initialize([ItemEditorPrefill? prefill]) {
    if (_prefill == prefill && prefill != null) {
      return;
    }

    _prefill = prefill;
    state = ItemEditorPageState(
      draft: ItemEditorDefaults.createDraft(prefill),
    );
  }

  void selectType(ItemType type) {
    _updateDraft(ItemEditorDefaults.applyType(state.draft, type));
  }

  void updateTitle(String value) {
    _updateDraft(state.draft.copyWith(title: value));
  }

  void updateDetails(String value) {
    _updateDraft(state.draft.copyWith(details: value));
  }

  void updateLocation(String value) {
    _updateDraft(state.draft.copyWith(location: value));
  }

  void selectColor(ItemColorOption color) {
    _updateDraft(state.draft.copyWith(color: color));
  }

  void selectReminder(ReminderOption option) {
    _updateDraft(state.draft.copyWith(reminder: option));
  }

  void selectRepeatRule(RepeatRule rule) {
    _updateDraft(state.draft.copyWith(repeatRule: rule));
  }

  void updateStartDate(DateTime date) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      state.draft.startAt.hour,
      state.draft.startAt.minute,
    );
    final end = state.draft.endAt.isBefore(start) ? start : state.draft.endAt;
    _updateDraft(
      state.draft.copyWith(
        startAt: start,
        endAt: end,
        targetDate: date,
      ),
    );
  }

  void updateStartTime(int hour, int minute) {
    final start = DateTime(
      state.draft.startAt.year,
      state.draft.startAt.month,
      state.draft.startAt.day,
      hour,
      minute,
    );
    final end = state.draft.endAt.isBefore(start) ? start : state.draft.endAt;
    _updateDraft(state.draft.copyWith(startAt: start, endAt: end));
  }

  void updateEndDate(DateTime date) {
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      state.draft.endAt.hour,
      state.draft.endAt.minute,
    );
    _updateDraft(state.draft.copyWith(endAt: end));
  }

  void updateEndTime(int hour, int minute) {
    final end = DateTime(
      state.draft.endAt.year,
      state.draft.endAt.month,
      state.draft.endAt.day,
      hour,
      minute,
    );
    _updateDraft(state.draft.copyWith(endAt: end));
  }

  void updateDeadlineDate(DateTime date) {
    final currentDeadline = state.draft.deadline ?? state.draft.endAt;
    final deadline = DateTime(
      date.year,
      date.month,
      date.day,
      currentDeadline.hour,
      currentDeadline.minute,
    );
    _updateDraft(state.draft.copyWith(deadline: deadline));
  }

  void updateDeadlineTime(int hour, int minute) {
    final currentDeadline = state.draft.deadline ?? state.draft.endAt;
    final deadline = DateTime(
      currentDeadline.year,
      currentDeadline.month,
      currentDeadline.day,
      hour,
      minute,
    );
    _updateDraft(state.draft.copyWith(deadline: deadline));
  }

  void clearDeadline() {
    _updateDraft(state.draft.copyWith(clearDeadline: true));
  }

  void updateTargetDate(DateTime date) {
    _updateDraft(state.draft.copyWith(targetDate: date));
  }

  void updateEstimatedDuration(Duration duration) {
    _updateDraft(state.draft.copyWith(estimatedDuration: duration));
  }

  Future<bool> submit(ItemEditorValidationErrors errors) async {
    state = state.copyWith(errors: errors, submitSucceeded: false);
    if (errors.hasErrors) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    await ref.read(itemEditorRepositoryProvider).createItem(state.draft);
    state = state.copyWith(
      isSubmitting: false,
      submitSucceeded: true,
    );
    return true;
  }

  void clearSubmitSucceeded() {
    if (state.submitSucceeded) {
      state = state.copyWith(submitSucceeded: false);
    }
  }

  void _updateDraft(ItemDraft draft) {
    state = state.copyWith(
      draft: draft,
      errors: const ItemEditorValidationErrors(),
      submitSucceeded: false,
    );
  }
}

final itemEditorPageControllerProvider =
    NotifierProvider.autoDispose<ItemEditorPageController, ItemEditorPageState>(
  ItemEditorPageController.new,
);
