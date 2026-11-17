import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/data/course_review_api.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/domain/models/course_review_models.dart';
import 'package:luotopia/features/pages/campus/sub_apps/course_review/presentation/viewmodels/course_review_view_models.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class CourseReviewWalletPage extends ConsumerStatefulWidget {
  const CourseReviewWalletPage({super.key});

  @override
  ConsumerState<CourseReviewWalletPage> createState() =>
      _CourseReviewWalletPageState();
}

class _CourseReviewWalletPageState
    extends ConsumerState<CourseReviewWalletPage> {
  List<CourseReview>? _myReviews;
  bool _loadingReviews = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (!ref.read(luotopiaAuthProvider).isAuthenticated) {
        return;
      }
      ref.read(courseReviewSessionViewModelProvider.notifier).refreshWallet();
      _loadMyReviews();
    });
  }

  Future<void> _loadMyReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final reviews = await ref.read(courseReviewApiProvider).myReviews();
      if (mounted) setState(() => _myReviews = reviews);
    } catch (_) {
      // 静默失败，不阻塞钱包展示。
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = ref.watch(courseReviewSessionViewModelProvider);
    final authenticated = ref.watch(luotopiaAuthProvider).isAuthenticated;
    final policyAsync = ref.watch(courseReviewPolicyProvider);

    if (!authenticated) {
      return ui.Scaffold(
        headers: [
          ui.AppBar(
            leading: [
              ui.IconButton.ghost(
                icon: const Icon(AppIcons.back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
            title: const Text('我的积分'),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('登录后查看积分与兑换查询权限'),
              const SizedBox(height: 16),
              ui.PrimaryButton(
                onPressed: () =>
                    context.openSecondary(AppRoutePaths.luotopiaLogin),
                child: const Text('去登录'),
              ),
            ],
          ),
        ),
      );
    }

    final wallet = session.wallet;
    final balance = wallet?.balance ?? 0;
    final grant = wallet?.accessGrant;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('我的积分'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          ui.Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('积分余额', style: theme.textTheme.bodySmall),
                  Text(
                    '$balance',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    grant == null
                        ? '当前无查询权限'
                        : '查询权限有效期至 ${_formatDate(grant.expiresAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          policyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: ui.CircularProgressIndicator()),
            ),
            error: (error, _) => Text(
              '兑换策略加载失败：$error',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            data: (policy) => _RedeemSection(
              policy: policy,
              isSubmitting: session.isSubmitting,
              onRedeem: _redeem,
            ),
          ),
          if (session.message != null) ...[
            const SizedBox(height: 8),
            Text(
              session.message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
          if (session.error != null) ...[
            const SizedBox(height: 8),
            Text(
              session.error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('我的评价', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_loadingReviews)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: ui.CircularProgressIndicator()),
            )
          else if (_myReviews == null || _myReviews!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('还没有发布过评价', style: theme.textTheme.bodyMedium),
            )
          else
            for (final review in _myReviews!)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ui.Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '难度${review.difficulty}·工作${review.workload}·质量${review.quality}·趣味${review.interest}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.contentText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(review.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _redeem(int days) async {
    final ok = await ref
        .read(courseReviewSessionViewModelProvider.notifier)
        .redeemAccess(days);
    if (!mounted) return;
    if (ok) _toast('兑换成功');
  }

  void _toast(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}

class _RedeemSection extends StatelessWidget {
  const _RedeemSection({
    required this.policy,
    required this.isSubmitting,
    required this.onRedeem,
  });

  final CourseReviewPolicy policy;
  final bool isSubmitting;
  final ValueChanged<int> onRedeem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = <int>[
      7,
      30,
    ].where(policy.canRedeemDays).toList(growable: false);
    if (policy.accessCostPerDay <= 0 || options.isEmpty) {
      return Text('暂不可兑换查询权限', style: theme.textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '兑换查询权限（每日 ${policy.accessCostPerDay} 积分）',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: ui.PrimaryButton(
                  onPressed: isSubmitting ? null : () => onRedeem(options[i]),
                  child: Text(
                    '${options[i]} 天 · ${policy.costForDays(options[i])} 积分',
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

String _formatDate(DateTime time) {
  return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
}
