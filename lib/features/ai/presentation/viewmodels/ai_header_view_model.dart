import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_action_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';

enum AiHeaderPeriod {
  day,
  week,
  month,
}

enum AiWorkflowPhase {
  idle,
  parsing,
  awaitingConfirm,
  creating,
  answering,
  failed,
}

class AiHeaderState {
  const AiHeaderState({
    required this.period,
    required this.anchor,
    this.input = '',
    this.phase = AiWorkflowPhase.idle,
    this.pendingDraft,
    this.pendingDraftNavigationId,
    this.lastError,
    this.composerEnabled = true,
    this.composerDisabledReason,
  });

  final AiHeaderPeriod period;
  final DateTime anchor;
  final String input;
  final AiWorkflowPhase phase;
  final AiCreateItemDraft? pendingDraft;
  final int? pendingDraftNavigationId;
  final String? lastError;
  final bool composerEnabled;
  final String? composerDisabledReason;

  bool get isBusy {
    return phase == AiWorkflowPhase.parsing ||
        phase == AiWorkflowPhase.creating ||
        phase == AiWorkflowPhase.answering;
  }

  bool get canSend => composerEnabled && !isBusy && input.trim().isNotEmpty;

  AiHeaderState copyWith({
    AiHeaderPeriod? period,
    DateTime? anchor,
    String? input,
    AiWorkflowPhase? phase,
    AiCreateItemDraft? pendingDraft,
    bool clearPendingDraft = false,
    int? pendingDraftNavigationId,
    bool clearPendingDraftNavigation = false,
    String? lastError,
    bool clearError = false,
    bool? composerEnabled,
    String? composerDisabledReason,
    bool clearComposerDisabledReason = false,
  }) {
    return AiHeaderState(
      period: period ?? this.period,
      anchor: anchor ?? this.anchor,
      input: input ?? this.input,
      phase: phase ?? this.phase,
      pendingDraft: clearPendingDraft ? null : (pendingDraft ?? this.pendingDraft),
      pendingDraftNavigationId: clearPendingDraftNavigation
          ? null
          : (pendingDraftNavigationId ?? this.pendingDraftNavigationId),
      lastError: clearError ? null : (lastError ?? this.lastError),
      composerEnabled: composerEnabled ?? this.composerEnabled,
      composerDisabledReason: clearComposerDisabledReason
          ? null
          : (composerDisabledReason ?? this.composerDisabledReason),
    );
  }
}

class AiHeaderViewModel extends Notifier<AiHeaderState> {
  @override
  AiHeaderState build() {
    final now = DateTime.now();
    final settings = ref.watch(appAiSettingsProvider);
    return AiHeaderState(
      period: AiHeaderPeriod.day,
      anchor: DateTime(now.year, now.month, now.day),
      composerEnabled: settings.isConfigured,
      composerDisabledReason: settings.isConfigured ? null : '请先在设置中完成 AI 配置。',
    );
  }

  void select(AiHeaderPeriod period) {
    state = state.copyWith(period: period);
  }

  void updateInput(String value) {
    state = state.copyWith(input: value, clearError: true);
  }

  void selectAnchor(DateTime date) {
    state = state.copyWith(anchor: DateTime(date.year, date.month, date.day));
  }

  void refreshComposerAvailability() {
    final settings = ref.read(appAiSettingsProvider);
    if (settings.isConfigured && !state.composerEnabled) {
      state = state.copyWith(
        composerEnabled: true,
        clearComposerDisabledReason: true,
      );
      return;
    }
    if (!settings.isConfigured &&
        (state.composerEnabled || state.composerDisabledReason != '请先在设置中完成 AI 配置。')) {
      state = state.copyWith(
        composerEnabled: false,
        composerDisabledReason: '请先在设置中完成 AI 配置。',
      );
    }
  }

