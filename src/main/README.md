# 核心源码

原项目的校园、课表、账户和其他业务仍沿用原工程目录。新增统一插件机制将navigation、campusCard、settingsRow三处入口交给管理器；受保护核心项保持可达，可选内置项复用原页面，外部JS经公开协议接入。

- [Flutter App 源码](../Luotopia-app/lib)
- [插件域、管理、运行时与UI](../Luotopia-app/lib/features/plugins)
- [内置受信贡献目录](../Luotopia-app/lib/features/plugins/domain/builtin_plugins.dart)
- [全校课表核心模块](../Luotopia-app/lib/features/pages/campus/sub_apps/all_school_timetable)
- [Go 服务端源码](../Luotopia-server)
- [Astro 展示站源码](../Luotopia-website)

外部执行当前仅Android，其他平台保留原内置功能和管理。实际构建、设备运行和视觉验收以 [实现与验收说明](../../docs/plugins/IMPLEMENTATION.md) 的最终记录为准。旧日期CSV方案未接入，不能据旧 `docs/DESIGN.docx` 推断当前实现。
