import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/app_bootstrap.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_action_models.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_conversation_models.dart';
import 'package:luotopia/features/pages/ai/domain/models/ai_stream_event.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_chat_repository.dart';
import 'package:luotopia/features/pages/ai/domain/repositories/ai_service.dart';
import 'package:luotopia/features/pages/settings/domain/models/ai_settings.dart';
import 'package:luotopia/features/pages/settings/domain/providers/settings_state_providers.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/item_memo_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final aiChatBootstrapSessionStoreProvider = Provider<AiChatSessionStore>((ref) {
  final now = DateTime.now();
  return AiChatSessionStore(
    sessions: [
      AiChatSession(
        id: 'session_initial',
        createdAt: now,
        updatedAt: now,
        messages: const [],
      ),
    ],
    activeSessionId: 'session_initial',
  );
});

class InMemoryAiChatRepository extends Notifier<AiChatSessionStore>
    implements AiChatRepository {
  @override
  AiChatSessionStore build() {
    return ref.read(aiChatBootstrapSessionStoreProvider);
  }

  @override
  List<AiChatSession> getSessions() => state.sessions;

  @override
  AiChatSession? getActiveSession() => state.activeSession;

  @override
  Future<AiChatSession> createSession() async {
    final now = DateTime.now();
    final session = AiChatSession(
      id: 'session_${now.microsecondsSinceEpoch}',
      createdAt: now,
      updatedAt: now,
      messages: const [],
    );
    state = AiChatSessionStore(
      sessions: [session, ...state.sessions],
      activeSessionId: session.id,
    );
    await _persist();
    return session;
  }

  @override
  Future<void> selectSession(String sessionId) async {
    if (!state.sessions.any((session) => session.id == sessionId)) {
      return;
    }
    state = state.copyWith(activeSessionId: sessionId);
    await _persistActiveSessionId();
  }

  @override
  Future<void> appendToActiveSession(AiChatMessage message) async {
    final active = state.activeSession ?? await createSession();
    final updatedMessage = message.sessionId == active.id
        ? message
        : AiChatMessage(
            id: message.id,
            sessionId: active.id,
            content: message.content,
            createdAt: message.createdAt,
            role: message.role,
            kind: message.kind,
            citations: message.citations,
          );
    final updatedSession = active.copyWith(
      updatedAt: updatedMessage.createdAt,
      messages: [...active.messages, updatedMessage],
    );
    final sessions = [
      updatedSession,
      for (final session in state.sessions)
        if (session.id != active.id) session,
    ]..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    state = AiChatSessionStore(
      sessions: sessions,
      activeSessionId: active.id,
    );
    await _persist();
  }

  Future<void> _persist() async {
    await _prefs?.setString(
      AppBootstrapStorageKeys.aiSessions,
      jsonEncode([
        for (final session in state.sessions) _sessionToJson(session),
      ]),
    );
    await _persistActiveSessionId();
  }

  Future<void> _persistActiveSessionId() async {
    await _prefs?.setString(
      AppBootstrapStorageKeys.activeAiSessionId,
      state.activeSessionId,
    );
  }

  Map<String, dynamic> _sessionToJson(AiChatSession session) {
    return {
      'id': session.id,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
      'messages': [
        for (final message in session.messages) _messageToJson(message),
      ],
    };
  }

  Map<String, dynamic> _messageToJson(AiChatMessage item) {
    return {
      'id': item.id,
      'sessionId': item.sessionId,
      'content': item.content,
      'createdAt': item.createdAt.toIso8601String(),
      'role': item.role.name,
      'kind': item.kind.name,
      'citations': [
        for (final citation in item.citations)
          {
            'itemId': citation.itemId,
            'title': citation.title,
            'type': citation.type.name,
            'startAt': citation.startAt?.toIso8601String(),
            'endAt': citation.endAt?.toIso8601String(),
            'reason': citation.reason,
          },
      ],
    };
  }

  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider);
}

class OpenAiConfigurationException extends AiServiceException {
  const OpenAiConfigurationException(String message)
      : super(code: AiServiceErrorCode.configuration, message: message);
}

class OpenAiCompatibleAiService implements AiService {
  const OpenAiCompatibleAiService(this._ref);

  final Ref _ref;

