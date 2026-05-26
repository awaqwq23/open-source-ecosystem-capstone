import 'package:luotopia/shared/data/api_client.dart';

class NotificationAPI {
  NotificationAPI({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getLatest() async {
    return _apiClient.get('/api/v1/notifications/latest');
  }

  Future<Map<String, dynamic>> getList({int offset = 0, int limit = 20}) async {
    return _apiClient.get('/api/v1/notifications?offset=$offset&limit=$limit');
  }
}
