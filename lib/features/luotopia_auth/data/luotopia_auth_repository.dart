import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LuotopiaUser {
  final int id;
  final String username;
  final String email;
  final String? displayName;
  final String? bio;
  final String? avatar;
  final bool isAdmin;
  final DateTime createdAt;

  const LuotopiaUser({
    required this.id,
    required this.username,
    this.email = '',
    this.displayName,
    this.bio,
    this.avatar,
    this.isAdmin = false,
    required this.createdAt,
  });

  String get displayNameStr => displayName ?? username;

  factory LuotopiaUser.fromJson(Map<String, dynamic> json) {
    return LuotopiaUser(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      avatar: json['avatar'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class LuotopiaAuthRepository {
  static const _tokenKey = 'luotopia.auth.token';
  static const _userKey = 'luotopia.auth.user';

  // 配置：服务端地址
  // 开发环境使用本地地址，生产环境需修改
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String _registerPath = '/api/v1/register';
  static const String _loginPath = '/api/v1/login';
  static const String _mePath = '/api/v1/me';

  // -- Token 持久化 -- //

  String? readToken(SharedPreferences? prefs) {
    return prefs?.getString(_tokenKey);
  }

  Future<void> writeToken(SharedPreferences? prefs, String token) async {
    await prefs?.setString(_tokenKey, token);
  }

  Future<void> clearToken(SharedPreferences? prefs) async {
    await prefs?.remove(_tokenKey);
    await prefs?.remove(_userKey);
  }

  LuotopiaUser? readUser(SharedPreferences? prefs) {
    final json = prefs?.getString(_userKey);
    if (json == null || json.isEmpty) {
      return null;
    }
    try {
      return LuotopiaUser.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUser(SharedPreferences? prefs, LuotopiaUser user) async {
    await prefs?.setString(_userKey, jsonEncode({
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'display_name': user.displayName,
      'bio': user.bio,
      'avatar': user.avatar,
      'is_admin': user.isAdmin,
      'created_at': user.createdAt.toIso8601String(),
    }));
  }

  // -- API 调用 -- //

  Future<({String token, LuotopiaUser user})> register({
    required String username,
    required String password,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_registerPath'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String? ?? '';
      final userData = data['user'] as Map<String, dynamic>?;
      final user = userData != null
          ? LuotopiaUser.fromJson(userData)
          : LuotopiaUser(id: 0, username: username, createdAt: DateTime.now());
      return (token: token, user: user);
    }

    final error = _parseError(response);
    throw Exception(error);
  }

  Future<({String token, LuotopiaUser user})> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$_loginPath'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String? ?? '';
      final userData = data['user'] as Map<String, dynamic>?;
      if (token.isEmpty) {
        throw Exception('登录失败：未返回令牌');
      }
      final user = userData != null
          ? LuotopiaUser.fromJson(userData)
          : LuotopiaUser(id: 0, username: username, createdAt: DateTime.now());
      return (token: token, user: user);
    }

    final error = _parseError(response);
    throw Exception(error);
  }

  Future<LuotopiaUser> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$_mePath'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception('获取用户信息失败');
      }
      return LuotopiaUser.fromJson(userData);
    }

    throw Exception('获取用户信息失败（${response.statusCode}）');
  }

  String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['error'] as String? ??
          data['message'] as String? ??
          '请求失败（${response.statusCode}）';
    } catch (_) {
      return '请求失败（${response.statusCode}）';
    }
  }
}
