# 测试占位

已有 [Flutter 测试](../../Luotopia-app/test)和 [Go 课表包测试](../../Luotopia-server/internal/modules/sub_apps/school_timetable/app/package_test.go)。课程新增测试随相关模块提交到构建工具识别的测试目录。

| 待补场景 | 预期 |
| --- | --- |
| 查课与教学班详情 | 按学期和关键词查到演示教学班。无匹配时给出提示。 |
| 扩展接入 | 用[样例](../samples/timetable-date-export.json)导出 2026-09-07 和 2026-09-21 两条记录。 |
| 禁用与错误回退 | 关闭扩展仍可查看详情。注入失败时保留原排课并提示。 |
| 临时改错再恢复 | 错误日期使测试失败，恢复后同一测试通过。 |

[课程 CI 配置](../../.github/workflows/course-check.yml)
