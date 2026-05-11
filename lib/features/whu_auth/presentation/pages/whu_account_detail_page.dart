import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/domain/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class WhuAccountDetailPage extends ConsumerWidget {
  const WhuAccountDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final whuAuth = ref.watch(whuAuthProvider);
    final colors = Theme.of(context).colorScheme;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('武大教务账户'),
        ),
      ],
      child: whuAuth.isAuthenticated
          ? _AuthenticatedView(whuAuth: whuAuth)
          : _UnauthenticatedView(colors: colors),
    );
  }
}

class _UnauthenticatedView extends StatelessWidget {
  const _UnauthenticatedView({required this.colors});
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: colors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            '未登录武大教务',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ui.PrimaryButton(
            onPressed: () => context.push(AppRoutePaths.settingsWhuAuthLogin),
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }
}

class _AuthenticatedView extends ConsumerWidget {
  const _AuthenticatedView({required this.whuAuth});
  final WhuAuthState whuAuth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 头像和信息卡片
        ui.Card(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.school, size: 32, color: colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      whuAuth.studentName?.isNotEmpty == true
                          ? whuAuth.studentName!
                          : '已登录',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (whuAuth.studentId?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        '学号：${whuAuth.studentId}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '会话已保存，无需重复登录',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 操作按钮
        SizedBox(
          width: double.infinity,
          child: ui.OutlineButton(
            onPressed: () => _confirmLogout(context, ref),
            leading: const Icon(Icons.logout, size: 18),
            child: const Text('退出登录'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final isZh = Localizations.localeOf(context).languageCode
        .toLowerCase()
        .startsWith('zh');
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isZh ? '退出登录' : 'Logout'),
        content: Text(
          isZh ? '确定要退出武大教务账户吗？' : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isZh ? '取消' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isZh ? '退出' : 'Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await ref.read(whuAuthProvider.notifier).logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isZh ? '已退出武大教务账户' : 'Logged out'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
