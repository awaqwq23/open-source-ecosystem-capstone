# 测试入口与验收

App保留 [Flutter测试](../Luotopia-app/test)，插件测试位于 [test/features/plugins](../Luotopia-app/test/features/plugins)。服务端原测试见 [Go课表包测试](../Luotopia-server/internal/modules/sub_apps/school_timetable/app/package_test.go)。

从 `src/Luotopia-app/` 运行：

```text
flutter test
flutter analyze
flutter build apk --debug
```

从仓库根目录运行独立工具检查：

```text
python -B -m unittest discover -s src/plugin/luotopia-plugin-sdk/tests
node src/samples/plugins/study-time/test.mjs
node src/plugin/luotopia-plugin-sdk/tests/bridge-security.mjs
```

可选真实网络检查：`dart run src/test/plugin_https_smoke.dart`。使用实际宿主网络实现连接公开HTTPS站点，检查TLS连接及响应；需要联网，不加入离线CI。Android原生执行检查：在App目录运行 `flutter test integration_test/plugin_runtime_test.dart -d <测试设备ID>`，仅使用隔离测试设备。

| 范围 | 核查内容 |
| --- | --- |
| manifest与包 | 三个贡献、allowedViews、权限、边界、重复JSON键、ZIP路径/大小/CRC等非法包 |
| 管理与持久化 | 核心保护、可选移除恢复、顺序、revision、安装/更新失败、备份封存及容量 |
| 表单与桥接 | 实际输入30,45计算75、错误输入、动作绑定、防重复、原型篡改和pending限制 |
| 真实Android后端 | 导入同一APK、死循环/内存/Promise/取消、native释放和其他核心功能可用性 |
| 原业务和外观 | 原导航、校园、设置、主题/尺寸及认证/返回流程的实际操作与截图对比 |

本轮执行数量、构建、实际UI和设备结果已记录在 [实现与验收说明](../../docs/plugins/IMPLEMENTATION.md)。命令和测试文件存在不表示执行通过；资源/设备未验项继续保留。A12故障注入使用独立临时副本，不在产品源码保留错误。

旧 [CSV合成样例](../samples/timetable-date-export.json) 仅为历史资料，未接入本轮插件，也不作为当前扩展验收结果。 [课程CI配置](../../.github/workflows/course-check.yml) 的实际远程结果需按提交核对。
