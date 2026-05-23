import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final _identifierCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  _LoginMode _mode = _LoginMode.code;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final credential = _parseCredential();
    if (credential == null) {
      return;
    }
    await ref
        .read(luotopiaAuthProvider.notifier)
        .sendLoginCode(
          targetType: credential.targetType,
          target: credential.value,
        );
    _showStateMessage();
  }

  Future<void> _loginWithCode() async {
    final credential = _parseCredential();
    final code = _codeCtrl.text.trim();
    if (credential == null) {
      return;
    }
    if (code.isEmpty) {
      _showSnackBar('请填写验证码');
      return;
    }
    await ref
        .read(luotopiaAuthProvider.notifier)
        .loginWithCode(
          targetType: credential.targetType,
          target: credential.value,
          code: code,
        );
    _finishIfAuthenticated();
  }

  Future<void> _loginWithPassword() async {
    final credential = _parseCredential();
    final password = _passwordCtrl.text;
    if (credential == null) {
      return;
    }
    if (password.isEmpty) {
      _showSnackBar('请填写密码');
      return;
    }
    await ref
        .read(luotopiaAuthProvider.notifier)
        .loginWithPassword(identifier: credential.value, password: password);
    _finishIfAuthenticated();
  }

  Future<void> _login() {
    return switch (_mode) {
      _LoginMode.code => _loginWithCode(),
      _LoginMode.password => _loginWithPassword(),
    };
  }

  _Credential? _parseCredential() {
    final value = _identifierCtrl.text.trim();
    if (_phonePattern.hasMatch(value)) {
      return _Credential(targetType: 'phone', value: value);
    }
    if (_emailPattern.hasMatch(value)) {
      return _Credential(targetType: 'email', value: value);
    }
    _showSnackBar('请填写有效的手机号或邮箱');
    return null;
  }

  void _switchMode() {
    setState(() {
      _mode = _mode == _LoginMode.code ? _LoginMode.password : _LoginMode.code;
    });
  }

  void _showUnavailable(String name) {
    _showSnackBar('$name登录暂未开放');
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
    ui.showToast(
      context: context,
      location: ui.ToastLocation.bottomCenter,
      builder: (context, overlay) {
        return ui.Alert(
          title: Text(msg),
          trailing: ui.IconButton.ghost(
            icon: const Icon(Icons.close, size: 16),
            onPressed: overlay.close,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(luotopiaAuthProvider);
    final loading = authState.status == LuotopiaAuthStatus.loading;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isCodeMode = _mode == _LoginMode.code;
    const wechatColor = Color(0xFF188038);
    const qqColor = Color(0xFF2563EB);

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
          TextField(
            controller: _identifierCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: '手机号 / 邮箱',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          if (isCodeMode)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '验证码',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _loginWithCode(),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: loading ? null : _sendCode,
                    child: const Text('发送验证码'),
                  ),
                ),
              ],
            )
          else
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '密码',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _loginWithPassword(),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: loading ? null : _login,
              child: Text(loading ? '处理中...' : '登录'),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: loading ? null : _switchMode,
                child: Text(isCodeMode ? '账号密码登录' : '验证码登录'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: wechatColor.withValues(alpha: 0.48)),
                ),
                onPressed: loading ? null : () => _showUnavailable('微信'),
                icon: const Icon(Icons.wechat, size: 18, color: wechatColor),
                label: const Text('微信登录'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: qqColor.withValues(alpha: 0.48)),
                ),
                onPressed: loading ? null : () => _showUnavailable('QQ'),
                icon: const FaIcon(
                  FontAwesomeIcons.qq,
                  size: 18,
                  color: qqColor,
                ),
                label: const Text('QQ 登录'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _LoginMode { code, password }

class _Credential {
  const _Credential({required this.targetType, required this.value});

  final String targetType;
  final String value;
}

final _phonePattern = RegExp(r'^1[3-9]\d{9}$');
final _emailPattern = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
  r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
  r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
);