  void retryEnableComposer() {
    final settings = ref.read(appAiSettingsProvider);
    state = state.copyWith(
      composerEnabled: settings.isConfigured,
      composerDisabledReason: settings.isConfigured ? null : '请先在设置中完成 AI 配置。',
      clearError: true,
      phase: state.pendingDraft == null ? AiWorkflowPhase.idle : AiWorkflowPhase.awaitingConfirm,
    );
  }

  Future<void> sendMessage() async {
    refreshComposerAvailability();
    if (!state.composerEnabled) {
      return;
    }

    final content = state.input.trim();
    if (content.isEmpty) {
      return;
    }

    final repository = ref.read(aiChatRepositoryNotifierProvider);
    final service = ref.read(aiServiceProvider);
    final now = DateTime.now();
    await repository.append(
      AiChatMessage(
        id: 'user_${now.microsecondsSinceEpoch}',
        content: content,
        createdAt: now,
        role: AiChatRole.user,
      ),
    );

    state = state.copyWith(
      phase: AiWorkflowPhase.parsing,
      clearError: true,
      clearPendingDraft: true,
    );

    try {
      final items = ref.read(agendaItemRepositoryProvider);
      final resolved = await service.resolveMessage(
        message: content,
        items: items,
      );

      switch (resolved.intent) {
        case AiResolvedIntentType.createItem:
          await _onCreateItemResolved(resolved);
        case AiResolvedIntentType.answer:
          await _appendAssistantMessage(
            content: resolved.reply,
            kind: AiMessageKind.answer,
            citations: resolved.citations,
          );
          state = state.copyWith(
            input: '',
            phase: AiWorkflowPhase.idle,
            clearError: true,
          );
        case AiResolvedIntentType.fallback:
          await _appendAssistantMessage(
            content: resolved.reply,
            kind: AiMessageKind.chat,
          );
          state = state.copyWith(
            input: '',
            phase: AiWorkflowPhase.idle,
            clearError: true,
          );
      }
    } on OpenAiConfigurationException catch (error) {
      state = state.copyWith(
        phase: AiWorkflowPhase.failed,
        composerEnabled: false,
        composerDisabledReason: error.message,
        lastError: error.message,
      );
    } on AiServiceException catch (error) {
      final shouldDisableComposer = error.code == AiServiceErrorCode.network ||
          error.code == AiServiceErrorCode.configuration;
      state = state.copyWith(
        phase: AiWorkflowPhase.failed,
        composerEnabled: !shouldDisableComposer,
        composerDisabledReason: shouldDisableComposer ? 'AI 服务暂不可用，请先修复配置或网络。' : null,
        clearComposerDisabledReason: !shouldDisableComposer,
        lastError: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        phase: AiWorkflowPhase.failed,
        composerEnabled: false,
        composerDisabledReason: 'AI 服务暂不可用，请先修复配置或网络。',
        lastError: 'AI 服务暂不可用，请稍后重试。',
      );
    }
  }

  Future<void> confirmCreateDraft() async {
    requestOpenDraftEditor();
  }

  void discardCreateDraft() {
    state = state.copyWith(
      clearPendingDraft: true,
      clearPendingDraftNavigation: true,
      phase: AiWorkflowPhase.idle,
    );
  }

  void requestOpenDraftEditor() {
    if (state.pendingDraft == null) {
      return;
    }
    state = state.copyWith(
      pendingDraftNavigationId: DateTime.now().microsecondsSinceEpoch,
      phase: AiWorkflowPhase.awaitingConfirm,
    );
  }

  void consumeDraftNavigationRequest() {
    if (state.pendingDraftNavigationId == null) {
      return;
    }
    state = state.copyWith(
      clearPendingDraftNavigation: true,
      phase: AiWorkflowPhase.idle,
    );
  }

