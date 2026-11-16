import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:luotopia/features/luotopia_auth/data/luotopia_auth_repository.dart';

class SyncClient {
  SyncClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _requestTimeout = Duration(seconds: 15);

  Future<bool> capability({required String accessToken}) async {
    final response = await _client
        .get(
          Uri.parse('${LuotopiaAuthRepository.baseUrl}/api/v1/sync/capability'),
          headers: _authHeaders(accessToken),
        )
        .timeout(_requestTimeout);
    final data = _readJson(response);
    return data['enabled'] == true;
  }

  Future<Map<String, dynamic>> pullChanges({
    required String accessToken,
    required int cursor,
    int limit = 500,
  }) async {
    final uri = Uri.parse(
      '${LuotopiaAuthRepository.baseUrl}/api/v1/sync/changes'
      '?cursor=$cursor&limit=$limit',
    );
    final response = await _client
        .get(uri, headers: _authHeaders(accessToken))
        .timeout(_requestTimeout);
    return _readJson(response);
  }

  Future<Map<String, dynamic>> pushChanges({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final response = await _client
        .post(
          Uri.parse('${LuotopiaAuthRepository.baseUrl}/api/v1/sync/changes'),
          headers: _authHeaders(accessToken),
          body: jsonEncode(body),
        )
        .timeout(_requestTimeout);
    return _readJson(response);
  }

  Map<String, String> _authHeaders(String accessToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }

  Map<String, dynamic> _readJson(http.Response response) {
    if (response.statusCode == 403) {
      throw const SyncDisabledException();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SyncClientException('同步请求失败（${response.statusCode}）');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const SyncClientException('同步响应格式异常');
  }
}

class SyncDisabledException implements Exception {
  const SyncDisabledException();

  @override
  String toString() => '当前账号未开通同步';
}

class SyncClientException implements Exception {
  const SyncClientException(this.message);

  final String message;

  @override
  String toString() => message;
}
