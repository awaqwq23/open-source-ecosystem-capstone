# Luotopia 课程大作业

## 用户、场景与范围

本轮在原 Flutter App 中实现统一插件机制，覆盖导航大模块（navigation）、校园卡片（campusCard）、设置功能行（settingsRow）。内置功能继续复用原生页面和业务服务；Android可导入独立JavaScript插件包，经预览、授权、试运行后生效，无需因导入、启用或停用重新打包宿主。其他平台保留原内置功能和插件管理，外部执行返回UNSUPPORTED_RUNTIME。

本仓库是 [Enchograph/Luotopia](https://github.com/Enchograph/Luotopia) 的课程 fork，基线为 `e40a726`。通过 [课程仓库](https://github.com/awaqwq23/open-source-ecosystem-capstone) 访问。实现位置、使用步骤和验收记录见 [插件实现与验收说明](docs/plugins/IMPLEMENTATION.md)，已在Android 35独立模拟器验证同一APK导入外部插件运行。

原“课表日期展开/CSV单扩展”属于旧方案资料，未作为本轮插件接入。`docs/DESIGN.docx` 仍是旧方案，最终提交教师的Word需要与当前 [系统插件设计](docs/superpowers/specs/2026-11-21-system-plugin-design.md) 和 [SPI](docs/plugins/SPI-v1.md) 统一更新，不能把旧Word当作当前实现说明。

```text
project/                        仓库根目录
├─ .git/
├─ README.md
├─ LICENSE
├─ .gitignore
├─ docs/DESIGN.docx
├─ src/
│  ├─ Luotopia-app/             Flutter 客户端、测试与依赖
│  ├─ Luotopia-data/            课表和校历数据
│  ├─ Luotopia-docs/            原项目开发文档
│  ├─ Luotopia-server/          Go 服务端和部署配置
│  ├─ Luotopia-tools/           课表抓取、转换和打包工具
│  ├─ Luotopia-website/         Astro 展示站
│  ├─ main/                    核心源码入口说明
│  ├─ plugin/                  独立JS SDK、打包工具与QuickJS仓库补丁
│  ├─ test/                    测试入口与验收说明
│  └─ samples/                 学习时长插件示例；另保留旧CSV资料
├─ .github/workflows/           CI
└─ release/
   ├─ 已验证交付物/              APK 放置位置
   └─ RELEASE.md
```

## 快速开始

课程环境为 Flutter 3.38.5（Dart 3.10.4）、JDK 17 和 Android SDK。以下命令从仓库根目录开始执行，使用 PowerShell：

```powershell
Set-Location src/Luotopia-app
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
flutter pub get
flutter test
flutter analyze
flutter build apk --debug
```

在干净目录准备 `.env`，其中只填环境地址等公开示例配置。上述为本地命令，不代表当前提交已经完成测试或构建；实际结果见实现与验收说明。 [原项目开发说明](docs/UPSTREAM-DEVELOPMENT.md)

独立 [学习时长示例](src/samples/plugins/study-time/README.md) 同时贡献三个入口，输入30,45计算75分钟，并通过preferences展示目标配置。打包命令见 [SDK说明](src/plugin/luotopia-plugin-sdk/README.md)。旧 [CSV合成样例](src/samples/timetable-date-export.json) 只保留为历史资料，未接入App。当前本地测试APK、插件包及摘要见 [实现与验收说明](docs/plugins/IMPLEMENTATION.md)；[课程发布记录](release/RELEASE.md) 仍用于最终提交，尚未发布。

## 核心与扩展

主页、校园和设置是受保护核心导航，账户、通用设置、备份和插件管理保持可达。清单、论坛、AI及其他可选贡献可在允许范围内管理。稳定ID决定身份与路由，改显示名不改变业务；隐藏单入口与停用/卸载整个插件分开处理。

外部包固定manifest.json、main.js、LICENSE.txt三个载荷，通过SDK的Python标准库工具生成 `.luoplugin`。宿主校验JSON界面和权限、限制执行与资源；备份不携带脚本和执行授权，恢复数据先封存，同ID重新导入仍需确认复用。SQLite与插件文件的失败补偿不等于真实断电原子提交。 [扩展入口](src/plugin/README.md) · [实现与限制](docs/plugins/IMPLEMENTATION.md)

## 测试与检查

从 `src/Luotopia-app/` 运行 `flutter test`、`flutter analyze` 和 `flutter build apk --debug`。工具测试从仓库根目录运行，命令见 [测试说明](src/test/README.md)。测试覆盖声明、管理、包校验、表单和故障行为；单元或工具检查不能替代Android实际导入、资源释放与原页面截图验收。

本轮Flutter全套83项测试、全App静态分析及Android原生运行时4项测试通过；实际UI与44对受控视觉比较的范围和限制见 [实现与验收说明](docs/plugins/IMPLEMENTATION.md)。

[课程 CI 配置](.github/workflows/course-check.yml) 和 [GitHub运行记录](https://github.com/awaqwq23/open-source-ecosystem-capstone/actions/workflows/course-check.yml) 可用于核对对应提交。历史运行不代表本轮提交状态；远程CI与最终制品结果需记录实际提交和日志。

推送或合并到 `main` 后，[构建工作流](.github/workflows/release-apk.yml) 执行全套 CI，并将签名 APK 与 SHA-256 保存到 Actions 的 Artifacts 供验收。给该提交推送版本标签后，[发布工作流](.github/workflows/publish-tagged-apk.yml) 才将同一份文件公开到 Releases。签名配置、打标签示例和重试见[发布说明](release/RELEASE.md)。

## 协作与贡献入口

在 GitHub Issues 或 PR 说明问题与验收条件，在个人分支提交改动。由另一位实际组员审查，作者回应或修正后由审查人复核，再由小组确认合并。保存实际作者、审查人、审查提交、意见和处理结果。平台不可用时把同样信息写入 README。

当前代表性改动为 [交付结构 PR #1](https://github.com/awaqwq23/open-source-ecosystem-capstone/pull/1)。真实组内 Review 及处理结果待成员完成后登记。

## 成员贡献与AI核验

| 姓名／学号 | 本人实质改动及 Commit／PR | 审查他人的改动及结果 | 关键决策与 AI 核验 |
| --- | --- | --- | --- |
| 陈同学／待填 | 本次课程核心改动待填写 | 待填写 | 待本人填写 |
| 曾同学／待填 | 独立扩展改动待填写 | 待填写 | 待本人填写 |
| awa／待填 | 页面与测试改动待填写 | 待填写 | 待本人填写 |
| 李同学／待填 | 测试与发布改动待填写 | 待填写 | 待本人填写 |

填写实际修改和审查结果。AI 核验记录一项建议、采用或拒绝的决定、验证方法及结果。未使用填写“未使用”。

## 许可与已知限制

根 [LICENSE](LICENSE) 已登记上游待授权状态。项目许可文本、许可选择理由和授权范围由权利人确认后更新。发行前按实际打包内容核对依赖与素材许可，保留相应声明。 [天气图标许可](src/Luotopia-app/assets/qweather_icons/LICENSE) · [站点素材署名](src/Luotopia-website/ATTRIBUTION.md)

外部执行仅开放Android，已验证Android 35模拟器同一APK导入、三个入口、重启及受控视觉回归；arm64真机和登录校园服务尚未验证。进程内引擎不是系统级沙箱。最终课程发布验收见 [发布记录](release/RELEASE.md)。
