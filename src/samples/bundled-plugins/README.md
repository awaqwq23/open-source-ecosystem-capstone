# 随应用分发的独立 JavaScript 插件

首批迁移五个设置占位项，以及图书借阅、蹭课、课程给分、学习资料共享四张占位卡片。每个目录恰好包含自己的 manifest、JS 页面和许可证，不依赖宿主 Dart 页面。页面当前提供真实的功能说明和展开/收起操作，尚未连接校园业务服务。

`python src/samples/bundled-plugins/build.py` 可重复生成确定性的 `.luoplugin` 文件；`node src/samples/bundled-plugins/test.mjs` 检查九个页面的渲染和操作。构建脚本专用于受信任应用资源，外部 SDK 与安装入口仍拒绝 `luotopia.` 身份。

Android 启动时从 Flutter AssetManifest 自动发现 `assets/system_plugins/` 下的包，注册为可停用、卸载和恢复的系统插件。其他平台保留原有原生入口。旧入口 ID、布局、隐藏和重命名配置保持兼容；新增系统插件无需修改 Dart 注册列表。核心插件身份不能被应用资源覆盖。

本批页面不申请存储、网络或校园数据权限。Node/Dart 检查不代替 Android QuickJS 真机验收。
