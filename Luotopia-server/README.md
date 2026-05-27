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

## Docker 开发环境

后端开发环境默认只用 Docker Compose 启动状态服务，应用服务仍可直接在本机运行，便于调试和快速迭代。

```powershell
docker compose -f docker-compose.dev.yml up -d
```

默认启动内容：

- Postgres
- Redis

本机运行迁移和服务：

```powershell
go run ./cmd/migrate
go run ./cmd/server
```

需要完整容器化联调时启用 `app` profile：

```powershell
docker compose -f docker-compose.dev.yml --profile app up --build
```

服务启动后访问：

```text
http://localhost:8080/healthz
```

如需清空本地开发数据库：

```powershell
docker compose -f docker-compose.dev.yml down -v
```

## 本地配置

服务端启动时必须读取 `configs/.env` 或当前工作目录 `.env` 中声明的配置。首次运行先复制 `configs/config.example.env` 为 `configs/.env`，再按本机环境修改数据库、Redis、短信、SMTP 和令牌密钥配置。

完整容器化联调使用 `configs/config.docker.env`，其中数据库和 Redis 地址指向 Compose 内部服务名。

# 服务端架构说明

Luotopia Server 采用模块化单体。所有业务模块运行在同一个 Go 进程中，通过清晰的模块接口协作，先保证一致的数据边界和部署简单度。

## 数据边界

- 使用单 PostgreSQL 数据库。
- 每个模块拥有自己的表和迁移。
- 跨模块协作通过模块暴露的应用层接口完成，不直接读取其他模块表。
- Redis 只作为缓存、验证码、限流、会话等临时状态适配预留。
- 文件对象统一通过 `internal/platform/storage` 抽象访问。

## WHU 数据红线

WHU 统一认证完全留在客户端本地。服务端不保存 Cookie、Token、个人成绩、个人课表或预约状态，也不代理个人教务请求。

## 路由边界

- `/api/v1`：客户端 API。
- `/admin/api/v1`：后台管理 API。

二者属于同一服务进程，不拆分为独立服务。
