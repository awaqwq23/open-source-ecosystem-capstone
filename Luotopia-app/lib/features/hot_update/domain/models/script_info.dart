/// 解析脚本元信息
class ScriptInfo {
  final String name;
  final String displayName;
  final int version;
  final String url;
  final String? localPath;
  final bool isDefault;

  const ScriptInfo({
    required this.name,
    required this.displayName,
    required this.version,
    required this.url,
    this.localPath,
    this.isDefault = true,
  });

  ScriptInfo copyWith({
    int? version,
    String? url,
    String? localPath,
    bool? isDefault,
  }) {
    return ScriptInfo(
      name: name,
      displayName: displayName,
      version: version ?? this.version,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory ScriptInfo.fromJson(Map<String, dynamic> json) {
    return ScriptInfo(
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      url: json['url'] as String? ?? '',
      localPath: json['localPath'] as String?,
      isDefault: json['isDefault'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'displayName': displayName,
        'version': version,
        'url': url,
        'localPath': localPath,
        'isDefault': isDefault,
      };
}

/// 远程脚本配置清单
class ScriptManifest {
  final List<ScriptInfo> scripts;

  const ScriptManifest({required this.scripts});

  factory ScriptManifest.fromJson(Map<String, dynamic> json) {
    final list = json['scripts'] as List<dynamic>? ?? [];
    return ScriptManifest(
      scripts: list
          .map((e) => ScriptInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 支持的解析器名称常量
abstract class ParserNames {
  static const course = 'course-parser';
  static const score = 'score-parser';
}
