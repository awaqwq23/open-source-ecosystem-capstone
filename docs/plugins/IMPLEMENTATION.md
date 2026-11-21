# 插件机制实现与使用说明

本轮在原Flutter App中统一管理导航、校园卡片和设置行，并提供Android外部JavaScript插件执行路径。原业务继续使用原生页面与服务。完整协议见 [SPI-v1.md](SPI-v1.md)，需求和验收清单见 [系统插件设计](../superpowers/specs/2026-11-21-system-plugin-design.md)。本文描述实现和操作方式；测试结果以文末记录为准。

## 三个入口与管理边界

| 贡献位置 | 用途 | 示例 |
| --- | --- | --- |
| navigation | 导航大模块 | 清单、论坛、AI、学习统计 |
| campusCard | 校园卡片 | 天气与通知、课程表、外部学习统计卡片 |
| settingsRow | 设置功能行 | 可选设置、外部插件preferences入口 |

主页、校园、设置是受保护核心导航；主页固定首位，校园和设置固定末尾两项。账户、通用设置、数据更新与备份及插件管理保持可达。核心保护由宿主管理层实施，外部包不能自称核心，也不能覆盖 `luotopia.` 命名空间。

清单、论坛、AI以及校园和设置中的可选入口可以按允许范围停用、隐藏、恢复、排序或修改显示信息。隐藏单个贡献只影响该入口；停用整个插件影响其全部贡献。内置可选项的移除保留随App发布的代码与原业务数据；外部卸载默认封存本插件数据。恢复默认布局恢复内置项、清除显示覆盖与顺序，隐藏外部贡献，保留外部包和数据。

入口身份使用 `pluginId/contributionId`，不依赖显示名或数组位置。外部页面路径为 `/plugins/:pluginId/:contributionId/:viewId`，访问时重新检查启用、可见性和allowedViews。

## 打包与导入示例

独立示例位于 `src/samples/plugins/study-time/`，同一包贡献三个入口，main计算时长，preferences展示目标分钟数。`30,45`应得到75；负数、空项、小数、超限和非字符串输入应拒绝。配置由宿主插件管理校验后提供，示例不申请网络或存储权限。

在仓库根目录运行，需Python 3.12+；Node用于行为测试，打包仅使用Python标准库：

```powershell
node src/samples/plugins/study-time/test.mjs
python -B -m unittest discover -s src/plugin/luotopia-plugin-sdk/tests
New-Item -ItemType Directory -Path study-time-payload
Copy-Item src/samples/plugins/study-time/manifest.json,src/samples/plugins/study-time/main.js,src/samples/plugins/study-time/LICENSE.txt study-time-payload
python src/plugin/luotopia-plugin-sdk/pack.py study-time-payload study-time-1.0.0.luoplugin
```

暂存目录必须恰好包含manifest.json、main.js、LICENSE.txt三个普通UTF-8文件；README、测试、依赖和密钥不入包。输出文件必须尚不存在。SDK的README和index.d.ts位于 `src/plugin/luotopia-plugin-sdk/`，作者不需要Flutter或宿主私有Dart包。

在Android App进入“设置 → 通用设置 → 插件管理”，选择 `.luoplugin` 文件，核对来源、版本、SHA-256摘要、申请权限和三个贡献后确认。宿主先用PluginPackage.decode形成预览，再受限试运行，成功提交后刷新入口。摘要表示文件一致性，不证明作者身份。同ID更高版本通过同一导入流程更新，失败保留旧状态；复用封存数据需要单独确认。

Android导入使用专用原生文件选择/读取通道：`src/Luotopia-app/lib/features/plugins/data/plugin_package_picker.dart` 与 `src/Luotopia-app/android/app/src/main/kotlin/org/openwhu/luotopia/PluginPackagePicker.kt`。替换通用file_selector路径，是因为文档提供方可能改写文件后缀，且通用路径可能在校验前分配整个文件。当前按包内容验证，以大小元数据和实际读取流双重执行5MiB限额；读取预算15秒，配合取消信号，超时未安全退出则隔离导入通道并要求重启。恶意且不合作的文档提供方尚未实测，不能把普通文件超限测试当作该场景通过。

## 课堂演示的五个阶段

