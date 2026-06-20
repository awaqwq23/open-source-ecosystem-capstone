# WHU 全校课表原始数据抓取工具

这个工具由管理员在本机手动运行，用浏览器登录武汉大学教务系统后抓取全校课表 jqGrid 原始行，并输出 Luotopia 服务端可导入的数据包。

## 使用

推荐使用 TUI：

```powershell
pip install -r requirements.txt
python scrape_school_timetable.py --tui
```

TUI 支持三种模式：

- 单学期抓取。
- 输入起止学年，自动生成多个学期的抓取队列。
- 输入最新学期和最旧学期，按“最新到最旧”的顺序全量抓取。

脚本只打开一次 Chrome。每到一个学期时，请在浏览器中手动切换到对应学期并等待表格加载完成，再回到命令行按 Enter。每个学期会输出一个独立的 `.ndjson.gz` 数据包。

也可以继续使用原来的单学期命令：

```powershell
pip install -r requirements.txt
python scrape_school_timetable.py --term-key 2025-2026-1 --school-year 2025-2026 --term 1 --output 2025-2026-1.ndjson.gz
```

脚本会打开 Chrome。请在浏览器中完成统一身份认证、进入全校课表页面并加载目标学期数据后，回到命令行按 Enter。

如果已经把课表查询结果保存成 HTML，可以直接离线转换为同一上传包格式：

```powershell
python convert_saved_html.py --output output\2025-2026-2.ndjson.gz tmp\课表查询1.html tmp\课表查询2.html
```

脚本会从 HTML 原始字段中自动推断学年和学期。也可以显式指定：

```powershell
python convert_saved_html.py --term-key 2025-2026-2 --school-year 2025-2026 --term 2 --output output\2025-2026-2.ndjson.gz tmp\课表查询1.html tmp\课表查询2.html
```

离线转换会默认只输出字段齐全且至少有一个上课时间字段的合法课程行，不完整行会被跳过并在命令行报告数量。

## 输出格式

输出文件是 gzip 压缩的 NDJSON：

- 第 1 行：manifest，包含学期、字段列表、行数、生成时间、源数据校验和。
- 后续每行：一条 `row`，其中 `fields` 保留 HTML 原始字段代码和值，包括隐藏字段 `key`。离线 HTML 转换会额外写入 `_source_file`、`_source_page_index`、`_source_row_index` 和 `_source_package_index`，用于追溯包内来源行；原始 `key` 可能重复，不能作为唯一行号。
