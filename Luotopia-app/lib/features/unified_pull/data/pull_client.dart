import 'package:luotopia/features/unified_pull/data/pull_response.dart';
import 'package:luotopia/shared/data/api_client.dart';

class PullClient {
  PullClient({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PullResponse> pull() async {
    final json = await _apiClient.get('/api/v1/pull');
    return PullResponse.fromJson(json);
  }
}
