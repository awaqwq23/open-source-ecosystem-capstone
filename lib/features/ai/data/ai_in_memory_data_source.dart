import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_action_models.dart';
import 'package:huajuan_agenda/features/ai/domain/models/ai_conversation_models.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_chat_repository.dart';
import 'package:huajuan_agenda/features/ai/domain/repositories/ai_service.dart';
import 'package:huajuan_agenda/features/settings/domain/models/ai_settings.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_memo_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_schedule_details.dart';
import 'package:huajuan_agenda/shared/domain/value_objects/item_task_details.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:huajuan_agenda/shared/value_objects/item_color_option.dart';
import 'package:huajuan_agenda/shared/value_objects/reminder_option.dart';
import 'package:huajuan_agenda/shared/value_objects/repeat_rule.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final aiChatBootstrapMessagesProvider = Provider<List<AiChatMessage>>((ref) {
  return const [];
});

class InMemoryAiChatRepository extends Notifier<List<AiChatMessage>>
    implements AiChatRepository {
  static const _hydrateChunkSize = 200;

  var _hasMutated = false;
  var _hydratedDeferred = false;

  @override
  List<AiChatMessage> build() {
    _hasMutated = false;
    _hydratedDeferred = false;
    return ref.read(aiChatBootstrapMessagesProvider);
  }

  @override
  List<AiChatMessage> getAll() => state;

  @override
  List<AiChatMessage> getByRange(DateTimeRangeValue range) {
    return [
      for (final message in state)
        if (!message.createdAt.isBefore(range.start) &&
            message.createdAt.isBefore(range.end))
          message,
    ];
  }

  @override
  Future<void> append(AiChatMessage message) async {
    _hasMutated = true;
    state = [...state, message];
    await _prefs?.setString(
      AppBootstrapStorageKeys.aiMessages,
      jsonEncode([
        for (final item in state)
          {
            'id': item.id,
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
          },
      ]),
    );
  }

  void hydrateFromBootstrap(List<AiChatMessage> messages) {
    if (_hydratedDeferred) {
      return;
    }
    _hydratedDeferred = true;
    if (_hasMutated || state.isNotEmpty) {
      return;
    }
    state = [...messages];
  }

  Future<void> hydrateFromSerializedBootstrap(List<Map<String, dynamic>> itemsJson) async {
    if (_hydratedDeferred) {
      return;
    }
    _hydratedDeferred = true;
    if (_hasMutated || state.isNotEmpty || itemsJson.isEmpty) {
      return;
    }

    final messages = <AiChatMessage>[];
    for (var index = 0; index < itemsJson.length; index += _hydrateChunkSize) {
      final end = (index + _hydrateChunkSize).clamp(0, itemsJson.length);
      final chunk = itemsJson.sublist(index, end);
      for (final item in chunk) {
        final message = AiChatMessage(
          id: item['id'] as String? ?? '',
          content: item['content'] as String? ?? '',
          createdAt: DateTime.tryParse(item['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
          role: switch (item['role']) {
            'assistant' => AiChatRole.assistant,
            _ => AiChatRole.user,
          },
          kind: switch (item['kind']) {
            'answer' => AiMessageKind.answer,
            'system' => AiMessageKind.system,
            _ => AiMessageKind.chat,
          },
          citations: _decodeCitations(item['citations']),
        );
        if (message.id.isNotEmpty) {
          messages.add(message);
        }
      }
      if (end < itemsJson.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    state = messages;
  }

  List<AiCitation> _decodeCitations(Object? raw) {
    if (raw is! List<dynamic>) {
      return const [];
    }
    final citations = <AiCitation>[];
    for (final row in raw) {
      if (row is! Map<String, dynamic>) {
        continue;
      }
      final type = _itemTypeFromString(row['type'] as String?);
      if (type == null) {
        continue;
      }
      citations.add(
        AiCitation(
          itemId: row['itemId'] as String? ?? '',
          title: row['title'] as String? ?? '',
          type: type,
          startAt: DateTime.tryParse(row['startAt'] as String? ?? ''),
          endAt: DateTime.tryParse(row['endAt'] as String? ?? ''),
          reason: row['reason'] as String?,
        ),
      );
    }
    return citations;
  }

  ItemType? _itemTypeFromString(String? value) {
    return switch (value) {
      'schedule' => ItemType.schedule,
      'task' => ItemType.task,
      'memo' => ItemType.memo,
      'course' => ItemType.course,
      _ => null,
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
      final payload = _extractJsonPayload(content);
      final intent = _parseIntent(payload['intent'] as String?);
      final reply = (payload['assistant_reply'] as String? ?? '').trim();

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

你是“花卷日程”AI页解析器。你必须只输出一个 JSON 对象，不要输出 markdown。
当前时间：${now.toIso8601String()}
事项数据：$itemSummary

输出 JSON schema：
{
  "intent": "create_item" | "answer" | "fallback",
  "assistant_reply": "字符串，给用户的自然语言回复",
  "create_item": {
    "type": "schedule" | "task" | "memo",
    "title": "字符串",
    "details": "字符串，可空",
    "location": "字符串，可空",
    "start_at": "ISO8601，可空",
    "end_at": "ISO8601，可空",
    "deadline": "ISO8601，可空",
    "target_date": "ISO8601，可空",
    "estimated_minutes": 数字，可空,
    "is_important": 布尔，可空
  },
  "citations": [
    {
      "item_id": "字符串",
      "reason": "字符串，可空"
    }
  ]
}

规则：
1. 当用户在“创建/新增/安排/提醒”时 intent=create_item。
2. create_item 缺少必要字段时仍返回 create_item，并在 assistant_reply 中用自然语言追问缺失信息。
3. 非必要字段允许为空，不要臆造。
4. 当用户问“我有什么安排/冲突/空闲”等问题时 intent=answer，并尽量给 citations。
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
    NotifierProvider<InMemoryAiChatRepository, List<AiChatMessage>>(
  InMemoryAiChatRepository.new,
);

final aiChatRepositoryNotifierProvider = Provider<AiChatRepository>((ref) {
  return ref.read(aiChatRepositoryProvider.notifier);
});

final aiServiceProvider = Provider<AiService>((ref) {
  return OpenAiCompatibleAiService(ref);
});
