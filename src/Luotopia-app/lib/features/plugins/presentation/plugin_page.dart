import 'package:luotopia/features/whu_auth/whu_auth.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/data/repositories/in_memory_course_timetable_repository.dart';
import '../runtime/plugin_school_timetable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;
import 'package:luotopia/shared/presentation/widgets/app_bar_builder.dart';
import '../application/plugin_manager.dart';
import '../domain/plugin_error.dart';
import '../domain/plugin_view.dart';
import '../runtime/plugin_session.dart';
import 'plugin_view_content.dart';

class PluginPage extends ConsumerStatefulWidget {
  const PluginPage({
    super.key,
    required this.pluginId,
    required this.contributionId,
    required this.viewId,
  });
  final String pluginId, contributionId, viewId;
  @override
  ConsumerState<PluginPage> createState() => _PluginPageState();
}

class _PluginPageState extends ConsumerState<PluginPage> {
  PluginSession? _session;
  PluginResult? _result;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void didUpdateWidget(PluginPage old) {
    super.didUpdateWidget(old);
    if (old.pluginId != widget.pluginId ||
        old.contributionId != widget.contributionId ||
        old.viewId != widget.viewId) {
      _open();
    }
  }

  Future<void> _open() async {
    _session?.dispose();
    if (!mounted) return;
    setState(() {
      _error = null;
      _result = null;
    });
    try {
      final manager = ref.read(pluginManagerProvider);
      final c = manager.contribution(
        '${widget.pluginId}/${widget.contributionId}',
      );
      manager.checkAccess(c.key, widget.viewId);
      final session = PluginSession(
        manager,
        c,
        widget.viewId,
        schoolTimetable: PluginSchoolTimetable(
          isAuthenticated: () => ref.read(whuAuthProvider).isAuthenticated,
          ownsTimetable: (id) => ref
              .read(schoolTimetableProvenanceProvider)
              .timetableIds
              .contains(id),
          store: () => ref.read(courseTimetableRepositoryProvider),
          items: () => ref.read(agendaItemRepositoryProvider),
        ),
        locale: Localizations.localeOf(context).languageCode == 'zh'
            ? 'zh'
            : 'en',
        theme: ui.Theme.of(context).brightness == Brightness.dark
            ? 'dark'
            : 'light',
      );
      _session = session;
      final result = await session.open();
      if (mounted && identical(_session, session)) {
        setState(() => _result = result);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is PluginException ? e.toString() : '插件启动失败，请重试',
        );
      }
    }
  }

  Future<void> _action(String id, Map<String, dynamic> input) async {
    final session = _session!;
    final result = await session.action(id, input);
    if (!mounted || !identical(session, _session)) return;
    if (session.nextView != null) {
      context.go(
        '/plugins/${widget.pluginId}/${widget.contributionId}/${session.nextView}',
      );
    } else {
      setState(() => _result = result);
    }
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(schoolTimetableProvenanceProvider, (previous, next) {
      if (previous != null && !identical(previous, next)) {
        _session?.dispose();
        setState(() {
          _result = null;
          _error = '教务账户状态已变化，请重新打开插件并导入课表。';
        });
      }
    });
    ref.watch(pluginManagerProvider);
    final error =
        _error ??
        (_session?.engine.closed == true ? '插件配置或状态已变化，请重新打开。' : null);
    return ui.Scaffold(
      headers: [
        buildSecondaryAppBar(context, title: _result?.view.title ?? '插件'),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: error != null
            ? Column(
                children: [
                  Text(error),
                  const SizedBox(height: 16),
                  ui.SecondaryButton(onPressed: _open, child: const Text('重试')),
                ],
              )
            : _result == null
            ? const Center(child: CircularProgressIndicator())
            : PluginViewContent(
                key: ValueKey(
                  '${widget.pluginId}/${widget.contributionId}/${widget.viewId}',
                ),
                view: _result!.view,
                onAction: _action,
              ),
      ),
    );
  }
}
