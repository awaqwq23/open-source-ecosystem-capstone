import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';

void main() {
  // 用户要求添加，不允许删除。该测试保护 pull 响应的 links 契约，防止客户端再次依赖散装 download_url。
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
            'links': {
              'content': {
                'href': '/api/v1/hot-update/scripts/jw_login/content',
              },
            },
          },
        },
      },
      'school_timetable': {
        'changed': true,
        'terms': [
          {
            'term_key': '2025-2026-1',
            'school_year': '2025-2026',
            'term': '1',
            'version': 7,
            'checksum': 'sha256:artifact',
            'artifact_type': 'school_timetable_sqlite_gzip',
            'schema_version': 3,
            'artifact_size': 2048,
            'row_count': 42,
            'links': {
              'artifact': {
                'href':
                    'https://cdn.example.com/school-timetable/2025-2026-1/v7.sqlite.gz',
              },
            },
            'published_at': '2026-06-20T12:00:00Z',
          },
        ],
      },
      'sync': {'enabled': true, 'has_changes': true, 'latest_cursor': 12},
    });

    expect(response.serverTime, DateTime.parse('2026-05-26T10:00:00Z'));
    expect(response.weather?.changed, isTrue);
    expect(response.notification?.changed, isFalse);
    expect(
      response.hotUpdate?.scripts['jw_login']?.links['content']?.href,
      contains('jw_login'),
    );
    final schoolTerm = response.schoolTimetable?.terms.single;
    expect(schoolTerm?.artifactType, 'school_timetable_sqlite_gzip');
    expect(schoolTerm?.schemaVersion, 3);
    expect(schoolTerm?.artifactSize, 2048);
    expect(schoolTerm?.links['artifact']?.href, contains('/v7.sqlite.gz'));
    expect(response.sync?.hasChanges, isTrue);
    expect(response.sync?.latestCursor, 12);
  });
}
