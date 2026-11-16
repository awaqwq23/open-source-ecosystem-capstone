## lib 目录说明

本目录采用轻量 `MVVM + feature-first` 组织方式。顶层先区分应用装配、基础设施、共享业务与功能代码；`features/` 内再按页面型功能和组件型功能归类。

### 顶层分层

- `app/`：应用装配层，负责启动、路由、全局页面骨架。
- `core/`：纯基础设施层，放跨业务的底层能力。
- `shared/`：跨功能共享的业务概念与通用组件。
- `features/`：按页面和组件归类的功能模块，每个模块内部遵循 MVVM。

### MVVM 约束

- `presentation/`：页面、组件、`ViewModel`，只处理 UI 状态与交互编排。
- `domain/`：业务规则、实体、仓储接口、用例，不依赖 Flutter UI。
- `data/`：数据源、DTO、Mapper、仓储实现，负责对接本地存储、远端同步等。

### 依赖方向

- `presentation -> domain`
- `data -> domain`
- `app -> features/core/shared`
- 功能模块之间禁止直接深度耦合，跨模块复用优先进入 `shared/`。

### features 归类

- `features/pages/`：完整页面入口，例如主页、日程页、论坛页、校园页、事项编辑页、设置页。
- `features/components/`：可被页面调用的独立组件或跨端能力，例如时间选择器、桌面小组件同步。
- 页面内部的子应用放在所属页面模块下，例如校园页使用 `features/pages/campus/sub_apps/`。
- 页面型与组件型模块内部都按实际需要保留 `presentation / domain / data`，不为占位强行建目录。

### 当前阶段

当前应用层与页面框架统一建立在 `shadcn_flutter` 与 Material 组件体系上。
项目不再维护私有页面骨架、私有顶部栏、私有弹层脚手架；页面应直接组合组件库公开组件，并只保留必要的业务型 UI 代码。

### 目录维护约束

- 不再维护模板化空目录；目录在首次落地代码时再创建。
- 不使用 `.gitkeep` 保存占位目录。
- 新增目录前先确认是否已有可复用目录，避免“同义目录”并存。

### 导入白名单（强约束）

- `domain` 层禁止导入任意 `presentation/*` 和 `data/*`。
- `presentation` 层优先导入 `domain` 的类型/接口；跨 feature 访问优先走 `domain` 暴露入口。
- `shared` 统一使用 `shared/domain/entities/*` 与 `shared/domain/repositories/*`，不再增加并行别名入口。
