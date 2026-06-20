from __future__ import annotations

import argparse
from html.parser import HTMLParser
from pathlib import Path

from scrape_school_timetable import REQUIRED_FIELDS, TermSpec, parse_term_key, school_year_label, validate_rows, write_package


WEEKDAY_FIELDS = ("sun", "mon", "tue", "wen", "thu", "fri", "sat")


class GridParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.rows: list[dict[str, str]] = []
        self.in_row = False
        self.current_row: dict[str, str] | None = None
        self.current_code: str | None = None
        self.current_value: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = {key: value or "" for key, value in attrs}
        if tag == "tr" and "jqgrow" in values.get("class", "").split():
            self.in_row = True
            self.current_row = {}
            dom_id = values.get("id", "").strip()
            if dom_id:
                self.current_row["_dom_id"] = dom_id
            return

        if not self.in_row or tag != "td":
            return
        described_by = values.get("aria-describedby", "")
        if not described_by:
            return
        code = described_by.rsplit("_", 1)[-1].strip()
        if not code or code == "cb":
            return
        self.current_code = code
        title = values.get("title")
        self.current_value = [] if title is None or title == "" else [title]

    def handle_data(self, data: str) -> None:
        if self.current_code is not None and not self.current_value:
            self.current_value.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag == "td" and self.current_code is not None and self.current_row is not None:
            value = "".join(self.current_value).replace("\xa0", " ").strip()
            self.current_row[self.current_code] = value
            self.current_code = None
            self.current_value = []
            return

        if tag == "tr" and self.in_row and self.current_row is not None:
            if any(value for key, value in self.current_row.items() if key != "_dom_id"):
                self.rows.append(self.current_row)
            self.in_row = False
            self.current_row = None
            self.current_code = None
            self.current_value = []


def read_html(path: Path) -> str:
    data = path.read_bytes()
    for encoding in ("utf-8-sig", "utf-8", "gb18030"):
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue
    return data.decode("utf-8", errors="replace")


def parse_file(path: Path) -> list[dict[str, str]]:
    parser = GridParser()
    parser.feed(read_html(path))
    parser.close()
    return parser.rows


def infer_spec(rows: list[dict[str, str]], args: argparse.Namespace) -> TermSpec:
    school_year = args.school_year
    term = args.term
    term_key = args.term_key
    if term_key and (not school_year or not term):
        start_year, parsed_term = parse_term_key(term_key)
        school_year = school_year or school_year_label(start_year)
        term = term or parsed_term
    if not school_year:
        school_year = first_non_empty(rows, "xn")
    if not term:
        term = first_non_empty(rows, "xq")
    if not school_year or not term:
        raise RuntimeError("无法推断学年/学期，请传入 --term-key 或 --school-year 与 --term")
    if not term_key:
        term_key = f"{school_year}-{term}"
    return TermSpec(term_key=term_key, school_year=school_year, term=term, output=args.output)


def first_non_empty(rows: list[dict[str, str]], code: str) -> str:
    for row in rows:
        value = row.get(code, "").strip()
        if value:
            return value
    return ""


def is_complete_course_row(row: dict[str, str]) -> bool:
    if any(not row.get(field, "").strip() for field in REQUIRED_FIELDS):
        return False
    return any(row.get(field, "").strip() for field in WEEKDAY_FIELDS)


def main() -> None:
    parser = argparse.ArgumentParser(description="把保存下来的 WHU 全校课表 HTML 转为服务端上传包")
    parser.add_argument("html", nargs="+", help="保存下来的课表 HTML 文件，可传多页")
    parser.add_argument("--term-key", help="学期 key，例如 2025-2026-2；不传则从 HTML 推断")
    parser.add_argument("--school-year", help="学年，例如 2025-2026；不传则从 HTML 推断")
    parser.add_argument("--term", choices=("1", "2"), help="学期，1 或 2；不传则从 HTML 推断")
    parser.add_argument("--output", required=True, help="输出 .ndjson.gz 路径")
    args = parser.parse_args()

    rows: list[dict[str, str]] = []
    skipped = 0
    for page_index, raw_path in enumerate(args.html, 1):
        path = Path(raw_path)
        page_rows = parse_file(path)
        for page_row_index, row in enumerate(page_rows, 1):
            row["_source_file"] = path.name
            row["_source_page_index"] = str(page_index)
            row["_source_row_index"] = str(page_row_index)
            if not is_complete_course_row(row):
                skipped += 1
                continue
            row["_source_package_index"] = str(len(rows) + 1)
            rows.append(row)
        print(f"{path}：{len(page_rows)} 行")

    if not rows:
        raise RuntimeError("没有从 HTML 中解析到 jqGrid 课程行")

    spec = infer_spec(rows, args)
    errors = validate_rows(rows)
    if errors:
        raise RuntimeError("\n".join(errors[:20]))
    write_package(spec, rows, source="jwgl_N214599_saved_html")
    if skipped:
        print(f"已跳过不完整行：{skipped} 行")


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as err:
        print(f"错误：{err}")
        raise SystemExit(1)
