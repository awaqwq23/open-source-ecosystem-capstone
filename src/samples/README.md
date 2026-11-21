# 课程样例

当前独立插件示例为 [plugins/study-time](plugins/study-time/README.md)：同一JavaScript包声明navigation、campusCard、settingsRow三个贡献，main计算逗号分隔的学习分钟数，preferences展示宿主配置目标。输入30,45应显示75；非法输入应明确拒绝。

按 [SDK说明](../plugin/luotopia-plugin-sdk/README.md) 将manifest.json、main.js、LICENSE.txt三个文件单独暂存并打包为 `.luoplugin`。Node脚本测试业务行为；实际Android导入、同一APK和设备验收以 [实现与验收说明](../../docs/plugins/IMPLEMENTATION.md) 最终记录为准。

[timetable-date-export.json](timetable-date-export.json) 保留旧日期CSV方案的离线合成输入与预期结果（第1、3周周一对应2026-09-07、2026-09-21），未接入当前App插件机制。旧 `docs/DESIGN.docx` 需在教师最终Word中统一更新，不将该资料标为已完成课程功能。
