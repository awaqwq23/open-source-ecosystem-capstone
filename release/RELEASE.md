# 本次版本交付

## 从验收包到公开 Release

1. **构建**。推送或合并到 `main` 会运行 **Build signed APK**。全套 CI 通过后，签名并校验 APK、插件内容和 SHA-256。打开该次运行的 **Artifacts**，下载 `signed-apk-<完整提交 SHA>-<运行尝试序号>`。PR 和 `devops` 推送执行课程 CI。
2. **验收**。解压得到 `luotopia.apk`、`luotopia.apk.sha256`。安装 APK 测试，用 `Get-FileHash .\luotopia.apk -Algorithm SHA256` 比对摘要，记录运行链接、提交 SHA、产物 ID 和摘要。产物 ID 可在上传步骤输出的 artifact URL 末尾找到。有仓库读取权限并已登录 GitHub 的用户可下载有效期内的 Actions 产物。
3. **发布**。确认分发授权与验收结果后，给已验收的 SHA 创建标签并推送。将下面示例中的 SHA 和产物 ID 替换为实际值：

   ```powershell
   git tag -a course-v0.1.0 <已验收的提交SHA> -m "发布课程验收版" -m "Artifact-ID: 123456789"
   git push origin refs/tags/course-v0.1.0
   ```

4. **领取**。**Publish tagged APK** 会核对标签提交、成功的 main 构建、产物 ID 与摘要，将原 APK 和校验文件上传到草稿后公开。最终下载入口是 **Releases → 对应标签 → Assets**。标签发布不重新签名或编译。

**命名与重试**。支持 `v1.2.3`、`course-v0.1.0` 及 `-rc.1` 等预发布后缀。一个提交只有一份有效候选产物时可省略 `Artifact-ID`。有多份时，使用附注标签明确选择验收过的那份。来源不符、构建失败、产物过期或摘要有误时停止发布；若仅上传中断，在原标签运行中选择 **Re-run failed jobs**。产物过期后须重新构建并验收，再以有效的版本标签发布。

**版本与权限**。APK 内部版本在构建时确定，默认版本名为 `0.1.N`、版本号为构建运行序号 N。需要指定 APK 内部版本时，可在 main 手动运行 **Build signed APK** 并填写版本。仓库的 Actions Secrets 需配置 `ANDROID_KEYSTORE_BASE64`、`ANDROID_KEYSTORE_PASSWORD`、`ANDROID_KEY_ALIAS`、`ANDROID_KEY_PASSWORD`。公开发布作业需要读取 Actions 产物并写入 Release 的权限。

## 课程验收记录

> 2026-11-21插件重构已完成本地测试构建和独立模拟器验证，实际结果见 [插件实现与验收说明](../docs/plugins/IMPLEMENTATION.md)。以下保留课程正式发布模板与历史记录，不代表当前本地验证状态；最终提交、Tag、组员Review及许可确认仍未完成，发布决定保持HOLD。

- **版本及选择理由** `course-v0.1.0` 为计划中的首次课程验收版本。
- **最终 Commit（完整 SHA）** 待冻结并验证最终提交。原项目基线为 `e40a726a2aff07fdd17be15668f8180bebecac53`。
- **Tag 及其目标 Commit（完整 SHA）** 待打 Tag 后填写。
- **工作区状态、构建／测试结果及 CI 真实状态** [devops 基线 CI](https://github.com/awaqwq23/open-source-ecosystem-capstone/actions/runs/44892904164) 成功。最终课程版本的 main 发布运行及安装结果待登记。
- **交付物名称、环境要求与运行命令** 计划交付 Android APK。实际文件名、系统版本、安装命令及 App 样例入口待实测。 [交付物目录](已验证交付物/README.md)
- **交付物 SHA-256、原件／副本一致性** 待取得制品并解包后填写实际摘要和比对结果。
- **核心场景及扩展操作的实际结果** 最终 APK 需复核插件导入、启停、入口展示与原业务回归。
- **本次变化、已知限制与未验证范围** 项目目录、设计初稿和合成样例已整理。运行时插件已合入，最终签名制品及课程验收记录待核对。
- **发布决定** **HOLD**。课程场景、质量检查和制品一致性尚未完成验收。

## 提交前自检

- [ ] 设计 Word 包含架构图、关键流程图、扩展示例，与最终代码一致。
- [ ] 核心场景有可重复样例，独立扩展可单独打包、启用、禁用并按约定处理错误。
- [ ] 正常、边界／失败和扩展接入有断言，已验证故意改错能触发测试失败。
- [ ] 构建与测试命令经实测，基础检查已执行，CI 有真实成功记录。
- [ ] 四人均有实质代码或测试提交，留存真实交叉审查及 AI 核验。
- [ ] 工作区干净，Tag 对应最终 Commit。实际安装和运行已验证，制品副本摘要一致。
- [ ] ZIP 包含 `.git`、源码、测试、设计 Word、依赖声明、许可、小样例和运行配置。清理秘密、缓存、IDE 文件和无关大文件。
- [ ] 从新目录解压最终 ZIP，按 README 复跑并核对 APK 摘要。

从干净的最终提交构建。核对 Tag 后，在提交 ZIP 的暂存副本填写本文件，并把 APK 放在 `project/release/已验证交付物/`。仓库以根目录 `release/` 管理课程模板。上传前以老师确认的外层 ZIP 结构为准。
