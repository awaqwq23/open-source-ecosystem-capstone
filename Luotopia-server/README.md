# Luotopia Server

Luotopia Server 是 Luotopia 的 Go 模块化单体服务端骨架。

服务端只承载 Luotopia 自有账号、用户同步、运营内容、热更新、课程公共数据、论坛、课程给分/评价、资料共享等能力。WHU 统一认证、个人 Cookie、个人 Token、个人成绩、个人课表和预约状态都留在客户端本地，服务端不保存、不代理、不转发。

## 结构

- `cmd/server`：唯一长期运行的 HTTP 服务进程。
- `cmd/migrate`：数据库迁移命令入口。
- `internal/platform`：配置、数据库、缓存、存储、HTTP、日志、审计、调度等横向基础设施。
- `internal/modules`：业务模块，每个模块按 `domain / app / infra / transport` 四层组织。
- `api/openapi`：HTTP 契约占位。
- `configs`：配置模板。
- `deployments`：本地开发部署辅助。
- `docs`：服务端架构文档。

## 本地验证

```powershell
go test ./...
```
