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

  Future<void> _selectWindow({
    required SportsVenueAvailability availability,
    required SportsAppointmentWindow window,
  }) async {
    await ref
        .read(sportsReservationViewModelProvider.notifier)
        .loadAreaAvailability(availability: availability, window: window);
    if (!mounted) {
      return;
    }
    final state = ref.read(sportsReservationViewModelProvider);
    if (state.selectedAvailability == null || state.selectedWindow == null) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _AreaSelectionSheet(
          state: ref.read(sportsReservationViewModelProvider),
          onCheckout: (area) {
            Navigator.of(context).pop();
            _openCheckout(area);
          },
        );
      },
    );
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _FilterSection(
            state: state,
            onProjectSelected: (project) => ref
                .read(sportsReservationViewModelProvider.notifier)
                .selectProject(project),
            onDateSelected: (date) => ref
                .read(sportsReservationViewModelProvider.notifier)
                .selectDate(date),
            onVenueSelected: (venue) => ref
                .read(sportsReservationViewModelProvider.notifier)
                .selectVenue(venue),
          ),
          const SizedBox(height: 12),
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
            ...state.availability.map(
              (availability) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _VenueAvailabilityCard(
                  availability: availability,
                  selectedAvailability: state.selectedAvailability,
                  selectedWindow: state.selectedWindow,
                  onWindowSelected: (window) =>
                      _selectWindow(availability: availability, window: window),
                ),
              ),
            ),
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

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.state,
    required this.onProjectSelected,
    required this.onDateSelected,
    required this.onVenueSelected,
  });

  final SportsReservationState state;
  final ValueChanged<SportsProject> onProjectSelected;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<SportsVenue?> onVenueSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selectedProject = state.selectedProject;

    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '预约条件',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _ProjectSelector(
            projects: state.projects,
            selectedProject: selectedProject,
            onSelected: onProjectSelected,
          ),
          const SizedBox(height: 12),
          _DateSelector(
            selectedDate: state.selectedDate,
            onSelected: onDateSelected,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            key: ValueKey(state.selectedVenue?.id),
            initialValue: state.selectedVenue?.id,
            decoration: const InputDecoration(
              labelText: '场馆',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('全部场馆')),
              ...state.venues.map(
                (venue) => DropdownMenuItem<int?>(
                  value: venue.id,
                  child: Text(
                    _venueLabel(venue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: state.isBusy
                ? null
                : (venueId) {
                    if (venueId == null) {
                      onVenueSelected(null);
                      return;
                    }
                    final selected = state.venues.where(
                      (venue) => venue.id == venueId,
                    );
                    onVenueSelected(selected.isEmpty ? null : selected.first);
                  },
          ),
          if (selectedProject == null) ...[
            const SizedBox(height: 10),
            Text(
              '暂无可选运动项目',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  static String _venueLabel(SportsVenue venue) {
    if (venue.campusTitle.trim().isEmpty) {
      return venue.title;
    }
    return '${venue.title} · ${venue.campusTitle}';
  }
}

class _ProjectSelector extends StatelessWidget {
  const _ProjectSelector({
    required this.projects,
    required this.selectedProject,
    required this.onSelected,
  });

  final List<SportsProject> projects;
  final SportsProject? selectedProject;
  final ValueChanged<SportsProject> onSelected;

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final project = projects[index];
          final selected = selectedProject?.id == project.id;
          return ChoiceChip(
            label: Text(project.title),
            selected: selected,
            onSelected: (_) => onSelected(project),
          );
        },
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.selectedDate, required this.onSelected});

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final dates = List.generate(3, (index) => today.add(Duration(days: index)));
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = dates[index];
          final selected = DateUtils.isSameDay(date, selectedDate);
          return _DateChip(
            date: date,
            label: switch (index) {
              0 => '今天',
              1 => '明天',
              _ => '后天',
            },
            selected: selected,
            onTap: () => onSelected(date),
          );
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? colors.primary.withValues(alpha: 0.12) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? colors.primary : colors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.month}/${date.day}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
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

class _AreaSelectionSheet extends StatelessWidget {
  const _AreaSelectionSheet({required this.state, required this.onCheckout});

  final SportsReservationState state;
  final ValueChanged<SportsAreaAvailability> onCheckout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = state.selectedAvailability!;
    final window = state.selectedWindow!;
    final reservableAreas = state.areaAvailability.where(
      (area) => area.windows.any(
        (areaWindow) =>
            areaWindow.canReserve &&
            areaWindow.startTime == window.startTime &&
            areaWindow.endTime == window.endTime,
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择具体场地',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '${selected.venue.title} · ${window.startTime}-${window.endTime}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            if (state.status == SportsReservationViewStatus.refreshing &&
                state.areaAvailability.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.areaAvailability.isEmpty)
              Text(
                '暂未查询到具体场地。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              )
            else ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final area in state.areaAvailability)
                    _AreaChip(
                      area: area,
                      selectedWindow: window,
                      onCheckout: onCheckout,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      reservableAreas.isEmpty
                          ? '该时段暂无可预约场地。'
                          : '选择一个可预约场地后，将打开官方页面继续确认和支付。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (state.submitErrorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.submitErrorMessage!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.error),
                ),
              ],
            ],
          ],
        ),
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

class _VenueAvailabilityCard extends StatelessWidget {
  const _VenueAvailabilityCard({
    required this.availability,
    required this.selectedAvailability,
    required this.selectedWindow,
    required this.onWindowSelected,
  });

  final SportsVenueAvailability availability;
  final SportsVenueAvailability? selectedAvailability;
  final SportsAppointmentWindow? selectedWindow;
  final ValueChanged<SportsAppointmentWindow> onWindowSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final venue = availability.venue;
    final reservableCount = availability.windows
        .where((window) => window.canReserve)
        .length;

    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.stadium_outlined, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(
                text: reservableCount > 0 ? '$reservableCount 个可约' : '暂无可约',
                active: reservableCount > 0,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final window in availability.windows)
                _TimeWindowChip(
                  window: window,
                  selected:
                      selectedAvailability?.stadiumsAreaId ==
                          availability.stadiumsAreaId &&
                      selectedWindow?.startTime == window.startTime &&
                      selectedWindow?.endTime == window.endTime,
                  onTap: window.canReserve
                      ? () => onWindowSelected(window)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final parts = [
      if (availability.sportsTypeTitle.isNotEmpty) availability.sportsTypeTitle,
      if (availability.venue.campusTitle.isNotEmpty)
        availability.venue.campusTitle,
      if (availability.venue.address.isNotEmpty) availability.venue.address,
      _priceText,
    ];
    return parts.where((part) => part.trim().isNotEmpty).join(' · ');
  }

  String get _priceText {
    final range = availability.chargeRange;
    if (range.isFree) {
      return '免费';
    }
    if (range.lowPrice == range.highPrice) {
      return '${range.lowPrice.toStringAsFixed(0)} 元';
    }
    return '${range.lowPrice.toStringAsFixed(0)}-${range.highPrice.toStringAsFixed(0)} 元';
  }
}

class _TimeWindowChip extends StatelessWidget {
  const _TimeWindowChip({
    required this.window,
    required this.selected,
    required this.onTap,
  });

  final SportsAppointmentWindow window;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 118),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : enabled
              ? colors.surface
              : colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? colors.primary
                : enabled
                ? colors.outlineVariant
                : colors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              window.title.isEmpty ? '时段' : window.title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: enabled ? colors.onSurface : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${window.startTime}-${window.endTime}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({
    required this.area,
    required this.selectedWindow,
    required this.onCheckout,
  });

  final SportsAreaAvailability area;
  final SportsAppointmentWindow selectedWindow;
  final ValueChanged<SportsAreaAvailability> onCheckout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final available = area.windows.any(
      (window) =>
          window.canReserve &&
          window.startTime == selectedWindow.startTime &&
          window.endTime == selectedWindow.endTime,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: available ? () => onCheckout(area) : null,
      child: Container(
        constraints: const BoxConstraints(minWidth: 84),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: available
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: available
                ? colors.primary.withValues(alpha: 0.35)
                : colors.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${area.areaNo} 号场',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: available ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              available ? '继续确认' : '不可约',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active
            ? colors.primary.withValues(alpha: 0.10)
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: active ? colors.primary : colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