  @override
  Future<AiResolvedMessage> resolveMessage({
    required String message,
    required List<AgendaItem> items,
  }) async {
    final settings = _ref.read(appAiSettingsProvider);
    final now = DateTime.now();

    try {
      final response = await _postChatCompletion(
        settings: settings,
        messages: [
          {
            'role': 'system',
            'content': _buildResolverPrompt(
              basePrompt: settings.systemPrompt,
              now: now,
              items: items,
            ),
          },
          {
            'role': 'user',
            'content': message,
          },
        ],
      );

      final content = _extractContentFromResponse(response);
      final reply = _extractReplyFromStream(content);
      final payload = _extractJsonFromStreamData(content);

      // 如果没有 <data> 标签，兼容旧格式（纯 JSON 对象）
      if (payload == null) {
        final legacyPayload = _tryExtractLegacyJson(content);
        if (legacyPayload != null) {
          return _buildResolvedMessage(
            payload: legacyPayload,
            reply: (legacyPayload['assistant_reply'] as String? ?? '').trim(),
            now: now,
            items: items,
          );
        }
      }

      final effectiveReply = reply.isEmpty
          ? (payload?['assistant_reply'] as String? ?? '').trim()
          : reply;

      return _buildResolvedMessage(
        payload: payload ?? <String, dynamic>{},
        reply: effectiveReply,
        now: now,
        items: items,
      );
    } on AiServiceException {
      rethrow;
    } on FormatException catch (error) {
      throw AiServiceException(
        code: AiServiceErrorCode.parse,
        message: 'AI 返回内容解析失败：${error.message}',
      );
    } catch (_) {
      throw const AiServiceException(
        code: AiServiceErrorCode.network,
        message: 'AI 服务暂不可用，请稍后再试。',
      );
    }
  }

  @override
  Stream<AiStreamEvent> streamMessage({
    required String message,
    required List<AgendaItem> items,
  }) async* {
    final settings = _ref.read(appAiSettingsProvider);
    final now = DateTime.now();
    _ensureConfigured(settings);

    yield const AiStreamStarted();

    final uri = _buildChatCompletionsUri(settings.baseUrl.trim());
    final client = http.Client();

    try {
      final request = http.Request('POST', uri);
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${settings.apiKey.trim()}',
      });
      request.body = jsonEncode({
        'model': settings.model.trim(),
        'stream': true,
        'messages': [
          {
            'role': 'system',
            'content': _buildResolverPrompt(
              basePrompt: settings.systemPrompt,
              now: now,
              items: items,
            ),
          },
          {
            'role': 'user',
            'content': message,
          },
        ],
      });

