# Runtime Plugins Implementation Plan

> 执行方式：主代理连续实施关键路径，轻量子代理处理独立任务；统一集成验证和最终独立审阅。用户已确认设计并授权执行，不再重复请求计划批准。

**Goal:** 保留现有功能和美术，将三个入口统一插件化，并在同一安装包内导入运行外部JS插件。

**Architecture:** 受信内置插件适配原页面；外部ZIP包经校验注册，在独立有预算的JS上下文执行；宿主用原生组件渲染受验证JSON界面。统一管理器保存插件状态、入口顺序及配置，强制核心保护。

**Tech Stack:** Flutter 3.38.5、Riverpod 2、go_router 16、现有shadcn_flutter 0.0.52；运行时与ZIP依赖先审查实际源码并验证。

**Spec:** `../specs/2026-11-21-system-plugin-design.md`、`../../plugins/SPI-v1.md`。

## Global Constraints

- 原有Flutter业务、路由、账户权限、数据、视觉组件保持；现有占位功能不冒充新增实现。
- 三个入口navigation/campusCard/settingsRow；主页首位，校园/设置末尾锁定；默认布局保持。
- 外部.luoplugin文件导入即运行，无重新打包；不加载Dart/原生库/任意HTML。
- 核心保护、权限、ID与输入验证在管理/桥接层执行，不仅隐藏UI按钮。
- 包/JS/JSON/HTTP/并发预算、allowedViews、原子保存及数据恢复遵循SPI；实际依赖不能支持时更换执行后端，不虚报。
- 不推送、发布、合并或操作用户真实手机；本地构建和独立测试设备用于验收。

## Review Focus

- 导航隐藏后旧深链接和后台结果仍访问被移除能力：管理器及路由测试。
- 损坏包与升级失败覆盖旧包/数据：真实临时目录事务测试。
- 同步死循环、无限微任务和宿主请求洪泛拖垮应用：实际引擎中断及预算测试。
- 旧默认导航/备份恢复导致核心入口丢失：迁移及恢复测试。
- 修改显示名或拖动后点击打开错误业务：稳定ID组件测试与默认截图比对。

## 执行结果（2026-11-21）

已完成协议、包校验、内置目录、管理器、三个入口、Android执行器、能力桥、SDK、样例、备份迁移和CI配置。实际代码路径以 [实现与验收说明](../../plugins/IMPLEMENTATION.md) 为准，下面保留原计划，不将计划中的每个复合步骤视为单独的设备验证结论。

- Flutter全套83项通过，全App静态分析无问题；Android真实native后端4项通过。
- SDK Python 8项、Node样例和实际桥接、TypeScript接口及样例检查通过；独立副本故意引错失败、恢复通过。
- 原版/当前版44对受控截图：导航和设置完全一致，校园最大通道差异1/255。
- x64、arm64主程序release构建及签名检查通过；最终x64 APK实际导入外部包、三个入口和重启可用，导入前后已安装APK摘要相同。
- 独立代码复核发现的容量、恢复、网络、分组、视觉选择和文件读取问题已修复。
- 尚未执行arm64真机、登录校园服务、断电恢复和恶意不合作文件提供方验证；未推送、合并、发布或操作个人手机。旧课程Word和真实成员Review不属于本轮完成结论。

## 原计划 Tasks

### 1. 运行环境与基线
- [ ] 建立Flutter/Android可用环境，记录准确版本；当前feature分支复用checkout。
- [ ] 运行原测试，记录原有静态分析和构建状态；固定动态数据捕获默认界面基线。
- [ ] 审查JS候选实际依赖源码，写硬中断/内存/异步失败测试；确认可在目标发行环境使用。

### 2. 公共协议与包校验
Files: `lib/features/plugins/domain/plugin_manifest.dart`、`plugin_error.dart`、`plugin_view.dart`；`data/plugin_package.dart`；`test/features/plugins/*`。
Interfaces: `PluginManifest.fromJson(Map<String,dynamic>)`；`PluginPackage.decode(Uint8List)`；`PluginView.fromJson`；统一`PluginException(code,message)`。
- [ ] 先测试保留ID、错误版本/字段、allowedViews、ZIP超限/穿越/重复和非法UI。
- [ ] 实现不可变类型、逐字段校验和有实际流量限制的解包；同一合法包产生三个贡献。
- [ ] 写SDK类型、独立样例与打包命令，包含正常/失败用例。

### 3. 内置目录、状态与事务管理
Files: `lib/app/plugins/builtin_plugins.dart`；`lib/features/plugins/application/plugin_manager.dart`、`plugin_providers.dart`；`data/plugin_store.dart`。
Interfaces: 管理方法遵循SPI，UI从provider订阅变更；内置贡献通过稳定ID找到现有路由或native builder。
- [ ] 先测试核心锁、隐藏/停用区别、显示修改、严格排序、旧导航迁移和默认页回退。
- [ ] 实现安装预览/授权、事务安装更新、原子保存与恢复、数据保留和备份接口。
- [ ] 真实文件故障测试验证失败不覆盖旧版本，重启不重置用户配置。

### 4. JS执行器与能力桥
Files: `application/plugin_runtime.dart`、`data/plugin_http.dart`、`data/plugin_storage.dart`。
Interfaces: `render`/`onAction`按对象绑定调用；通过宿主绑定plugin/contribution/view/instance/generation授权。
- [ ] 写真实JS样例测试，覆盖输入30,45=75、异常、错误UI、同步循环/微任务/内存限制。
- [ ] 实现生命周期、后台执行、硬预算、请求取消与generation校验。
- [ ] 实现隔离存储、HTTPS目标验证/重定向/限流、仅允许作用于当前贡献的openView。
- [ ] 洪泛与跨插件访问测试；无运行时支持的平台明确错误而非偷偷降级。

### 5. 三个宿主入口与管理界面
Files: 原`app_shell.dart`、`app_router.dart`、`campus_page.dart`、`settings_page.dart`、`settings_navigation_page.dart`及新增插件页面/渲染组件。
- [ ] 先写widget测试保护原默认导航、稳定ID点击、核心锁、空态和表单结果。
- [ ] 内置插件复用原native页面/卡片；动态导航按稳定ID选择，不因布局编辑重建整个路由。
- [ ] 校园小卡/全宽卡长按排序、边缘滚动、取消/保存失败回退与无障碍替代。
- [ ] 设置保留核心，管理可选行/原分组；插件管理固定可达，完整导入/配置/更新/删除流程。

### 6. 迁移、备份与回归
Files: `app_bootstrap.dart`、`main.dart`、`settings_data_updates_page.dart`、`local_database_backup_service.dart`及对应测试。
- [ ] 备份包含隔离插件数据，恢复封存，重新导入同ID并确认后可用；授权不自动继承。
- [ ] 运行全测试、静态分析、Android构建；修复新增问题，列明既有失败。
- [ ] 比较原布局与迁移默认布局截图；测试宽/窄屏、深浅色、论坛/AI切换、卡片拖动、返回路径。

### 7. 发行模式导入验证与交付
- [ ] 独立测试Android环境安装一次APK；运行包摘要核对、导入真实外部包、三个入口及计算、停用/更新/卸载/恢复。
- [ ] 故意引错→测试失败→恢复通过，保存真实验证记录。
- [ ] 同步README/SDK/SPI实现限制与课程设计材料，产物和验证记录放本地release目录。
- [ ] 最终独立代码审阅，修复重要发现；最终完整检查后报告真实完成范围。

本计划的进度/证据记录在本地 `.tmp/plugin-refactor/progress.md`，不得把计划勾选当作运行验证。
