import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'package:flutter_qjs_next/quickjs/quickjs_runtime2.dart';
import 'package:flutter_qjs_next/web/web_apis.dart';
import '../domain/plugin_error.dart';

typedef PluginCapability =
    Future<Object?> Function(String method, List<dynamic> arguments);

/// One persistent engine per view. No web APIs, modules or application objects.
class PluginEngine {
  Isolate? _isolate;
  SendPort? _worker;
  ReceivePort? _events;
  StreamSubscription<dynamic>? _subscription;
  Completer<Object?>? _pending;
  PluginCapability? _capability;
  int _request = 0;
  bool _closed = false;
  Timer? _shutdownTimer;
  final _terminated = Completer<bool>();
  Future<bool> get terminated => _terminated.future;
  static int _active = 0;
  static final _perPlugin = <String, int>{};
  String? _pluginId;
  bool get closed => _closed;

  Future<void> start(String pluginId, String script) async {
    if (!Platform.isAndroid) {
      throw const PluginException(
        'UNSUPPORTED_RUNTIME',
        '外部插件运行目前支持 Android；本平台仍可管理内置插件',
      );
    }
    if (_closed) throw const PluginException('PLUGIN_DISABLED', '运行环境已关闭');
    if (_active >= 4 || (_perPlugin[pluginId] ?? 0) >= 3) {
      throw const PluginException('RESOURCE_LIMIT_EXCEEDED', '请先关闭一个插件页面');
    }
    _active++;
    _perPlugin[pluginId] = (_perPlugin[pluginId] ?? 0) + 1;
    _pluginId = pluginId;
    final ready = Completer<void>();
    _events = ReceivePort();
    _subscription = _events!.listen((dynamic message) async {
      if (message is SendPort) {
        _worker = message;
        if (_closed) _worker!.send({'type': 'close'});
        if (!ready.isCompleted) ready.complete();
        return;
      }
      if (message is Map && message['type'] == 'closed') {
        _finishShutdown(true);
        return;
      }
      if (message is! Map || _closed) return;
      if (message['type'] == 'startupError') {
        if (!ready.isCompleted) {
          ready.completeError(
            const PluginException('UNSUPPORTED_RUNTIME', '此平台无法启动插件执行环境'),
          );
        }
        return;
      }
      if (message['request'] != _request) return;
      if (message['type'] == 'host') {
        final request = _request;
        try {
          final value = await _capability!(
            message['method'] as String,
            message['args'] as List<dynamic>,
          );
          if (!_closed && request == _request) {
            _worker?.send({
              'type': 'reply',
              'request': request,
              'id': message['id'],
              'value': value,
            });
          }
        } catch (e) {
          if (!_closed && request == _request) {
            _worker?.send({
              'type': 'reply',
              'request': request,
              'id': message['id'],
              'error': e is PluginException ? e.code : 'SCRIPT_ERROR',
            });
          }
        }
      } else if (message['type'] == 'done') {
        if (_pending?.isCompleted == false) {
          _pending!.complete(message['value']);
        }
      } else if (message['type'] == 'error') {
        if (_pending?.isCompleted == false) {
          _pending!.completeError(
            PluginException(message['code'] as String, '插件运行失败，请重试或停用该插件'),
          );
        }
      }
    });
    try {
      _isolate = await Isolate.spawn(
        _engineWorker,
        _events!.sendPort,
        errorsAreFatal: true,
        onError: _events!.sendPort,
      );
      if (_closed) {
        _beginShutdown();
        await ready.future.timeout(const Duration(seconds: 10));
        throw const PluginException('PLUGIN_DISABLED', '插件启动已取消');
      }
      await ready.future.timeout(const Duration(seconds: 10));
      await _execute(
        {'type': 'load', 'script': script},
        (_, _) async =>
            throw const PluginException('PERMISSION_DENIED', '加载时不能访问宿主'),
      );
    } catch (_) {
      close();
      if (_isolate == null) _finishShutdown(true);
      rethrow;
    }
  }

  Future<Object?> invoke(
    String method,
    Map<String, dynamic> request,
    Map<String, dynamic> context,
    PluginCapability capability,
  ) => _execute({
    'type': 'call',
    'method': method,
    'payload': request,
    'context': context,
  }, capability);

  Future<Object?> _execute(
    Map<String, dynamic> command,
    PluginCapability capability,
  ) async {
    if (_closed || _worker == null) {
      throw const PluginException('PLUGIN_DISABLED', '插件执行器已关闭');
    }
    if (_pending != null) {
      throw const PluginException('RESOURCE_LIMIT_EXCEEDED', '请等待上一个操作结束');
    }
    final pending = Completer<Object?>();
    _pending = pending;
    _capability = capability;
    _request++;
    _worker!.send({...command, 'request': _request});
    try {
      return await pending.future.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      close();
      throw const PluginException('EXECUTION_TIMEOUT', '插件执行超时，已停止');
    } on PluginException {
      close();
      rethrow;
    } finally {
      _pending = null;
      _capability = null;
    }
  }

