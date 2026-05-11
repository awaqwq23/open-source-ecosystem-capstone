import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class LuotopiaRegisterPage extends ConsumerStatefulWidget {
  const LuotopiaRegisterPage({super.key});

  @override
  ConsumerState<LuotopiaRegisterPage> createState() =>
      _LuotopiaRegisterPageState();
}

class _LuotopiaRegisterPageState extends ConsumerState<LuotopiaRegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _doRegister() async {
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (username.length < 3) {
      _showSnackBar('用户名至少 3 个字符');
      return;
    }
    if (password.length < 6) {
      _showSnackBar('密码至少 6 个字符');
      return;
    }
    if (password != confirm) {
      _showSnackBar('两次输入的密码不一致');
      return;
    }

    await ref.read(luotopiaAuthProvider.notifier).register(
          username: username,
          password: password,
          email: email.isNotEmpty ? email : null,
        );

    if (mounted) {
      final state = ref.read(luotopiaAuthProvider);
      if (state.status == LuotopiaAuthStatus.authenticated) {
        Navigator.of(context).maybePop();
      }
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
          title: const Text('注册 Luotopia'),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Text(
            '创建 Luotopia 账户',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              labelText: '用户名',
              hintText: '至少 3 个字符',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: '邮箱（可选）',
              hintText: '用于找回密码',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '至少 6 个字符',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: '确认密码',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _doRegister(),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              authState.errorMessage!,
              style: TextStyle(color: colors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: authState.status == LuotopiaAuthStatus.loading
                  ? null
                  : _doRegister,
              child: Text(
                authState.status == LuotopiaAuthStatus.loading
                    ? '注册中...'
                    : '注册',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '已有账户？',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: () =>
                    context.push(AppRoutePaths.settingsLuotopiaLogin),
                child: const Text('登录'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
