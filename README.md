# Luotopia 课程大作业

## 用户、场景与范围

武汉大学学生从原 Android App 进入「校园 → 全校课表」，按学期和关键词查课并查看教学班排课。计划添加一个独立扩展，将每周排课换算为具体日期并导出可复制的 CSV。验收只覆盖原 App 的这条课表流程，一份离线合成样例和一个扩展。校园账号、实时教务同步和其他校园服务沿用原项目范围。

本仓库是 [Enchograph/Luotopia](https://github.com/Enchograph/Luotopia) 的课程 fork，基线为 `e40a726`。通过 [课程仓库](https://github.com/awaqwq23/open-source-ecosystem-capstone) 访问。目录和设计初稿已整理，课程功能与发布待完成。

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
│  ├─ plugin/                  独立扩展占位
│  ├─ test/                    测试占位与验收预期
│  └─ samples/                 合成课表和预期结果
├─ .github/workflows/           CI
└─ release/
   ├─ 已验证交付物/              APK 放置位置
   └─ RELEASE.md
```

## 快速开始

课程环境为 Flutter 3.38.5（Dart 3.10.4）、JDK 17 和 Android SDK。以下命令从仓库根目录开始执行，使用 PowerShell：

```powershell
Set-Location src/Luotopia-app
Copy-Item .env.example .env
flutter pub get
flutter test
flutter analyze
flutter build apk --debug
```

已有 CI 记录验证了依赖安装步骤。测试和 APK 构建的实际状态见下文。在干净目录准备 `.env`，其中只填环境地址等公开示例配置。 [原项目开发说明](docs/UPSTREAM-DEVELOPMENT.md)

课程 [合成样例](src/samples/timetable-date-export.json) 中，演示教学班仅在第 1 和第 3 周的周一上课。扩展应输出 2026-09-07 和 2026-09-21 两条记录。离线样例页面入口待接入。最终 APK 安装方式见 [发布记录](release/RELEASE.md)。

## 核心与扩展

核心通过现有 ViewModel 与仓储查询教学班。扩展拟按公开契约接收学期首周周一和排课，将周次展开成日期，返回 CSV。装配位置是 App 的依赖声明和 Riverpod 启动装配。启用、禁用均需重新构建 APK。扩展执行报错时，原详情应保留并显示导出错误。

独立构建、打包和接入命令由扩展负责人在实现后填入。接入时以已固定的核心提交为基线，用 `git diff <核心基线>..<接入提交> -- src/Luotopia-app/lib/features/pages/campus/sub_apps/all_school_timetable` 核对核心目录。启用、禁用和失败情况使用同一份样例。 [系统设计](docs/DESIGN.docx) · [扩展占位](src/plugin/README.md)

## 测试与检查

从 `src/Luotopia-app/` 运行 `flutter test`、`flutter analyze` 和 `flutter build apk --debug`。基础检查选择 Flutter 静态分析。现有测试入口和需要补齐的正常、边界／失败及扩展接入断言见 [测试说明](src/test/README.md)。

故意改错示例待随扩展测试实现。计划在临时副本中把第 3 周的偏移改少 7 天，确认日期断言失败，恢复后复跑同一测试。

[课程 CI 配置](.github/workflows/course-check.yml) 默认执行 App 测试与 APK 构建。已有 [首次 CI 运行](https://github.com/awaqwq23/open-source-ecosystem-capstone/actions/runs/43910348699) 的依赖安装通过，Flutter 测试失败，APK 步骤跳过。以 [分支最新运行](https://github.com/awaqwq23/open-source-ecosystem-capstone/actions/workflows/course-check.yml?query=branch%3Acourse%2Fdelivery-scaffold) 核对当前状态，最终成功记录待完成。

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

扩展、离线样例入口、实际支持的 Android 版本和最终制品仍待验证。发布验收见 [发布记录](release/RELEASE.md)。
