import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/domain/sports_reservation_domain.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/pages/sports_reservation_order_webview_page.dart';
import 'package:luotopia/features/pages/campus/sub_apps/sports_reservation/presentation/viewmodels/sports_reservation_view_model.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class SportsReservationPage extends ConsumerStatefulWidget {
  const SportsReservationPage({super.key});

  @override
  ConsumerState<SportsReservationPage> createState() =>
      _SportsReservationPageState();
}

class _SportsReservationPageState extends ConsumerState<SportsReservationPage> {
  int? _expandedAvailabilityKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sportsReservationViewModelProvider);
    final whuAuth = ref.watch(whuAuthProvider);

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('运动场馆预约'),
          trailing: [
            ui.IconButton.ghost(
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: state.isBusy || !whuAuth.isAuthenticated
                  ? null
                  : _openOrdersSheet,
            ),
            ui.IconButton.ghost(
              icon: const Icon(Icons.refresh),
              onPressed: state.isBusy || !whuAuth.isAuthenticated
                  ? null
                  : () => _refreshAvailability(
                      forceGymSession:
                          state.status ==
                          SportsReservationViewStatus.authorizationExpired,
                    ),
            ),
          ],
        ),
      ],
      child: _buildBody(state, whuAuth.isAuthenticated),
    );
  }

  Future<bool> _ensureGymSession({bool force = false}) async {
    final whuAuth = ref.read(whuAuthProvider);
    if (!whuAuth.isAuthenticated || whuAuth.isExpired) {
      return false;
    }

    final viewModel = ref.read(sportsReservationViewModelProvider.notifier);
    if (!force && viewModel.hasGymSession) {
      return true;
    }

    try {
      final session = await ref
          .read(sportsReservationAuthServiceProvider)
          .createSession();
      if (!mounted) {
        return false;
      }
      viewModel.useSession(session);
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      viewModel.clearGymSession();
      _showMessage('场馆系统授权失败，请稍后重试。');
      return false;
    }
  }

  Future<void> _loadInitial({bool forceGymSession = false}) async {
    if (!await _ensureGymSession(force: forceGymSession)) {
      return;
    }
    await ref.read(sportsReservationViewModelProvider.notifier).loadInitial();
  }

  Future<void> _refreshAvailability({bool forceGymSession = false}) async {
    if (!await _ensureGymSession(force: forceGymSession)) {
      return;
    }
    await ref
        .read(sportsReservationViewModelProvider.notifier)
        .refreshAvailability();
  }

  Future<void> _loadOrders({bool forceGymSession = false}) async {
    if (!await _ensureGymSession(force: forceGymSession)) {
      return;
    }
    await ref.read(sportsReservationViewModelProvider.notifier).loadOrders();
  }

  Future<void> _openOrdersSheet() async {
    if (!await _ensureGymSession()) {
      return;
    }
    await _loadOrders();
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final state = ref.read(sportsReservationViewModelProvider);
        return _OrdersSheet(
          orders: state.orders,
          actionOrderNo: state.orderActionOrderNo,
          onRefresh: _loadOrders,
          onOpen: (order) {
            Navigator.of(context).pop();
            _openOrderDetail(order);
          },
        );
      },
    );
  }

  Future<void> _toggleAvailabilityDetails(
    SportsVenueAvailability availability,
  ) async {
    final availabilityKey = availability.stadiumsAreaId;
    if (_expandedAvailabilityKey == availabilityKey) {
      setState(() {
        _expandedAvailabilityKey = null;
      });
      ref
          .read(sportsReservationViewModelProvider.notifier)
          .clearAreaSelection();
      return;
    }
    setState(() {
      _expandedAvailabilityKey = availabilityKey;
    });
    final window = _firstWindowForDetails(availability);
    if (window == null) {
      return;
    }
    await ref
        .read(sportsReservationViewModelProvider.notifier)
        .loadAreaAvailability(availability: availability, window: window);
  }

  Future<void> _reserveAreaWindow({
    required SportsVenueAvailability availability,
    required SportsAreaAvailability area,
    required SportsAppointmentWindow window,
  }) async {
    await ref
        .read(sportsReservationViewModelProvider.notifier)
        .loadAreaAvailability(availability: availability, window: window);
    if (!mounted) {
      return;
    }
    await _openCheckout(area);
  }

  SportsAppointmentWindow? _firstWindowForDetails(
    SportsVenueAvailability availability,
  ) {
    for (final window in availability.windows) {
      if (window.canReserve) {
        return window;
      }
    }
    return availability.windows.isEmpty ? null : availability.windows.first;
  }

  Future<void> _openCheckout(SportsAreaAvailability area) async {
    final viewModel = ref.read(sportsReservationViewModelProvider.notifier);
    if (!await _ensureGymSession()) {
      return;
    }
    final args = viewModel.prepareCheckout(area);
    if (args == null) {
      return;
    }
    if (!mounted) {
      return;
    }

    final result = await context.push<SportsCheckoutResult>(
      AppRoutePaths.campusSportsReservationCheckout,
      extra: args,
    );
    if (!mounted) {
      return;
    }
    final checkoutResult = result ?? const SportsCheckoutResult.dismissed();
    await viewModel.handleCheckoutResult(checkoutResult);
    if (!mounted) {
      return;
    }
    _showCheckoutFeedback(checkoutResult);
  }

  void _showCheckoutFeedback(SportsCheckoutResult result) {
    if (result.suppressFeedback) {
      return;
    }
    final message = switch (result.outcome) {
      SportsCheckoutOutcome.completed => '预约或支付已完成，已刷新场馆状态。',
      SportsCheckoutOutcome.orderChanged => '预约订单已更新，已刷新场馆状态。',
      SportsCheckoutOutcome.authorizationExpired =>
        result.message.isEmpty ? '登录状态已失效，请重新登录。' : result.message,
      SportsCheckoutOutcome.failed =>
        result.message.isEmpty ? '预约确认失败，请稍后重试。' : result.message,
      SportsCheckoutOutcome.dismissed => '',
    };
    if (message.isEmpty) {
      return;
    }
    _showMessage(message);
  }

  Widget _buildBody(SportsReservationState state, bool isWhuAuthenticated) {
    if (!isWhuAuthenticated ||
        state.status == SportsReservationViewStatus.unauthenticated) {
      return _LoginRequiredView(
        onLogin: () => context.push(AppRoutePaths.whuAccount),
      );
    }

    if (state.errorMessage != null &&
        state.projects.isEmpty &&
        state.venues.isEmpty) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => _loadInitial(
          forceGymSession:
              state.status == SportsReservationViewStatus.authorizationExpired,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAvailability,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          _ProjectToggleBar(
            projects: state.projects,
            selectedProject: state.selectedProject,
            onProjectSelected: (project) => ref
                .read(sportsReservationViewModelProvider.notifier)
                .selectProject(project),
          ),
          const SizedBox(height: 10),
          _DateNavigator(
            selectedDate: state.selectedDate,
            minDate: _minReservableDate(),
            maxDate: _maxReservableDate(state),
            onSelected: (date) => ref
                .read(sportsReservationViewModelProvider.notifier)
                .selectDate(date),
          ),
          const SizedBox(height: 10),
          if (state.errorMessage != null)
            _InlineError(
              message: state.errorMessage!,
              onRetry: () => _refreshAvailability(
                forceGymSession:
                    state.status ==
                    SportsReservationViewStatus.authorizationExpired,
              ),
            ),
          if (state.status == SportsReservationViewStatus.loading ||
              state.status == SportsReservationViewStatus.refreshing)
            const _RefreshingIndicator(),
          if (state.availability.isEmpty &&
              state.status != SportsReservationViewStatus.loading)
            const _EmptyAvailabilityView()
          else
            ...state.availability.map((availability) {
              final expanded =
                  _expandedAvailabilityKey == availability.stadiumsAreaId;
              final detailsBelongToRow =
                  state.selectedAvailability?.stadiumsAreaId ==
                  availability.stadiumsAreaId;
              return _AvailabilityListRow(
                availability: availability,
                expanded: expanded,
                loadingDetails:
                    expanded &&
                    state.status == SportsReservationViewStatus.refreshing &&
                    state.areaAvailability.isEmpty,
                areaAvailability: expanded && detailsBelongToRow
                    ? state.areaAvailability
                    : const [],
                onToggleExpanded: () =>
                    _toggleAvailabilityDetails(availability),
                onReserve: (area, window) => _reserveAreaWindow(
                  availability: availability,
                  area: area,
                  window: window,
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _openOrderDetail(SportsReservation order) async {
    if (!await _ensureGymSession()) {
      return;
    }
    final viewModel = ref.read(sportsReservationViewModelProvider.notifier);
    final detail = await viewModel.loadOrderDetail(order.id);
    if (!mounted || detail == null) {
      _showMessage('订单详情加载失败，请稍后重试。');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _OrderDetailSheet(
          order: detail,
          actionOrderNo: ref
              .read(sportsReservationViewModelProvider)
              .orderActionOrderNo,
          onPay: () {
            Navigator.of(context).pop();
            _openOrderPayment(detail);
          },
          onCancel: () async {
            Navigator.of(context).pop();
            await _confirmAndRunOrderAction(
              title: '取消订单？',
              message: '取消后该时段会重新释放，请确认不再使用该预约。',
              successMessage: '订单已取消。',
              action: () => viewModel.cancelOrder(detail.id),
            );
          },
          onRefund: () async {
            Navigator.of(context).pop();
            await _confirmAndRunOrderAction(
              title: '申请退款？',
              message: '退款申请提交后，订单状态将以后端审核结果为准。',
              successMessage: '退款申请已提交。',
              action: () => viewModel.applyRefund(detail.id),
            );
          },
          onDelete: () async {
            Navigator.of(context).pop();
            await _confirmAndRunOrderAction(
              title: '删除订单记录？',
              message: '删除只会移除历史记录，不会替代取消或退款。',
              successMessage: '订单记录已删除。',
              action: () => viewModel.deleteOrder(detail.id),
            );
          },
        );
      },
    );
  }

  Future<void> _openOrderPayment(SportsReservation order) async {
    if (!await _ensureGymSession()) {
      return;
    }
    if (!mounted) {
      return;
    }
    final result = await context.push<SportsCheckoutResult>(
      AppRoutePaths.campusSportsReservationOrder,
      extra: SportsReservationOrderWebViewArgs(orderNo: order.id),
    );
    if (!mounted) {
      return;
    }
    final checkoutResult = result ?? const SportsCheckoutResult.dismissed();
    await ref
        .read(sportsReservationViewModelProvider.notifier)
        .handleCheckoutResult(checkoutResult);
    if (!mounted) {
      return;
    }
    _showCheckoutFeedback(checkoutResult);
  }

  Future<void> _confirmAndRunOrderAction({
    required String title,
    required String message,
    required String successMessage,
    required Future<bool> Function() action,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    var succeeded = false;
    try {
      succeeded = await action();
    } catch (error) {
      debugPrint('[SportsReservationPage] order action failed: $error');
    }
    if (!mounted) {
      return;
    }
    _showMessage(succeeded ? successMessage : '操作失败，请稍后重试。');
  }

  void _showMessage(String message) {
    if (message.isEmpty || !mounted) {
      return;
    }
    try {
      ui.showToast(
        context: context,
        location: ui.ToastLocation.bottomCenter,
        showDuration: const Duration(seconds: 3),
        builder: (context, overlay) {
          return ui.Card(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (error) {
      debugPrint('[SportsReservationPage] toast skipped: $error');
    }
  }
}

class _ProjectToggleBar extends StatelessWidget {
  const _ProjectToggleBar({
    required this.projects,
    required this.selectedProject,
    required this.onProjectSelected,
  });

  final List<SportsProject> projects;
  final SportsProject? selectedProject;
  final ValueChanged<SportsProject> onProjectSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      _ProjectToggleSpec(
        label: '羽毛球',
        aliases: ['羽毛'],
        icon: Icons.sports_tennis,
      ),
      _ProjectToggleSpec(label: '乒乓球', aliases: ['乒乓'], icon: Icons.table_bar),
      _ProjectToggleSpec(
        label: '健身房',
        aliases: ['健身'],
        icon: Icons.fitness_center,
      ),
    ];
    final matchedProjects = [
      for (final item in items) _matchProject(item, projects),
    ];
    final selectedIndex = matchedProjects.indexWhere(
      (project) => project?.id == selectedProject?.id,
    );
    final disabledIndexes = {
      for (var index = 0; index < matchedProjects.length; index++)
        if (matchedProjects[index] == null) index,
    };
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<int>(
        backgroundColor: CupertinoDynamicColor.resolve(
          CupertinoColors.tertiarySystemFill,
          context,
        ),
        disabledChildren: disabledIndexes,
        groupValue: selectedIndex < 0 ? 0 : selectedIndex,
        onValueChanged: (index) {
          if (index == null) {
            return;
          }
          final project = matchedProjects[index];
          if (project != null) {
            onProjectSelected(project);
          }
        },
        children: {
          for (var index = 0; index < items.length; index++)
            index: _ProjectSegment(
              icon: items[index].icon,
              label: items[index].label,
            ),
        },
      ),
    );
  }

  SportsProject? _matchProject(
    _ProjectToggleSpec spec,
    List<SportsProject> projects,
  ) {
    for (final project in projects) {
      final title = project.title.trim();
      if (title == spec.label ||
          spec.aliases.any((alias) => title.contains(alias))) {
        return project;
      }
    }
    return null;
  }
}

class _ProjectSegment extends StatelessWidget {
  const _ProjectSegment({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _ProjectToggleSpec {
  const _ProjectToggleSpec({
    required this.label,
    required this.aliases,
    required this.icon,
  });

  final String label;
  final List<String> aliases;
  final IconData icon;
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.selectedDate,
    required this.minDate,
    required this.maxDate,
    required this.onSelected,
  });

  final DateTime selectedDate;
  final DateTime minDate;
  final DateTime maxDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final currentDate = DateUtils.dateOnly(selectedDate);
    final previousDate = currentDate.subtract(const Duration(days: 1));
    final nextDate = currentDate.add(const Duration(days: 1));
    final canPrevious = !previousDate.isBefore(minDate);
    final canNext = !nextDate.isAfter(maxDate);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          ui.IconButton.ghost(
            icon: const Icon(Icons.chevron_left),
            onPressed: canPrevious ? () => onSelected(previousDate) : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                _formatFullDate(selectedDate),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          ui.IconButton.ghost(
            icon: const Icon(Icons.chevron_right),
            onPressed: canNext ? () => onSelected(nextDate) : null,
          ),
        ],
      ),
    );
  }
}

class _OrdersSheet extends StatelessWidget {
  const _OrdersSheet({
    required this.orders,
    required this.actionOrderNo,
    required this.onRefresh,
    required this.onOpen,
  });

  final List<SportsReservation> orders;
  final String? actionOrderNo;
  final VoidCallback onRefresh;
  final ValueChanged<SportsReservation> onOpen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '我的订单',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ui.IconButton.ghost(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: actionOrderNo == null ? onRefresh : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: orders.isEmpty
                  ? Text(
                      '暂无订单。完成预约后会在这里显示状态。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const Divider(height: 18),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _OrderTile(
                          order: order,
                          busy: actionOrderNo == order.id,
                          onTap: () => onOpen(order),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityListRow extends StatelessWidget {
  const _AvailabilityListRow({
    required this.availability,
    required this.expanded,
    required this.loadingDetails,
    required this.areaAvailability,
    required this.onToggleExpanded,
    required this.onReserve,
  });

  final SportsVenueAvailability availability;
  final bool expanded;
  final bool loadingDetails;
  final List<SportsAreaAvailability> areaAvailability;
  final VoidCallback onToggleExpanded;
  final void Function(SportsAreaAvailability, SportsAppointmentWindow)
  onReserve;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _VenueImage(venue: availability.venue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          availability.venue.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (availability.sportsTypeTitle.isNotEmpty)
                              availability.sportsTypeTitle,
                            _formatChargeRange(availability.chargeRange),
                          ].join('  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        _DayPartSummary(windows: availability.windows),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _AreaAvailabilityMatrix(
              availability: availability,
              areas: areaAvailability,
              loading: loadingDetails,
              onReserve: onReserve,
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 160),
          ),
        ],
      ),
    );
  }
}

class _VenueImage extends StatelessWidget {
  const _VenueImage({required this.venue});

  final SportsVenue venue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final imageUrl = venue.imageUrl.trim().isNotEmpty
        ? venue.imageUrl.trim()
        : venue.images.where((url) => url.trim().isNotEmpty).firstOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: imageUrl == null
            ? ColoredBox(
                color: colors.surfaceContainerHighest,
                child: Icon(Icons.stadium_outlined, color: colors.primary),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: colors.surfaceContainerHighest,
                  child: Icon(Icons.stadium_outlined, color: colors.primary),
                ),
              ),
      ),
    );
  }
}

