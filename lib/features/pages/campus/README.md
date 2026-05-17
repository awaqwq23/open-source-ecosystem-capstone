## campus 目录说明

校园页是一个聚合型页面，包含多个校园子应用。主入口页面保留在 `presentation/pages/`，具体子应用放在 `sub_apps/`。

### 子应用

- `sub_apps/timetable/`：校园课程表页面；课程导入流程放在其内部 `course_import/`。
- `sub_apps/score/`：成绩页面、成绩模型与成绩服务。
- `sub_apps/seat_reservation/`：自习预约页面与授权服务。
- `sub_apps/luojia_ecard/`：珞珈 E 卡与付款码 WebView 页面。

### 边界规则

- `sub_apps/` 严格按实际校园子应用建一级目录；辅助流程放进所属子应用内部。
- 子应用内部按需要保留 `presentation / domain / data`，不为占位强行建目录。
- `features/whu_auth/` 是跨校园子应用复用的认证能力，保留在原位置，不收进校园页。
- 跨页面共享组件和实体继续放在 `shared/` 或 `features/components/`。
