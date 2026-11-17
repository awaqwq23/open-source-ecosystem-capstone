import 'dart:async';

import 'package:characters/characters.dart' as characters;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/luotopia_auth/data/luotopia_auth_repository.dart';
import 'package:luotopia/features/luotopia_auth/domain/luotopia_auth_state.dart';
import 'package:luotopia/features/luotopia_auth/presentation/providers/luotopia_auth_provider.dart';
import 'package:luotopia/features/pages/settings/presentation/widgets/settings_flat_list.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class LuotopiaAccountPage extends ConsumerWidget {
  const LuotopiaAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(luotopiaAuthProvider);
    final user = authState.user;
    final loading = authState.status == LuotopiaAuthStatus.loading;

    return ui.Scaffold(
      headers: [_AccountAppBar(title: 'Luotopia 账户')],
      child: user == null || !authState.isAuthenticated
          ? const Center(child: Text('未登录'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 28),
              children: [
                _AccountHero(user: user),
                SettingsFlatSection(
                  children: [
                    SettingsFlatTile(
                      title: '账户设置',
                      leading: const Icon(Icons.manage_accounts_outlined),
                      onTap: () => context.openSecondary(
                        AppRoutePaths.luotopiaAccountSettings,
                      ),
                    ),
                    SettingsFlatTile(
                      title: '假文1111',
                      leading: const Icon(Icons.article_outlined),
                      onTap: () => _showMessage(context, '假文暂未开放'),
                    ),
                    SettingsFlatTile(
                      title: '假文2222',
                      leading: const Icon(Icons.article_outlined),
                      onTap: () => _showMessage(context, '假文暂未开放'),
                    ),
                    SettingsFlatTile(
                      title: '设备管理',
                      leading: const Icon(Icons.devices_outlined),
                      onTap: () =>
                          context.openSecondary(AppRoutePaths.luotopiaDevices),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : () => unawaited(
                            ref.read(luotopiaAuthProvider.notifier).logout(),
                          ),
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      '退出账户',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class LuotopiaAccountSettingsPage extends ConsumerWidget {
  const LuotopiaAccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(luotopiaAuthProvider).user;
    if (user == null) {
      return ui.Scaffold(
        headers: [_AccountAppBar(title: '账户设置')],
        child: const Center(child: Text('未登录')),
      );
    }

    return ui.Scaffold(
      headers: [_AccountAppBar(title: '账户设置')],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          SettingsFlatSection(
            children: [
              SettingsFlatTile(
                title: '用户名',
                subtitle: user.hasUsername ? user.username : '去设置',
                leading: const Icon(Icons.badge_outlined),
                onTap: () =>
                    context.openSecondary(AppRoutePaths.luotopiaUsername),
              ),
              SettingsFlatTile(
                title: '密码',
                subtitle: user.hasPassword ? '已设置' : '去设置',
                leading: const Icon(Icons.lock_outline),
                onTap: () =>
                    context.openSecondary(AppRoutePaths.luotopiaPassword),
              ),
              SettingsFlatTile(
                title: '手机号',
                subtitle: user.identities.phone ?? '去绑定',
                leading: const Icon(Icons.phone_android_outlined),
                onTap: () => context.openSecondary(AppRoutePaths.luotopiaPhone),
              ),
              SettingsFlatTile(
                title: '邮箱',
                subtitle: user.identities.email ?? '去绑定',
                leading: const Icon(Icons.mail_outline),
                onTap: () => context.openSecondary(AppRoutePaths.luotopiaEmail),
              ),
              SettingsFlatTile(
                title: '微信',
                subtitle: user.identities.wechat ?? '去绑定',
                leading: const Icon(Icons.wechat),
                onTap: () =>
                    context.openSecondary(AppRoutePaths.luotopiaWechat),
              ),
              SettingsFlatTile(
                title: 'QQ',
                subtitle: user.identities.qq ?? '去绑定',
                leading: const Icon(Icons.chat_bubble_outline),
                onTap: () => context.openSecondary(AppRoutePaths.luotopiaQQ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LuotopiaUsernamePage extends ConsumerStatefulWidget {
  const LuotopiaUsernamePage({super.key});

  @override
  ConsumerState<LuotopiaUsernamePage> createState() =>
      _LuotopiaUsernamePageState();
}

class _LuotopiaUsernamePageState extends ConsumerState<LuotopiaUsernamePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(luotopiaAuthProvider).user?.username ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      _showMessage(context, '请填写用户名');
      return;
    }
    if (characters.Characters(value).length > 30) {
      _showMessage(context, '用户名最多 30 个字符');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).setUsername(value);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(luotopiaAuthProvider).status == LuotopiaAuthStatus.loading;
    return ui.Scaffold(
      headers: [_AccountAppBar(title: '设置用户名')],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          SettingsFlatSection(
            children: [
              SettingsFlatInputRow(
                label: '用户名',
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '输入用户名',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => unawaited(_save()),
                ),
              ),
            ],
          ),
          _SubmitButton(label: '保存用户名', loading: loading, onPressed: _save),
        ],
      ),
    );
  }
}

class LuotopiaPasswordPage extends ConsumerStatefulWidget {
  const LuotopiaPasswordPage({super.key});

  @override
  ConsumerState<LuotopiaPasswordPage> createState() =>
      _LuotopiaPasswordPageState();
}

class _LuotopiaPasswordPageState extends ConsumerState<LuotopiaPasswordPage> {
  final _controller = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final password = _controller.text;
    if (password.length < 8) {
      _showMessage(context, '密码至少 8 位');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).setPassword(password);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(luotopiaAuthProvider).status == LuotopiaAuthStatus.loading;
    return ui.Scaffold(
      headers: [_AccountAppBar(title: '设置密码')],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          SettingsFlatSection(
            children: [
              SettingsFlatInputRow(
                label: '新密码',
                child: TextField(
                  controller: _controller,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
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
                  onSubmitted: (_) => unawaited(_save()),
                ),
              ),
            ],
          ),
          _SubmitButton(label: '保存密码', loading: loading, onPressed: _save),
        ],
      ),
    );
  }
}

class LuotopiaPhonePage extends ConsumerStatefulWidget {
  const LuotopiaPhonePage({super.key});

  @override
  ConsumerState<LuotopiaPhonePage> createState() => _LuotopiaPhonePageState();
}

class _LuotopiaPhonePageState extends ConsumerState<LuotopiaPhonePage> {
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
    if (!_phonePattern.hasMatch(phone)) {
      _showMessage(context, '请填写有效的手机号');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).sendPhoneBindCode(phone);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
  }

  Future<void> _bind() async {
    final phone = _phoneCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    if (!_phonePattern.hasMatch(phone) || code.isEmpty) {
      _showMessage(context, '请填写手机号和验证码');
      return;
    }
    await ref
        .read(luotopiaAuthProvider.notifier)
        .bindPhone(phone: phone, code: code);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(luotopiaAuthProvider).status == LuotopiaAuthStatus.loading;
    return _VerificationBindPage(
      title: '绑定手机号',
      targetLabel: '手机号',
      targetController: _phoneCtrl,
      codeController: _codeCtrl,
      keyboardType: TextInputType.phone,
      loading: loading,
      onSendCode: _sendCode,
      onBind: _bind,
    );
  }
}

class LuotopiaEmailPage extends ConsumerStatefulWidget {
  const LuotopiaEmailPage({super.key});

  @override
  ConsumerState<LuotopiaEmailPage> createState() => _LuotopiaEmailPageState();
}

class _LuotopiaEmailPageState extends ConsumerState<LuotopiaEmailPage> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      _showMessage(context, '请填写有效的邮箱');
      return;
    }
    await ref.read(luotopiaAuthProvider.notifier).sendEmailBindCode(email);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
  }

  Future<void> _bind() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    if (!_emailPattern.hasMatch(email) || code.isEmpty) {
      _showMessage(context, '请填写邮箱和验证码');
      return;
    }
    await ref
        .read(luotopiaAuthProvider.notifier)
        .bindEmail(email: email, code: code);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final loading =
        ref.watch(luotopiaAuthProvider).status == LuotopiaAuthStatus.loading;
    return _VerificationBindPage(
      title: '绑定邮箱',
      targetLabel: '邮箱',
      targetController: _emailCtrl,
      codeController: _codeCtrl,
      keyboardType: TextInputType.emailAddress,
      loading: loading,
      onSendCode: _sendCode,
      onBind: _bind,
    );
  }
}

