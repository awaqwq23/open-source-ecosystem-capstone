import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class WhuAccountDetailPage extends ConsumerWidget {
  const WhuAccountDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(whuAuthProvider);
    final account = authState.account;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ui.Card(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(
                    AppIcons.web,
                    size: 30,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  authState.isAuthenticated
                      ? account?.displayName ?? '已认证'
                      : '未登录',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authState.isAuthenticated ? '武大统一认证已连接' : '登录后可授权成绩、课程表等校园服务',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ui.Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '账户信息',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow(colors, '学号', account?.studentId ?? '未获取'),
                const Divider(height: 1),
                _detailRow(colors, '姓名', account?.name ?? '未获取'),
                const Divider(height: 1),
                _detailRow(colors, '学院', account?.college ?? '未获取'),
                const Divider(height: 1),
                _detailRow(
                  colors,
                  '最近登录',
                  _formatDateTime(authState.lastAuthenticatedAt),
                ),
                const Divider(height: 1),
                _detailRow(
                  colors,
                  '最近验证',
                  _formatDateTime(authState.lastVerifiedAt),
                ),
              ],
            ),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              authState.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ui.PrimaryButton(
              onPressed: () =>
                  context.openSecondary(AppRoutePaths.whuAccountLogin),
              child: Text(authState.isAuthenticated ? '重新登录' : '登录武大统一认证'),
            ),
          ),
          if (authState.isAuthenticated) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ui.OutlineButton(
                onPressed: () async {
                  await ref.read(whuAuthProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text('退出登录', style: TextStyle(color: colors.error)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(ColorScheme colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '未获取' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '未记录';
    }
    String pad(int value) => value.toString().padLeft(2, '0');
    return '${dateTime.year}-${pad(dateTime.month)}-${pad(dateTime.day)} '
        '${pad(dateTime.hour)}:${pad(dateTime.minute)}';
  }
}
