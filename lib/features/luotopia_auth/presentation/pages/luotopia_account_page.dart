import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class LuotopiaAccountPage extends ConsumerWidget {
  const LuotopiaAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(luotopiaAuthProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!authState.isAuthenticated) {
      return ui.Scaffold(
        headers: [
          ui.AppBar(
            leading: [
              ui.IconButton.ghost(
                icon: const Icon(AppIcons.back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
            title: const Text('Luotopia 账户'),
          ),
        ],
        body: const Center(child: Text('未登录')),
      );
    }

    final user = authState.user!;

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('Luotopia 账户'),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户头像和信息卡片
          ui.Card(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    user.displayNameStr.isNotEmpty
                        ? user.displayNameStr[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayNameStr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user.username != user.displayNameStr) ...[
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
                if (user.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_outlined,
                          size: 14, color: colors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 账户详情
          ui.Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '账户详情',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow(colors, 'ID', '${user.id}'),
                const Divider(height: 1),
                _detailRow(colors, '用户名', user.username),
                const Divider(height: 1),
                _detailRow(colors, '邮箱', user.email.isNotEmpty ? user.email : '未设置'),
                const Divider(height: 1),
                _detailRow(colors, '注册时间', _formatDate(user.createdAt)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 退出按钮
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('确认退出'),
                    content: const Text('退出后需要重新登录才能使用论坛等功能。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text(
                          '退出',
                          style: TextStyle(color: colors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(luotopiaAuthProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                }
              },
              icon: Icon(Icons.logout, size: 18, color: colors.error),
              label: Text(
                '退出登录',
                style: TextStyle(color: colors.error),
              ),
            ),
          ),
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
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}
