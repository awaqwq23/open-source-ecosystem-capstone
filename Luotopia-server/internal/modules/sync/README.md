# sync

用户允许同步的数据同步模块，覆盖日程、课程表元数据等跨端数据。

本模块不保存个人 WHU Cookie、Token、个人成绩、个人教务课表原始请求或预约状态。

## 客户端 API

- `GET /api/v1/sync/changes?cursor=0&limit=500`：拉取指定游标后的变更。
- `POST /api/v1/sync/changes`：提交本机离线变更。

同步游标使用服务端 `sync_changes.id`，不依赖客户端时间。冲突策略为删除优先；普通编辑按服务端接收顺序最后写入生效。