class LuotopiaSocialBindPage extends StatelessWidget {
  const LuotopiaSocialBindPage({required this.providerName, super.key});

  final String providerName;

  @override
  Widget build(BuildContext context) {
    return ui.Scaffold(
      headers: [_AccountAppBar(title: '绑定$providerName')],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          SettingsFlatSection(
            children: [
              SettingsFlatTile(
                title: '$providerName 绑定',
                subtitle: '暂未开放',
                leading: const Icon(Icons.link_off_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LuotopiaDeviceManagementPage extends ConsumerStatefulWidget {
  const LuotopiaDeviceManagementPage({super.key});

  @override
  ConsumerState<LuotopiaDeviceManagementPage> createState() =>
      _LuotopiaDeviceManagementPageState();
}

class _LuotopiaDeviceManagementPageState
    extends ConsumerState<LuotopiaDeviceManagementPage> {
  Future<List<LuotopiaDeviceSession>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LuotopiaDeviceSession>> _load() {
    final auth = ref.read(luotopiaAuthProvider);
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      return Future.value(const []);
    }
    return ref.read(luotopiaAuthRepositoryProvider).sessions(token);
  }

  Future<void> _logoutDevice(LuotopiaDeviceSession session) async {
    await ref.read(luotopiaAuthProvider.notifier).logoutSession(session.id);
    if (!mounted) {
      return;
    }
    _showStateMessage(context, ref);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return ui.Scaffold(
      headers: [_AccountAppBar(title: '设备管理')],
      child: FutureBuilder<List<LuotopiaDeviceSession>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final sessions = snapshot.data ?? const [];
          if (sessions.isEmpty) {
            return const Center(child: Text('暂无设备'));
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              SettingsFlatSection(
                children: [
                  for (final session in sessions)
                    SettingsFlatTile(
                      title: session.deviceName.isEmpty
                          ? '未知设备'
                          : session.deviceName,
                      subtitle: [
                        if (session.current) '当前设备',
                        '登录于 ${_formatDateTime(session.createdAt)}',
                      ].join(' · '),
                      leading: const Icon(Icons.smartphone_outlined),
                      trailing: session.current
                          ? const Text('当前')
                          : TextButton(
                              onPressed: () =>
                                  unawaited(_logoutDevice(session)),
                              child: const Text('退出'),
                            ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountHero extends StatelessWidget {
  const _AccountHero({required this.user});

  final LuotopiaUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer,
            colors.tertiaryContainer.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: colors.surface.withValues(alpha: 0.86),
            backgroundImage: user.avatarUrl == null
                ? null
                : NetworkImage(user.avatarUrl!),
            child: user.avatarUrl == null
                ? Icon(Icons.person_outline, size: 42, color: colors.primary)
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (user.hasUsername) ...[
            const SizedBox(height: 4),
            Text(
              user.externalId,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onPrimaryContainer.withValues(alpha: 0.72),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerificationBindPage extends StatelessWidget {
  const _VerificationBindPage({
    required this.title,
    required this.targetLabel,
    required this.targetController,
    required this.codeController,
    required this.keyboardType,
    required this.loading,
    required this.onSendCode,
    required this.onBind,
  });

  final String title;
  final String targetLabel;
  final TextEditingController targetController;
  final TextEditingController codeController;
  final TextInputType keyboardType;
  final bool loading;
  final Future<void> Function() onSendCode;
  final Future<void> Function() onBind;

  @override
  Widget build(BuildContext context) {
    return ui.Scaffold(
      headers: [_AccountAppBar(title: title)],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          SettingsFlatSection(
            children: [
              SettingsFlatInputRow(
                label: targetLabel,
                child: TextField(
                  controller: targetController,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: '输入$targetLabel',
                  ),
                ),
              ),
              SettingsFlatInputRow(
                label: '验证码',
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '输入验证码',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: loading ? null : () => unawaited(onSendCode()),
                      child: const Text('发送'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          _SubmitButton(label: title, loading: loading, onPressed: onBind),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: FilledButton(
        onPressed: loading ? null : () => unawaited(onPressed()),
        child: Text(loading ? '处理中...' : label),
      ),
    );
  }
}

class _AccountAppBar extends StatelessWidget {
  const _AccountAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ui.AppBar(
      leading: [
        ui.IconButton.ghost(
          icon: const Icon(AppIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
      title: Text(title),
    );
  }
}

void _showStateMessage(BuildContext context, WidgetRef ref) {
  final state = ref.read(luotopiaAuthProvider);
  final message = state.errorMessage ?? state.noticeMessage;
  if (message != null) {
    _showMessage(context, message);
  }
}

void _showMessage(BuildContext context, String msg) {
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

String _formatDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

final _phonePattern = RegExp(r'^1[3-9]\d{9}$');
final _emailPattern = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@"
  r"[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?"
  r"(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
);
