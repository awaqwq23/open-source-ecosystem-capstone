-- 0003 移除更旧一代理库的 Postgres 规范化分表（已被实体化 KV school_timetable_entities 取代）。
-- Go 代码仅在 bundle.go/package.go 的“离线 SQLite 包”schema/查询中使用同名表（独立 SQLite 库），
-- 不通过 ORM 读写这些 Postgres 表；其数据与 entities 内对应实体计数一致，属重复遗留。
-- 依赖关系：course_heads ← offerings ← audiences/meetings，CASCADE 一次清理并解除外键。
DROP TABLE IF EXISTS school_timetable_audiences, school_timetable_meetings, school_timetable_offerings, school_timetable_course_heads CASCADE;
