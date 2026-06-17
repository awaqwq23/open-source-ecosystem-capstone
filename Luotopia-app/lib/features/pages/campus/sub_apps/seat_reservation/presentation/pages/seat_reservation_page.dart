import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/features/pages/campus/sub_apps/seat_reservation/data/seat_reservation_auth_service.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/agenda_item_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';
import 'package:luotopia/shared/presentation/widgets/app_web_view_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_cookie_manager_flutter/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SeatReservationPage extends ConsumerStatefulWidget {
  const SeatReservationPage({super.key});

  @override
  ConsumerState<SeatReservationPage> createState() =>
      _SeatReservationPageState();
}

class _SeatReservationPageState extends ConsumerState<SeatReservationPage> {
  final WebviewCookieManager _cookieManager = WebviewCookieManager();
  WebViewController? _controller;
  bool _showingSyncDialog = false;
  String? _errorMessage;
  String? _lastHandledSourceId;
  final Map<String, _SeatReservationTimeContext> _timeContexts = {};

  Future<AppWebViewRequest?> _loadSeatSession(
    WebViewController controller,
  ) async {
    final authState = ref.read(whuAuthProvider);
    if (!authState.isAuthenticated) {
      return null;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      final session = await SeatReservationAuthService(
        gateway: ref.read(whuAuthGatewayProvider),
      ).createWebSession();
      if (!mounted) {
        return null;
      }
      await _primeSeatCookies(session);
      setState(() {
        _controller = controller;
      });
      return AppWebViewRequest(
        uri: session.launchUri,
        headers: _seatHeaders(session),
      );
    } catch (error) {
      if (!mounted) {
        return null;
      }
      setState(() {
        _errorMessage = error.toString();
      });
      return null;
    }
  }

  Future<void> _configureSeatController(WebViewController controller) async {
    _controller = controller;
    await controller.addJavaScriptChannel(
      'SeatReservationBridge',
      onMessageReceived: _handleBridgeMessage,
    );
  }

  Future<void> _primeSeatCookies(SeatReservationWebSession session) async {
    final cookies = _seatCookies(session.cookieHeader);
    if (cookies.isEmpty) {
      return;
    }
    await _cookieManager.setCookies(
      cookies,
      origin: 'https://seat.lib.whu.edu.cn',
    );
  }

