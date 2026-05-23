import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class LuotopiaAccountPage extends ConsumerStatefulWidget {
  const LuotopiaAccountPage({super.key});

  @override
  ConsumerState<LuotopiaAccountPage> createState() =>
      _LuotopiaAccountPageState();
}

class _LuotopiaAccountPageState extends ConsumerState<LuotopiaAccountPage> {
  final _passwordCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _emailCodeCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    _emailCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _setPassword() async {
    final password = _passwordCtrl.text;
    if (password.length < 8) {
      _showSnackBar('密码至少 8 位');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).setPassword(password);
    _showStateMessage();
  }

  Future<void> _sendEmailCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnackBar('请填写邮箱');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).sendEmailBindCode(email);
    _showStateMessage();
  }

  Future<void> _bindEmail() async {
    final email = _emailCtrl.text.trim();
    final code = _emailCodeCtrl.text.trim();
    if (email.isEmpty || code.isEmpty) {
      _showSnackBar('请填写邮箱和验证码');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).bindEmail(
          email: email,
          code: code,
        );
    _showStateMessage();
  }

  Future<void> _logout(bool allDevices) async {
    if (allDevices) {
      await ref.read(luotopiaAuthProvider.notifier).logoutAll();
    } else {
      await ref.read(luotopiaAuthProvider.notifier).logout();
    }
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  void _showStateMessage() {
    final state = ref.read(luotopiaAuthProvider);
    final message = state.errorMessage ?? state.noticeMessage;
    if (message != null) {
      _showSnackBar(message);
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(luotopiaAuthProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loading = authState.status == LuotopiaAuthStatus.loading;

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
      child: authState.isAuthenticated
          ? ListView(
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
                          Icons.person_outline,
                          size: 36,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '用户 ${authState.user?.shortId ?? ''}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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
                        '设置密码',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '新密码',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : _setPassword,
                          child: const Text('保存密码'),
                        ),
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
                        '绑定邮箱',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: '邮箱',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailCodeCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '验证码',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: loading ? null : _sendEmailCode,
                            child: const Text('发送'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: loading ? null : _bindEmail,
                          child: const Text('绑定邮箱'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: loading ? null : () => _logout(false),
                  icon: Icon(Icons.logout, color: colors.error),
                  label: Text('退出当前设备', style: TextStyle(color: colors.error)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: loading ? null : () => _logout(true),
                  icon: Icon(Icons.power_settings_new, color: colors.error),
                  label: Text('退出所有设备', style: TextStyle(color: colors.error)),
                ),
              ],
            )
          : const Center(child: Text('未登录')),
    );
  }
}
