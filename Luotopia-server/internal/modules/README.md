# 业务模块

每个业务模块按四层组织：

- `domain`：领域模型、领域规则和模块对外语义。
- `app`：用例编排、事务边界和跨模块接口调用。
- `infra`：数据库、缓存、对象存储、外部服务等适配实现。
- `transport`：HTTP、后台接口、任务入口等输入输出适配。

跨模块协作必须通过模块接口完成，不直接访问其他模块的数据表。

## 模块目录

| 模块 | 说明 |
|---|---|
| `account/` | **账号体系**（见下） |
| `account/auth/` | 自有账号注册/登录、验证码、密码、会话与凭证 |
| `account/profile/` | 用户公开资料——昵称、头像、公开用户号 |
| `agenda-sync/` | 用户事项数据跨设备同步 |
| `forum/` | 珞珈防空洞论坛 |
| `whusb/` | 课程评价社区 |
| `push-and-pull/` | **信息推送**（见下） |
| `push-and-pull/weather/` | 天气数据代理 |
| `push-and-pull/hot_update/` | 脚本热更新发布 |
| `push-and-pull/notification/` | 推送通知（预留） |
| `push-and-pull/user-stats/` | 用户统计（预留） |
| `sub_apps/` | **客户端校园子应用**（见下） |
| `sub_apps/scores/` | 课程给分样本与聚合 |
| `sub_apps/study-materials/` | 学习资料共享 |
| `sub_apps/timetable/` | 全校课表公共数据 |

## 系统级目录

| 目录 | 说明 |
|---|---|
| `internal/backend/admin/` | 后台管理系统（含 access 权限） |
| `internal/platform/` | 基础设施（http, database, config, logger, cache 等） |
| `internal/database/` | 数据库迁移 |
