# Luotopia 外部 JavaScript 插件 SDK（SPI v1）

本目录可独立复制给插件作者；无需 Flutter、App 私有 Dart 包或 npm 安装。`index.d.ts` 提供编辑器类型提示，`pack.py` 使用 Python 3.12+ 标准库完成开发期预检及打包。SDK 不提供运行引擎或宿主权限实现。权威契约见仓库的 `docs/plugins/SPI-v1.md`，本工具通过不代表 App 已可安装或已通过设备验收。

## 从示例开始

示例位于 `src/samples/plugins/study-time/`。从仓库根目录运行（Windows 可使用 `py -3.12` 替代 `python`）：

```powershell
node src/samples/plugins/study-time/test.mjs
node src/plugin/luotopia-plugin-sdk/tests/bridge-security.mjs
python -m unittest discover -s src/plugin/luotopia-plugin-sdk/tests
New-Item -ItemType Directory -Path study-time-payload
Copy-Item src/samples/plugins/study-time/manifest.json,src/samples/plugins/study-time/main.js,src/samples/plugins/study-time/LICENSE.txt study-time-payload
python src/plugin/luotopia-plugin-sdk/pack.py study-time-payload study-time-1.0.0.luoplugin
```

暂存目录必须**恰好**包含 `manifest.json`、`main.js`、`LICENSE.txt` 三个普通文件，不递归收集文件，不能放 README、测试、依赖或密钥。输出文件必须使用 `.luoplugin` 后缀且事先不存在；工具拒绝覆盖已有发行物。成功返回退出码0，失败返回非0并打印错误。命令不执行 `main.js`、不安装插件，也不连接网络。Node 只用于本地行为测试，打包只需要 Python。

## manifest 与身份

以示例 manifest 为可运行模板。必填字段为 `schemaVersion,id,name,version,apiVersion,entry,description,author,license,permissions,networkHosts,views,contributions,config`。v1 的两个版本字段均为整数1，entry 固定 `main.js`。工具拒绝未知字段，尤其不能提供 `core/nativeBuilder/route/protected` 等宿主字段。

插件ID最长96字符，符合 `^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+$`，禁止 `luotopia.` 前缀。发布版本为无前导零的 `major.minor.patch`，不能带预发布标识。更新应保持ID并提高版本，作者字段不证明身份。

版本字符串最多32字符。name、author、license均为1..128个UTF-16代码单元，description为1..2000；贡献title为1..64；配置label、选项value/label为1..128。SDK按Dart/JavaScript的UTF-16长度计算，例如两个emoji占4个代码单元。文本配置default允许空串，其他上述文本不得为空。

贡献和view ID均符合 `^[a-z][a-z0-9_-]{0,47}$`。单包最多32个贡献，局部贡献ID唯一；宿主生成 `pluginId/contributionId`。每个贡献有 `id,slot,title,icon,viewId,allowedViews`；slot只接受 `navigation/campusCard/settingsRow`。allowedViews必须包含根viewId并且全部属于本包views。导航不允许凭空跳到另一个贡献的设置页。卡片可设 `size:small|wide` 与宿主颜色名 `color`；设置行可设 `group:extensions`。图标、颜色最终由宿主支持列表验证。

views数量为1..32，networkHosts最多16，config最多32，allowedViews最多32且唯一。当前公开图标为 `timer,tune,home,list,forum,school,settings,book,calendar,star,code,cloud,chart,info`；颜色为 `sky,blue,green,amber,purple,pink,slate`，打包预检同步拒绝未知值。可选size/color/group缺省或null表示使用默认值。networkHosts需使用规范小写DNS标签（每段1..63，整名最多253），顶级域名仅2..63个英文字母；不接受IP、URL、端口、通配符、尾点及当前宿主不支持的数字/连字符顶级域名。

SDK配置字段采用以下有边界的JSON形状，全部需要 `key,type,label,default`，key唯一、符合 `^[a-zA-Z][a-zA-Z0-9_]{0,47}$`；默认值必须满足对应边界：