1. **发现**：打开 `src/Luotopia-app/lib/features/plugins/domain/builtin_plugins.dart` 查看受信内置目录；再查看示例manifest的三个贡献。说明来源分类与展示位置是两套独立概念。
2. **注册**：从 `src/Luotopia-app/lib/features/plugins/data/plugin_package.dart` 的decode进入 `src/Luotopia-app/lib/features/plugins/application/plugin_manager.dart` 的install，展示包校验、权限预览、试运行和持久化提交。更新使用install的update参数，不重新构建宿主。
3. **激活**：查看 `src/Luotopia-app/lib/features/plugins/runtime/plugin_session.dart`。每个外部view/session按需打开独立引擎，调用activate；能力始终绑定宿主掌握的插件、贡献和generation。
4. **渲染**：输入30,45触发onAction。外部脚本返回完整JSON结果，`src/Luotopia-app/lib/features/plugins/domain/plugin_view.dart`校验，`src/Luotopia-app/lib/features/plugins/presentation/plugin_view_content.dart`用原生表单、文本、按钮和列表绘制；脚本不能提供HTML、CSS或任意Flutter组件。
5. **失败**：演示非法输入、隐藏入口或错误包；结合 `src/Luotopia-app/test/features/plugins/` 中的测试说明旧状态保留、深链接检查、持久化失败及资源限制。死循环、内存和native释放须使用对应真实后端测试证据，不以错误弹窗代替。

## 执行、安全与备份限制

外部执行当前仅开放Android；其他平台保留原内置功能和管理，外部导入执行报告UNSUPPORTED_RUNTIME。内置目录直接复用原业务，不通过外部JS重写认证、数据库、教务或AI会话。

外部运行后端为 `src/plugin/flutter_qjs_next/` 的1.5.1仓库补丁。native调用窗口100ms、每请求累计JS工作500ms、总请求15秒；单引擎32MiB堆、1MiB栈，最多4个引擎、每插件3个view。空闲关闭尽力执行deactivate最多100ms；关闭不运行pending jobs，确认native释放后才归还容量。1秒看门狗未确认释放则结束isolate并隔离该名额，要求重启，不能据kill推断native堆已释放。

Host API只提供本插件存储、明确授权HTTPS、当前贡献allowedViews内导航及当前不交付内容的日志方法。初始化/render只读，写入、网络和导航要求用户动作。网络有精确域名、公网地址、重定向、取消、并发和流量限制；不提供账户Cookie、AI密钥、宿主文件系统、任意路由或其他插件数据。完整数值和接口以SPI为准。进程内引擎仍需要维护与校准。

包固定三个文件，manifest≤64KiB、脚本≤2MiB、许可≤1MiB、ZIP≤5MiB。活动包、保留包元信息、活动数据和封存数据按ID去重后合计最多16个命名空间，整个插件状态文件≤64MiB；卸载保留数据仍占名额，可在“待重新导入”行永久删除保留数据释放。

备份导出v4并兼容读取v3。v4包含插件元信息、布局、非敏感配置和业务数据，不带脚本或执行授权。恢复会撤下备份涉及的同ID活动包、权限与数据，封存备份数据；其他插件保留。导入确认提前告知这一替换行为。之后同ID可重新导入同版本，重新授权并明确确认复用数据；ID相同不代表作者相同。

PluginStore使用pending文件、活动快照和上一份快照。数据库恢复在SQLite行校验后、commit前写插件快照；捕获数据库失败时补偿旧插件快照，commit成功才发布manager内存状态。这是已处理异常的协调机制，不能宣称SQLite与独立JSON文件在真实断电时原子提交；断电/进程中断恢复仍需专项验证。

## 测试记录

已实际执行的验证：

| 项目 | 结果与范围 |
| --- | --- |
| Flutter全套测试 | 83项通过；命令为 `flutter test --no-pub` |
| 全App静态分析 | `flutter analyze --no-pub`：No issues found |
| SDK类型检查 | tsc检查index.d.ts和实际示例main.js通过 |
| Android原生集成 | Android 35模拟器emulator-5580，`src/Luotopia-app/integration_test/plugin_runtime_test.dart` 的4项全部通过；包含加载/调用死循环、无限Promise、堆超限、恶意getter、generation撤销、启动取消和native释放确认 |
| 实际HTTPS | Windows执行 `src/test/plugin_https_smoke.dart`，受控HTTPS GET返回200；该检查使用真实公网，不作为离线测试保证 |

独立工具与故障注入：

