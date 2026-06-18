import 'dart:convert';

import 'package:http/http.dart' as http;

/// 统一 HTTP 客户端，自动处理 base URL、认证头、JSON 解析和超时。
class ApiClient {
  ApiClient({
    http.Client? client,
    required this.baseUrl,
    required this.tokenProvider,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String Function() tokenProvider;
  final Duration timeout;

  Map<String, String> get _jsonHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Map<String, String> get _authHeaders => {
    ..._jsonHeaders,
    'Authorization': 'Bearer ${tokenProvider()}',
  };

  Future<Map<String, dynamic>> get(String path) async {
    return _request(
      _client.get(Uri.parse('$baseUrl$path'), headers: _authHeaders),
    );
  }

  Future<String> getText(String path) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$path'), headers: _authHeaders)
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiClientException._(
        response.statusCode,
        _parseErrorMessage(response),
      );
    }
    return response.body;
  }

  Future<List<int>> getBytes(String path) async {
    final response = await _client
        .get(Uri.parse('$baseUrl$path'), headers: _authHeaders)
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiClientException._(
        response.statusCode,
        _parseErrorMessage(response),
      );
    }
    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    return _request(
      _client.post(
        Uri.parse('$baseUrl$path'),
        headers: withAuth ? _authHeaders : _jsonHeaders,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<Map<String, dynamic>> _request(Future<http.Response> future) async {
    final response = await future.timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiClientException._(
        response.statusCode,
        _parseErrorMessage(response),
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const ApiClientException._(0, '响应格式异常');
  }

  String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final error = data['error'];
      if (error is Map<String, dynamic>) {
        return error['message'] as String? ?? '请求失败（${response.statusCode}）';
      }
      return data['message'] as String? ?? '请求失败（${response.statusCode}）';
    } catch (_) {
      return '请求失败（${response.statusCode}）';
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiClientException implements Exception {
  const ApiClientException._(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}
