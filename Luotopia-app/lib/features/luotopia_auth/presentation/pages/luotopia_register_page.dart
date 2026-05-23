import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
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

  Future<void> _createAccount() async {
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

    return ui.Scaffold(
      headers: [
        ui.AppBar(
          leading: [
            ui.IconButton.ghost(
              icon: const Icon(AppIcons.back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
          title: const Text('创建 Luotopia 账户'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Text(
            '手机号验证后即可创建账户',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : _createAccount,
              child: Text(loading ? '处理中...' : '创建 / 登录'),
            ),
          ),
        ],
      ),
    );
  }
}
