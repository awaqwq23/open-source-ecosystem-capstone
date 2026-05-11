import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/data/scorecalc_service.dart';
import 'package:luotopia/features/pages/campus/domain/models/scorecalc_item.dart';
import 'package:luotopia/features/whu_auth/domain/models/score_entity.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:luotopia/features/whu_auth/data/education_api_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

// ---------- 模型 ----------

class _ScoreEntry {
  String name;
  double credit;
  double score;

  _ScoreEntry({required this.name, required this.credit, required this.score});
}

// ---------- 页面 ----------

class ScoreCalcPage extends ConsumerStatefulWidget {
  const ScoreCalcPage({super.key});

  @override
  ConsumerState<ScoreCalcPage> createState() => _ScoreCalcPageState();
}

class _ScoreCalcPageState extends ConsumerState<ScoreCalcPage> {
  final _service = ScoreCalcService();
  final _nameCtrl = TextEditingController();
  final _creditCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _scriptCtrl = TextEditingController();

  List<_ScoreEntry> _entries = [];
  List<ScoreCalcItem> _allScripts = [];
  ScoreCalcItem? _selectedScript;
  ScoreCalcResult? _lastResult;
  bool _showDevMode = false;
  bool _isLoadingScripts = false;
  bool _isCalculating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScripts();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _creditCtrl.dispose();
    _scoreCtrl.dispose();
    _scriptCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadScripts() async {
    setState(() => _isLoadingScripts = true);
    try {
      final github = await _service.fetchFromGithub();
      setState(() {
        _allScripts = github;
        if (_selectedScript == null && github.isNotEmpty) {
          _selectedScript = github.first;
        }
        _isLoadingScripts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingScripts = false;
        _errorMessage = '加载脚本失败：$e';
      });
    }
  }

  Future<void> _importFromScores() async {
    final whuAuth = ref.read(whuAuthProvider);
    if (!whuAuth.isAuthenticated) {
      _showMessage('请先登录武大教务获取成绩');
      return;
    }
    try {
      final api = EducationApiService();
      final result = await api.getScoreList(
        cookieHeader: whuAuth.cookieHeader,
      );
      setState(() {
        _entries = result.scores
            .where((s) => s.score > 0)
            .map((s) => _ScoreEntry(
                  name: s.name,
                  credit: s.credit,
                  score: s.score.toDouble(),
                ))
            .toList();
      });
      _showMessage('已导入 ${_entries.length} 门成绩');
    } catch (e) {
      _showMessage('导入失败：$e');
    }
  }

  void _addEntry() {
    final name = _nameCtrl.text.trim();
    final credit = double.tryParse(_creditCtrl.text.trim());
    final score = double.tryParse(_scoreCtrl.text.trim());
    if (name.isEmpty || credit == null || score == null) {
      _showMessage('请填写完整的课程信息');
      return;
    }
    setState(() {
      _entries.add(_ScoreEntry(name: name, credit: credit, score: score));
    });
    _nameCtrl.clear();
    _creditCtrl.clear();
    _scoreCtrl.clear();
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
  }

  void _clearEntries() {
    setState(() {
      _entries.clear();
      _lastResult = null;
    });
  }

  Future<void> _calculate() async {
    if (_entries.isEmpty) {
      _showMessage('请先添加成绩');
      return;
    }
    if (_selectedScript == null) {
      _showMessage('请先选择计算脚本');
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      // 如果脚本内容为空，先拉取
      String script = _selectedScript!.script;
      if (script.isEmpty && _selectedScript!.url.isNotEmpty) {
        script = await _service.fetchScript(_selectedScript!.url);
        final idx = _allScripts.indexWhere(
          (s) => s.title == _selectedScript!.title,
        );
        if (idx >= 0) {
          _allScripts[idx] = _allScripts[idx].copyWith(script: script);
          _selectedScript = _allScripts[idx];
        }
      }

      if (_showDevMode && _scriptCtrl.text.trim().isNotEmpty) {
        script = _scriptCtrl.text.trim();
      }

      final inputs = _entries
          .map((e) => CalcScoreInput(name: e.name, credit: e.credit, score: e.score))
          .toList();

      final result = _service.evaluate(script: script, scores: inputs);
      setState(() {
        _lastResult = result;
        _isCalculating = false;
      });
    } catch (e) {
      setState(() {
        _isCalculating = false;
        _errorMessage = '计算失败：$e';
      });
    }
  }

