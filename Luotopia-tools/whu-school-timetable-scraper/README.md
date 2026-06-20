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

## 输出格式

输出文件是 gzip 压缩的 NDJSON：

- 第 1 行：manifest，包含学期、字段列表、行数、生成时间、源数据校验和。
- 后续每行：一条 `row`，其中 `fields` 保留 HTML 原始字段代码和值，包括隐藏字段 `key`。
