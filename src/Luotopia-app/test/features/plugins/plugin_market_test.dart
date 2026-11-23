import 'package:flutter_test/flutter_test.dart';
import 'package:luotopia/features/plugins/data/plugin_market_service.dart';

void main() {
  final valid = [
    {
      'tag_name': 'v1',
      'assets': [
        {
          'name': 'study.luoplugin',
          'size': 123,
          'browser_download_url':
              'https://github.com/alice/study/releases/download/v1/study.luoplugin',
        },
        {'name': 'notes.txt', 'size': 1},
      ],
    },
  ];
  test('lists only packages belonging to selected repository', () {
    final assets = PluginMarketService.parseReleases(valid, 'alice/study');
    expect(assets.single.name, 'study.luoplugin');
    expect(assets.single.release, 'v1');
    expect(
      () => PluginMarketService.parseReleases(valid, 'bob/study'),
      throwsA(isA<Exception>()),
    );
  });
  test('rejects injected repository paths', () {
    for (final value in [
      'https://github.com/a/b',
      'a/b/../c',
      '../b',
      'a/..',
      'a/b?x=1',
    ]) {
      expect(
        () => PluginMarketService.repository(value),
        throwsA(isA<Exception>()),
      );
    }
  });
  test('rejects unsafe initial and redirect destinations', () {
    for (final value in [
      'http://github.com/a',
      'https://localhost/a',
      'https://github.com.evil.test/a',
      'https://github.com:444/a',
      'https://user:pass@github.com/a',
      'https://github.com/a#x',
    ]) {
      expect(
        () => PluginMarketService.validateUrl(Uri.parse(value)),
        throwsA(isA<Exception>()),
      );
    }
    expect(
      PluginMarketService.validateUrl(
        Uri.parse('https://release-assets.githubusercontent.com/a'),
      ).host,
      'release-assets.githubusercontent.com',
    );
  });
  test('ignores prerelease and rejects oversized packages', () {
    expect(
      PluginMarketService.parseReleases([
        {'prerelease': true},
      ], 'alice/study'),
      isEmpty,
    );
    final release = {
      'tag_name': 'v1',
      'assets': [
        {
          'name': 'large.luoplugin',
          'size': 6 * 1024 * 1024,
          'browser_download_url':
              'https://github.com/alice/study/releases/download/v1/large.luoplugin',
        },
      ],
    };
    expect(
      () => PluginMarketService.parseReleases([release], 'alice/study'),
      throwsA(isA<Exception>()),
    );
  });
}
