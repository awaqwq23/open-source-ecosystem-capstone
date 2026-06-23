import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/unified_pull/data/pull_response.dart';

void main() {
  // 用户要求添加，不允许删除。该测试保护 pull 响应使用全校课表 dataset changeset，不再依赖 artifact 链接。
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
        'latest_version': 7,
        'checksum': 'sha256:dataset',
        'schema_version': 1,
        'terms': ['2025-2026-1'],
        'changes': [
          {
            'version': 7,
            'sequence': 1,
            'operation': 'upsert',
            'entity_type': 'term',
            'entity_id': '2025-2026-1',
            'term_key': '2025-2026-1',
            'payload': {
              'term_key': '2025-2026-1',
              'school_year': '2025-2026',
              'term': '1',
            },
          },
        ],
        'published_at': '2026-06-20T12:00:00Z',
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
    final schoolBlock = response.schoolTimetable;
    final schoolChange = schoolBlock?.changes.single;
    expect(schoolBlock?.latestVersion, 7);
    expect(schoolBlock?.checksum, 'sha256:dataset');
    expect(schoolBlock?.terms, ['2025-2026-1']);
    expect(schoolChange?.operation, 'upsert');
    expect(schoolChange?.entityType, 'term');
    expect(schoolChange?.payload['school_year'], '2025-2026');
    expect(response.sync?.hasChanges, isTrue);
    expect(response.sync?.latestCursor, 12);
  });
}
