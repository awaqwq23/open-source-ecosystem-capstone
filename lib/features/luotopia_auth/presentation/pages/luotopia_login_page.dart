import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class LuotopiaLoginPage extends ConsumerStatefulWidget {
  const LuotopiaLoginPage({super.key});

  @override
  ConsumerState<LuotopiaLoginPage> createState() => _LuotopiaLoginPageState();
}

class _LuotopiaLoginPageState extends ConsumerState<LuotopiaLoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('请填写用户名和密码');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).login(
          username: username,
          password: password,
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
          title: const Text('登录 Luotopia'),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 32),
          Icon(Icons.account_circle, size: 64, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            '欢迎回来',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _usernameCtrl,
            decoration: const InputDecoration(
              labelText: '用户名 / 邮箱',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密码',
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _doLogin(),
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
              onPressed:
                  authState.status == LuotopiaAuthStatus.loading ? null : _doLogin,
              child: Text(
                authState.status == LuotopiaAuthStatus.loading
                    ? '登录中...'
                    : '登录',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '还没有账户？',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutePaths.settingsLuotopiaRegister),
                child: const Text('注册'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