  void close() {
    if (_closed) return;
    _closed = true;
    if (_isolate != null) {
      _beginShutdown();
    } else if (_pluginId == null) {
      _finishShutdown(true);
    }
    if (_pending?.isCompleted == false) {
      _pending!.completeError(
        const PluginException('PLUGIN_DISABLED', '插件页面已关闭'),
      );
    }
  }

  void _beginShutdown() {
    if (_shutdownTimer != null || _terminated.isCompleted) return;
    _worker?.send({'type': 'close'});
    _shutdownTimer = Timer(const Duration(seconds: 1), () {
      _isolate?.kill(priority: Isolate.immediate);
      // Quarantine its capacity if native release was not acknowledged. Killing
      // a Dart isolate alone cannot prove that its native heap has been freed.
      _finishShutdown(false);
    });
  }

  void _finishShutdown(bool freed) {
    if (_terminated.isCompleted) return;
    _shutdownTimer?.cancel();
    _subscription?.cancel();
    _events?.close();
    final pluginId = _pluginId;
    if (freed && pluginId != null) {
      _active--;
      _perPlugin[pluginId] = (_perPlugin[pluginId] ?? 1) - 1;
    }
    _pluginId = null;
    _terminated.complete(freed);
  }
}

void _engineWorker(SendPort parent) async {
  QuickJsRuntime2? engine;
  final commands = ReceivePort();
  try {
    engine = QuickJsRuntime2(
      timeout: 100,
      memoryLimit: 32 * 1024 * 1024,
      stackSize: 1024 * 1024,
      autoExecutePendingJobs: false,
      webApis: const JsWebApis.none(),
      hostPromiseRejectionHandler: (_) {},
    );
    final qjs = engine;
    int request = 0;
    int hostCalls = 0;
    var busy = false;
    final cpu = Stopwatch();
    final wall = Stopwatch();
    Timer? pump;
    dynamic evaluate(String script) {
      cpu.start();
      try {
        final result = qjs.evaluate(script);
        if (result.isError) throw StateError(result.stringResult);
        return result.rawResult;
      } finally {
        cpu.stop();
      }
    }

    void fail(Object error) {
      busy = false;
      pump?.cancel();
      final detail = error.toString().toLowerCase();
      final code = detail.contains('interrupt') || detail.contains('timeout')
          ? 'EXECUTION_TIMEOUT'
          : detail.contains('memory') || detail.contains('alloc')
          ? 'MEMORY_LIMIT_EXCEEDED'
          : detail.contains('invalid_view')
          ? 'INVALID_VIEW'
          : 'SCRIPT_ERROR';
      parent.send({'type': 'error', 'request': request, 'code': code});
    }

    void tick() {
      if (!busy) return;
      try {
        if (cpu.elapsedMilliseconds >= 500 ||
            wall.elapsedMilliseconds >= 15000) {
          throw StateError('timeout');
        }
        for (var i = 0; i < 32 && qjs.hasPendingJobs; i++) {
          cpu.start();
          final status = qjs.executePendingJob();
          cpu.stop();
          if (status < 0) throw StateError('script job failed');
          if (cpu.elapsedMilliseconds >= 500) throw StateError('timeout');
        }
        final packetText = evaluate('__luo.poll()') as String;
        if (packetText.length > 512 * 1024) {
          throw StateError('RESOURCE_LIMIT_EXCEEDED');
        }
        final packet = jsonDecode(packetText) as Map<String, dynamic>;
        final host = packet['host'];
        if (host is! List || host.length > 16 || hostCalls + host.length > 32) {
          throw StateError('RESOURCE_LIMIT_EXCEEDED');
        }
        hostCalls += host.length;
        for (final raw in host) {
          if (raw is! Map ||
              raw.keys.any((k) => !{'id', 'method', 'args'}.contains(k)) ||
              raw['id'] is! int ||
              raw['method'] is! String ||
              raw['args'] is! List) {
            throw StateError('INVALID_INPUT');
          }
          parent.send({
            'type': 'host',
            'request': request,
            'id': raw['id'],
            'method': raw['method'],
            'args': raw['args'],
          });
        }
        if (packet['done'] == true) {
          busy = false;
          pump?.cancel();
          if (packet['error'] != null) throw StateError(packet['error']);
          parent.send({
            'type': 'done',
            'request': request,
            'value': packet['value'],
          });
        }
      } catch (e) {
        fail(e);
      }
    }

    evaluate(_bridgeSource);
    parent.send(commands.sendPort);
    await for (final dynamic raw in commands) {
      final message = raw as Map;
      if (message['type'] == 'close') {
        pump?.cancel();
        break;
      }
      try {
        if (message['type'] == 'reply') {
          if (busy && message['request'] == request) {
            evaluate('__luo.reply(${jsonEncode(message)});void 0');
          }
          continue;
        }
        request = message['request'] as int;
        hostCalls = 0;
        cpu.reset();
        wall.reset();
        wall.start();
        busy = true;
        if (message['type'] == 'load') {
          evaluate('${message['script']}\n;void 0;');
          evaluate('__luo.check();void 0');
          busy = false;
          parent.send({'type': 'done', 'request': request, 'value': null});
        } else {
          evaluate('__luo.start(${jsonEncode(message)});void 0');
          pump = Timer.periodic(const Duration(milliseconds: 1), (_) => tick());
          tick();
        }
      } catch (e) {
        fail(e);
      }
    }
  } catch (_) {
    parent.send({'type': 'startupError'});
  } finally {
    commands.close();
    try {
      engine?.dispose();
      parent.send({'type': 'closed'});
    } catch (_) {}
  }
}

