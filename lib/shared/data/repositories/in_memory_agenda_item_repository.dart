import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/app/app_bootstrap.dart';
import 'package:huajuan_agenda/core/perf/startup_perf_probe.dart';
import 'package:huajuan_agenda/features/settings/domain/providers/settings_state_providers.dart';
import 'package:huajuan_agenda/shared/data/mappers/agenda_item_storage_mapper.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';
import 'package:huajuan_agenda/shared/domain/entities/item_draft.dart';
import 'package:huajuan_agenda/shared/domain/repositories/agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/enums/item_type.dart';
import 'package:huajuan_agenda/shared/value_objects/date_time_range.dart';
import 'package:shared_preferences/shared_preferences.dart';

final agendaItemsBootstrapProvider = Provider<List<AgendaItem>>((ref) {
  return const [];
});

class InMemoryAgendaItemRepository extends Notifier<List<AgendaItem>>
    implements AgendaItemRepository {
  static const _hydrateChunkSize = 200;
  static const _windowWeekStoragePrefix = 'agenda.items.window.week:';
  static const _windowMonthStoragePrefix = 'agenda.items.window.month:';

  var _idSeed = 0;
  var _hasMutated = false;
  var _hydratedMinimal = false;
  var _hydratedFull = false;
  final Set<String> _loadedWindowKeys = <String>{};
  final Set<String> _loadingWindowKeys = <String>{};

  @override
  List<AgendaItem> build() {
    final items = ref.read(agendaItemsBootstrapProvider);
    _idSeed = items.length;
    _hasMutated = false;
    _hydratedMinimal = false;
    _hydratedFull = false;
    _loadedWindowKeys.clear();
    _loadingWindowKeys.clear();
    return items;
  }

  @override
  List<AgendaItem> get items => state;

  @override
  AgendaItem? findById(String id) {
    for (final item in state) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  List<AgendaItem> findByRange(DateTimeRangeValue range) {
    return [
      for (final item in state)
        if (_matchesRange(item, range)) item,
    ];
  }

  @override
  Future<AgendaItem> createItem(
    ItemDraft draft, {
    bool isImportant = false,
  }) async {
    _hasMutated = true;
    final now = DateTime.now();
    final nextOrder = state.isEmpty
        ? 0.0
        : state
                .map((item) => item.manualOrder)
                .reduce((value, element) => value > element ? value : element) +
            1;
    final item = _normalizeCompletionByType(
      AgendaItem.fromDraft(
      id: 'item_${_idSeed++}',
      draft: draft,
      createdAt: now,
      manualOrder: nextOrder,
      isImportant: isImportant,
      ),
    );
    state = [...state, item];
    await _persist();
    return item;
  }

  @override
  Future<AgendaItem?> updateItem(
    String id,
    ItemDraft draft, {
    bool? isImportant,
  }) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    _hasMutated = true;
    final current = state[index];
    final updated = _normalizeCompletionByType(current.copyWith(
      type: draft.type,
      title: draft.title.trim(),
      details: draft.details.trim(),
      location: draft.location.trim(),
      color: draft.color,
      reminder: draft.reminder,
      repeatRule: draft.repeatRule,
      scheduleDetails: draft.scheduleDetails,
      taskDetails: draft.taskDetails,
      memoDetails: draft.memoDetails,
      courseDetails: draft.courseDetails,
      isImportant: isImportant ?? current.isImportant,
      updatedAt: DateTime.now(),
    ));
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    await _persist();
    return updated;
  }

  @override
  Future<void> deleteItem(String id) async {
    _hasMutated = true;
    state = state.where((item) => item.id != id).toList(growable: false);
    await _persist();
  }

  @override
  Future<AgendaItem?> toggleCompleted(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    _hasMutated = true;
    final current = state[index];
    if (!current.supportsManualCompletion) {
      return current;
    }
    final completed = !current.isCompleted;
    final updated = current.copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
      clearCompletedAt: !completed,
      updatedAt: DateTime.now(),
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    await _persist();
    return updated;
  }

  @override
  Future<AgendaItem?> toggleImportant(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index < 0) {
      return null;
    }

    _hasMutated = true;
    final current = state[index];
    if (current.type == ItemType.course) {
      return current;
    }
    final updated = current.copyWith(
      isImportant: !current.isImportant,
      updatedAt: DateTime.now(),
    );
    state = [
      ...state.take(index),
      updated,
      ...state.skip(index + 1),
    ];
    await _persist();
    return updated;
  }

  @override
  Future<void> reorderItems(List<String> orderedIds) async {
    _hasMutated = true;
    final orderMap = <String, double>{};
    for (var index = 0; index < orderedIds.length; index++) {
      orderMap[orderedIds[index]] = index.toDouble();
    }

    state = [
      for (final item in state)
        item.copyWith(
          manualOrder: orderMap[item.id] ?? item.manualOrder,
          updatedAt: DateTime.now(),
        ),
    ];
    await _persist();
  }

  Future<void> replaceItemsByIdPrefix({
    required String idPrefix,
    required List<AgendaItem> items,
  }) async {
    _hasMutated = true;
    final preservedItems = [
      for (final item in state)
        if (!item.id.startsWith(idPrefix)) item,
    ];
    state = [
      ...preservedItems,
      ...items,
    ];
    _idSeed = state.length;
    await _persist();
  }

  void hydrateFromBootstrap(List<AgendaItem> items) {
    if (_hydratedFull || _hydratedMinimal) {
      return;
    }
    if (_hasMutated || state.isNotEmpty) {
      return;
    }
    _hydratedMinimal = true;
    _hydratedFull = true;
    state = items;
    _idSeed = items.length;
  }

  Future<void> hydrateMinimalFromSerializedBootstrap(
    List<Map<String, dynamic>> itemsJson,
  ) async {
    if (_hydratedMinimal) {
      return;
    }
    _hydratedMinimal = true;
    if (_hasMutated || itemsJson.isEmpty) {
      return;
    }

    final hydratedItems = await _decodeItemsFromJson(itemsJson);
    if (hydratedItems.isEmpty) {
      return;
    }
    state = hydratedItems;
    _idSeed = hydratedItems.length;
  }

  Future<void> hydrateRemainingFromSerializedBootstrap(
    List<Map<String, dynamic>> itemsJson,
  ) async {
    if (_hydratedFull) {
      return;
    }
    _hydratedFull = true;
    if (_hasMutated || state.isNotEmpty || itemsJson.isEmpty) {
      if (_hasMutated || itemsJson.isEmpty) {
        return;
      }
      // state 非空代表此前有最小数据，允许继续全量覆盖。
    }

    final hydratedItems = await _decodeItemsFromJson(itemsJson);
    if (hydratedItems.isEmpty) {
      return;
    }
    state = hydratedItems;
    _idSeed = hydratedItems.length;
  }

  Future<void> hydrateFromSerializedBootstrap(List<Map<String, dynamic>> itemsJson) async {
    await hydrateRemainingFromSerializedBootstrap(itemsJson);
  }

  Future<List<AgendaItem>> _decodeItemsFromJson(List<Map<String, dynamic>> itemsJson) async {
    final hydratedItems = <AgendaItem>[];
    for (var index = 0; index < itemsJson.length; index += _hydrateChunkSize) {
      final end = (index + _hydrateChunkSize).clamp(0, itemsJson.length);
      final chunk = itemsJson.sublist(index, end);
      for (final itemJson in chunk) {
        final item = AgendaItemStorageMapper.fromJson(itemJson);
        if (item != null) {
          hydratedItems.add(item);
        }
      }
      if (end < itemsJson.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    return hydratedItems;
  }

  Future<void> _persist() {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs == null) {
      return Future<void>.value();
    }
    final allItemsJson = [
      for (final item in state) AgendaItemStorageMapper.toJson(item),
    ];
    final weekStart = _currentWeekStart();
    final weekEndExclusive = weekStart.add(const Duration(days: 7));
    final currentWeekItemsJson = [
      for (final item in state)
        if (_belongsToCurrentWeek(item, weekStart: weekStart, weekEndExclusive: weekEndExclusive))
          AgendaItemStorageMapper.toJson(item),
    ];
    final pendingWrites = <Future<bool>>[
      prefs.setString(
        AppBootstrapStorageKeys.agendaItems,
        jsonEncode(allItemsJson),
      ),
      prefs.setString(
        AppBootstrapStorageKeys.agendaItemsCurrentWeek,
        jsonEncode(currentWeekItemsJson),
      ),
      prefs.setString(
        AppBootstrapStorageKeys.agendaItemsCurrentWeekStart,
        weekStart.toIso8601String(),
      ),
    ];

    for (final windowKey in _loadedWindowKeys) {
      final range = _resolveWindowRange(windowKey);
      if (range == null) {
        continue;
      }
      final itemsJson = [
        for (final item in state)
          if (_belongsToWindow(
            item,
            startInclusive: range.start,
            endExclusive: range.end,
          ))
            AgendaItemStorageMapper.toJson(item),
      ];
      pendingWrites.add(
        prefs.setString(
          _windowStorageKey(windowKey),
          jsonEncode(itemsJson),
        ),
      );
    }
    return Future.wait(pendingWrites).then((_) {});
  }

  bool hasLoadedWindow(String windowKey) {
    return _loadedWindowKeys.contains(windowKey);
  }

  Future<void> loadWindowFromStorage({
    required String windowKey,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    final probe = StartupPerfProbe.instance;
    final loadSeq = probe.nextSequence('home_window_storage_load');
    final loadTimer = Stopwatch()..start();
    probe.mark(
      'home_window_storage_load_start',
      extras: <String, Object?>{
        'load_seq': loadSeq,
        'window_key': windowKey,
        'start': startInclusive.toIso8601String(),
        'end': endExclusive.toIso8601String(),
      },
    );
    if (_loadedWindowKeys.contains(windowKey) || _loadingWindowKeys.contains(windowKey)) {
      probe.mark(
        'home_window_storage_load_skipped',
        extras: <String, Object?>{
          'load_seq': loadSeq,
          'window_key': windowKey,
          'already_loaded': _loadedWindowKeys.contains(windowKey),
          'already_loading': _loadingWindowKeys.contains(windowKey),
          'elapsed_ms': (loadTimer.elapsedMicroseconds / 1000).toStringAsFixed(3),
        },
      );
      return;
    }
    _loadingWindowKeys.add(windowKey);
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      if (prefs == null) {
        _loadedWindowKeys.add(windowKey);
        // 触发依赖刷新，让 Home 看到窗口已加载状态。
        state = [...state];
        probe.mark(
          'home_window_storage_load_end',
          extras: <String, Object?>{
            'load_seq': loadSeq,
            'window_key': windowKey,
            'reason': 'preferences_null',
            'loaded_items': 0,
            'state_items': state.length,
            'elapsed_ms': (loadTimer.elapsedMicroseconds / 1000).toStringAsFixed(3),
          },
        );
        return;
      }

      final cacheStorageKeys = _candidateCacheStorageKeys(
        prefs: prefs,
        windowKey: windowKey,
      );
      String? cacheRaw;
      String? hitStorageKey;
      final cacheReadStartUs = loadTimer.elapsedMicroseconds;
      for (final key in cacheStorageKeys) {
        final raw = prefs.getString(key);
        if (raw != null && raw.isNotEmpty) {
          cacheRaw = raw;
          hitStorageKey = key;
          break;
        }
      }
      final cacheReadEndUs = loadTimer.elapsedMicroseconds;
      probe.mark(
        'home_window_storage_cache_lookup',
        extras: <String, Object?>{
          'load_seq': loadSeq,
          'window_key': windowKey,
          'cache_hit': cacheRaw != null,
          'storage_key': hitStorageKey,
          'lookup_keys': cacheStorageKeys.length,
          'read_cost_ms': ((cacheReadEndUs - cacheReadStartUs) / 1000).toStringAsFixed(3),
        },
      );

      final windowItems = <AgendaItem>[];
      var source = 'cache';
      var fallbackPath = false;

      if (cacheRaw != null) {
        windowItems.addAll(
          await _decodeAndFilterWindowItems(
            raw: cacheRaw,
            startInclusive: startInclusive,
            endExclusive: endExclusive,
          ),
        );
      } else {
        source = 'all_items_fallback';
        fallbackPath = true;
        final readStartUs = loadTimer.elapsedMicroseconds;
        final raw = prefs.getString(AppBootstrapStorageKeys.agendaItems);
        final readEndUs = loadTimer.elapsedMicroseconds;
        probe.mark(
          'home_window_storage_raw_read',
          extras: <String, Object?>{
            'load_seq': loadSeq,
            'window_key': windowKey,
            'raw_length': raw?.length ?? 0,
            'read_cost_ms': ((readEndUs - readStartUs) / 1000).toStringAsFixed(3),
          },
        );
        if (raw != null && raw.isNotEmpty) {
          windowItems.addAll(
            await _decodeAndFilterWindowItems(
              raw: raw,
              startInclusive: startInclusive,
              endExclusive: endExclusive,
            ),
          );
        }
      }

      _loadedWindowKeys.add(windowKey);
      if (windowItems.isNotEmpty) {
        final mergeStartUs = loadTimer.elapsedMicroseconds;
        final byId = <String, AgendaItem>{
          for (final item in state) item.id: item,
        };
        for (final item in windowItems) {
          byId[item.id] = item;
        }
        state = byId.values.toList(growable: false);
        _idSeed = state.length;
        final mergeEndUs = loadTimer.elapsedMicroseconds;
        probe.mark(
          'home_window_storage_merge_done',
          extras: <String, Object?>{
            'load_seq': loadSeq,
            'window_key': windowKey,
            'loaded_items': windowItems.length,
            'state_items': state.length,
            'merge_cost_ms': ((mergeEndUs - mergeStartUs) / 1000).toStringAsFixed(3),
          },
        );
      } else {
        // 窗口内无数据时也要刷新一次，避免页面永远等待“加载完成”。
        state = [...state];
      }
      if (fallbackPath) {
        final windowItemsJson = [
          for (final item in windowItems) AgendaItemStorageMapper.toJson(item),
        ];
        await prefs.setString(
          _windowStorageKey(windowKey),
          jsonEncode(windowItemsJson),
        );
      }
      probe.mark(
        'home_window_storage_load_end',
        extras: <String, Object?>{
          'load_seq': loadSeq,
          'window_key': windowKey,
          'reason': 'success',
          'source': source,
          'fallback_path': fallbackPath,
          'cache_storage_key': hitStorageKey,
          'loaded_items': windowItems.length,
          'state_items': state.length,
          'loaded_window_count': _loadedWindowKeys.length,
          'elapsed_ms': (loadTimer.elapsedMicroseconds / 1000).toStringAsFixed(3),
        },
      );
    } finally {
      _loadingWindowKeys.remove(windowKey);
    }
  }

  List<String> _candidateCacheStorageKeys({
    required SharedPreferences prefs,
    required String windowKey,
  }) {
    final keys = <String>[
      _windowStorageKey(windowKey),
    ];
    if (windowKey.startsWith('week:')) {
      final weekStart = windowKey.substring('week:'.length);
      final legacyWeekStart = prefs.getString(AppBootstrapStorageKeys.agendaItemsCurrentWeekStart);
      if (legacyWeekStart == weekStart) {
        keys.add(AppBootstrapStorageKeys.agendaItemsCurrentWeek);
      }
    }
    return keys;
  }

  Future<List<AgendaItem>> _decodeAndFilterWindowItems({
    required String raw,
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) async {
    List<dynamic> decoded;
    try {
      final json = jsonDecode(raw);
      decoded = json is List<dynamic> ? json : const [];
    } catch (_) {
      decoded = const [];
    }
    if (decoded.isEmpty) {
      return const [];
    }

    final windowItems = <AgendaItem>[];
    for (var index = 0; index < decoded.length; index += _hydrateChunkSize) {
      final end = (index + _hydrateChunkSize).clamp(0, decoded.length);
      for (final itemRaw in decoded.sublist(index, end)) {
        if (itemRaw is! Map<Object?, Object?>) {
          continue;
        }
        final map = itemRaw.map(
          (key, value) => MapEntry(key is String ? key : key.toString(), value),
        );
        final parsed = AgendaItemStorageMapper.fromJson(map);
        if (parsed == null) {
          continue;
        }
        if (!_belongsToWindow(
          parsed,
          startInclusive: startInclusive,
          endExclusive: endExclusive,
        )) {
          continue;
        }
        windowItems.add(parsed);
      }
      if (end < decoded.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    return windowItems;
  }

  String _windowStorageKey(String windowKey) {
    if (windowKey.startsWith('week:')) {
      return '$_windowWeekStoragePrefix${windowKey.substring('week:'.length)}';
    }
    if (windowKey.startsWith('month:')) {
      return '$_windowMonthStoragePrefix${windowKey.substring('month:'.length)}';
    }
    return '$_windowWeekStoragePrefix$windowKey';
  }

  _WindowRange? _resolveWindowRange(String windowKey) {
    if (windowKey.startsWith('week:')) {
      final start = DateTime.tryParse(windowKey.substring('week:'.length));
      if (start == null) {
        return null;
      }
      return _WindowRange(
        start: start,
        end: start.add(const Duration(days: 7)),
      );
    }
    if (windowKey.startsWith('month:')) {
      final month = windowKey.substring('month:'.length);
      final parts = month.split('-');
      if (parts.length != 2) {
        return null;
      }
      final year = int.tryParse(parts[0]);
      final mon = int.tryParse(parts[1]);
      if (year == null || mon == null || mon < 1 || mon > 12) {
        return null;
      }
      final start = DateTime(year, mon, 1);
      return _WindowRange(
        start: start,
        end: DateTime(year, mon + 1, 1),
      );
    }
    return null;
  }

  DateTime _currentWeekStart() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: today.weekday - DateTime.monday));
  }

  bool _belongsToCurrentWeek(
    AgendaItem item, {
    required DateTime weekStart,
    required DateTime weekEndExclusive,
  }) {
    return _belongsToWindow(
      item,
      startInclusive: weekStart,
      endExclusive: weekEndExclusive,
    );
  }

  bool _belongsToWindow(
    AgendaItem item, {
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    if (item.type != ItemType.task &&
        item.type != ItemType.schedule &&
        item.type != ItemType.course) {
      return false;
    }
    return item.endAt.isAfter(startInclusive) && item.startAt.isBefore(endExclusive);
  }

  bool _matchesRange(AgendaItem item, DateTimeRangeValue range) {
    return switch (item.type) {
      ItemType.memo =>
        !item.targetDate.isBefore(range.start) &&
            !item.targetDate.isAfter(range.end),
      _ => item.endAt.isAfter(range.start) && item.startAt.isBefore(range.end),
    };
  }

  AgendaItem _normalizeCompletionByType(AgendaItem item) {
    final normalized = item.type == ItemType.course
        ? item.copyWith(isImportant: false)
        : item;
    if (normalized.supportsManualCompletion) {
      return normalized;
    }
    return normalized.copyWith(
      isCompleted: false,
      clearCompletedAt: true,
    );
  }
}

class _WindowRange {
  const _WindowRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}

final agendaItemRepositoryProvider =
    NotifierProvider<InMemoryAgendaItemRepository, List<AgendaItem>>(
  InMemoryAgendaItemRepository.new,
);

final agendaItemRepositoryNotifierProvider = Provider<AgendaItemRepository>((ref) {
  return ref.read(agendaItemRepositoryProvider.notifier);
});

final agendaItemByIdProvider = Provider.family<AgendaItem?, String>((ref, id) {
  final repository = ref.watch(agendaItemRepositoryProvider.notifier);
  return repository.findById(id);
});
