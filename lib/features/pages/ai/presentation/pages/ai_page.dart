import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_action_models.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_runtime_providers.dart';
import 'package:luotopia/features/pages/ai/presentation/viewmodels/ai_header_view_model.dart';
import 'package:luotopia/features/pages/ai/presentation/widgets/ai_item_visualizer.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_args.dart';
import 'package:luotopia/features/pages/item_editor/domain/models/item_editor_prefill.dart';
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class AiPage extends ConsumerStatefulWidget {
  const AiPage({this.autoFocusInput = false, super.key});

  final bool autoFocusInput;

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  late final TextEditingController _controller;
  late final FocusNode _inputFocusNode;
  bool _focusRequested = false;
  bool _isDraftRouteOpening = false;
  int? _lastHandledDraftNavigationId;
  int _lastActivationCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _inputFocusNode = FocusNode();
    _lastActivationCount = ref.read(aiPageActivationProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(aiHeaderViewModelProvider.notifier).createSession();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activationCount = ref.watch(aiPageActivationProvider);
    if (activationCount > _lastActivationCount) {
      _lastActivationCount = activationCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(aiHeaderViewModelProvider.notifier).createSession();
        }
      });
    }

    final state = ref.watch(aiHeaderViewModelProvider);
    final session = ref.watch(aiActiveSessionProvider);
    _syncController(state.input);
    _tryAutoFocus();
    _setupDraftNavigationListener();

    return ui.Scaffold(
      headers: [
        buildTabAppBar(
          title: context.l10n.aiTitle,
          trailing: [
            ui.Tooltip(
              tooltip: (context) =>
                  Text(_text(context, zh: '对话列表', en: 'Conversations')),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.openTimePicker),
                onPressed: () => context.push(AppRoutePaths.aiSessions),
              ),
            ),
            ui.Tooltip(
              tooltip: (context) =>
                  Text(_text(context, zh: '新对话', en: 'New chat')),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.add),
                onPressed: ref
                    .read(aiHeaderViewModelProvider.notifier)
                    .createSession,
              ),
            ),
          ],
        ),
      ],
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!state.composerEnabled || state.lastError != null)
              _ErrorBanner(
                message:
                    state.composerDisabledReason ??
                    state.lastError ??
                    _text(context, zh: 'AI 服务异常', en: 'AI service error'),
                onOpenSettings: () => context.go(AppRoutePaths.settingsAi),
                onRetry: ref
                    .read(aiHeaderViewModelProvider.notifier)
                    .retryEnableComposer,
              ),
            Expanded(
              child: _ConversationTimeline(
                session: session,
                pendingDraft: state.pendingDraft,
                streamingContent: state.streamingContent,
                onOpenDraft: ref
                    .read(aiHeaderViewModelProvider.notifier)
                    .requestOpenDraftEditor,
              ),
            ),
            _ComposerBar(
              controller: _controller,
              focusNode: _inputFocusNode,
              canSend: state.canSend,
              isBusy: state.isBusy,
              onChanged: ref
                  .read(aiHeaderViewModelProvider.notifier)
                  .updateInput,
              onSend: ref.read(aiHeaderViewModelProvider.notifier).sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _setupDraftNavigationListener() {
    ref.listen<AiHeaderState>(aiHeaderViewModelProvider, (previous, next) {
      final navId = next.pendingDraftNavigationId;
      if (navId == null ||
          _isDraftRouteOpening ||
          _lastHandledDraftNavigationId == navId ||
          next.pendingDraft == null) {
        return;
      }
      _lastHandledDraftNavigationId = navId;
      _openDraftEditor(next.pendingDraft!);
    });
  }

  Future<void> _openDraftEditor(AiCreateItemDraft draft) async {
    if (!mounted) {
      return;
    }
    _isDraftRouteOpening = true;
    final notifier = ref.read(aiHeaderViewModelProvider.notifier);
    notifier.consumeDraftNavigationRequest();
    final result = await context.openItemEditorFlow<bool>(
      extra: ItemEditorArgs(prefill: _draftToPrefill(draft)),
    );
    if (!mounted) {
      return;
    }
    await notifier.onDraftEditorClosed(created: result == true);
    _isDraftRouteOpening = false;
  }

  ItemEditorPrefill _draftToPrefill(AiCreateItemDraft draft) {
    final itemDraft = draft.draft;
    return ItemEditorPrefill(
      type: itemDraft.type,
      title: itemDraft.title,
      details: itemDraft.details,
      location: itemDraft.location,
      color: itemDraft.color,
      isAllDay: itemDraft.isAllDay,
      reminder: itemDraft.reminder,
      repeatRule: itemDraft.repeatRule,
      startAt: itemDraft.startAt,
      endAt: itemDraft.endAt,
      deadline: itemDraft.deadline,
      targetDate: itemDraft.targetDate,
      estimatedDuration: itemDraft.estimatedDuration,
    );
  }

  @override
  void didUpdateWidget(covariant AiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autoFocusInput && widget.autoFocusInput) {
      _focusRequested = false;
      _tryAutoFocus();
    }
  }

  void _tryAutoFocus() {
    if (!widget.autoFocusInput || _focusRequested) {
      return;
    }
    _focusRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _inputFocusNode.requestFocus();
    });
  }

  void _syncController(String value) {
    if (_controller.text == value) {
      return;
    }
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  static String _text(
    BuildContext context, {
    required String zh,
    required String en,
  }) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }
}