class _DayPartSummary extends StatelessWidget {
  const _DayPartSummary({required this.windows});

  final List<SportsAppointmentWindow> windows;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final part in _dayParts)
          Text(
            '${part.label}：${_hasReservableWindow(part, windows) ? '有' : '无'}',
            style: style?.copyWith(
              color: _hasReservableWindow(part, windows)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _AreaAvailabilityMatrix extends StatelessWidget {
  const _AreaAvailabilityMatrix({
    required this.availability,
    required this.areas,
    required this.loading,
    required this.onReserve,
  });

  final SportsVenueAvailability availability;
  final List<SportsAreaAvailability> areas;
  final bool loading;
  final void Function(SportsAreaAvailability, SportsAppointmentWindow)
  onReserve;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: LinearProgressIndicator(minHeight: 2),
      );
    }
    if (areas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          '暂无具体场地状态',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ui.OutlinedContainer(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            _AreaMatrixHeader(),
            for (final area in areas)
              _AreaMatrixRow(area: area, onReserve: onReserve),
          ],
        ),
      ),
    );
  }
}

class _AreaMatrixHeader extends StatelessWidget {
  const _AreaMatrixHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Center(child: Text('场地', style: style)),
          ),
          const SizedBox(width: 4),
          for (final part in _dayParts)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(child: Text(part.label, style: style)),
              ),
            ),
          const SizedBox(width: 52),
        ],
      ),
    );
  }
}

