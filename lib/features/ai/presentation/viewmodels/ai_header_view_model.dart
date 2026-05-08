import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_runtime_initializer.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_action_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_stream_event.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';

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
    this.input = '',
    this.phase = AiWorkflowPhase.idle,
    this.pendingDraft,
    this.pendingDraftNavigationId,
    this.lastError,
    this.composerEnabled = true,
    this.composerDisabledReason,
    this.streamingContent,
  });

  final String input;
  final AiWorkflowPhase phase;
  final AiCreateItemDraft? pendingDraft;
  final int? pendingDraftNavigationId;
  final String? lastError;
  final bool composerEnabled;
  final String? composerDisabledReason;
  final String? streamingContent;

  bool get isBusy {
    return phase == AiWorkflowPhase.parsing ||
        phase == AiWorkflowPhase.creating ||
        phase == AiWorkflowPhase.answering;
  }

  bool get canSend => composerEnabled && !isBusy && input.trim().isNotEmpty;

  AiHeaderState copyWith({
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
    String? streamingContent,
    bool clearStreamingContent = false,
  }) {
    return AiHeaderState(
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
      streamingContent: clearStreamingContent ? null : (streamingContent ?? this.streamingContent),
    );
  }
}

class AiHeaderViewModel extends Notifier<AiHeaderState> {
  @override
  AiHeaderState build() {
    final settings = ref.watch(appAiSettingsProvider);
    return AiHeaderState(
      composerEnabled: settings.isConfigured,
      composerDisabledReason: settings.isConfigured ? null : '请先在设置中完成 AI 配置。',
    );
  }

