## features 目录说明

这里按“页面型功能”和“组件型功能”组织代码。模块内部按实际需要采用 `data / domain / presentation`，不为占位强行增加层级。

### 页面型模块

- `pages/home/`：主页表格页。
- `pages/list/`：日程列表页。
- `pages/forum/`：论坛页。
- `pages/campus/`：校园页。
- `pages/item_editor/`：事项添加与编辑页。
- `pages/item_detail/`：事项详情页。
- `pages/settings/`：设置页及设置二级页。

### 组件型模块

- `components/time_picker/`：日周月时间选择组件。
- `components/course_import/`：课程导入相关页面、适配器与服务。
- `components/home_widgets/`：系统桌面小组件同步能力。
- `components/wallpaper/`：应用内壁纸获取、缓存与展示能力。

### 模块边界规则

- 每个模块优先自包含。
- 跨模块通用能力抽到 `shared/` 或 `core/`。
- 模块间不要直接依赖彼此的 `data/` 实现。
- `components/home_widgets/` 的命名用于区别 Flutter `Widget` 概念，不再使用单独的 `features/widgets/`。