class _AreaMatrixRow extends StatelessWidget {
  const _AreaMatrixRow({required this.area, required this.onReserve});

  final SportsAreaAvailability area;
  final void Function(SportsAreaAvailability, SportsAppointmentWindow)
  onReserve;

  @override
  Widget build(BuildContext context) {
    final reserveWindow = _firstReservableWindow(area.windows);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 54,
            child: Center(
              child: Text(
                '${area.areaNo}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 4),
          for (final part in _dayParts)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _WindowStatusBlock(
                  window: _windowForPart(part, area.windows),
                ),
              ),
            ),
          SizedBox(
            width: 52,
            height: 54,
            child: Center(
              child: FittedBox(
                child: ui.OutlineButton(
                  onPressed: reserveWindow == null
                      ? null
                      : () => onReserve(area, reserveWindow),
                  density: ui.ButtonDensity.compact,
                  child: const Text('预定'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({
    required this.order,
    required this.busy,
    required this.onTap,
  });

  final SportsReservation order;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final areaNo = order.areaNo;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: busy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: busy
                  ? const Padding(
                      padding: EdgeInsets.all(9),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.event_available_outlined, color: colors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      order.venueTitle,
                      if (areaNo != null) '$areaNo 号场',
                    ].where((part) => part.trim().isNotEmpty).join(' · '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.sportsTypeTitle} · '
                    '${_formatReservationDate(order.appointmentDate)} '
                    '${order.startTime}-${order.endTime}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StatusPill(
              text: _reservationStatusText(order),
              active: order.status == SportsReservationStatus.reserved,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({
    required this.order,
    required this.actionOrderNo,
    required this.onPay,
    required this.onCancel,
    required this.onRefund,
    required this.onDelete,
  });

  final SportsReservation order;
  final String? actionOrderNo;
  final VoidCallback onPay;
  final VoidCallback onCancel;
  final VoidCallback onRefund;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final busy = actionOrderNo == order.id;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 18,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '订单详情',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _StatusPill(
                    text: _reservationStatusText(order),
                    active: order.status == SportsReservationStatus.reserved,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                [
                  order.venueTitle,
                  if (order.areaNo != null) '${order.areaNo} 号场',
                ].where((part) => part.trim().isNotEmpty).join(' · '),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '${order.sportsTypeTitle} · '
                '${_formatFullDate(order.appointmentDate)} '
                '${order.startTime}-${order.endTime}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _OrderDetailRows(order: order),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (order.canPay)
                    ui.PrimaryButton(
                      onPressed: busy ? null : onPay,
                      child: const Text('去支付'),
                    ),
                  if (order.status == SportsReservationStatus.pendingPayment)
                    ui.OutlineButton(
                      onPressed: busy ? null : onCancel,
                      child: const Text('取消订单'),
                    ),
                  if (order.status == SportsReservationStatus.reserved)
                    ui.OutlineButton(
                      onPressed: busy
                          ? null
                          : order.canApplyRefund
                          ? onRefund
                          : onCancel,
                      child: Text(order.canApplyRefund ? '申请退款' : '取消订单'),
                    ),
                  if (order.canDelete)
                    ui.OutlineButton(
                      onPressed: busy ? null : onDelete,
                      child: const Text('删除记录'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '订单操作完成后会重新同步远端状态。',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderDetailRows extends StatelessWidget {
  const _OrderDetailRows({required this.order});

  final SportsReservation order;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OrderDetailRow(label: '订单编号', value: _redactedOrderNo(order.id)),
        if (order.createdAt != null)
          _OrderDetailRow(
            label: '创建时间',
            value: _formatDateTime(order.createdAt!),
          ),
        if (order.amount != null)
          _OrderDetailRow(label: '实付金额', value: _formatMoney(order.amount!)),
        if (order.totalAmount != null)
          _OrderDetailRow(
            label: '订单总额',
            value: _formatMoney(order.totalAmount!),
          ),
        if (order.discountAmount != null)
          _OrderDetailRow(
            label: '优惠金额',
            value: _formatMoney(order.discountAmount!),
          ),
        if (order.paymentStartTime != null)
          _OrderDetailRow(
            label: '可支付时间',
            value: _formatDateTime(order.paymentStartTime!),
          ),
        if (order.paymentDeadlineTime != null)
          _OrderDetailRow(
            label: '支付截止',
            value: _formatDateTime(order.paymentDeadlineTime!),
          ),
        if (order.paymentTime != null)
          _OrderDetailRow(
            label: '支付时间',
            value: _formatDateTime(order.paymentTime!),
          ),
        if (order.refundDeadlineTime != null)
          _OrderDetailRow(
            label: '退款截止',
            value: _formatDateTime(order.refundDeadlineTime!),
          ),
        if (order.refundAmount != null)
          _OrderDetailRow(
            label: '退款金额',
            value: _formatMoney(order.refundAmount!),
          ),
        if (order.cancelRemark.isNotEmpty)
          _OrderDetailRow(label: '取消原因', value: order.cancelRemark),
        if (order.cancelTime != null)
          _OrderDetailRow(
            label: '取消时间',
            value: _formatDateTime(order.cancelTime!),
          ),
        if (order.refundTime != null)
          _OrderDetailRow(
            label: '退款时间',
            value: _formatDateTime(order.refundTime!),
          ),
        if (order.realName.isNotEmpty)
          _OrderDetailRow(label: '姓名', value: _redactedName(order.realName)),
        if (order.studentWorkNo.isNotEmpty)
          _OrderDetailRow(
            label: '学号/工号',
            value: _redactedStudentNo(order.studentWorkNo),
          ),
      ],
    );
  }
}

class _OrderDetailRow extends StatelessWidget {
  const _OrderDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowStatusBlock extends StatelessWidget {
  const _WindowStatusBlock({required this.window});

  final SportsAppointmentWindow? window;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final available = window?.canReserve == true;
    final textColor = available ? colors.primary : colors.onSurfaceVariant;
    return ui.OutlinedContainer(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      borderRadius: BorderRadius.circular(6),
      borderColor: available ? colors.primary : colors.outlineVariant,
      backgroundColor: available
          ? colors.primary.withValues(alpha: 0.08)
          : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _compactTime(window?.startTime ?? '--'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Divider(height: 1, thickness: 1, color: textColor),
              ),
              const SizedBox(width: 2),
              Text(
                available ? '有' : '无',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _compactTime(window?.endTime ?? '--'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPart {
  const _DayPart({
    required this.label,
    required this.startHourInclusive,
    required this.endHourExclusive,
  });

  final String label;
  final int startHourInclusive;
  final int endHourExclusive;

  bool contains(SportsAppointmentWindow window) {
    final hour = _parseStartHour(window.startTime);
    return hour >= startHourInclusive && hour < endHourExclusive;
  }
}

const _dayParts = [
  _DayPart(label: '上午', startHourInclusive: 0, endHourExclusive: 14),
  _DayPart(label: '下午', startHourInclusive: 14, endHourExclusive: 18),
  _DayPart(label: '晚上', startHourInclusive: 18, endHourExclusive: 24),
];

bool _hasReservableWindow(
  _DayPart part,
  List<SportsAppointmentWindow> windows,
) {
  return windows.any((window) => part.contains(window) && window.canReserve);
}

SportsAppointmentWindow? _windowForPart(
  _DayPart part,
  List<SportsAppointmentWindow> windows,
) {
  for (final window in windows) {
    if (part.contains(window)) {
      return window;
    }
  }
  return null;
}

SportsAppointmentWindow? _firstReservableWindow(
  List<SportsAppointmentWindow> windows,
) {
  for (final part in _dayParts) {
    for (final window in windows) {
      if (part.contains(window) && window.canReserve) {
        return window;
      }
    }
  }
  return null;
}

int _parseStartHour(String startTime) {
  final digits = startTime.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 2) {
    return 0;
  }
  return int.tryParse(digits.substring(0, 2)) ?? 0;
}

String _compactTime(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length >= 4) {
    return digits.substring(0, 4);
  }
  return value;
}

String _formatChargeRange(SportsChargeRange range) {
  if (range.isFree) {
    return '免费';
  }
  if (range.lowPrice == range.highPrice) {
    return '${range.lowPrice.toStringAsFixed(0)} 元';
  }
  return '${range.lowPrice.toStringAsFixed(0)}-${range.highPrice.toStringAsFixed(0)} 元';
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final child = Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
    return active
        ? ui.PrimaryBadge(child: child)
        : ui.SecondaryBadge(child: child);
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ui.Card(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(width: 8),
            ui.OutlineButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _RefreshingIndicator extends StatelessWidget {
  const _RefreshingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: LinearProgressIndicator(minHeight: 2),
    );
  }
}

class _EmptyAvailabilityView extends StatelessWidget {
  const _EmptyAvailabilityView();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ui.Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.event_busy, size: 42, color: colors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('当前条件下暂无可预约场馆', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            '可以切换项目、日期或场馆再试。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LoginRequiredView extends StatelessWidget {
  const _LoginRequiredView({required this.onLogin});

  final VoidCallback onLogin;

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
            Text('请先登录武大统一认证', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '登录后才能查询运动场馆可预约状态。',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            ui.OutlineButton(onPressed: onLogin, child: const Text('去登录')),
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
            const SizedBox(height: 20),
            ui.OutlineButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

String _formatReservationDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day';
}

DateTime _minReservableDate() {
  return DateUtils.dateOnly(DateTime.now());
}

DateTime _maxReservableDate(SportsReservationState state) {
  final today = _minReservableDate();
  final dayCount = state.advanceAppointmentDayCount;
  if (dayCount <= 0) {
    return today;
  }
  final offset = _hasReachedAdvanceStartTime(state.advanceAppointmentStartTime)
      ? dayCount
      : dayCount - 1;
  return today.add(Duration(days: offset < 0 ? 0 : offset));
}

bool _hasReachedAdvanceStartTime(String value) {
  final start = _parseClockTime(value);
  if (start == null) {
    return true;
  }
  final now = DateTime.now();
  return now.hour > start.$1 || now.hour == start.$1 && now.minute >= start.$2;
}

(int, int)? _parseClockTime(String value) {
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 4) {
    return null;
  }
  final hour = int.tryParse(digits.substring(0, 2));
  final minute = int.tryParse(digits.substring(2, 4));
  if (hour == null || minute == null) {
    return null;
  }
  return (hour, minute);
}

String _formatFullDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = dateTime.month.toString().padLeft(2, '0');
  final day = dateTime.day.toString().padLeft(2, '0');
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}

String _formatMoney(double amount) {
  final rounded = amount.roundToDouble();
  final value = amount == rounded
      ? rounded.toStringAsFixed(0)
      : amount.toStringAsFixed(2);
  return '$value 元';
}

String _redactedOrderNo(String orderNo) {
  if (orderNo.length <= 8) {
    return orderNo;
  }
  return '${orderNo.substring(0, 4)}...${orderNo.substring(orderNo.length - 4)}';
}

String _redactedName(String name) {
  final trimmed = name.trim();
  if (trimmed.length <= 1) {
    return trimmed;
  }
  return '${trimmed.substring(0, 1)}*';
}

String _redactedStudentNo(String studentWorkNo) {
  final trimmed = studentWorkNo.trim();
  if (trimmed.length <= 6) {
    return trimmed;
  }
  return '${trimmed.substring(0, 3)}...${trimmed.substring(trimmed.length - 3)}';
}

String _reservationStatusText(SportsReservation reservation) {
  if (reservation.rawStatus.trim().isNotEmpty) {
    return reservation.rawStatus;
  }
  return switch (reservation.status) {
    SportsReservationStatus.pendingPayment => '待付款',
    SportsReservationStatus.reserved => '待使用',
    SportsReservationStatus.cancelled => '已取消',
    SportsReservationStatus.completed => '已完成',
    SportsReservationStatus.refunded => '已退款',
    SportsReservationStatus.unknown => '状态未知',
  };
}
