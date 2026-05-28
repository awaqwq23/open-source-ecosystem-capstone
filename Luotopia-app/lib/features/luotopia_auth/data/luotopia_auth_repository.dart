import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LuotopiaUser {
  const LuotopiaUser({
    required this.externalId,
    this.username,
    this.avatarUrl,
    this.hasPassword = false,
    this.identities = const LuotopiaUserIdentities(),
  });

  final String externalId;
  final String? username;
  final String? avatarUrl;
  final bool hasPassword;
  final LuotopiaUserIdentities identities;

  String get displayName {
    final value = username?.trim();
    return value == null || value.isEmpty ? externalId : value;
  }

  bool get hasUsername => username != null && username!.trim().isNotEmpty;

  factory LuotopiaUser.fromJson(Map<String, dynamic> json) {
    return LuotopiaUser(
      externalId: json['external_id'] as String? ?? '',
      username: _readOptionalString(json['username']),
      avatarUrl: _readOptionalString(json['avatar_url']),
      hasPassword: json['has_password'] == true,
      identities: LuotopiaUserIdentities.fromJson(
        json['identities'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class LuotopiaUserIdentities {
  const LuotopiaUserIdentities({this.phone, this.email, this.wechat, this.qq});

  final String? phone;
  final String? email;
  final String? wechat;
  final String? qq;

  factory LuotopiaUserIdentities.fromJson(Map<String, dynamic> json) {
    return LuotopiaUserIdentities(
      phone: _readOptionalString(json['phone']),
      email: _readOptionalString(json['email']),
      wechat: _readOptionalString(json['wechat']),
      qq: _readOptionalString(json['qq']),
    );
  }
}

class LuotopiaDeviceSession {
  const LuotopiaDeviceSession({
    required this.id,
    required this.deviceName,
    required this.current,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String deviceName;
  final bool current;
  final DateTime createdAt;
  final DateTime expiresAt;

  factory LuotopiaDeviceSession.fromJson(Map<String, dynamic> json) {
    return LuotopiaDeviceSession(
      id: json['id'] as String? ?? '',
      deviceName: json['device_name'] as String? ?? '',
      current: json['current'] == true,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expiresAt:
          DateTime.tryParse(json['expires_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class LuotopiaTokenPair {
  const LuotopiaTokenPair({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  factory LuotopiaTokenPair.fromJson(Map<String, dynamic> json) {
    return LuotopiaTokenPair(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }
}

class LuotopiaAuthResult {
  const LuotopiaAuthResult({required this.user, required this.tokens});

  final LuotopiaUser user;
  final LuotopiaTokenPair tokens;

  factory LuotopiaAuthResult.fromJson(Map<String, dynamic> json) {
    return LuotopiaAuthResult(
      user: LuotopiaUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      tokens: LuotopiaTokenPair.fromJson(
        json['tokens'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class LuotopiaAuthException implements Exception {
  const LuotopiaAuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class LuotopiaTokenStore {
  LuotopiaTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _refreshTokenKey = 'luotopia.auth.refresh_token';

  final FlutterSecureStorage _storage;

  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> writeRefreshToken(String token) {
    return _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clear() {
    return _storage.delete(key: _refreshTokenKey);
  }
}

class LuotopiaAuthRepository {
  LuotopiaAuthRepository({http.Client? client, LuotopiaTokenStore? tokenStore})
    : _client = client ?? http.Client(),
      _tokenStore = tokenStore ?? LuotopiaTokenStore();

  static String get baseUrl {
    return dotenv.get('LUOTOPIA_API_BASE_URL');
  }

  final http.Client _client;
  final LuotopiaTokenStore _tokenStore;
  static const _requestTimeout = Duration(seconds: 10);

  Future<String?> readRefreshToken() => _tokenStore.readRefreshToken();

  Future<void> saveRefreshToken(String refreshToken) {
    return _tokenStore.writeRefreshToken(refreshToken);
  }

  Future<void> clearTokens() => _tokenStore.clear();

  Future<void> sendVerificationCode({
    required String targetType,
    required String target,
    required String purpose,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$baseUrl/api/v1/auth/verification-codes'),
          headers: _jsonHeaders(),
          body: jsonEncode({
            'target_type': targetType,
            'target': target,
            'purpose': purpose,
          }),
        )
        .timeout(
          _requestTimeout,
          onTimeout: () => throw const LuotopiaAuthException(
            '请求超时，请检查后端是否已启动或网络是否可达',
            code: 'request_timeout',
          ),
        );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  Future<LuotopiaAuthResult> loginWithVerificationCode({
    required String targetType,
    required String target,
    required String code,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/login/verification-code'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'target_type': targetType,
        'target': target,
        'code': code,
        'device_name': 'Flutter',
      }),
    );
    return _readAuthResult(response);
  }

  Future<LuotopiaAuthResult> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/login/password'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
        'device_name': 'Flutter',
      }),
    );
    return _readAuthResult(response);
  }

  Future<LuotopiaAuthResult> refresh(String refreshToken) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/token/refresh'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'refresh_token': refreshToken,
        'device_name': 'Flutter',
      }),
    );
    return _readAuthResult(response);
  }

  Future<LuotopiaUser> getMe(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/auth/me'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LuotopiaUser.fromJson(data['user'] as Map<String, dynamic>? ?? {});
  }

  Future<LuotopiaUser> setUsername({
    required String accessToken,
    required String username,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/profile/username'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({'username': username}),
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LuotopiaUser.fromJson(data['user'] as Map<String, dynamic>? ?? {});
  }

  Future<void> setPassword({
    required String accessToken,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/password'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  Future<LuotopiaUser> bindEmail({
    required String accessToken,
    required String email,
    required String code,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/identities/email'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({'email': email, 'code': code}),
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LuotopiaUser.fromJson(data['user'] as Map<String, dynamic>? ?? {});
  }

  Future<LuotopiaUser> bindPhone({
    required String accessToken,
    required String phone,
    required String code,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/identities/phone'),
      headers: _authHeaders(accessToken),
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LuotopiaUser.fromJson(data['user'] as Map<String, dynamic>? ?? {});
  }

  Future<List<LuotopiaDeviceSession>> sessions(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/v1/auth/sessions'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = data['sessions'] as List<dynamic>? ?? const [];
    return [
      for (final item in raw)
        if (item is Map<String, dynamic>) LuotopiaDeviceSession.fromJson(item),
    ];
  }

  Future<void> logoutSession({
    required String accessToken,
    required String sessionId,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/v1/auth/sessions/$sessionId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  Future<void> logout(String refreshToken) async {
    await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/logout'),
      headers: _jsonHeaders(),
      body: jsonEncode({'refresh_token': refreshToken}),
    );
  }

  Future<void> logoutAll(String accessToken) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/logout-all'),
      headers: _authHeaders(accessToken),
    );
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
  }

  LuotopiaAuthResult _readAuthResult(http.Response response) {
    if (response.statusCode != 200) {
      throw _parseError(response);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final result = LuotopiaAuthResult.fromJson(data);
    if (result.tokens.accessToken.isEmpty ||
        result.tokens.refreshToken.isEmpty) {
      throw const LuotopiaAuthException('登录失败：服务端未返回完整令牌');
    }
    return result;
  }

  Map<String, String> _jsonHeaders() {
    return {'Accept': 'application/json', 'Content-Type': 'application/json'};
  }

  Map<String, String> _authHeaders(String accessToken) {
    return {..._jsonHeaders(), 'Authorization': 'Bearer $accessToken'};
  }

  LuotopiaAuthException _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return LuotopiaAuthException(
          error['message'] as String? ?? '请求失败（${response.statusCode}）',
          code: error['code'] as String?,
        );
      }
      return LuotopiaAuthException(
        data['message'] as String? ?? '请求失败（${response.statusCode}）',
      );
    } catch (_) {
      return LuotopiaAuthException('请求失败（${response.statusCode}）');
    }
  }
}

String? _readOptionalString(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return value;
}