      final response = await client.send(request).timeout(const Duration(seconds: 120));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorBody = await response.stream.bytesToString();
        Map<String, dynamic> errorJson;
        try {
          errorJson = jsonDecode(errorBody) as Map<String, dynamic>;
        } catch (_) {
          errorJson = <String, dynamic>{};
        }
        final errorMessage = (errorJson['error'] is Map<String, dynamic>)
            ? (((errorJson['error'] as Map<String, dynamic>)['message'] as String?) ??
                '请求失败')
            : ((errorJson['message'] as String?) ?? '请求失败');
        throw AiServiceException(
          code: AiServiceErrorCode.network,
          message: 'AI 请求失败（${response.statusCode}）：$errorMessage',
        );
      }

      final fullContent = StringBuffer();
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final line in lines) {
        if (!line.startsWith('data: ')) {
          continue;
        }
        final data = line.substring(6).trim();
        if (data == '[DONE]') {
          continue;
        }

        try {
          final chunk = jsonDecode(data) as Map<String, dynamic>;
          final choices = chunk['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) {
            continue;
          }
          final delta = choices[0] as Map<String, dynamic>?;
          if (delta == null) {
            continue;
          }
          final deltaContent = (delta['delta'] as Map<String, dynamic>?)?['content'] as String?;
          if (deltaContent == null || deltaContent.isEmpty) {
            continue;
          }
          fullContent.write(deltaContent);
          yield AiStreamDelta(deltaContent);
        } on FormatException {
          // 跳过解析失败的 chunk
        }
      }

      final full = fullContent.toString();
      if (full.isEmpty) {
        throw const AiServiceException(
          code: AiServiceErrorCode.parse,
          message: 'AI 返回内容为空。',
        );
      }

      // 解析 <data> 标签中的 JSON payload
      final reply = _extractReplyFromStream(full);
      final payload = _extractJsonFromStreamData(full);
      final intent = payload != null ? _parseIntent(payload['intent'] as String?) : AiResolvedIntentType.fallback;
      final citations = _parseCitations(
        payload?['citations'] as List<dynamic>?,
        items: items,
      );

      AiCreateItemDraft? draft;
      if (intent == AiResolvedIntentType.createItem) {
        draft = _parseCreateDraft(
          payload?['create_item'] as Map<String, dynamic>?,
          now: now,
          items: items,
        );
      }

      yield AiStreamCompleted(
        full,
        AiResolvedMessage(
          intent: intent,
          reply: reply.isEmpty ? '我已经理解了你的消息。' : reply,
          createItemDraft: draft,
          citations: citations,
        ),
      );
    } on AiServiceException {
      rethrow;
    } on TimeoutException {
      throw const AiServiceException(
        code: AiServiceErrorCode.network,
        message: 'AI 响应超时，请稍后再试。',
      );
    } catch (_) {
      throw const AiServiceException(
        code: AiServiceErrorCode.network,
        message: 'AI 服务暂不可用，请稍后再试。',
      );
    } finally {
      client.close();
    }
  }

  String _extractReplyFromStream(String fullContent) {
    final dataIndex = fullContent.indexOf('<data>');
    if (dataIndex < 0) {
      return fullContent.trim();
    }
    return fullContent.substring(0, dataIndex).trim();
  }

  Map<String, dynamic>? _extractJsonFromStreamData(String fullContent) {
    final dataMatch = RegExp(r'<data>\s*([\s\S]*?)\s*</data>', caseSensitive: false).firstMatch(fullContent);
    if (dataMatch == null) {
      return null;
    }
    final jsonText = dataMatch.group(1)?.trim();
    if (jsonText == null || jsonText.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // fall through
    }
    return null;
  }

  @override
  Future<void> validateConnection({
    required AiSettings settings,
  }) async {
    await _postChatCompletion(
      settings: settings,
      messages: const [
        {
          'role': 'user',
          'content': 'Ping',
        },
      ],
      maxTokens: 1,
    );
  }

  void _ensureConfigured(AiSettings settings) {
    if (!settings.isConfigured) {
      throw const OpenAiConfigurationException('请先填写完整的 AI 地址、密钥和模型。');
    }
  }

  Future<Map<String, dynamic>> _postChatCompletion({
    required AiSettings settings,
    required List<Map<String, Object?>> messages,
    int? maxTokens,
  }) async {
    _ensureConfigured(settings);
    final uri = _buildChatCompletionsUri(settings.baseUrl.trim());
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${settings.apiKey.trim()}',
          },
          body: jsonEncode({
            'model': settings.model.trim(),
            'messages': messages,
            'enable_thinking': false,
            if (maxTokens != null) 'max_tokens': maxTokens,
          }),
        )
        .timeout(const Duration(seconds: 60));

    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const AiServiceException(
        code: AiServiceErrorCode.parse,
        message: 'AI 返回内容解析失败。',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = (body['error'] is Map<String, dynamic>)
          ? (((body['error'] as Map<String, dynamic>)['message'] as String?) ??
              '请求失败')
          : ((body['message'] as String?) ?? '请求失败');
      throw AiServiceException(
        code: AiServiceErrorCode.network,
        message: 'AI 请求失败（${response.statusCode}）：$message',
      );
    }

    return body;
  }

  Uri _buildChatCompletionsUri(String baseUrl) {
    final parsed = Uri.parse(baseUrl);
    final normalizedPath = parsed.path.endsWith('/')
        ? parsed.path.substring(0, parsed.path.length - 1)
        : parsed.path;
    final hasEndpoint = normalizedPath.endsWith('/chat/completions');
    final path = hasEndpoint ? normalizedPath : '$normalizedPath/chat/completions';
    return parsed.replace(path: path);
  }

  String _extractContentFromResponse(Map<String, dynamic> response) {
    final choices = response['choices'];
    if (choices is! List || choices.isEmpty) {
      return '';
    }
    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      return '';
    }
    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      return '';
    }
    final content = message['content'];
    if (content is String) {
      return content;
    }
    if (content is List) {
      return content
          .whereType<Map<String, dynamic>>()
          .map((part) => part['text'] as String? ?? '')
          .join();
    }
    return '';
  }

  AiResolvedMessage _buildResolvedMessage({
    required Map<String, dynamic> payload,
    required String reply,
    required DateTime now,
    required List<AgendaItem> items,
  }) {
    final intent = _parseIntent(payload['intent'] as String?);

    if (intent == AiResolvedIntentType.createItem) {
      final createDraft = _parseCreateDraft(
        payload['create_item'] as Map<String, dynamic>?,
        now: now,
        items: items,
      );
      return AiResolvedMessage(
        intent: intent,
        reply: reply.isEmpty ? '我已经整理好草稿，请确认后创建。' : reply,
        createItemDraft: createDraft,
      );
    }

    if (intent == AiResolvedIntentType.answer) {
      return AiResolvedMessage(
        intent: intent,
        reply: reply.isEmpty ? '我暂时没有找到明确答案。' : reply,
        citations: _parseCitations(
          payload['citations'] as List<dynamic>?,
          items: items,
        ),
      );
    }

    return AiResolvedMessage(
      intent: AiResolvedIntentType.fallback,
      reply: reply.isEmpty ? '我理解了你的消息，你可以继续补充需求。' : reply,
    );
  }

  Map<String, dynamic>? _tryExtractLegacyJson(String raw) {
    try {
      return _extractJsonPayload(raw);
    } catch (_) {
      return null;
    }
  }

  String _buildResolverPrompt({
    required String basePrompt,
    required DateTime now,
    required List<AgendaItem> items,
  }) {
    final itemSummary = items.isEmpty
        ? '[]'
        : jsonEncode([
            for (final item in items)
              {
                'id': item.id,
                'type': item.type.name,
                'title': item.title,
                'details': item.details,
                'location': item.location,
                'startAt': item.startAt.toIso8601String(),
                'endAt': item.endAt.toIso8601String(),
                'deadline': item.deadline?.toIso8601String(),
                'targetDate': item.targetDate.toIso8601String(),
                'isImportant': item.isImportant,
              },
          ]);

    return '''
${basePrompt.trim()}

你是”花卷日程”AI助手。
当前时间：${now.toIso8601String()}
事项数据：$itemSummary

输出格式：
先写一段自然语言回复（支持 Markdown 格式），然后在末尾加上 <data> 标签包含 JSON 数据。

完整输出示例：
回复文本内容...

<data>
{
  “intent”: “create_item” | “answer” | “fallback”,
  “assistant_reply”: “字符串，给用户的自然语言回复”,
  “create_item”: {
    “type”: “schedule” | “task” | “memo”,
    “title”: “字符串”,
    “details”: “字符串，可空”,
    “location”: “字符串，可空”,
    “start_at”: “ISO8601，可空”,
    “end_at”: “ISO8601，可空”,
    “deadline”: “ISO8601，可空”,
    “target_date”: “ISO8601，可空”,
    “estimated_minutes”: 数字，可空,
    “is_important”: 布尔，可空
  },
  “citations”: [
    {
      “item_id”: “字符串”,
      “reason”: “字符串，可空”
    }
  ]
}
</data>

规则：
1. 当用户在”创建/新增/安排/提醒”时 intent=create_item。
2. create_item 缺少必要字段时仍返回 create_item，并在 assistant_reply 中用自然语言追问缺失信息。
3. 非必要字段允许为空，不要臆造。
4. 当用户问”我有什么安排/冲突/空闲”等问题时 intent=answer，并尽量给 citations。
5. 其余情况 intent=fallback。
''';
  }

  Map<String, dynamic> _extractJsonPayload(String raw) {
    final fenced = RegExp(r'```json\s*([\s\S]*?)```', caseSensitive: false).firstMatch(raw);
    final candidate = fenced?.group(1)?.trim() ?? raw.trim();
    final firstBrace = candidate.indexOf('{');
    final lastBrace = candidate.lastIndexOf('}');
    if (firstBrace < 0 || lastBrace <= firstBrace) {
      throw const FormatException('未找到 JSON 对象。');
    }
    final jsonText = candidate.substring(firstBrace, lastBrace + 1);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('AI 输出不是 JSON 对象。');
    }
    return decoded;
  }

  AiResolvedIntentType _parseIntent(String? raw) {
    return switch ((raw ?? '').trim()) {
      'create_item' => AiResolvedIntentType.createItem,
      'answer' => AiResolvedIntentType.answer,
      _ => AiResolvedIntentType.fallback,
    };
  }

  AiCreateItemDraft _parseCreateDraft(
    Map<String, dynamic>? createMap, {
    required DateTime now,
    required List<AgendaItem> items,
  }) {
    final map = createMap ?? const <String, dynamic>{};
    final type = _itemTypeFromString(map['type'] as String?) ?? ItemType.schedule;
    final title = (map['title'] as String? ?? '').trim();
    final details = (map['details'] as String? ?? '').trim();
    final location = (map['location'] as String? ?? '').trim();
    final startAt = DateTime.tryParse((map['start_at'] as String? ?? '').trim());
    final endAt = DateTime.tryParse((map['end_at'] as String? ?? '').trim());
    final deadline = DateTime.tryParse((map['deadline'] as String? ?? '').trim());
    final targetDate = DateTime.tryParse((map['target_date'] as String? ?? '').trim());
    final estimatedMinutes = (map['estimated_minutes'] as num?)?.toInt();
    final isImportant = map['is_important'] as bool? ?? false;

    final normalizedStart = startAt ?? _roundToHalfHour(now);
    final normalizedEnd = (endAt ?? normalizedStart.add(const Duration(hours: 1)))
        .isAfter(normalizedStart)
        ? (endAt ?? normalizedStart.add(const Duration(hours: 1)))
        : normalizedStart.add(const Duration(hours: 1));
    final normalizedTargetDate = DateTime(
      (targetDate ?? normalizedStart).year,
      (targetDate ?? normalizedStart).month,
      (targetDate ?? normalizedStart).day,
    );
    final normalizedEstimate = Duration(
      minutes: (estimatedMinutes == null || estimatedMinutes <= 0)
          ? 60
          : estimatedMinutes,
    );

    final draft = ItemDraft(
      type: type,
      title: title,
      details: details,
      location: location,
      color: ItemColorOption.sky,
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.none,
      scheduleDetails: ItemScheduleDetails(
        range: DateTimeRangeValue(start: normalizedStart, end: normalizedEnd),
        isAllDay: false,
      ),
      taskDetails: ItemTaskDetails(
        schedule: ItemScheduleDetails(
          range: DateTimeRangeValue(start: normalizedStart, end: normalizedEnd),
          isAllDay: false,
        ),
        deadline: deadline,
      ),
      memoDetails: ItemMemoDetails(
        targetDate: normalizedTargetDate,
        estimatedDuration: normalizedEstimate,
      ),
    );

    final missingRequired = <String>[
      if (title.isEmpty) 'title',
      if ((type == ItemType.schedule || type == ItemType.task) && startAt == null) 'start_at',
      if ((type == ItemType.schedule || type == ItemType.task) && endAt == null) 'end_at',
      if (type == ItemType.memo && targetDate == null) 'target_date',
    ];

    return AiCreateItemDraft(
      draft: draft,
      isImportant: isImportant,
      missingRequired: missingRequired,
      conflicts: _findConflicts(draft: draft, items: items),
    );
  }

  List<AiDraftConflict> _findConflicts({
    required ItemDraft draft,
    required List<AgendaItem> items,
  }) {
    if (draft.type == ItemType.memo) {
      return const [];
    }
    final start = draft.startAt;
    final end = draft.endAt;
    if (!end.isAfter(start)) {
      return const [];
    }
    return [
      for (final item in items)
        if (item.endAt.isAfter(start) && item.startAt.isBefore(end))
          AiDraftConflict(
            itemId: item.id,
            title: item.title,
            overlapStart: item.startAt.isAfter(start) ? item.startAt : start,
            overlapEnd: item.endAt.isBefore(end) ? item.endAt : end,
          ),
    ];
  }

  List<AiCitation> _parseCitations(
    List<dynamic>? raw, {
    required List<AgendaItem> items,
  }) {
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final byId = {
      for (final item in items) item.id: item,
    };
    final citations = <AiCitation>[];
    for (final row in raw) {
      if (row is! Map<String, dynamic>) {
        continue;
      }
      final itemId = (row['item_id'] as String? ?? '').trim();
      if (itemId.isEmpty) {
        continue;
      }
      final matched = byId[itemId];
      if (matched == null) {
        continue;
      }
      citations.add(
        AiCitation(
          itemId: matched.id,
          title: matched.title,
          type: matched.type,
          startAt: matched.startAt,
          endAt: matched.endAt,
          reason: (row['reason'] as String?)?.trim(),
        ),
      );
    }
    return citations;
  }

  ItemType? _itemTypeFromString(String? raw) {
    return switch ((raw ?? '').trim()) {
      'schedule' => ItemType.schedule,
      'task' => ItemType.task,
      'memo' => ItemType.memo,
      _ => null,
    };
  }

  DateTime _roundToHalfHour(DateTime time) {
    return DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute >= 30 ? 30 : 0,
    );
  }
}

final aiChatRepositoryProvider =
    NotifierProvider<InMemoryAiChatRepository, AiChatSessionStore>(
  InMemoryAiChatRepository.new,
);

final aiChatRepositoryNotifierProvider = Provider<AiChatRepository>((ref) {
  return ref.read(aiChatRepositoryProvider.notifier);
});

final aiServiceProvider = Provider<AiService>((ref) {
  return OpenAiCompatibleAiService(ref);
});