  void updateInput(String value) {
    state = state.copyWith(input: value, clearError: true);
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

  Future<void> createSession() async {
    await ref.read(aiChatRepositoryNotifierProvider).createSession();
    state = state.copyWith(
      input: '',
      phase: AiWorkflowPhase.idle,
      clearPendingDraft: true,
      clearPendingDraftNavigation: true,
      clearError: true,
    );
  }

  Future<void> selectSession(String sessionId) async {
    await ref.read(aiChatRepositoryNotifierProvider).selectSession(sessionId);
    state = state.copyWith(
      input: '',
      phase: AiWorkflowPhase.idle,
      clearPendingDraft: true,
      clearPendingDraftNavigation: true,
      clearError: true,
    );
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
    final sessionId = repository.getActiveSession()?.id ??
        (await repository.createSession()).id;

    // 添加用户消息
    await repository.appendToActiveSession(
      AiChatMessage(
        id: 'user_${now.microsecondsSinceEpoch}',
        sessionId: sessionId,
        content: content,
        createdAt: now,
        role: AiChatRole.user,
      ),
    );

    state = state.copyWith(
      input: '',
      phase: AiWorkflowPhase.parsing,
      clearError: true,
      clearPendingDraft: true,
      streamingContent: '',
    );

    try {
      final items = ref.read(agendaItemRepositoryProvider);
      final stream = service.streamMessage(
        message: content,
        items: items,
      );

      String fullContent = '';
      await for (final event in stream) {
        switch (event) {
          case AiStreamDelta(:final text):
            fullContent += text;
            state = state.copyWith(streamingContent: fullContent);
          case AiStreamCompleted(:final result):
            fullContent = event.fullText;
            await _onStreamCompleted(result, sessionId);
          default:
            break;
        }
      }
    } on OpenAiConfigurationException catch (error) {
      state = state.copyWith(
        phase: AiWorkflowPhase.failed,
        streamingContent: null,
        clearStreamingContent: true,
        composerEnabled: false,
        composerDisabledReason: error.message,
        lastError: error.message,
      );
    } on AiServiceException catch (error) {
      final shouldDisableComposer = error.code == AiServiceErrorCode.network ||
          error.code == AiServiceErrorCode.configuration;
      state = state.copyWith(
        phase: AiWorkflowPhase.failed,
        clearStreamingContent: true,
        composerEnabled: !shouldDisableComposer,
        composerDisabledReason: shouldDisableComposer ? 'AI 服务暂不可用，请先修复配置或网络。' : null,
        clearComposerDisabledReason: !shouldDisableComposer,
        lastError: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        phase: AiWorkflowPhase.failed,
        clearStreamingContent: true,
        composerEnabled: false,
        composerDisabledReason: 'AI 服务暂不可用，请先修复配置或网络。',
        lastError: 'AI 服务暂不可用，请稍后重试。',
      );
    }
  }

  Future<void> _onStreamCompleted(
    AiResolvedMessage resolved,
    String sessionId,
  ) async {
    switch (resolved.intent) {
      case AiResolvedIntentType.createItem:
        await _onStreamCreateItemResolved(resolved);
      case AiResolvedIntentType.answer:
        await _appendAssistantMessage(
          content: resolved.reply,
          kind: AiMessageKind.answer,
          sessionId: sessionId,
          citations: resolved.citations,
        );
        state = state.copyWith(
          phase: AiWorkflowPhase.idle,
          clearError: true,
          clearStreamingContent: true,
        );
      case AiResolvedIntentType.fallback:
        await _appendAssistantMessage(
          content: resolved.reply,
          kind: AiMessageKind.chat,
          sessionId: sessionId,
        );
        state = state.copyWith(
          phase: AiWorkflowPhase.idle,
          clearError: true,
          clearStreamingContent: true,
        );
    }
  }

  Future<void> _onStreamCreateItemResolved(AiResolvedMessage resolved) async {
    final draft = resolved.createItemDraft;
    final repository = ref.read(aiChatRepositoryNotifierProvider);
    final sessionId = repository.getActiveSession()?.id;

    if (sessionId != null) {
      await _appendAssistantMessage(
        content: resolved.reply,
        kind: AiMessageKind.system,
        sessionId: sessionId,
      );
    }

    if (draft == null || draft.missingRequired.isNotEmpty) {
      state = state.copyWith(
        phase: AiWorkflowPhase.idle,
        clearStreamingContent: true,
        clearPendingDraft: true,
        clearPendingDraftNavigation: true,
      );
      return;
    }

    state = state.copyWith(
      phase: AiWorkflowPhase.awaitingConfirm,
      clearStreamingContent: true,
      pendingDraft: draft,
      pendingDraftNavigationId: DateTime.now().microsecondsSinceEpoch,
    );
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

  Future<void> _appendAssistantMessage({
    required String content,
    required AiMessageKind kind,
    String? sessionId,
    List<AiCitation> citations = const <AiCitation>[],
  }) {
    final repository = ref.read(aiChatRepositoryNotifierProvider);
    final text = content.trim();
    if (text.isEmpty) {
      return Future<void>.value();
    }
    final sid = sessionId ?? repository.getActiveSession()?.id;
    if (sid == null) {
      return Future<void>.value();
    }
    return repository.appendToActiveSession(
      AiChatMessage(
        id: 'assistant_${DateTime.now().microsecondsSinceEpoch}',
        sessionId: sid,
        content: text,
        createdAt: DateTime.now(),
        role: AiChatRole.assistant,
        kind: kind,
        citations: citations,
      ),
    );
  }
}

final aiHeaderViewModelProvider =
    NotifierProvider<AiHeaderViewModel, AiHeaderState>(
  AiHeaderViewModel.new,
);

final aiActiveSessionProvider = Provider<AiChatSession?>((ref) {
  if (!ref.watch(appBootstrapPhaseProvider).hasFullData) {
    return null;
  }
  return ref.watch(aiChatRepositoryProvider).activeSession;
});

final aiSessionsProvider = Provider<List<AiChatSession>>((ref) {
  if (!ref.watch(appBootstrapPhaseProvider).hasFullData) {
    return const [];
  }
  return ref.watch(aiChatRepositoryProvider).sessions;
});