- `python -B -m unittest discover -s src/plugin/luotopia-plugin-sdk/tests`：8个测试方法通过，使用真实CLI与ZIP产物断言。
- `node src/samples/plugins/study-time/test.mjs`：通过，涵盖75分钟结果及非法输入。
- `node src/plugin/luotopia-plugin-sdk/tests/bridge-security.mjs`：通过，执行从App提取的实际桥接源码，检查原型篡改、pending预算及绑定身份；不执行Dart worker或native引擎。
- A12独立副本：仅在 `.tmp/plugin-refactor/a12-study-time/` 将累加器改错，测试以退出码1检测到期望75、实际0；恢复后退出码0。主产品代码未作故障注入。

### Android系统选择器与实际页面

在Android 35模拟器emulator-5580上，使用release主APK的系统文件选择器导入2370字节的学习时长包，包SHA-256为 `a7e50c09c997c33e94bdb1e317d9079c1f3fd6d8731c9e7ef517f8cdacbca343`。导航和校园卡片入口分别输入30,45，均显示75分钟；设置preferences显示目标120，在管理配置改为240后，导航结果显示目标240。原生picker拒绝6MiB文件。核心清单创建 `PluginSmokeTask` 后重启App，该任务仍可见。

证据位于 `release/plugin-refactor/screenshots/device-*.png`，包括 [导入预览](../../release/plugin-refactor/screenshots/device-import-preview.png)、[导航75分钟](../../release/plugin-refactor/screenshots/device-plugin-nav-75.png)、[卡片75分钟](../../release/plugin-refactor/screenshots/device-plugin-card-75.png)、[preferences](../../release/plugin-refactor/screenshots/device-plugin-settings-open.png)、[配置240](../../release/plugin-refactor/screenshots/device-plugin-config-240.png)、[超限拒绝](../../release/plugin-refactor/screenshots/device-oversize-rejected.png) 和 [重启后清单](../../release/plugin-refactor/screenshots/device-restart-core-task.png)。

### 受控视觉回归

共44对原版/当前版Widget截图：导航20对、设置16对逐像素差异为0；校园8对最大通道差异为1/255。详见 [视觉比较报告](../../release/plugin-refactor/screenshots/VISUAL-COMPARISON.md)。这些图使用受控Widget测试字体、固定未登录账户/天气/通知、无网络与固定壁纸条件；导航内容为固定stub，因此证明范围是宿主控件和布局，不代表真实设备字体、登录后的校园服务或全部业务已验。

### 最终制品记录

2026-11-21完成最终主程序 `lib/main.dart` 的release构建，包含原生文件读取取消、超时和隔离处理。以下文件保存在本地 `release/plugin-refactor/`，使用Android Debug测试证书签名，未发布。

| 文件 | SHA-256 |
| --- | --- |
| luotopia-plugins-android-x64.apk | `a12901456d505d0eee749c17a9bca59aace1e1a3f527ad6fd536ca2d2cac7fc5` |
| luotopia-plugins-android-arm64.apk | `185de027b4e9005d34f16810253f185277e8a02e5ebed34f2a485d901b2e9052` |
| study-time-1.0.0.luoplugin | `a7e50c09c997c33e94bdb1e317d9079c1f3fd6d8731c9e7ef517f8cdacbca343` |

在最终x64 APK上重复执行系统文件选择器导入，验证 [6MiB超限拒绝](../../release/plugin-refactor/screenshots/device-final-oversize-rejected.png)、[合法包预览](../../release/plugin-refactor/screenshots/device-final-import-preview.png)、[导航计算75](../../release/plugin-refactor/screenshots/device-final-nav-75.png)、[校园卡片打开](../../release/plugin-refactor/screenshots/device-final-card-open.png)、[设置目标120](../../release/plugin-refactor/screenshots/device-final-settings-open.png)，以及 [强制停止并重启后打开插件](../../release/plugin-refactor/screenshots/device-final-restart-nav.png)。导入前、导入后及重启后的已安装base.apk摘要均为上表x64摘要，安装路径也一致；期间未重新安装或构建App。原生运行时4项测试先于最终picker改动执行，之后引擎和桥接代码未变。

配置修改、单入口隐藏、停用、卸载、保留数据删除和默认布局恢复在前一轮release主APK中实际操作通过；这些操作涉及的Dart代码与最终版本相同。最终版本重新验证范围如上，不把前轮操作描述为全部重新执行。安装方法和产物索引见 [本地测试交付](../../release/plugin-refactor/README.md)。

当前使用测试签名。尚未验证arm64真机、登录校园服务、真实断电及恶意不合作文档提供方；远程CI和上架未登记结果。上述证据不替代真实成员Review，也不表示全部课程评分要求或生产安全认证已经完成。
