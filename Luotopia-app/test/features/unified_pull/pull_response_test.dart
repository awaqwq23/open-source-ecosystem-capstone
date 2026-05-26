import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';

void main() {
  test('解析统一拉取响应中的差量状态', () {
    final response = PullResponse.fromJson({
      'server_time': '2026-05-26T10:00:00Z',
      'weather': {
        'changed': true,
        'data': {'temperature': 28.0},
        'cached_at': 1779789600,
      },
      'notification': {
        'changed': false,
        'latest_id': 'notice_2',
        'has_new': false,
        'count': 2,
      },
      'hot_update': {
        'scripts': {
          'jw_login': {
            'changed': true,
            'latest_version': 3,
            'checksum': 'abc',
            'download_url': '/api/v1/hot-update/scripts/jw_login/content',
          },
        },
      },
      'sync': {
        'enabled': true,
        'has_changes': true,
        'latest_cursor': 12,
      },
    });

    expect(response.serverTime, DateTime.parse('2026-05-26T10:00:00Z'));
    expect(response.weather?.changed, isTrue);
    expect(response.notification?.changed, isFalse);
    expect(response.hotUpdate?.scripts['jw_login']?.downloadUrl, contains('jw_login'));
    expect(response.sync?.hasChanges, isTrue);
    expect(response.sync?.latestCursor, 12);
  });
}
