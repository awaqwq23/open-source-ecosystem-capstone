# 插件SDK与运行后端

当前App提供navigation、campusCard、settingsRow三个插件贡献位置。外部JavaScript包通过公开JSON协议返回原生界面，在Android经导入预览、授权和试运行后接入，无需重新构建宿主；其他平台保留内置功能和管理，外部执行报告UNSUPPORTED_RUNTIME。

- [luotopia-plugin-sdk](luotopia-plugin-sdk/README.md)：index.d.ts、Python标准库pack.py、开发说明及CLI/桥接测试。
- [学习时长示例](../samples/plugins/study-time/README.md)：独立三个载荷文件，三个贡献及preferences配置。
- [flutter_qjs_next](flutter_qjs_next)：1.5.1仓库补丁后端，由App path依赖装配；不是外部包可携带的原生库。
- [实现与验收说明](../../docs/plugins/IMPLEMENTATION.md)、[SPI](../../docs/plugins/SPI-v1.md)：实际使用、边界、测试与Android模拟器验证结果。

旧日期CSV扩展和 `packages/timetable_date_export/` 是历史方案，未作为本轮插件实现接入。`docs/DESIGN.docx` 仍需在教师最终Word中统一更新。独立真实业务插件、作者贡献和真实组员Review由实际成员完成并登记，SDK示例不替代这些记录。