class _ConversationTimeline extends StatefulWidget {
  const _ConversationTimeline({
    required this.session,
    required this.pendingDraft,
    required this.onOpenDraft,
    this.streamingContent,
  });

  final AiChatSession? session;
  final AiCreateItemDraft? pendingDraft;
  final VoidCallback onOpenDraft;
  final String? streamingContent;

  @override
  State<_ConversationTimeline> createState() => _ConversationTimelineState();
}

class _ConversationTimelineState extends State<_ConversationTimeline> {
  final _scrollController = ScrollController();
  var _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ConversationTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streamingContent != null &&
        widget.streamingContent != oldWidget.streamingContent &&
        _autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.session?.messages ?? const <AiChatMessage>[];
    final hasHistory = messages.isNotEmpty;
    final hasStreaming = widget.streamingContent != null;
    if (!hasHistory && widget.pendingDraft == null && !hasStreaming) {
      return const SizedBox.expand();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is UserScrollNotification) {
          final isAtBottom =
              _scrollController.hasClients &&
              _scrollController.position.pixels >=
                  _scrollController.position.maxScrollExtent - 20;
          _autoScroll = isAtBottom;
        }
        return false;
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        children: [
          for (final message in messages) _MessageLine(message: message),
          if (hasStreaming)
            _StreamingMessage(content: widget.streamingContent!),
          if (widget.pendingDraft != null)
            _DraftEntryLine(
              pendingDraft: widget.pendingDraft!,
              onOpenDraft: widget.onOpenDraft,
            ),
        ],
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }
}

