import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/app/router/app_navigator.dart';
import 'package:luotopia/app/router/app_route_paths.dart';
import 'package:luotopia/core/theme/app_icons.dart';
import 'package:luotopia/features/pages/campus/sub_apps/score/data/whu_score_service.dart';
import 'package:luotopia/features/pages/campus/sub_apps/score/domain/models/score_entity.dart';
import 'package:luotopia/features/whu_auth/domain/models/whu_auth_state.dart';
import 'package:luotopia/features/whu_auth/presentation/providers/whu_auth_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as ui;

class ScorePage extends ConsumerStatefulWidget {
  const ScorePage({super.key});

  @override
  ConsumerState<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends ConsumerState<ScorePage> {
  List<ScoreEntity> _allScores = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedTermKey;

  List<String> _cachedTermGroups = [];
  List<ScoreEntity> _cachedFilteredScores = [];
  String? _cachedFilteredTermKey;
  bool _filteredScoresCacheValid = false;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final whuAuth = ref.read(whuAuthProvider);
    if (!whuAuth.isAuthenticated) {
      setState(() => _errorMessage = '请先登录武大教务账户。');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final client = await ref
          .read(whuAuthGatewayProvider)
          .authorizeEducation();
      final ScoreListResult result;
      try {
        result = await WhuScoreService(client: client).getScoreList();
      } finally {
        client.close();
      }
      final sorted = List<ScoreEntity>.from(result.scores)
        ..sort((a, b) {
          final cmp = b.year.compareTo(a.year);
          if (cmp != 0) {
            return cmp;
          }
          return b.semester.compareTo(a.semester);
        });

      if (!mounted) {
        return;
      }
      final termGroups = _computeTermGroups(sorted);
      setState(() {
        _allScores = sorted;
        _isLoading = false;
        _cachedTermGroups = termGroups;
        _filteredScoresCacheValid = false;
        _selectedTermKey ??= termGroups.isNotEmpty ? termGroups.first : null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  List<String> get _termGroups => _cachedTermGroups;

  static List<String> _computeTermGroups(List<ScoreEntity> scores) {
    final seen = <String>{};
    final result = <String>[];
    for (final s in scores) {
      final key = '${s.year}-${s.semester}';
      if (seen.add(key)) {
        result.add(key);
      }
    }
    return result;
  }

  List<ScoreEntity> get _filteredScores {
    if (_filteredScoresCacheValid && _cachedFilteredTermKey == _selectedTermKey) {
      return _cachedFilteredScores;
    }
    List<ScoreEntity> result;
    if (_selectedTermKey == null) {
      result = _allScores;
    } else {
      final parts = _selectedTermKey!.split('-');
      final year = int.parse(parts[0]);
      final semester = int.parse(parts[1]);
      result = _allScores
          .where((s) => s.year == year && s.semester == semester)
          .toList();
    }
    _cachedFilteredScores = result;
    _cachedFilteredTermKey = _selectedTermKey;
    _filteredScoresCacheValid = true;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final whuAuth = ref.watch(whuAuthProvider);
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
          title: const Text('成绩'),
        ),
      ],
      child: _buildBody(whuAuth, colors),
    );
  }

  Widget _buildBody(WhuAuthState whuAuth, ColorScheme colors) {
    if (!whuAuth.isAuthenticated) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('请先登录武大教务账户', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            ui.OutlineButton(
              onPressed: () => context.openSecondary(AppRoutePaths.whuAccount),
              child: const Text('去登录'),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _allScores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ui.OutlineButton(onPressed: _loadScores, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadScores,
      child: _isLoading && _allScores.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSemesterSelector(colors),
                const SizedBox(height: 16),
                _buildSummaryCard(colors),
                const SizedBox(height: 16),
                if (_filteredScores.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        '该学期暂无成绩数据',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  ..._filteredScores.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildScoreCard(s, colors),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSemesterSelector(ColorScheme colors) {
    final groups = _termGroups;
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }

    return ui.Card(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTermKey ?? groups.first,
          isExpanded: true,
          items: groups.map((key) {
            final parts = key.split('-');
            final year = parts[0];
            final semester = int.parse(parts[1]);
            final label = '$year-${int.parse(year) + 1} 第$semester学期';
            return DropdownMenuItem(value: key, child: Text(label));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedTermKey = val;
                _filteredScoresCacheValid = false;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ColorScheme colors) {
    final scores = _filteredScores;
    if (scores.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCredits = scores.fold<double>(0, (sum, s) => sum + s.credit);
    final weightedGPA = _calculateWeightedGPA(scores);
    final passed = scores.where((s) => s.score >= 60).length;
    final failed = scores.length - passed;

    return ui.Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _summaryItem(colors, '学分', totalCredits.toStringAsFixed(1)),
          Container(width: 1, height: 32, color: colors.outlineVariant),
          _summaryItem(colors, 'GPA', weightedGPA.toStringAsFixed(2)),
          Container(width: 1, height: 32, color: colors.outlineVariant),
          _summaryItem(colors, '通过', '$passed/$failed'),
        ],
      ),
    );
  }

  Widget _summaryItem(ColorScheme colors, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(ScoreEntity score, ColorScheme colors) {
    final gradeColor = switch (score.score) {
      >= 90 => Colors.green,
      >= 80 => Colors.blue,
      >= 70 => Colors.orange,
      >= 60 => Colors.orange.shade700,
      _ => Colors.red,
    };

    return ui.Card(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // 成绩数字
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${score.score}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 课程信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${score.credit}学分 · ${score.courseType}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (score.instructor.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    score.instructor,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 标准 4.0 绩点计算
  double _calculateWeightedGPA(List<ScoreEntity> scores) {
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in scores) {
      if (s.score < 60 || s.credit <= 0) {
        continue;
      }
      final point = switch (s.score) {
        >= 90 => 4.0,
        >= 85 => 3.7,
        >= 82 => 3.3,
        >= 78 => 3.0,
        >= 75 => 2.7,
        >= 72 => 2.3,
        >= 68 => 2.0,
        >= 64 => 1.5,
        >= 60 => 1.0,
        _ => 0.0,
      };
      totalPoints += point * s.credit;
      totalCredits += s.credit;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }
}
