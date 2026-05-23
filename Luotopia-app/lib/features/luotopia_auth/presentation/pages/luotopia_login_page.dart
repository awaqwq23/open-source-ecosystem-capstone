import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class _LuotopiaLoginPageState extends ConsumerState<LuotopiaLoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showSnackBar('请填写手机号');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).sendLoginCode(
          targetType: 'phone',
          target: phone,
        );
    _showStateMessage();
  }

  Future<void> _loginWithCode() async {
    final phone = _phoneCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    if (phone.isEmpty || code.isEmpty) {
      _showSnackBar('请填写手机号和验证码');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).loginWithCode(
          targetType: 'phone',
          target: phone,
          code: code,
        );
    _finishIfAuthenticated();
  }

  Future<void> _loginWithPassword() async {
    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (identifier.isEmpty || password.isEmpty) {
      _showSnackBar('请填写手机号/邮箱和密码');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).loginWithPassword(
          identifier: identifier,
          password: password,
        );
    _finishIfAuthenticated();
  }

  void _finishIfAuthenticated() {
    final state = ref.read(luotopiaAuthProvider);
    if (state.isAuthenticated && mounted) {
      Navigator.of(context).maybePop();
      return;
    }
    _showStateMessage();
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
    final loading = authState.status == LuotopiaAuthStatus.loading;
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
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Icon(Icons.account_circle_outlined, size: 64, color: colors.primary),
          const SizedBox(height: 16),
          Text(
            'Luotopia 账户',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '验证码'),
              Tab(text: '密码'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '手机号',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _codeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '验证码',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: loading ? null : _sendCode,
                          child: const Text('发送'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : _loginWithCode,
                        child: Text(loading ? '处理中...' : '登录 / 注册'),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    TextField(
                      controller: _identifierCtrl,
                      decoration: const InputDecoration(
                        labelText: '手机号 / 邮箱',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _loginWithPassword(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : _loginWithPassword,
                        child: Text(loading ? '登录中...' : '登录'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutePaths.settingsLuotopiaRegister),
            child: const Text('第一次使用？用手机号验证码创建账户'),
          ),
        ],
      ),
    );
  }
}