| type | 额外字段 | 示例 |
| --- | --- | --- |
| text | maxLength（1..4096） | `{"key":"caption","type":"text","label":"标题","default":"学习","maxLength":40}` |
| number | min、max（有限数） | `{"key":"targetMinutes","type":"number","label":"目标分钟数","default":120,"min":1,"max":1440}` |
| boolean | 无 | `{"key":"showGoal","type":"boolean","label":"显示目标","default":true}` |
| choice | options（1..100个唯一value/label） | `{"key":"unit","type":"choice","label":"单位","default":"minutes","options":[{"value":"minutes","label":"分钟"}]}` |

配置是普通偏好，v1不支持秘密字段，勿保存令牌。宿主负责校验更新后的配置，并在context.config提供结果；preferences只是普通的声明view，示例通过它展示目标，实际修改在宿主插件管理配置中完成。

## 编写 main.js

脚本须自包含，定义 `globalThis.luotopiaPlugin`，`apiVersion:1`，提供 `render(request,context)` 和 `onAction(request,context)`；可选 `activate(context)` 与 `deactivate()`。每个方法可同步返回或返回Promise。不要使用 import、require、浏览器DOM、fetch、XMLHttpRequest、Node文件系统或Shell。需要构建工具时，作者自行预打包为单个源码文件，App不运行构建步骤。

JavaScript作者可加 `// @ts-check` 和 `@type {import('./index').LuotopiaPlugin}`（按实际目录调整相对路径）；TypeScript作者可通过 `import type` 引入声明，最终交付仍只有自包含 `main.js`。类型声明不替代运行时安全校验。

context包含宿主绑定的pluginId、contributionId、viewId、locale（zh/en）、theme（light/dark）、已校验config和host。render的request含初始null的state；onAction另含actionId与当前表单input。必须验证实际业务输入，禁止宽松 `parseInt` 将 `1.5/1e2` 等意外当整数。示例接收0..1440的整数，最多100项、500字符；空项、负数、小数、非字符串均显示错误，`30,45`输出75。

activate/render只可读取自己的存储，禁止写入、网络和导航；初始化也不可弹窗。只有明确用户动作触发的onAction可调用已授权写入/网络/openView。deactivate是尽力清理，不能依靠它保存业务数据。宿主按对象方法绑定this；如使用辅助方法，也要维持绑定。

每次返回 `{state,view:{title,nodes}}`，包含完整新界面。state按view实例隔离，共享信息用插件自己的storage；不要用脚本全局变量混合多个入口状态。插件停用、更新或销毁后宿主丢弃旧generation结果，插件不能自报身份绕过此机制。

## 原生界面协议

`index.d.ts`完整列出text、input、number、toggle、select、button、list七类节点及字段。所有节点需要唯一id；button的actionId来自最近一次有效view。节点描述内容，宿主绘制导航/卡片/设置外壳，不能传HTML、CSS、Widget或任意布局脚本。输入只包含当前表单字段。

每view最多100节点，list最多200项；完整返回JSON最多256KiB、深度16，state最多64KiB。数值必须有限，不接受函数、undefined、BigInt、循环引用、NaN或Infinity。输入默认上限4096字符、表单合计64KiB；业务输入超限应拒绝，不能静默截断后计算。节点字段详见类型声明；未知节点会被宿主拒绝。

## Host API 与权限

| API | 许可与阶段 |
| --- | --- |
| `await host.storage.get(key)` | storage.self；仅当前插件命名空间，不存在返回null |
| `await host.storage.set(key,json)` / `remove(key)` | storage.self；仅用户动作；每插件1MiB，原子写入 |
| `await host.http.request({url,method,headers?,body?})` | network.https；仅用户动作；GET/POST，精确networkHosts许可 |
| `await host.openView(viewId)` | 仅用户动作；当前贡献allowedViews内，保留入口身份 |
| `host.log(level,message)` | v1接受调用但不保存或输出插件日志 |

