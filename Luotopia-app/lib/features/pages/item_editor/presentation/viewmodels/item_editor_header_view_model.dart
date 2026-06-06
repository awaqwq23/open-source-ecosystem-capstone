import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_defaults.dart';
import 'package:luotopia/features/pages/item_editor/domain/item_editor_validator.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/repositories/item_editor_repository_provider.dart';
import 'package:luotopia/features/pages/item_editor/domain/use_cases/build_item_editor_draft.dart';
import 'package:luotopia/features/pages/item_editor/domain/use_cases/save_item_draft.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';

enum CourseColorUpdateScope {
  singleItem,
  sameTitleCourses,
}

class ItemEditorPageState {
  const ItemEditorPageState({
    required this.itemId,
    required this.draft,
    this.errors = const ItemEditorValidationErrors(),
    this.isSubmitting = false,
    this.submitSucceeded = false,
  });

  final String? itemId;
  final ItemDraft draft;
  final ItemEditorValidationErrors errors;
  final bool isSubmitting;
  final bool submitSucceeded;

  bool get canSubmit => !isSubmitting;
  bool get isEditing => itemId != null;

  ItemEditorPageState copyWith({
    String? itemId,
    bool clearItemId = false,
    ItemDraft? draft,
    ItemEditorValidationErrors? errors,
    bool? isSubmitting,
    bool? submitSucceeded,
  }) {
    return ItemEditorPageState(
      itemId: clearItemId ? null : (itemId ?? this.itemId),
      draft: draft ?? this.draft,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
    );
  }
}

class ItemEditorPageController extends AutoDisposeNotifier<ItemEditorPageState> {
  static const _buildDraft = BuildItemEditorDraftUseCase();
  ItemEditorArgs? _args;
  CourseColorUpdateScope _courseColorUpdateScope =
      CourseColorUpdateScope.singleItem;

  @override
  ItemEditorPageState build() {
    return ItemEditorPageState(
      itemId: null,
      draft: _buildDraft(),
    );
  }

  void initialize([ItemEditorArgs? args]) {
    if (_args == args && args != null) {
      return;
    }
    _args = args;
    _courseColorUpdateScope = CourseColorUpdateScope.singleItem;
    state = ItemEditorPageState(
      itemId: args?.itemId,
      draft: _normalizeDraft(_buildDraft(args?.prefill)),
    );
  }

  void selectType(ItemType type) {
    if (type != ItemType.course) {
      _courseColorUpdateScope = CourseColorUpdateScope.singleItem;
    }
    _updateDraft(ItemEditorDefaults.applyType(state.draft, type));
  }

  void updateTitle(String value) => _updateDraft(state.draft.copyWith(title: value));

  void updateDetails(String value) => _updateDraft(state.draft.copyWith(notes: value));

  void updateLocation(String value) =>
      _updateDraft(state.draft.copyWith(location: value));

  void updateCourseNature(String value) {
    _updateDraft(
      state.draft.copyWith(
        courseDetails: state.draft.courseDetails.copyWith(courseNature: value),
      ),
    );
  }

  void updateCourseInstructor(String value) {
    _updateDraft(
      state.draft.copyWith(
        courseDetails: state.draft.courseDetails.copyWith(instructor: value),
      ),
    );
  }

  void selectColor(
    ItemColorOption color, {
    CourseColorUpdateScope courseScope = CourseColorUpdateScope.singleItem,
  }) {
    _courseColorUpdateScope = courseScope;
    _updateDraft(state.draft.copyWith(color: color));
  }

  void toggleAllDay(bool value) {
    if (state.draft.type == ItemType.task || state.draft.type == ItemType.memo) {
      return;
    }
    final currentStart = _rangeStart();
    final currentEnd = _rangeEnd(currentStart);
    if (value) {
      final start = DateTime(currentStart.year, currentStart.month, currentStart.day);
      final end = DateTime(currentEnd.year, currentEnd.month, currentEnd.day, 23, 59);
      _updateDraft(
        state.draft.copyWith(
          scheduleIsAllDay: true,
          scheduleStartAt: start,
          scheduleEndAt: end.isBefore(start)
              ? DateTime(start.year, start.month, start.day, 23, 59)
              : end,
        ),
      );
      return;
    }
    final start = DateTime(currentStart.year, currentStart.month, currentStart.day, 9);
    final end = DateUtils.isSameDay(currentStart, currentEnd)
        ? start.add(const Duration(hours: 1))
        : DateTime(currentEnd.year, currentEnd.month, currentEnd.day, 10);
    _updateDraft(
      state.draft.copyWith(
        scheduleIsAllDay: false,
        scheduleStartAt: start,
        scheduleEndAt: end.isBefore(start) ? start.add(const Duration(hours: 1)) : end,
      ),
    );
  }

  void selectReminder(ReminderOption option) {
    _updateDraft(state.draft.copyWith(reminder: option));
  }

  void selectRepeatRule(RepeatRule rule) {
    _updateDraft(state.draft.copyWith(repeatRule: rule));
  }