  void _showMessage(String msg) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('课程给分'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildScriptSelector(colors),
          const SizedBox(height: 16),
          _buildScoreInput(colors),
          const SizedBox(height: 12),
          _buildScoreList(colors),
          const SizedBox(height: 16),
          _buildResultCard(colors),
          const SizedBox(height: 16),
          _buildDevModeToggle(colors),
          if (_showDevMode) ...[
            const SizedBox(height: 12),
            _buildDevEditor(colors),
          ],
          const SizedBox(height: 16),
          _buildCalculateButton(colors),
        ],
      ),
    );
  }

  Widget _buildScriptSelector(ColorScheme colors) {
    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                '计算脚本',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_isLoadingScripts)
            const SizedBox(
              height: 20,
              child: Center(child: LinearProgressIndicator()),
            )
          else
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedScript?.title,
                isExpanded: true,
                hint: const Text('选择计算脚本'),
                items: _allScripts
                    .map((s) => DropdownMenuItem(
                          value: s.title,
                          child: Text(s.title),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val == null) {
                    return;
                  }
                  setState(() {
                    _selectedScript = _allScripts.firstWhere(
                      (s) => s.title == val,
                    );
                  });
                },
              ),
            ),
          if (_selectedScript != null) ...[
            const SizedBox(height: 6),
            Text(
              _selectedScript!.brief,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreInput(ColorScheme colors) {
    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text('成绩输入', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('导入'),
                onPressed: _importFromScores,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_nameCtrl, '课程名', hint: '高等数学A'),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: _buildTextField(_creditCtrl, '学分',
                    hint: '4.0', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: _buildTextField(_scoreCtrl, '成绩',
                    hint: '85', keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: colors.primary,
                onPressed: _addEntry,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildScoreList(ColorScheme colors) {
    if (_entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return ui.Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _entries.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Divider(height: 1, color: colors.outlineVariant),
              ),
            ListTile(
              dense: true,
              title: Text(_entries[i].name, maxLines: 1),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_entries[i].credit}学分  ${_entries[i].score.toInt()}分',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        size: 18, color: colors.error),
                    onPressed: () => _removeEntry(i),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
          Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '共 ${_entries.length} 门',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearEntries,
                  child:
                      const Text('清空', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(ColorScheme colors) {
    if (_isCalculating) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_lastResult == null && _errorMessage == null) {
      return const SizedBox.shrink();
    }

    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: colors.error, fontSize: 13),
              ),
            ),
          if (_lastResult != null) ...[
            Text(
              '计算结果',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _resultItem(colors, 'GPA',
                    _lastResult!.gpa.toStringAsFixed(2)),
                _resultItem(colors, '总学分',
                    _lastResult!.totalCredits.toStringAsFixed(1)),
                _resultItem(colors, '加权均分',
                    _lastResult!.weightedAverage.toStringAsFixed(2)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultItem(ColorScheme colors, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDevModeToggle(ColorScheme colors) {
    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(Icons.developer_mode, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: 8),
          const Text('开发者模式', style: TextStyle(fontSize: 14)),
          const Spacer(),
          Switch(
            value: _showDevMode,
            onChanged: (val) => setState(() => _showDevMode = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDevEditor(ColorScheme colors) {
    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '自定义 JS 脚本',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            '脚本需定义 function calculate(scores) 并返回 JSON',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _scriptCtrl,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'function calculate(scores) {\n  // ...\n  return { gpa, totalCredits, weightedAverage };\n}',
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
            ),
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _isLoadingScripts ? null : _calculate,
        icon: const Icon(Icons.calculate),
        label: Text(_isCalculating ? '计算中...' : '开始计算'),
      ),
    );
  }
}