storage key为1..128个 `[a-zA-Z0-9._-]` 字符，不是路径。networkHosts为小写精确DNS主机名，不能用通配符、端口或URL。网络仅HTTPS/443；不能带用户信息、Cookie/Authorization/Host等凭据头或自报IP，宿主另做公网IP校验、重定向检查、TLS与取消。不要访问账号Cookie、应用数据库、AI密钥或宿主文件系统：v1不提供这些能力。

HTTP默认10秒、最多3次重定向、请求体256KiB、响应1MiB，每请求最多32次能力调用（HTTP最多4次）；并发、缓冲、引擎实例和执行预算由宿主限制，超额会失败，不应自动无限重试。首版JS同步预算500ms、总请求15秒、清理100ms、引擎内存32MiB/栈1MiB，仍需真机校准。处理Promise拒绝和保存失败，勿先显示保存成功。

宿主能力调用失败时，Promise以 `Error` 拒绝，`error.message` 为错误码；不提供phase、retryable或requestId字段。Dart宿主使用 `PluginException(code,message)`，界面保留输入并展示可读错误。PERMISSION_DENIED不能改为旁路访问；超时或内存超限会终止实例；RESOURCE_LIMIT_EXCEEDED拒绝新工作；失败更新保留旧版本。错误信息勿泄露输入、凭据或原始堆栈。

## 工具检查范围与交付验收

pack.py检查三个精确文件名、普通文件/链接、严格UTF-8、重复JSON键、基本manifest及配置、ID/版本/权限/贡献/view引用、公开图标颜色、文本/列表边界、文件和包大小。manifest≤64KiB、脚本≤2MiB、LICENSE.txt≤1MiB、总解压≤10MiB、ZIP≤5MiB。仅含Dart空白字符或BOM的脚本/许可也拒绝。开发阶段预检不能检查脚本可信度、死循环、真实输出、网络安全、当前已安装版本或权限授权；宿主仍必须对实际ZIP流量、安全执行和所有返回值做最终校验。ZIP内容摘要只证明一致性，不证明作者身份。

`tests/bridge-security.mjs`从App实际runtime文件提取桥接源码，在Node VM执行原型toJSON攻击、1000次调用洪泛、绑定身份篡改及自定义toJSON结果拒绝检查。该开发回归测试需要仓库中的App源码，不是独立打包流程的依赖；它不能替代QuickJS硬中断、native资源释放和真机测试。

在具有SPI v1实现的App中手动选择包、审阅权限和三个入口后安装。分别进入导航/卡片并输入30,45确认75，设置入口查看目标；只隐藏card不影响其他入口；停用后旧链接不可进入。第二版提高version后再导入并验证失败回滚。完整接入验收还需要同一已安装APK前后摘要不变、真实Android运行和故障隔离证据。本SDK的CLI/VM测试不声称完成这些App验收。

本次开发检查及RED/GREEN记录见 `TESTING.md`。


### Personal school timetable (read only)

Declare `schoolTimetable.read` in `permissions` and obtain the normal installation approval.
From `onAction` call `context.host.schoolTimetable.listTimetables()` and
`context.host.schoolTimetable.getCourses({timetableId, offset: 0, limit: 50})`.
The host requires the app's current WHU login and checks it on every call.
Only WHU-imported personal timetables and course occurrences are returned; no
cookies, tokens, account identifiers, private notes, raw responses or write methods
are exposed. This reads the app's already imported local snapshot, not the public
all-school catalogue and not a live school-server refresh. Import/refresh first in
the existing app screen. A logged-in state alone does not prove snapshot freshness.
`limit` is 1–100, `offset` 0–100000; defaults are 50 and 0. Results are capped at
256 KiB; timetable listing returns at most 100. Unknown fields are rejected.
Login loss returns `AUTH_REQUIRED`, missing permission returns `PERMISSION_DENIED`.
The API cannot run during activate/render/package preview; use an explicit button.

Privacy boundary: only timetables imported in the current unchanged WHU login session are accessible. Account/status changes revoke session provenance and clear open plugin results. Legacy or synced snapshots and snapshots from before restart fail closed; reimport to enable access. No owner identifiers reach the plugin.
