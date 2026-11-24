String pluginPermissionLabel(String permission) => switch (permission) {
  'storage.self' => '读写本插件数据',
  'network.https' => '访问指定 HTTPS 网站',
  'schoolTimetable.read' => '读取个人课表（课程、时间和地点）',
  _ => permission,
};