  Map<String, String> _seatHeaders(SeatReservationWebSession session) {
    if (session.cookieHeader.trim().isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Cookie': session.cookieHeader};
  }

  List<Cookie> _seatCookies(String cookieHeader) {
    final values = <String, String>{};
    for (final part in cookieHeader.split(';')) {
      final trimmed = part.trim();
      if (trimmed.isEmpty || !trimmed.contains('=')) {
        continue;
      }
      final separator = trimmed.indexOf('=');
      final name = trimmed.substring(0, separator).trim();
      final value = trimmed.substring(separator + 1).trim();
      if (name.isEmpty || value.isEmpty || values.containsKey(name)) {
        continue;
      }
      values[name] = value;
    }
    return [
      for (final entry in values.entries)
        Cookie(entry.key, entry.value)
          ..domain = 'seat.lib.whu.edu.cn'
          ..path = '/'
          ..secure = true
          ..httpOnly = true,
    ];
  }

  Future<void> _injectReservationBridge() async {
    final controller = _controller;
    if (controller == null) {
      debugPrint('[SeatReservationSync] skip inject: controller is null');
      return;
    }
    await controller.runJavaScript('''
(function () {
  if (window.__luotopiaSeatBridgeInstalled) return;
  window.__luotopiaSeatBridgeInstalled = true;
  var targets = [
    '/static/frontApi/make/freeBook/',
    '/static/frontApi/make/quickBook/',
    '/static/frontApi/make/planBook/',
    '/static/frontApi/res/findRoomDuration/',
    '/static/frontApi/res/freeSeatIdsDuration/',
    '/static/frontApi/res/getEndTimes/'
  ];
  function isTarget(url) {
    return targets.some(function (target) {
      return String(url || '').indexOf(target) >= 0;
    });
  }
  function notify(source, url, status, responseText, requestBody) {
    if (!isTarget(url) || status < 200 || status >= 300) return;
    try {
      SeatReservationBridge.postMessage(JSON.stringify({
        source: source,
        url: String(url || ''),
        status: status,
        requestBody: requestBody || '',
        responseText: responseText || '',
        href: window.location.href,
        pageText: document.body ? document.body.innerText : ''
      }));
    } catch (_) {}
  }
  var open = XMLHttpRequest.prototype.open;
  var send = XMLHttpRequest.prototype.send;
  XMLHttpRequest.prototype.open = function (method, url) {
    this.__luotopiaSeatUrl = String(url || '');
    return open.apply(this, arguments);
  };
  XMLHttpRequest.prototype.send = function () {
    var xhr = this;
    var requestBody = arguments.length > 0 && arguments[0] ? String(arguments[0]) : '';
    xhr.addEventListener('load', function () {
      notify('xhr', xhr.__luotopiaSeatUrl || '', xhr.status, xhr.responseText || '', requestBody);
    });
    return send.apply(this, arguments);
  };
  if (window.fetch) {
    var originalFetch = window.fetch;
    window.fetch = function (input, init) {
      var url = typeof input === 'string' ? input : (input && input.url) || '';
      var requestBody = init && init.body ? String(init.body) : '';
      return originalFetch.apply(this, arguments).then(function (response) {
        if (!isTarget(url)) return response;
        try {
          response.clone().text().then(function (text) {
            notify('fetch', url, response.status, text || '', requestBody);
          }).catch(function () {});
        } catch (_) {}
        return response;
      });
    };
  }
  try {
    SeatReservationBridge.postMessage(JSON.stringify({
      source: 'installed',
      url: window.location.href,
      status: 0,
      responseText: '',
      href: window.location.href,
      pageText: ''
    }));
  } catch (_) {}
})();
''');
  }

  Future<void> _handleBridgeMessage(JavaScriptMessage message) async {
    final payload = _SeatReservationCandidate.decodePayload(message.message);
    final source = '${payload?['source'] ?? 'unknown'}';
    final url = '${payload?['url'] ?? ''}';
    final status = '${payload?['status'] ?? 'unknown'}';
    if (source == 'installed') {
      debugPrint(
        '[SeatReservationSync] bridge installed at ${_sanitizeSeatUrl(url)}',
      );
      return;
    }
    debugPrint(
      '[SeatReservationSync] captured $source ${_sanitizeSeatUrl(url)} '
      'status=$status',
    );
    _rememberTimeContext(payload);
    if (!_isSeatMakeUrl(url)) {
      return;
    }
    final candidate = _SeatReservationCandidate.tryParse(
      message.message,
      timeContextFor: _timeContextFor,
    );
    if (candidate == null || !candidate.remoteSucceeded) {
      debugPrint(
        '[SeatReservationSync] ignored: '
        '${candidate == null ? 'parse-failed' : 'remote-failed'}',
      );
      return;
    }
    if (_lastHandledSourceId == candidate.sourceId || _showingSyncDialog) {
      debugPrint(
        '[SeatReservationSync] ignored duplicate or dialog-active: ${candidate.sourceId}',
      );
      return;
    }
    _lastHandledSourceId = candidate.sourceId;

    if (_hasSynced(candidate.sourceId)) {
      _showSnackBar('这条预约已经在日程里了。');
      return;
    }

    _showingSyncDialog = true;
    final confirmed = await _confirmSync(candidate);
    _showingSyncDialog = false;
    if (!mounted || confirmed != true) {
      return;
    }

    await ref
        .read(agendaItemRepositoryProvider.notifier)
        .createItem(candidate.toDraft());
    debugPrint(
      '[SeatReservationSync] created agenda item: ${candidate.sourceId}',
    );
    if (!mounted) {
      return;
    }
    _showSnackBar('座位预约已添加到日程。');
  }

  void _rememberTimeContext(Map<String, dynamic>? payload) {
    final context = _SeatReservationTimeContext.tryParse(payload);
    if (context == null) {
      return;
    }
    _timeContexts[context.key] = context;
    _timeContexts[context.dateKey] = context;
    debugPrint(
      '[SeatReservationSync] remembered beginMinute=${context.beginMinute} '
      'for ${context.key}',
    );
  }

  _SeatReservationTimeContext? _timeContextFor(String seatId, String dateText) {
    final normalizedDate = _normalizeSeatDateText(dateText);
    return _timeContexts[_SeatReservationTimeContext.keyFor(
          seatId,
          normalizedDate,
        )] ??
        _timeContexts[_SeatReservationTimeContext.dateKeyFor(normalizedDate)];
  }

  bool _hasSynced(String sourceId) {
    return ref
        .read(agendaItemRepositoryProvider)
        .any(
          (item) =>
              item.sourceKind == AgendaItemSourceKind.seatReservation &&
              item.sourceRef == sourceId,
        );
  }

  Future<bool?> _confirmSync(_SeatReservationCandidate candidate) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加到日程？'),
          content: Text(
            '${candidate.location}\n'
            '${_formatDateTime(candidate.startAt)} - ${_formatTime(candidate.endAt)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(whuAuthProvider);
    return _buildBody(authState);
  }

  Widget _buildBody(WhuAuthState authState) {
    if (!authState.isAuthenticated) {
      return ui.Scaffold(
        child: _LoginRequiredView(
          onLogin: () async {
            await context.openSecondary(AppRoutePaths.whuAccount);
            if (mounted) {
              setState(() {});
            }
          },
        ),
      );
    }

    return AppWebViewPage(
      title: '自习预约',
      enableZoom: false,
      preparingMessage: '正在授权座位预约系统...',
      loadingMessage: '正在加载座位预约...',
      errorTitle: '座位预约暂时无法打开',
      initialRequest: _loadSeatSession,
      onControllerCreated: _configureSeatController,
      onPageStarted: (url, _) {
        debugPrint('[SeatReservationWebView] started ${_sanitizeSeatUrl(url)}');
      },
      onPageFinished: (url, _) async {
        debugPrint(
          '[SeatReservationWebView] finished ${_sanitizeSeatUrl(url)}',
        );
        await _injectReservationBridge();
      },
      onRefresh: (_, loadInitialRequest) => loadInitialRequest(),
      overlayBuilder: (context, state, controller) {
        final errorMessage = _errorMessage;
        if (errorMessage == null) {
          return null;
        }
        return ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: _ErrorView(
            message: errorMessage,
            onRetry: () async {
              setState(() => _errorMessage = null);
              final request = await _loadSeatSession(controller);
              if (request != null) {
                await controller.loadRequest(
                  request.uri,
                  headers: request.headers,
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView({required this.onLogin});

  final Future<void> Function() onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('请先登录武大教务账户', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            ui.OutlineButton(
              onPressed: () {
                onLogin();
              },
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ui.OutlineButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _SeatReservationCandidate {
  const _SeatReservationCandidate({
    required this.sourceId,
    required this.remoteSucceeded,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.seatId,
  });

  final String sourceId;
  final bool remoteSucceeded;
  final DateTime startAt;
  final DateTime endAt;
  final String location;
  final String seatId;

  static _SeatReservationCandidate? tryParse(
    String rawMessage, {
    _SeatReservationTimeContext? Function(String seatId, String dateText)?
    timeContextFor,
  }) {
    final payload = decodePayload(rawMessage);
    if (payload == null) {
      return null;
    }
    final response = _decodeMap('${payload['responseText'] ?? ''}');
    final remoteSucceeded = _isRemoteSuccess(response);
    final url = '${payload['url'] ?? ''}';
    final parsed =
        _parseBookUrl(url, timeContextFor: timeContextFor) ??
        _parseFromResponse(response);
    if (parsed == null) {
      return null;
    }
    final location =
        _extractLocation(response) ??
        _extractLocationFromPageText('${payload['pageText'] ?? ''}') ??
        '武汉大学图书馆';
    return _SeatReservationCandidate(
      sourceId:
          'seat:${parsed.seatId}:${parsed.dateText}:${parsed.startMinute}:${parsed.endMinute}',
      remoteSucceeded: remoteSucceeded,
      startAt: parsed.startAt,
      endAt: parsed.endAt,
      location: location,
      seatId: parsed.seatId,
    );
  }

  static Map<String, dynamic>? decodePayload(String raw) => _decodeMap(raw);

  ItemDraft toDraft() {
    return ItemDraft(
      type: ItemType.schedule,
      title: '图书馆座位预约',
      notes:
          '来源：武汉大学图书馆座位预约系统\n'
          '座位 ID：$seatId',
      location: location,
      color: ItemColorOption.indigo,
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.none,
      details: ScheduleItemDetails(
        startAt: startAt,
        endAt: endAt,
        isAllDay: false,
      ),
      sourceKind: AgendaItemSourceKind.seatReservation,
      sourceRef: sourceId,
    );
  }

  static Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static bool _isRemoteSuccess(Map<String, dynamic>? response) {
    if (response == null) {
      return false;
    }
    final status = response['status'];
    if (status == true || status == 'true') {
      return true;
    }
    final success = response['success'];
    if (success == true || success == 'true') {
      return true;
    }
    final code = response['code'];
    return code == 200 || code == '200';
  }

  static _ParsedFreeBook? _parseBookUrl(
    String rawUrl, {
    _SeatReservationTimeContext? Function(String seatId, String dateText)?
    timeContextFor,
  }) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return null;
    }
    final segments = uri.pathSegments;
    final quickBookIndex = segments.indexOf('quickBook');
    if (quickBookIndex >= 0 && segments.length > quickBookIndex + 2) {
      final roomId = segments[quickBookIndex + 1];
      final endMinute = int.tryParse(segments[quickBookIndex + 2]);
      final now = DateTime.now();
      final startMinute = now.hour * 60 + now.minute;
      return _parsedFromParts(
        seatId: 'room:$roomId',
        year: now.year,
        month: now.month,
        day: now.day,
        startMinute: startMinute,
        endMinute: endMinute,
      );
    }
    final freeBookIndex = segments.indexOf('freeBook');
    if (freeBookIndex < 0 || segments.length <= freeBookIndex + 4) {
      return null;
    }
    final seatId = segments[freeBookIndex + 1];
    final dateAndTime = segments.sublist(freeBookIndex + 2);
    final dateParts = _parseDateParts(dateAndTime.first);
    if (dateParts != null && dateAndTime.length >= 3) {
      final normalizedDate = _normalizeSeatDateText(dateAndTime.first);
      final context = timeContextFor?.call(seatId, normalizedDate);
      return _parsedFromParts(
        seatId: seatId,
        year: dateParts.year,
        month: dateParts.month,
        day: dateParts.day,
        startMinute: context?.beginMinute,
        endMinute: int.tryParse(dateAndTime[2]),
      );
    } else if (dateAndTime.length >= 5) {
      final year = int.tryParse(dateAndTime[0]);
      final month = int.tryParse(dateAndTime[1]);
      final day = int.tryParse(dateAndTime[2]);
      if (year == null || month == null || day == null) {
        return null;
      }
      return _parsedFromParts(
        seatId: seatId,
        year: year,
        month: month,
        day: day,
        startMinute: timeContextFor
            ?.call(seatId, '$year-$month-$day')
            ?.beginMinute,
        endMinute: int.tryParse(dateAndTime[4]),
      );
    } else {
      return null;
    }
  }

  static _ParsedFreeBook? _parsedFromParts({
    required String seatId,
    required int year,
    required int month,
    required int day,
    required int? startMinute,
    required int? endMinute,
  }) {
    if (startMinute == null || endMinute == null) {
      return null;
    }
    final start = DateTime(
      year,
      month,
      day,
    ).add(Duration(minutes: startMinute));
    final end = DateTime(year, month, day).add(Duration(minutes: endMinute));
    if (!end.isAfter(start)) {
      return null;
    }
    return _ParsedFreeBook(
      seatId: seatId,
      dateText: '$year/$month/$day',
      startMinute: startMinute,
      endMinute: endMinute,
      startAt: start,
      endAt: end,
    );
  }

  static _ParsedFreeBook? _parseFromResponse(Map<String, dynamic>? response) {
    if (response == null) {
      return null;
    }
    final dateText = _findString(response, const [
      'makeDate',
      'date',
      'day',
      'startDate',
      'beginDate',
      'startTime',
      'beginTime',
    ]);
    final startMinute = _findInt(response, const [
      'startMinute',
      'startTime',
      'beginMinute',
      'beginTime',
      'makeStartTime',
      'start',
    ]);
    final endMinute = _findInt(response, const [
      'endMinute',
      'endTime',
      'stopMinute',
      'stopTime',
      'makeEndTime',
      'end',
    ]);
    final seatId = _findString(response, const [
      'seatId',
      'resId',
      'resourceId',
      'resSeatId',
      'seatNum',
      'seatName',
      'makeId',
      'id',
    ]);
    final dateParts = _parseDateParts(dateText);
    if (dateParts == null ||
        startMinute == null ||
        endMinute == null ||
        seatId == null ||
        seatId.trim().isEmpty) {
      return null;
    }
    final start = DateTime(
      dateParts.year,
      dateParts.month,
      dateParts.day,
    ).add(Duration(minutes: startMinute));
    final end = DateTime(
      dateParts.year,
      dateParts.month,
      dateParts.day,
    ).add(Duration(minutes: endMinute));
    if (!end.isAfter(start)) {
      return null;
    }
    return _ParsedFreeBook(
      seatId: seatId,
      dateText: '${dateParts.year}/${dateParts.month}/${dateParts.day}',
      startMinute: startMinute,
      endMinute: endMinute,
      startAt: start,
      endAt: end,
    );
  }

  static String? _extractLocation(Object? value) {
    if (value is Map) {
      for (final key in const [
        'roomInfo',
        'roomName',
        'resName',
        'seatName',
        'name',
        'position',
      ]) {
        final raw = value[key];
        if (raw is String && raw.trim().isNotEmpty) {
          return raw.trim();
        }
      }
      for (final child in value.values) {
        final nested = _extractLocation(child);
        if (nested != null) {
          return nested;
        }
      }
    }
    if (value is List) {
      for (final child in value) {
        final nested = _extractLocation(child);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  static String? _extractLocationFromPageText(String text) {
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    for (final line in lines) {
      if (line.contains('|') && (line.contains('馆') || line.contains('楼'))) {
        return line;
      }
    }
    return null;
  }

  static String? _findString(Object? value, List<String> keys) {
    if (value is Map) {
      for (final key in keys) {
        final raw = value[key];
        if (raw is String && raw.trim().isNotEmpty) {
          return raw.trim();
        }
        if (raw is num) {
          return '$raw';
        }
      }
      for (final child in value.values) {
        final nested = _findString(child, keys);
        if (nested != null) {
          return nested;
        }
      }
    }
    if (value is List) {
      for (final child in value) {
        final nested = _findString(child, keys);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  static int? _findInt(Object? value, List<String> keys) {
    if (value is Map) {
      for (final key in keys) {
        final raw = value[key];
        if (raw is int) {
          return raw;
        }
        if (raw is num) {
          return raw.toInt();
        }
        if (raw is String) {
          final parsed =
              int.tryParse(raw.trim()) ?? _parseTimeMinute(raw.trim());
          if (parsed != null) {
            return parsed;
          }
        }
      }
      for (final child in value.values) {
        final nested = _findInt(child, keys);
        if (nested != null) {
          return nested;
        }
      }
    }
    if (value is List) {
      for (final child in value) {
        final nested = _findInt(child, keys);
        if (nested != null) {
          return nested;
        }
      }
    }
    return null;
  }

  static int? _parseTimeMinute(String value) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  static _DateParts? _parseDateParts(String? value) {
    if (value == null) {
      return null;
    }
    final match = RegExp(
      r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})',
    ).firstMatch(value);
    if (match == null) {
      return null;
    }
    final year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    if (year == null || month == null || day == null) {
      return null;
    }
    return _DateParts(year: year, month: month, day: day);
  }
}

class _ParsedFreeBook {
  const _ParsedFreeBook({
    required this.seatId,
    required this.dateText,
    required this.startMinute,
    required this.endMinute,
    required this.startAt,
    required this.endAt,
  });

  final String seatId;
  final String dateText;
  final int startMinute;
  final int endMinute;
  final DateTime startAt;
  final DateTime endAt;
}

class _SeatReservationTimeContext {
  const _SeatReservationTimeContext({
    required this.seatOrRoomId,
    required this.dateText,
    required this.beginMinute,
  });

  final String seatOrRoomId;
  final String dateText;
  final int beginMinute;

  String get key => keyFor(seatOrRoomId, dateText);

  String get dateKey => dateKeyFor(dateText);

  static _SeatReservationTimeContext? tryParse(Map<String, dynamic>? payload) {
    if (payload == null) {
      return null;
    }
    final url = '${payload['url'] ?? ''}';
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return null;
    }
    final requestBody = _SeatReservationCandidate._decodeMap(
      '${payload['requestBody'] ?? ''}',
    );
    final segments = uri.pathSegments;

    final getEndTimesIndex = segments.indexOf('getEndTimes');
    if (getEndTimesIndex >= 0 && segments.length > getEndTimesIndex + 3) {
      return _fromParts(
        seatOrRoomId: segments[getEndTimesIndex + 1],
        dateText: segments[getEndTimesIndex + 2],
        beginMinute: int.tryParse(segments[getEndTimesIndex + 3]),
      );
    }

    final freeSeatIndex = segments.indexOf('freeSeatIdsDuration');
    if (freeSeatIndex >= 0 && segments.length > freeSeatIndex + 2) {
      return _fromParts(
        seatOrRoomId: segments[freeSeatIndex + 1],
        dateText: segments[freeSeatIndex + 2],
        beginMinute: _SeatReservationCandidate._findInt(requestBody, const [
          'beginMinute',
        ]),
      );
    }

    final findRoomIndex = segments.indexOf('findRoomDuration');
    if (findRoomIndex >= 0 && segments.length > findRoomIndex + 2) {
      return _fromParts(
        seatOrRoomId: segments[findRoomIndex + 1],
        dateText: segments[findRoomIndex + 2],
        beginMinute: _SeatReservationCandidate._findInt(requestBody, const [
          'beginMinute',
        ]),
      );
    }

    return null;
  }

  static _SeatReservationTimeContext? _fromParts({
    required String seatOrRoomId,
    required String dateText,
    required int? beginMinute,
  }) {
    if (seatOrRoomId.trim().isEmpty || beginMinute == null || beginMinute < 0) {
      return null;
    }
    final normalizedDate = _normalizeSeatDateText(dateText);
    if (normalizedDate.isEmpty) {
      return null;
    }
    return _SeatReservationTimeContext(
      seatOrRoomId: seatOrRoomId,
      dateText: normalizedDate,
      beginMinute: beginMinute,
    );
  }

  static String keyFor(String seatOrRoomId, String dateText) {
    return '${seatOrRoomId.trim()}:${_normalizeSeatDateText(dateText)}';
  }

  static String dateKeyFor(String dateText) {
    return 'date:${_normalizeSeatDateText(dateText)}';
  }
}

class _DateParts {
  const _DateParts({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

bool _isSeatMakeUrl(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) {
    return false;
  }
  final segments = uri.pathSegments;
  return segments.contains('freeBook') ||
      segments.contains('quickBook') ||
      segments.contains('planBook');
}

String _normalizeSeatDateText(String value) {
  final match = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(value);
  if (match == null) {
    return value.trim();
  }
  final year = int.tryParse(match.group(1) ?? '');
  final month = int.tryParse(match.group(2) ?? '');
  final day = int.tryParse(match.group(3) ?? '');
  if (year == null || month == null || day == null) {
    return value.trim();
  }
  return '$year-${_two(month)}-${_two(day)}';
}

String _sanitizeSeatUrl(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) {
    return '<invalid-url>';
  }
  final queryKeys =
      uri.queryParameters.keys
          .where((key) {
            final lower = key.toLowerCase();
            return lower != 'token' && lower != 'ticket';
          })
          .toList(growable: false)
        ..sort();
  final queryText = queryKeys.isEmpty ? '' : '?${queryKeys.join(',')}';
  final fragmentText = uri.fragment.isEmpty ? '' : '#<fragment>';
  return '${uri.scheme}://${uri.host}${uri.path}$queryText$fragmentText';
}

String _formatDateTime(DateTime value) {
  return '${value.year}-${_two(value.month)}-${_two(value.day)} '
      '${_two(value.hour)}:${_two(value.minute)}';
}

String _formatTime(DateTime value) {
  return '${_two(value.hour)}:${_two(value.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
