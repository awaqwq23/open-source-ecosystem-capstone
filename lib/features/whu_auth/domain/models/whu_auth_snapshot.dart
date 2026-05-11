import 'package:luotopia/features/whu_auth/domain/models/whu_account.dart';

class WhuAuthSnapshot {
  const WhuAuthSnapshot({
    required this.casCookieHeader,
    required this.account,
    required this.lastAuthenticatedAt,
    this.lastVerifiedAt,
  });

  final String casCookieHeader;
  final WhuAccount account;
  final DateTime lastAuthenticatedAt;
  final DateTime? lastVerifiedAt;

  Map<String, dynamic> toJson() {
    return {
      'casCookieHeader': casCookieHeader,
      'account': account.toJson(),
      'lastAuthenticatedAt': lastAuthenticatedAt.toIso8601String(),
      'lastVerifiedAt': lastVerifiedAt?.toIso8601String(),
    };
  }

  factory WhuAuthSnapshot.fromJson(Map<String, dynamic> json) {
    final accountJson = json['account'];
    return WhuAuthSnapshot(
      casCookieHeader: json['casCookieHeader'] as String? ?? '',
      account: accountJson is Map<String, dynamic>
          ? WhuAccount.fromJson(accountJson)
          : const WhuAccount(
              studentId: '',
              name: '',
              college: '',
              major: '',
            ),
      lastAuthenticatedAt: DateTime.tryParse(
            json['lastAuthenticatedAt'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastVerifiedAt: DateTime.tryParse(json['lastVerifiedAt'] as String? ?? ''),
    );
  }
}
