import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/exceptions/empty_classroom_exception.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/models/empty_classroom.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/use_cases/build_empty_classroom_agenda_draft.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/use_cases/find_empty_classroom_conflicts.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/use_cases/format_empty_classroom_sections.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/domain/use_cases/group_empty_classroom_sections.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/presentation/viewmodels/empty_classroom_view_model.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/presentation/widgets/empty_classroom_card.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/presentation/widgets/empty_classroom_filter_card.dart';
import 'package:luotopia/features/pages/campus/sub_apps/empty_classroom/presentation/widgets/empty_classroom_status_views.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class EmptyClassroomPage extends ConsumerStatefulWidget {
  const EmptyClassroomPage({super.key});

  @override
  ConsumerState<EmptyClassroomPage> createState() => _EmptyClassroomPageState();
}

class _EmptyClassroomPageState extends ConsumerState<EmptyClassroomPage> {
  static const _formatSections = FormatEmptyClassroomSectionsUseCase();
  static const _groupSections = GroupEmptyClassroomSectionsUseCase();
  static const _draftBuilder = BuildEmptyClassroomAgendaDraftUseCase();
  static const _findConflicts = FindEmptyClassroomConflictsUseCase();

  final _expandedClassroomKeys = <String>{};
  final _conflictingSectionKeys = <String>{};
  String? _successBannerMessage;
  List<String>? _lastAddedIds;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        _loadInitialDataIfAuthenticated();
      }
    });
  }

  Future<void> _loadInitialDataIfAuthenticated() async {
    final authState = ref.read(whuAuthProvider);
    final state = ref.read(emptyClassroomViewModelProvider);
    if (!authState.isAuthenticated ||
        state.hasLoadedInitialData ||
        state.isInitialLoading) {
      return;
    }
    await ref.read(emptyClassroomViewModelProvider.notifier).loadInitialData();
  }

  Future<void> _query() async {
    setState(() {
      _expandedClassroomKeys.clear();
      _conflictingSectionKeys.clear();
    });
    ref
        .read(emptyClassroomViewModelProvider.notifier)
        .updateConflictingSectionKeys(const {});
    await ref.read(emptyClassroomViewModelProvider.notifier).query();
    if (mounted) {
      setState(_refreshConflicts);
    }
  }

  void _openLogin() {
    context.openSecondary(AppRoutePaths.whuAccount);
  }

  void _toggleExpanded(String key) {
    setState(() {
      if (_expandedClassroomKeys.contains(key)) {
        _expandedClassroomKeys.remove(key);
      } else {
        _expandedClassroomKeys.add(key);
      }
    });
  }

  void _expandAll() {
    final classrooms = ref
        .read(emptyClassroomViewModelProvider)
        .visibleClassrooms;
    setState(() {
      _expandedClassroomKeys.addAll(classrooms.map(_classroomKey));
    });
  }

  void _collapseAll() {
    setState(_expandedClassroomKeys.clear);
  }

  Future<void> _addSingleSection(EmptyClassroom classroom, int section) async {
    final l10n = context.l10n;
    await _addSectionsToAgenda(
      classroom: classroom,
      sections: [section],
      successMessage: l10n.emptyClassroomAddedSingle(classroom.name, section),
    );
  }

  Future<void> _addSectionGroup(
    EmptyClassroom classroom,
    List<int> sections,
  ) async {
    await _addSectionsToAgenda(
      classroom: classroom,
      sections: sections,
      successMessage: '已添加${classroom.name}${_formatSections(sections)}自习',
    );
  }

  Future<void> _addSectionsToAgenda({
    required EmptyClassroom classroom,
    required List<int> sections,
    required String successMessage,
  }) async {
    final draftContext = _draftContext();
    if (draftContext == null) {
      return;
    }

    final now = DateTime.now();
    final agendaItems = ref.read(agendaItemRepositoryProvider);
    final conflicts = _findConflicts(
      agendaItems: agendaItems,
      sections: sections,
      context: draftContext,
      now: now,
    );
    if (conflicts.isNotEmpty) {
      final confirmed = await _confirmConflict(conflicts);
      if (confirmed != true || !mounted) {
        return;
      }
    }

    final repository = ref.read(agendaItemRepositoryProvider.notifier);
    final addedIds = <String>[];
    for (final section in sections) {
      final item = await repository.createItem(
        _draftBuilder(
          classroom: classroom,
          section: section,
          context: draftContext,
          now: now,
        ),
      );
      addedIds.add(item.id);
    }

    if (!mounted) {
      return;
    }
    _lastAddedIds = addedIds;
    _showSuccessBanner(successMessage);
    setState(_refreshConflicts);
  }

  void _showSuccessBanner(String message) {
    setState(() => _successBannerMessage = message);
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted && _successBannerMessage == message) {
        setState(() => _successBannerMessage = null);
      }
    });
  }

  Future<bool?> _confirmConflict(List<int> conflictSections) {
    final l10n = context.l10n;
    final isSingle = conflictSections.length == 1;
    final content = isSingle
        ? l10n.emptyClassroomConflictSingle
        : l10n.emptyClassroomConflictMulti(_sectionText(conflictSections));
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.emptyClassroomConflictTitle),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.emptyClassroomConflictCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.emptyClassroomConflictConfirm),
          ),
        ],
      ),
    );
  }

  EmptyClassroomAgendaDraftContext? _draftContext() {
    final state = ref.read(emptyClassroomViewModelProvider);
    final termInfo = state.termInfo;
    if (termInfo == null) {
      return null;
    }
    return EmptyClassroomAgendaDraftContext(
      termInfo: termInfo,
      selectedWeek: state.selectedWeek,
      selectedWeekDay: state.selectedWeekDay,
    );
  }

  void _refreshConflicts() {
    final draftContext = _draftContext();
    if (draftContext == null) {
      _conflictingSectionKeys.clear();
      ref
          .read(emptyClassroomViewModelProvider.notifier)
          .updateConflictingSectionKeys(const {});
      return;
    }
    final now = DateTime.now();
    final agendaItems = ref.read(agendaItemRepositoryProvider);
    final state = ref.read(emptyClassroomViewModelProvider);
    _conflictingSectionKeys.clear();
    for (final classroom in state.classrooms) {
      final classroomKey = _classroomKey(classroom);
      final conflicts = _findConflicts(
        agendaItems: agendaItems,
        sections: classroom.availableSections,
        context: draftContext,
        now: now,
      );
      for (final section in conflicts) {
        _conflictingSectionKeys.add('$classroomKey|$section');
      }
    }
    ref
        .read(emptyClassroomViewModelProvider.notifier)
        .updateConflictingSectionKeys({..._conflictingSectionKeys});
  }

  void _showActionsSheet() {
    final l10n = context.l10n;
    final state = ref.read(emptyClassroomViewModelProvider);
    final expandedCount = _expandedClassroomKeys.length;
    final totalCount = state.visibleClassrooms.length;
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.emptyClassroomFABTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyClassroomFABExpanded(expandedCount, totalCount),
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.emptyClassroomFABHint,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ui.OutlineButton(
                  onPressed: () {
                    _expandAll();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.emptyClassroomExpandAll),
                ),
                const SizedBox(width: 12),
                ui.OutlineButton(
                  onPressed: () {
                    _collapseAll();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.emptyClassroomCollapseAll),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<WhuAuthState>(whuAuthProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        _loadInitialDataIfAuthenticated();
      }
    });

    final l10n = context.l10n;
    final authState = ref.watch(whuAuthProvider);
    final state = ref.watch(emptyClassroomViewModelProvider);
    final notifier = ref.read(emptyClassroomViewModelProvider.notifier);
    final theme = Theme.of(context);
    final visibleClassroomCount = state.visibleClassrooms.length;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: Text(l10n.emptyClassroomTitle),
        ),
      ],
      child: Stack(
        children: [
          _buildBody(authState: authState, state: state, notifier: notifier),
          if (_successBannerMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 6,
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _successBannerMessage!,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      if (_lastAddedIds != null && _lastAddedIds!.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            final ids = _lastAddedIds;
                            if (ids != null) {
                              final repository = ref.read(
                                agendaItemRepositoryProvider.notifier,
                              );
                              for (final id in ids) {
                                await repository.deleteItem(id);
                              }
                            }
                            if (!mounted) {
                              return;
                            }
                            setState(() {
                              _successBannerMessage = null;
                              _lastAddedIds = null;
                              _refreshConflicts();
                            });
                          },
                          child: Text(
                            l10n.emptyClassroomUndo,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _successBannerMessage = null),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!state.isQuerying)
            Positioned(
              right: 20,
              bottom: 24,
              child: FloatingActionButton(
                heroTag: 'empty-classroom-fab',
                onPressed: visibleClassroomCount == 0
                    ? null
                    : _showActionsSheet,
                backgroundColor: visibleClassroomCount == 0
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
                    : theme.colorScheme.primary,
                foregroundColor: visibleClassroomCount == 0
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                    : theme.colorScheme.onPrimary,
                child: const Icon(Icons.dashboard_customize),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required WhuAuthState authState,
    required EmptyClassroomState state,
    required EmptyClassroomViewModel notifier,
  }) {
    final l10n = context.l10n;
    final visibleClassrooms = state.visibleClassrooms;

    if (!authState.isAuthenticated) {
      return EmptyClassroomLoginRequiredView(onLogin: _openLogin);
    }

    if (state.hasInitialError && state.errorMessage != null) {
      final authExpired =
          state.errorCode == EmptyClassroomExceptionCode.authExpired;
      return EmptyClassroomInitialErrorView(
        message: state.errorMessage!,
        retryLabel: authExpired
            ? l10n.emptyClassroomGoLogin
            : l10n.emptyClassroomRetry,
        onRetry: authExpired ? _openLogin : notifier.loadInitialData,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        EmptyClassroomFilterCard(
          state: state,
          onCampusChanged: notifier.selectCampus,
          onBuildingChanged: notifier.selectBuilding,
          onWeekChanged: notifier.selectWeek,
          onWeekDayChanged: notifier.selectWeekDay,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ui.PrimaryButton(
            onPressed: state.canQuery ? _query : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: state.isQuerying ? 0 : 1,
                  child: Text(l10n.emptyClassroomQueryButton),
                ),
                if (state.isQuerying)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        ),
        if (state.hasQueried && state.classrooms.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ConflictFreeFilterRow(
            value: state.onlyConflictFree,
            onChanged: (value) {
              setState(() {
                _expandedClassroomKeys.clear();
              });
              notifier.setOnlyConflictFree(value);
            },
          ),
        ],
        const SizedBox(height: 20),
        if (state.isQuerying)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.errorMessage != null)
          EmptyClassroomQueryErrorCard(
            message: state.errorMessage!,
            actionLabel:
                state.errorCode == EmptyClassroomExceptionCode.authExpired
                ? l10n.emptyClassroomGoLogin
                : null,
            onRetry: state.errorCode == EmptyClassroomExceptionCode.authExpired
                ? _openLogin
                : _query,
          )
        else if (visibleClassrooms.isEmpty && state.selectedCampus != null)
          state.hasQueried
              ? const EmptyClassroomEmptyCard()
              : const EmptyClassroomQueryHint()
        else
          ...visibleClassrooms.map((classroom) {
            final classroomKey = _classroomKey(classroom);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EmptyClassroomCard(
                key: ValueKey(classroomKey),
                classroom: classroom,
                isExpanded: _expandedClassroomKeys.contains(classroomKey),
                formatSections: _formatSections.call,
                groupSections: _groupSections.call,
                conflictingSections: _sectionConflictsForClassroom(
                  classroomKey,
                ),
                onSectionTap: (section) =>
                    _addSingleSection(classroom, section),
                onSectionGroupTap: (sections) =>
                    _addSectionGroup(classroom, sections),
                onToggleExpanded: () => _toggleExpanded(classroomKey),
              ),
            );
          }),
      ],
    );
  }

  String _classroomKey(EmptyClassroom classroom) {
    return '${classroom.building}|${classroom.name}';
  }

  Set<String> _sectionConflictsForClassroom(String classroomKey) {
    final prefix = '$classroomKey|';
    return _conflictingSectionKeys
        .where((key) => key.startsWith(prefix))
        .map((key) => key.substring(prefix.length))
        .toSet();
  }

  String _sectionText(List<int> sections) {
    final l10n = context.l10n;
    return sections
        .map((section) => l10n.emptyClassroomSectionLabel(section))
        .join('、');
  }
}

class _ConflictFreeFilterRow extends StatelessWidget {
  const _ConflictFreeFilterRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.36),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '只看无冲突节次',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}
