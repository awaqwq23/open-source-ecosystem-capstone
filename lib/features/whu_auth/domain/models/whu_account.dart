class WhuAccount {
  const WhuAccount({
    required this.studentId,
    required this.name,
    required this.college,
    required this.major,
  });

  final String studentId;
  final String name;
  final String college;
  final String major;

  String get displayName {
    if (name.trim().isNotEmpty) {
      return name.trim();
    }
    if (studentId.trim().isNotEmpty) {
      return studentId.trim();
    }
    return '武大账户';
  }

  bool get hasProfile =>
      studentId.trim().isNotEmpty ||
      name.trim().isNotEmpty ||
      college.trim().isNotEmpty ||
      major.trim().isNotEmpty;

  WhuAccount copyWith({
    String? studentId,
    String? name,
    String? college,
    String? major,
  }) {
    return WhuAccount(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      college: college ?? this.college,
      major: major ?? this.major,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'name': name,
      'college': college,
      'major': major,
    };
  }

  factory WhuAccount.fromJson(Map<String, dynamic> json) {
    return WhuAccount(
      studentId: json['studentId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      college: json['college'] as String? ?? '',
      major: json['major'] as String? ?? '',
    );
  }
}
