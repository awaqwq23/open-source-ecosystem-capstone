import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/data/seat_reservation_auth_service.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/domain/entities/item_draft.dart';
import 'package:luotopia/shared/domain/value_objects/item_memo_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_schedule_details.dart';
import 'package:luotopia/shared/domain/value_objects/item_task_details.dart';
import 'package:luotopia/shared/enums/item_type.dart';
import 'package:luotopia/shared/value_objects/date_time_range.dart';
import 'package:luotopia/shared/value_objects/item_color_option.dart';
import 'package:luotopia/shared/value_objects/reminder_option.dart';
import 'package:luotopia/shared/value_objects/repeat_rule.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class SeatReservationPage extends ConsumerStatefulWidget {
  const SeatReservationPage({super.key});

  @override
  ConsumerState<SeatReservationPage> createState() => _SeatReservationPageState();
}

class _SeatReservationPageState extends ConsumerState<SeatReservationPage> {
  WebViewController? _controller;
  bool _loadingSession = false;
  bool _loadingPage = false;
  bool _showingSyncDialog = false;
  String? _errorMessage;
  String? _lastHandledSourceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSeatSession();
    });
  }

  Future<void> _loadSeatSession() async {
    final authState = ref.read(whuAuthProvider);
    if (!authState.isAuthenticated || _loadingSession) {
      return;
    }

    setState(() {
      _loadingSession = true;
      _loadingPage = true;
      _errorMessage = null;
    });

    try {
      final session = await SeatReservationAuthService(
        gateway: ref.read(whuAuthGatewayProvider),
      ).createWebSession();
      final controller = await _buildController();
      await controller.loadRequest(session.launchUri);
      if (!mounted) {
        return;
      }
      setState(() {
        _controller = controller;
        _loadingSession = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingSession = false;
        _loadingPage = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<WebViewController> _buildController() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SeatReservationBridge',
        onMessageReceived: _handleBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (mounted) {
              setState(() => _loadingPage = false);
            }
            await _injectReservationBridge();
          },
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _loadingPage = true);
            }
          },
        ),
      )
      ..enableZoom(false);

    final platformController = controller.platform;
    if (platformController is AndroidWebViewController) {
      await platformController.setUseWideViewPort(true);
      await platformController.setTextZoom(100);
    }
    return controller;
  }

  Future<void> _injectReservationBridge() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    await controller.runJavaScript('''
(function () {
  if (window.__luotopiaSeatBridgeInstalled) return;
  window.__luotopiaSeatBridgeInstalled = true;
  var targets = [
    '/static/frontApi/make/freeBook/',
    '/static/frontApi/make/quickBook/',
    '/static/frontApi/make/planBook/'
  ];
  var open = XMLHttpRequest.prototype.open;
  var send = XMLHttpRequest.prototype.send;
  XMLHttpRequest.prototype.open = function (method, url) {
    this.__luotopiaSeatUrl = String(url || '');
    return open.apply(this, arguments);
  };
  XMLHttpRequest.prototype.send = function () {
    var xhr = this;
    xhr.addEventListener('load', function () {
      var url = xhr.__luotopiaSeatUrl || '';
      var matched = targets.some(function (target) {
        return url.indexOf(target) >= 0;
      });
      if (!matched || xhr.status < 200 || xhr.status >= 300) return;
      try {
        SeatReservationBridge.postMessage(JSON.stringify({
          url: url,
          responseText: xhr.responseText || '',
          href: window.location.href,
          pageText: document.body ? document.body.innerText : ''
        }));
      } catch (_) {}
    });
    return send.apply(this, arguments);
  };
})();
''');
  }

  Future<void> _handleBridgeMessage(JavaScriptMessage message) async {
    final candidate = _SeatReservationCandidate.tryParse(message.message);
    if (candidate == null || !candidate.remoteSucceeded) {
      return;
    }
    if (_lastHandledSourceId == candidate.sourceId || _showingSyncDialog) {
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

    await ref.read(agendaItemRepositoryProvider.notifier).createItem(
          candidate.toDraft(),
        );
    if (!mounted) {
      return;
    }
    _showSnackBar('座位预约已添加到日程。');
  }

  bool _hasSynced(String sourceId) {
    final marker = _sourceMarker(sourceId);
    return ref
        .read(agendaItemRepositoryProvider)
        .any((item) => item.details.contains(marker));
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
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(whuAuthProvider);
    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('自习预约'),
          trailing: [
            ui.IconButton.ghost(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (!_loadingSession) {
                  _loadSeatSession();
                }
              },
            ),
          ],
        ),
      ],
      child: _buildBody(authState),
    );
  }

  Widget _buildBody(WhuAuthState authState) {
    if (!authState.isAuthenticated) {
      return _LoginRequiredView(onLogin: () async {
        await context.push(AppRoutePaths.settingsWhuAccount);
        if (mounted) {
          await _loadSeatSession();
        }
      });
    }

    if (_errorMessage != null && _controller == null) {
      return _ErrorView(
        message: _errorMessage!,
        onRetry: _loadSeatSession,
      );
    }

    final controller = _controller;
    return Stack(
      children: [
        if (controller != null)
          WebViewWidget(controller: controller)
        else
          const SizedBox.expand(),
        if (_loadingSession || _loadingPage)
          ColoredBox(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(_loadingSession ? '正在授权座位预约系统...' : '正在加载座位预约...'),
                ],
              ),
            ),
          ),
      ],
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
            Text(
              '请先登录武大教务账户',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
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
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

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
            ui.OutlineButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
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

  static _SeatReservationCandidate? tryParse(String rawMessage) {
    final payload = _decodeMap(rawMessage);
    if (payload == null) {
      return null;
    }
    final response = _decodeMap('${payload['responseText'] ?? ''}');
    final remoteSucceeded = response?['status'] == true || response?['success'] == true;
    final url = '${payload['url'] ?? ''}';
    final parsed = _parseFromResponse(response) ?? _parseFreeBookUrl(url);
    if (parsed == null) {
      return null;
    }
    final location = _extractLocation(response) ??
        _extractLocationFromPageText('${payload['pageText'] ?? ''}') ??
        '武汉大学图书馆';
    return _SeatReservationCandidate(
      sourceId: 'seat:${parsed.seatId}:${parsed.dateText}:${parsed.startMinute}:${parsed.endMinute}',
      remoteSucceeded: remoteSucceeded,
      startAt: parsed.startAt,
      endAt: parsed.endAt,
      location: location,
      seatId: parsed.seatId,
    );
  }

  ItemDraft toDraft() {
    final schedule = ItemScheduleDetails(
      isAllDay: false,
      range: DateTimeRangeValue(start: startAt, end: endAt),
    );
    return ItemDraft(
      type: ItemType.schedule,
      title: '图书馆座位预约',
      details: '来源：武汉大学图书馆座位预约系统\n'
          '座位 ID：$seatId\n'
          '${_sourceMarker(sourceId)}',
      location: location,
      color: ItemColorOption.indigo,
      reminder: ReminderOption.none,
      repeatRule: RepeatRule.none,
      scheduleDetails: schedule,
      taskDetails: ItemTaskDetails(
        schedule: schedule,
        deadline: null,
        estimatedDuration: endAt.difference(startAt),
      ),
      memoDetails: const ItemMemoDetails(),
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

  static _ParsedFreeBook? _parseFreeBookUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      return null;
    }
    final segments = uri.pathSegments;
    final freeBookIndex = segments.indexOf('freeBook');
    if (freeBookIndex < 0 || segments.length <= freeBookIndex + 6) {
      return null;
    }
    final seatId = segments[freeBookIndex + 1];
    final year = int.tryParse(segments[freeBookIndex + 2]);
    final month = int.tryParse(segments[freeBookIndex + 3]);
    final day = int.tryParse(segments[freeBookIndex + 4]);
    final startMinute = int.tryParse(segments[freeBookIndex + 5]);
    final endMinute = int.tryParse(segments[freeBookIndex + 6]);
    if (year == null ||
        month == null ||
        day == null ||
        startMinute == null ||
        endMinute == null) {
      return null;
    }
    final start = DateTime(year, month, day).add(Duration(minutes: startMinute));
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
    final dateText = _findString(response, const ['makeDate', 'date', 'day']);
    final startMinute = _findInt(response, const [
      'startMinute',
      'startTime',
      'beginMinute',
      'beginTime',
    ]);
    final endMinute = _findInt(response, const [
      'endMinute',
      'endTime',
      'stopMinute',
      'stopTime',
    ]);
    final seatId = _findString(response, const ['seatId', 'resId', 'resourceId']);
    final dateParts = _parseDateParts(dateText);
    if (dateParts == null ||
        startMinute == null ||
        endMinute == null ||
        seatId == null ||
        seatId.trim().isEmpty) {
      return null;
    }
    final start = DateTime(dateParts.year, dateParts.month, dateParts.day)
        .add(Duration(minutes: startMinute));
    final end = DateTime(dateParts.year, dateParts.month, dateParts.day)
        .add(Duration(minutes: endMinute));
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
          final parsed = int.tryParse(raw.trim());
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

  static _DateParts? _parseDateParts(String? value) {
    if (value == null) {
      return null;
    }
    final match = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})').firstMatch(value);
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

String _sourceMarker(String sourceId) => '座位预约同步ID：$sourceId';

String _formatDateTime(DateTime value) {
  return '${value.year}-${_two(value.month)}-${_two(value.day)} '
      '${_two(value.hour)}:${_two(value.minute)}';
}

String _formatTime(DateTime value) {
  return '${_two(value.hour)}:${_two(value.minute)}';
}

String _two(int value) => value.toString().padLeft(2, '0');
