import 'plugin_manifest.dart';

String settingsGroupFor(String pluginId) => switch (pluginId) {
  'luotopia.settings' ||
  'luotopia.home-settings' ||
  'luotopia.ai-settings' => 'main',
  'luotopia.notification' => 'notification',
  _ => pluginId.startsWith('luotopia.') ? 'legacy' : 'extensions',
};

class BuiltinPlugin {
  const BuiltinPlugin(this.id, this.name, this.source, this.contributions);
  final String id, name;
  final PluginSource source;
  final List<PluginContribution> contributions;
}

final builtinPlugins = <BuiltinPlugin>[
  _navigation('home', '首页', '/', PluginSource.core),
  _navigation('list', '清单', '/list', PluginSource.system),
  _navigation('forum', '论坛', '/forum', PluginSource.system),
  _navigation('ai', 'AI', '/ai', PluginSource.system),
  _navigation('campus', '校园', '/campus', PluginSource.core),
  BuiltinPlugin('luotopia.settings', '设置', PluginSource.core, [
    const PluginContribution(
      pluginId: 'luotopia.settings',
      id: 'tab',
      slot: ContributionSlot.navigation,
      title: '设置',
      icon: 'settings',
      nativeRoute: '/settings',
      protected: true,
    ),
    for (final row in [
      ('accounts', '账户', '/settings/accounts'),
      ('general', '通用设置', '/settings/general'),
      ('data', '数据更新与备份', '/settings/data-updates'),
    ])
      PluginContribution(
        pluginId: 'luotopia.settings',
        id: row.$1,
        slot: ContributionSlot.settingsRow,
        title: row.$2,
        icon: 'settings',
        nativeRoute: row.$3,
        protected: true,
      ),
  ]),
  BuiltinPlugin('luotopia.campus-info', '校园天气与通知', PluginSource.system, [
    const PluginContribution(
      pluginId: 'luotopia.campus-info',
      id: 'card',
      slot: ContributionSlot.campusCard,
      title: '校园天气与通知',
      icon: 'cloud',
      size: 'wide',
    ),
  ]),
  for (final card in [
    ('timetable', '课程表', '/campus/timetable'),
    ('seat-reservation', '自习预约', '/campus/seat-reservation'),
    ('library', '图书借阅', ''),
    ('sports-reservation', '运动场馆', '/campus/sports-reservation'),
    ('luojia-ecard', '珞珈E卡', '/campus/luojia-ecard'),
    ('ecard-payment-code', 'E卡付款码', '/campus/ecard-payment-code'),
    ('score', '成绩', '/campus/score'),
    ('empty-classroom', '空闲教室', '/campus/empty-classroom'),
    ('audit-course', '蹭课', ''),
    ('all-school-timetable', '全校课表', '/campus/all-school-timetable'),
    ('grading', '课程给分', ''),
    ('course-review', '课程评价', '/campus/course-review'),
    ('study-materials', '学习资料共享', ''),
  ])
    BuiltinPlugin('luotopia.${card.$1}', card.$2, PluginSource.system, [
      PluginContribution(
        pluginId: 'luotopia.${card.$1}',
        id: 'card',
        slot: ContributionSlot.campusCard,
        title: card.$2,
        icon: 'school',
        nativeRoute: card.$3.isEmpty ? null : card.$3,
      ),
    ]),
  for (final row in [
    ('home-settings', '首页设置', '/settings/home'),
    ('ai-settings', 'AI 设置', '/settings/ai'),
    ('notification', '通知', ''),
    ('placeholder-1', 'Lorem Ipsum', ''),
    ('placeholder-2', 'Sed Do Eiusmod', ''),
    ('placeholder-3', 'Ut Enim Ad Minim', ''),
    ('placeholder-4', 'Duis Aute Irure', ''),
    ('placeholder-5', 'Excepteur Sint', ''),
  ])
    BuiltinPlugin('luotopia.${row.$1}', row.$2, PluginSource.system, [
      PluginContribution(
        pluginId: 'luotopia.${row.$1}',
        id: 'row',
        slot: ContributionSlot.settingsRow,
        title: row.$2,
        icon: 'settings',
        nativeRoute: row.$3.isEmpty ? null : row.$3,
      ),
    ]),
];

BuiltinPlugin _navigation(
  String id,
  String name,
  String route,
  PluginSource source,
) => BuiltinPlugin('luotopia.$id', name, source, [
  PluginContribution(
    pluginId: 'luotopia.$id',
    id: 'tab',
    slot: ContributionSlot.navigation,
    title: name,
    icon: id == 'campus'
        ? 'school'
        : id == 'ai'
        ? 'star'
        : id,
    nativeRoute: route,
    protected: source == PluginSource.core,
  ),
]);