const _bridgeSource = r'''
(() => {
  const stringify = JSON.stringify.bind(JSON), parse = JSON.parse.bind(JSON);
  const keys = Object.keys, finite = Number.isFinite, isArray = Array.isArray;
  const apply = Reflect.apply, define = Object.defineProperty, freeze = Object.freeze;
  const SetClass = Set, MapClass = Map, ErrorClass = Error, getPrototypeOf = Object.getPrototypeOf;
  const ObjectPrototype = Object.prototype, ArrayPrototype = Array.prototype;
  const PromiseClass = Promise;
  // The runtime's generic Dart channel is outside the validated SPI bridge.
  define(globalThis, 'sendMessage', {value:undefined, writable:false, configurable:false});
  // A plugin may define its own prototypes, but cannot rewrite bridge intrinsics.
  for (const intrinsic of [Object, Array, Map, Set, Promise, String, Number, Boolean, Function, Error]) {
    freeze(intrinsic.prototype); freeze(intrinsic);
  }
  let pending = new MapClass(), queue = [], next = 0, calls = 0, done = false, value = null, error = null, active = false;
  function json(data, limit) {
    const seen = new SetClass();
    function visit(v, depth) {
      if (depth > 16) throw Error('INVALID_VIEW depth');
      if (v === null || typeof v === 'string' || typeof v === 'boolean') return;
      if (typeof v === 'number' && finite(v)) return;
      if (typeof v !== 'object' || seen.has(v)) throw Error('INVALID_VIEW JSON');
      const prototype = getPrototypeOf(v);
      if ((prototype !== ObjectPrototype && prototype !== ArrayPrototype && prototype !== null) || typeof v.toJSON === 'function') throw new ErrorClass('INVALID_VIEW prototype');
      seen.add(v);
      for (const key of keys(v)) visit(v[key], depth + 1);
      seen.delete(v);
    }
    visit(data, 0);
    const text = stringify(data);
    if (text.length > limit) throw Error('INVALID_VIEW size');
    return text;
  }
  function host(method, args) {
    if (!active || ++calls > 32 || pending.size >= 16) return PromiseClass.reject(Error('RESOURCE_LIMIT_EXCEEDED'));
    const data = parse(json(args, 256 * 1024));
    const id = ++next;
    return new PromiseClass((resolve, reject) => { pending.set(id, {resolve,reject}); queue.push({id,method,args:data}); });
  }
  const api = freeze({
    storage: freeze({get: key => host('storage.get',[key]), set: (key,value) => host('storage.set',[key,value]), remove: key => host('storage.remove',[key])}),
    http: freeze({request: request => host('http.request',[request])}),
    openView: id => host('openView',[id]),
    log: (level,message) => { /* Logs deliberately contain no plugin-supplied data. */ }
  });
  function check() {
    const p = globalThis.luotopiaPlugin;
    if (!p || p.apiVersion !== 1 || typeof p.render !== 'function' || typeof p.onAction !== 'function') throw Error('Invalid provider');
  }
  define(globalThis, '__luo', {value: freeze({
    check,
    start(m) {
      pending.clear(); queue = []; calls = 0; done = false; value = null; error = null; active = true;
      const p = globalThis.luotopiaPlugin, context = freeze({...m.context, host: api});
      PromiseClass.resolve().then(() => {
        const fn = p[m.method];
        if (fn === undefined && (m.method === 'activate' || m.method === 'deactivate')) return null;
        return apply(fn, p, m.method === 'activate' ? [context] : m.method === 'deactivate' ? [] : [m.payload, context]);
      }).then(result => {
        value = result === undefined ? null : parse(json(result, 256 * 1024)); done = true; active = false;
      }, () => { error = 'SCRIPT_ERROR'; done = true; active = false; }).catch(() => {error = 'INVALID_VIEW'; done = true; active = false;});
    },
    reply(m) { const p = pending.get(m.id); if (!p) return; pending.delete(m.id); m.error ? p.reject(Error(m.error)) : p.resolve(m.value); },
    poll() { const packet = json({host:queue, done:done && pending.size === 0, value, error}, 2 * 1024 * 1024); queue = []; return packet; }
  }), writable:false, configurable:false});
})();void 0;
''';
