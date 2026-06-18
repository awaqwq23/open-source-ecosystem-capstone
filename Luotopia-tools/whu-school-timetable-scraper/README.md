# WHU 全校课表原始数据抓取工具

这个工具由管理员在本机手动运行，用浏览器登录武汉大学教务系统后抓取全校课表 jqGrid 原始行，并输出 Luotopia 服务端可导入的数据包。

## 使用

```powershell
pip install -r requirements.txt
python scrape_school_timetable.py --term-key 2025-2026-1 --school-year 2025-2026 --term 1 --output 2025-2026-1.ndjson.gz
```

脚本会打开 Chrome。请在浏览器中完成统一身份认证、进入全校课表页面并加载目标学期数据后，回到命令行按 Enter。

## 输出格式

输出文件是 gzip 压缩的 NDJSON：

- 第 1 行：manifest，包含学期、字段列表、行数、生成时间、源数据校验和。
- 后续每行：一条 `row`，其中 `fields` 保留 HTML 原始字段代码和值，包括隐藏字段 `key`。

