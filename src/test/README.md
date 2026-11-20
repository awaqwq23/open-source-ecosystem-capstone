# 课表集成与契约测试

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

将最后一个参数换成实际表头。正确样例退出码为 0；将 2026-09-21 改为 2026-09-14 会显示实际与预期并返回 1，恢复后重新通过。校验器仅验收样例的日期列和行数。等扩展及 App 离线入口实现后，还需从页面实际触发复制，覆盖启用、禁用、错误提示和保留详情。

[课程 CI](../../.github/workflows/course-check.yml) 对变更的 Dart 文件执行格式检查，对 App 全量执行静态分析与测试。依赖检查覆盖 Flutter 锁文件和 Go 模块完整性。
