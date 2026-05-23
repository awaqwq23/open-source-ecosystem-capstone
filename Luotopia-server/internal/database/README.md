# 数据库迁移

迁移按模块归档。每个模块拥有自己的表结构，跨模块数据访问必须通过模块接口完成。

建议目录形式：

```text
internal/database/migrations/<module>/<version>_<name>.sql
```