  void updateStartDate(DateTime date) {
    final currentStart = _rangeStart();
    final currentEnd = _rangeEnd(currentStart);
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      currentStart.hour,
      currentStart.minute,
    );
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      currentEnd.hour,
      currentEnd.minute,
    );
    _updateDraft(
      state.draft.copyWith(
        scheduleStartAt: start,
        scheduleEndAt: end.isBefore(start) ? start : end,
      ),
    );
  }

  void updateStartDateTime(DateTime dateTime) {
    final end = _rangeEnd(dateTime);
    _updateDraft(
      state.draft.copyWith(
        scheduleStartAt: dateTime,
        scheduleEndAt: end.isBefore(dateTime) ? dateTime : end,
      ),
    );
  }

  void updateStartTime(int hour, int minute) {
    final currentStart = _rangeStart();
    final start = DateTime(
      currentStart.year,
      currentStart.month,
      currentStart.day,
      hour,
      minute,
    );
    final end = _rangeEnd(start);
    _updateDraft(
      state.draft.copyWith(
        scheduleStartAt: start,
        scheduleEndAt: end.isBefore(start) ? start : end,
      ),
    );
  }

  void updateEndDate(DateTime date) {
    final currentEnd = _rangeEnd(_rangeStart());
    _updateDraft(
      state.draft.copyWith(
        scheduleEndAt: DateTime(
          date.year,
          date.month,
          date.day,
          currentEnd.hour,
          currentEnd.minute,
        ),
      ),
    );
  }

  void updateEndTime(int hour, int minute) {
    final currentEnd = _rangeEnd(_rangeStart());
    _updateDraft(
      state.draft.copyWith(
        scheduleEndAt: DateTime(
          currentEnd.year,
          currentEnd.month,
          currentEnd.day,
          hour,
          minute,
        ),
      ),
    );
  }

  void updateEndDateTime(DateTime dateTime) {
    _updateDraft(state.draft.copyWith(scheduleEndAt: dateTime));
  }

  void updateDeadlineDate(DateTime date) {
    final current = state.draft.deadlineAt ?? DateTime.now();
    _updateDraft(
      state.draft.copyWith(
        taskDeadlineAt: DateTime(
          date.year,
          date.month,
          date.day,
          current.hour,
          current.minute,
        ),
      ),
    );
  }

  void updateDeadlineTime(int hour, int minute) {
    final current = state.draft.deadlineAt ?? DateTime.now();
    _updateDraft(
      state.draft.copyWith(
        taskDeadlineAt: DateTime(
          current.year,
          current.month,
          current.day,
          hour,
          minute,
        ),
      ),
    );
  }

  void updateDeadlineDateTime(DateTime dateTime) {
    _updateDraft(state.draft.copyWith(taskDeadlineAt: dateTime));
  }

  Future<bool> submit(ItemEditorValidationErrors errors) async {
    state = state.copyWith(errors: errors, submitSucceeded: false);
    if (errors.hasErrors) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    final repository = ref.read(itemEditorRepositoryProvider);
    final saveDraft = SaveItemDraftUseCase(repository);
    var draft = _normalizeDraftForSave(state.draft);
    if (draft.type == ItemType.course) {
      draft = draft.copyWith(
        reminder: ReminderOption.none,
        repeatRule: RepeatRule.none,
      );
    }
    await saveDraft(
      itemId: state.itemId,
      draft: draft,
    );
    if (draft.type == ItemType.course &&
        state.itemId != null &&
        _courseColorUpdateScope == CourseColorUpdateScope.sameTitleCourses) {
      await repository.updateCourseColorByTitle(
        title: draft.title,
        color: draft.color,
      );
    }
    _courseColorUpdateScope = CourseColorUpdateScope.singleItem;
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
      draft: _normalizeDraft(draft),
      errors: const ItemEditorValidationErrors(),
      submitSucceeded: false,
    );
  }

  ItemDraft _normalizeDraft(ItemDraft draft) {
    if (draft.type == ItemType.task && draft.details is! TaskItemDetails) {
      return draft.copyWith(
        details: TaskItemDetails(
          deadlineAt: draft.timelineEndAt ?? DateTime.now().add(const Duration(hours: 1)),
        ),
      );
    }
    return draft;
  }

  ItemDraft _normalizeDraftForSave(ItemDraft draft) {
    if (draft.type == ItemType.task && draft.deadlineAt == null) {
      return draft.copyWith(
        details: TaskItemDetails(
          deadlineAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
    }
    return draft;
  }

  DateTime _rangeStart() {
    return state.draft.timelineStartAt ?? DateTime.now();
  }

  DateTime _rangeEnd(DateTime fallbackStart) {
    return state.draft.timelineEndAt ?? fallbackStart.add(const Duration(hours: 1));
  }
}

final itemEditorPageControllerProvider =
    NotifierProvider.autoDispose<ItemEditorPageController, ItemEditorPageState>(
  ItemEditorPageController.new,
);
