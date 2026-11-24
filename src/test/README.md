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
node src/samples/plugins/school-timetable/test.mjs
node src/samples/bundled-plugins/test.mjs
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

发布构建还会核对每个 Flutter ABI 的 QuickJS 动态库，以及预置插件和市场插件资源是否与当前提交逐字节一致。从仓库根目录运行 `python src/test/check_plugin_apk.py <APK路径>` 即可复核。

## 课表业务回归与历史 CSV 样例

从仓库根目录运行以下 PowerShell 命令。Go 版本见服务端 go.mod，课程 Flutter 版本为 3.38.5。

```powershell
$env:TIMETABLE_CONTRACT_BUNDLE = Join-Path ([System.IO.Path]::GetTempPath()) ("luotopia-" + [guid]::NewGuid() + ".sqlite.gz")
Push-Location src/Luotopia-server
go mod download
go mod verify
go vet ./...
go test -count=1 -mod=readonly ./...
Pop-Location
Push-Location src/Luotopia-app
if (!(Test-Path .env)) { Copy-Item .env.example .env }
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub
Pop-Location
python -B -m unittest discover -s src/test -v
```

| 覆盖范围 | 输入和断言 |
| --- | --- |
| Go 与 Flutter 的全量包契约 | Go 读取合成 SQLite 源包，使用生产代码生成压缩数据包。Flutter 导入同一文件，搜索“软件工程”，核对教学班的周五、第 1 和 2 周、教室 3区1-101。CI 将 Go 作业的文件传给 Flutter 作业。 |
| 增量同步与详情 | 读取课程 JSON 样例，走真实 Drift 数据库、Riverpod 查询和详情逻辑，核对首周周一、星期、周次、节次和地点，并检查无匹配课程和无效教学班 ID。页面测试还从真实全校课表页输入关键词，点击课程、教学班，核对详情中的地点。 |
| CSV 日期及行数 | 验收工具比对课程 JSON 中的两个预期日期。示例测试覆盖正常、第三周错写成第二周、缺行、重复和空结果。 |

从 App 单独运行 Flutter 测试时，只有跨语言用例需要上述环境变量；路径已设置但文件缺失会令测试失败。检查实际导出的 UTF-8 CSV 可运行：

```powershell
python src/test/check_export.py export.csv --date-column 日期
```

将最后一个参数换成实际表头。正确样例退出码为 0；将 2026-09-21 改为 2026-09-14 会显示实际与预期并返回 1，恢复后重新通过。校验器仅验收样例的日期列和行数。本轮运行时插件的验收见上方插件测试。

[课程 CI](../../.github/workflows/course-check.yml) 对变更的 Dart 文件执行格式检查，对 App 全量执行静态分析与测试。依赖检查覆盖 Flutter 锁文件和 Go 模块完整性。
