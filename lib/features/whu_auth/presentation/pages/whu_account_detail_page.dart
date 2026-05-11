import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/localization/locale_extensions.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_state.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class WhuAccountDetailPage extends ConsumerWidget {
  const WhuAccountDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
          title: Text(l10n.settingsAccountWhuTitle),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (whuAuth.isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _buildInfoCard(context, whuAuth),
            const SizedBox(height: 16),
            _buildSessionCard(context, whuAuth),
            const SizedBox(height: 16),
            _buildActionsCard(context, ref, whuAuth),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, WhuAuthState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.itemTypeCourse, size: 24, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                '认证信息',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(context, state),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, '学号', state.studentId),
          const Divider(height: 1),
          _buildInfoRow(context, '姓名', state.studentName),
          const Divider(height: 1),
          _buildInfoRow(context, '学院', state.college),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, WhuAuthState state) {
    final badgeColor = switch (state.educationSessionState) {
      EducationSessionState.valid => Colors.green,
      EducationSessionState.expired => Colors.orange,
      EducationSessionState.none => Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        switch (state.educationSessionState) {
          EducationSessionState.valid => '已认证',
          EducationSessionState.expired => '会话过期',
          EducationSessionState.none => '未认证',
        },
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '未设置',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: value.isNotEmpty
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: value.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WhuAuthState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final authStatus = state.isAuthenticated ? '已绑定 Cookie' : '未绑定';
    final eduStatus = switch (state.educationSessionState) {
      EducationSessionState.valid => '教务会话有效',
      EducationSessionState.expired => '教务会话已过期',
      EducationSessionState.none => '未登录教务系统',
    };
    final verifiedStr = state.lastVerifiedAt != null
        ? '${state.lastVerifiedAt!.hour.toString().padLeft(2, '0')}:'
          '${state.lastVerifiedAt!.minute.toString().padLeft(2, '0')}'
        : '尚未验证';

    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 20, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                '会话状态',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSessionRow(context, 'Cookie', authStatus),
          const Divider(height: 1),
          _buildSessionRow(context, '教务登录', eduStatus),
          const Divider(height: 1),
          _buildSessionRow(context, '上次验证', verifiedStr),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    WidgetRef ref,
    WhuAuthState state,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, size: 20, color: colors.primary),
              const SizedBox(width: 10),
              Text(
                '操作',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isAuthenticated) ...[
            _buildActionButton(
              context,
              icon: Icons.refresh,
              label: '刷新教务会话',
              onTap: () async {
                await ref.read(whuAuthProvider.notifier).refreshEducationSession();
              },
            ),
            const SizedBox(height: 8),
            _buildActionButton(
              context,
              icon: Icons.logout,
              label: '退出登录（清除认证信息）',
              isDestructive: true,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('确认退出'),
                    content: const Text('退出后将清除所有武大认证信息，需要时重新登录即可。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('退出'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(whuAuthProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                }
              },
            ),
          ] else ...[
            _buildActionButton(
              context,
              icon: AppIcons.web,
              label: '登录武大教务',
              onTap: () {
                // 跳转到登录页
                Navigator.of(context).maybePop();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final fgColor = isDestructive ? colors.error : colors.primary;

    return SizedBox(
      width: double.infinity,
      child: ui.OutlineButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
