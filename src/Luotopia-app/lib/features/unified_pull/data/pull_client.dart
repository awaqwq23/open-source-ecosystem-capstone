import 'dart:io';

import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/features/unified_pull/data/pull_request.dart';
import 'package:luotopia/shared/data/api_client.dart';

class PullClient {
  PullClient({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PullResponse> pull(PullRequest request) async {
    final json = await _apiClient.post('/api/v1/pull', body: request.toJson());
    return PullResponse.fromJson(json);
  }

  Future<PullResponse> pullPublic(PullRequest request) async {
    final json = await _apiClient.post(
      '/api/v1/pull/public',
      body: request.toJson(),
      withAuth: false,
    );
    return PullResponse.fromJson(json);
  }

  Future<String> downloadScript(String path) {
    return _apiClient.getText(path);
  }

  Future<FileDownloadResult> downloadSchoolTimetableBundle(
    String href,
    File destination,
  ) {
    return _apiClient.downloadToFile(
      href,
      destination,
      timeoutOverride: const Duration(minutes: 3),
    );
  }
}