  Future<void> onDraftEditorClosed({
    required bool created,
  }) async {
    final draft = state.pendingDraft;
    if (created && draft != null) {
      await _appendAssistantMessage(
        content: '已通过草稿页创建事项：${draft.draft.title}',
        kind: AiMessageKind.system,
      );
      state = state.copyWith(
        clearPendingDraft: true,
        clearPendingDraftNavigation: true,
        phase: AiWorkflowPhase.idle,
        clearError: true,
      );
      return;
    }
    state = state.copyWith(
      clearPendingDraftNavigation: true,
      phase: AiWorkflowPhase.idle,
    );
  }

  Future<void> _onCreateItemResolved(AiResolvedMessage resolved) async {
    final draft = resolved.createItemDraft;
    await _appendAssistantMessage(
      content: resolved.reply,
      kind: AiMessageKind.system,
    );

    if (draft == null) {
      state = state.copyWith(
        input: '',
        phase: AiWorkflowPhase.idle,
      );
      return;
    }

    if (draft.missingRequired.isNotEmpty) {
      state = state.copyWith(
        phase: AiWorkflowPhase.idle,
        clearPendingDraft: true,
        clearPendingDraftNavigation: true,
      );
      return;
    }

    state = state.copyWith(
      input: '',
      phase: AiWorkflowPhase.awaitingConfirm,
      pendingDraft: draft,
      pendingDraftNavigationId: DateTime.now().microsecondsSinceEpoch,
    );
  }

  Future<void> _appendAssistantMessage({
    required String content,
    required AiMessageKind kind,
    List<AiCitation> citations = const <AiCitation>[],
  }) {
    final repository = ref.read(aiChatRepositoryNotifierProvider);
    final text = content.trim();
    if (text.isEmpty) {
      return Future<void>.value();
    }
    return repository.append(
      AiChatMessage(
        id: 'assistant_${DateTime.now().microsecondsSinceEpoch}',
        content: text,
        createdAt: DateTime.now(),
        role: AiChatRole.assistant,
        kind: kind,
        citations: citations,
      ),
    );
  }

  DateTimeRangeValue visibleRange() {
    final anchor = DateTime(state.anchor.year, state.anchor.month, state.anchor.day);
    return switch (state.period) {
      AiHeaderPeriod.day => DateTimeRangeValue(
          start: anchor,
          end: anchor.add(const Duration(days: 1)),
        ),
      AiHeaderPeriod.week => DateTimeRangeValue(
          start: anchor.subtract(Duration(days: anchor.weekday - DateTime.monday)),
          end: anchor
              .subtract(Duration(days: anchor.weekday - DateTime.monday))
              .add(const Duration(days: 7)),
        ),
      AiHeaderPeriod.month => DateTimeRangeValue(
          start: DateTime(anchor.year, anchor.month, 1),
          end: DateTime(anchor.year, anchor.month + 1, 1),
        ),
    };
  }
}

final aiHeaderViewModelProvider =
    NotifierProvider<AiHeaderViewModel, AiHeaderState>(
  AiHeaderViewModel.new,
);

final aiConversationGroupsProvider = Provider<List<AiConversationGroup>>((ref) {
  final range = ref.read(aiHeaderViewModelProvider.notifier).visibleRange();
  final messages = ref.watch(aiChatRepositoryProvider).where((message) {
    return !message.createdAt.isBefore(range.start) && message.createdAt.isBefore(range.end);
  }).toList()
    ..sort((left, right) => left.createdAt.compareTo(right.createdAt));

  final groups = <DateTime, List<AiChatMessage>>{};
  for (final message in messages) {
    final day = DateTime(
      message.createdAt.year,
      message.createdAt.month,
      message.createdAt.day,
    );
    groups.putIfAbsent(day, () => <AiChatMessage>[]).add(message);
  }

  return groups.entries.map((entry) {
    final day = entry.key;
    return AiConversationGroup(
      label: '${day.year}/${day.month}/${day.day}',
      range: DateTimeRangeValue(
        start: day,
        end: day.add(const Duration(days: 1)),
      ),
      messages: entry.value,
    );
  }).toList()
    ..sort((left, right) => left.range.start.compareTo(right.range.start));
});