class _StreamingMessage extends StatelessWidget {
  const _StreamingMessage({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MarkdownContent(message: content),
              const SizedBox(height: 4),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageLine extends StatefulWidget {
  const _MessageLine({required this.message});

  final AiChatMessage message;

  @override
  State<_MessageLine> createState() => _MessageLineState();
}

class _MessageLineState extends State<_MessageLine> {
  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == AiChatRole.user;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (isUser)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    widget.message.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              else
                _MarkdownContent(message: widget.message.content),
              if (widget.message.citations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: AiItemVisualizer(citations: widget.message.citations),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkdownContent extends StatelessWidget {
  const _MarkdownContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MarkdownBody(
      data: message,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        h1: theme.textTheme.headlineSmall,
        h2: theme.textTheme.titleLarge,
        h3: theme.textTheme.titleMedium,
        code: theme.textTheme.bodyMedium?.copyWith(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        listBullet: theme.textTheme.bodyLarge,
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}

class _DraftEntryLine extends StatelessWidget {
  const _DraftEntryLine({
    required this.pendingDraft,
    required this.onOpenDraft,
  });

  final AiCreateItemDraft pendingDraft;
  final VoidCallback onOpenDraft;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final draft = pendingDraft.draft;
    final title = draft.title.trim().isEmpty
        ? _text(context, zh: '未命名事项', en: 'Untitled item')
        : draft.title.trim();
    final timeLabel = draft.type.name == 'memo'
        ? DateFormat.yMd(locale).format(draft.targetDate)
        : '${DateFormat.yMd(locale).format(draft.startAt)} ${DateFormat.Hm(locale).format(draft.startAt)}';

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _text(context, zh: '草稿已生成：$title', en: 'Draft ready: $title'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              timeLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            ui.GhostButton(
              onPressed: onOpenDraft,
              child: Text(_text(context, zh: '打开草稿二级页', en: 'Open Draft Page')),
            ),
          ],
        ),
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.isBusy,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final bool isBusy;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ui.TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              minLines: 1,
              maxLines: 5,
              hintText: context.l10n.aiInputHint,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (canSend) {
                  onSend();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          ui.Tooltip(
            tooltip: (context) => Text(
              isBusy
                  ? _text(context, zh: '发送中', en: 'Sending')
                  : _text(context, zh: '发送', en: 'Send'),
            ),
            child: ui.IconButton.primary(
              icon: Icon(isBusy ? Icons.hourglass_empty : Icons.send_outlined),
              onPressed: canSend ? onSend : null,
            ),
          ),
        ],
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }
}

class AiSessionsPage extends ConsumerStatefulWidget {
  const AiSessionsPage({super.key});

  @override
  ConsumerState<AiSessionsPage> createState() => _AiSessionsPageState();
}

class _AiSessionsPageState extends ConsumerState<AiSessionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(aiHeaderViewModelProvider.notifier).removeEmptySessions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(aiSessionsProvider);
    final activeSessionId = ref.watch(aiActiveSessionProvider)?.id;

    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(
          context,
          title: _text(context, zh: '对话列表', en: 'Conversations'),
          trailing: [
            ui.Tooltip(
              tooltip: (context) =>
                  Text(_text(context, zh: '清空历史', en: 'Clear history')),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.delete),
                onPressed: sessions.isEmpty
                    ? null
                    : () async {
                        final confirmed = await _confirmClearSessions(context);
                        if (!confirmed) {
                          return;
                        }
                        await ref
                            .read(aiHeaderViewModelProvider.notifier)
                            .clearSessions();
                        await ref
                            .read(aiHeaderViewModelProvider.notifier)
                            .removeEmptySessions();
                      },
              ),
            ),
            ui.Tooltip(
              tooltip: (context) =>
                  Text(_text(context, zh: '新对话', en: 'New chat')),
              child: ui.IconButton.ghost(
                icon: const Icon(AppIcons.add),
                onPressed: () async {
                  await ref
                      .read(aiHeaderViewModelProvider.notifier)
                      .createSession();
                  if (context.mounted) {
                    context.pop();
                  }
                },
              ),
            ),
          ],
        ),
      ],
      child: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          itemCount: sessions.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final session = sessions[index];
            final selected = session.id == activeSessionId;
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              leading: Icon(
                selected ? AppIcons.selected : AppIcons.aiOutlined,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(
                _sessionTitle(context, session),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _sessionSubtitle(context, session),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ui.Tooltip(
                    tooltip: (context) =>
                        Text(_text(context, zh: '重命名', en: 'Rename')),
                    child: ui.IconButton.ghost(
                      icon: const Icon(AppIcons.edit, size: 18),
                      onPressed: () async {
                        final title = await _promptRenameSession(
                          context,
                          session,
                        );
                        if (title == null) {
                          return;
                        }
                        await ref
                            .read(aiHeaderViewModelProvider.notifier)
                            .renameSession(session.id, title);
                      },
                    ),
                  ),
                  ui.Tooltip(
                    tooltip: (context) =>
                        Text(_text(context, zh: '删除', en: 'Delete')),
                    child: ui.IconButton.ghost(
                      icon: const Icon(AppIcons.delete, size: 18),
                      onPressed: () async {
                        await ref
                            .read(aiHeaderViewModelProvider.notifier)
                            .deleteSession(session.id);
                      },
                    ),
                  ),
                ],
              ),
              onTap: () async {
                await ref
                    .read(aiHeaderViewModelProvider.notifier)
                    .selectSession(session.id);
                if (context.mounted) {
                  context.pop();
                }
              },
            );
          },
        ),
      ),
    );
  }

  String _sessionTitle(BuildContext context, AiChatSession session) {
    final customTitle = session.title?.trim();
    if (customTitle != null && customTitle.isNotEmpty) {
      return customTitle;
    }
    for (final message in session.messages) {
      if (message.role == AiChatRole.user &&
          message.content.trim().isNotEmpty) {
        final content = message.content.trim();
        return content.length > 28 ? '${content.substring(0, 28)}...' : content;
      }
    }
    return _text(context, zh: '新对话', en: 'New chat');
  }

  String _sessionSubtitle(BuildContext context, AiChatSession session) {
    final count = session.messages.length;
    if (count == 0) {
      return _text(context, zh: '没有消息', en: 'No messages');
    }
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? '$count 条消息'
        : '$count messages';
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }

  Future<String?> _promptRenameSession(
    BuildContext context,
    AiChatSession session,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _RenameSessionDialog(
        initialTitle: session.title ?? _sessionTitle(context, session),
      ),
    );
    final trimmed = result?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  Future<bool> _confirmClearSessions(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_text(context, zh: '清空对话历史', en: 'Clear conversations')),
          content: Text(
            _text(
              context,
              zh: '所有本地 AI 对话记录将被清空。',
              en: 'All local AI conversations will be cleared.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(_text(context, zh: '取消', en: 'Cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_text(context, zh: '清空', en: 'Clear')),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

class _RenameSessionDialog extends StatefulWidget {
  const _RenameSessionDialog({required this.initialTitle});

  final String initialTitle;

  @override
  State<_RenameSessionDialog> createState() => _RenameSessionDialogState();
}

class _RenameSessionDialogState extends State<_RenameSessionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_text(context, zh: '重命名对话', en: 'Rename conversation')),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 48,
        decoration: InputDecoration(
          labelText: _text(context, zh: '标题', en: 'Title'),
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_text(context, zh: '取消', en: 'Cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(_text(context, zh: '保存', en: 'Save')),
        ),
      ],
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: Theme.of(
        context,
      ).colorScheme.errorContainer.withValues(alpha: 0.55),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          ui.GhostButton(
            onPressed: onOpenSettings,
            child: Text(_text(context, zh: 'AI 设置', en: 'AI Settings')),
          ),
          ui.GhostButton(
            onPressed: onRetry,
            child: Text(_text(context, zh: '重试', en: 'Retry')),
          ),
        ],
      ),
    );
  }

  String _text(BuildContext context, {required String zh, required String en}) {
    return Localizations.localeOf(context).languageCode.startsWith('zh')
        ? zh
        : en;
  }
}
