# 我的教务课表

独立校园卡片插件；仅声明 `schoolTimetable.read`。安装后点击“读取课表”。
未登录时提示到应用账户页登录；尚未导入时提示在原课程表页面导入。
展示应用中已经导入的武大课表，支持切换课表，每次显示前 50 次课程。
这是本地快照，不会替用户登录、刷新教务数据或改动课程；不包含凭据。

`node test.mjs` 验证初始视图、未登录提示和模拟快照显示。
发布包为 `release/school-timetable-1.0.0.luoplugin`，真实 Android 安装和账号读取仍需设备验收。

Privacy boundary: only timetables imported in the current unchanged WHU login session are accessible. Account/status changes revoke session provenance and clear open plugin results. Legacy or synced snapshots and snapshots from before restart fail closed; reimport to enable access. No owner identifiers reach the plugin.
