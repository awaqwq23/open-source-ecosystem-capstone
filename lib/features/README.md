## features 目录说明

这里按功能模块组织代码。每个模块内部统一采用 `data / domain / presentation` 三层结构。

### 当前规划模块

- `home/`：主页表格页。
- `list/`：列表页。
- `ai/`：AI 页。
- `item_editor/`：事项添加与编辑页。
- `settings/`：设置页。
- `time_picker/`：日周月时间选择组件。
- `item_detail/`：事项详情展示组件或页面。

### 模块边界规则

- 每个模块优先自包含。
- 跨模块通用能力抽到 `shared/` 或 `core/`。
- 模块间不要直接依赖彼此的 `data/` 实现。
