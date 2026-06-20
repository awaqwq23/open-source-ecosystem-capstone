from __future__ import annotations

import argparse
import gzip
import hashlib
import json
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


TARGET_URL = "https://jwgl.whu.edu.cn/design/viewFunc_cxDesignFuncPageIndex.html?gnmkdm=N214599&layout=default"
REQUIRED_FIELDS = {"key", "xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs"}


@dataclass(frozen=True)
class TermSpec:
    term_key: str
    school_year: str
    term: str
    output: str


def setup_driver(headless: bool) -> webdriver.Chrome:
    try:
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options
        from selenium.webdriver.chrome.service import Service
    except ImportError as err:
        raise RuntimeError(
            "无法导入 Selenium。请先在当前 Python 环境运行："
            "python -m pip install -r requirements.txt"
        ) from err

    options = Options()
    if headless:
        options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    return webdriver.Chrome(service=Service(executable_path=None), options=options)


def parse_school_year(value: str) -> int:
    parts = value.strip().split("-")
    if len(parts) != 2 or not all(part.isdigit() for part in parts):
        raise ValueError("学年格式应为 YYYY-YYYY，例如 2025-2026")
    start = int(parts[0])
    end = int(parts[1])
    if end != start + 1:
        raise ValueError("学年结束年份必须是开始年份 + 1")
    return start


def school_year_label(start_year: int) -> str:
    return f"{start_year}-{start_year + 1}"


def parse_term_key(value: str) -> tuple[int, str]:
    parts = value.strip().split("-")
    if len(parts) != 3:
        raise ValueError("学期 key 格式应为 YYYY-YYYY-N，例如 2025-2026-1")
    school_year = f"{parts[0]}-{parts[1]}"
    start_year = parse_school_year(school_year)
    term = parts[2]
    if term not in {"1", "2"}:
        raise ValueError("学期只能是 1 或 2")
    return start_year, term


def term_key(start_year: int, term: str) -> str:
    return f"{school_year_label(start_year)}-{term}"


def default_latest_term_key() -> str:
    now = datetime.now()
    if now.month >= 9:
        start_year = now.year
        term = "1"
    elif now.month >= 2:
        start_year = now.year - 1
        term = "2"
    else:
        start_year = now.year - 1
        term = "1"
    return term_key(start_year, term)


def default_output(term: str, output_dir: str) -> str:
    return str(Path(output_dir) / f"{term}.ndjson.gz")


def spec_from_key(value: str, output_dir: str) -> TermSpec:
    start_year, term = parse_term_key(value)
    key = term_key(start_year, term)
    return TermSpec(
        term_key=key,
        school_year=school_year_label(start_year),
        term=term,
        output=default_output(key, output_dir),
    )


def generate_year_range(start_school_year: str, end_school_year: str, descending: bool, output_dir: str) -> list[TermSpec]:
    start = parse_school_year(start_school_year)
    end = parse_school_year(end_school_year)
    if start > end:
        raise ValueError("起始学年不能晚于结束学年")
    specs = [
        spec_from_key(term_key(year, term), output_dir)
        for year in range(start, end + 1)
        for term in ("1", "2")
    ]
    if descending:
        specs.reverse()
    return specs


def generate_descending_terms(latest: str, oldest: str, output_dir: str) -> list[TermSpec]:
    latest_year, latest_term = parse_term_key(latest)
    oldest_year, oldest_term = parse_term_key(oldest)
    current = (latest_year, int(latest_term))
    stop = (oldest_year, int(oldest_term))
    if current < stop:
        raise ValueError("最新学期不能早于最旧学期")
    specs = []
    while current >= stop:
        year, term = current
        specs.append(spec_from_key(term_key(year, str(term)), output_dir))
        current = (year, 1) if term == 2 else (year - 1, 2)
    return specs


def prompt(text: str, default: str | None = None) -> str:
    suffix = f" [{default}]" if default else ""
    value = input(f"{text}{suffix}: ").strip()
    return value or (default or "")


def prompt_choice(text: str, choices: dict[str, str], default: str) -> str:
    print(text)
    for key, label in choices.items():
        marker = "（默认）" if key == default else ""
        print(f"  {key}. {label}{marker}")
    while True:
        value = prompt("请选择", default)
        if value in choices:
            return value
        print("输入无效，请重新选择。")


def build_tui_specs() -> list[TermSpec]:
    print("WHU 全校课表抓取 TUI")
    output_dir = prompt("输出目录", "output")
    mode = prompt_choice(
        "选择抓取模式",
        {
            "1": "单学期",
            "2": "起止学年生成队列",
            "3": "全量抓取：最新到最旧",
        },
        "3",
    )
    if mode == "1":
        key = prompt("学期 key", default_latest_term_key())
        specs = [spec_from_key(key, output_dir)]
    elif mode == "2":
        start = prompt("起始学年", "2025-2026")
        end = prompt("结束学年", start)
        order = prompt_choice("队列顺序", {"1": "从旧到新", "2": "从新到旧"}, "1")
        specs = generate_year_range(start, end, order == "2", output_dir)
    else:
        latest = prompt("最新学期 key", default_latest_term_key())
        oldest = prompt("最旧学期 key")
        specs = generate_descending_terms(latest, oldest, output_dir)

    print("\n将按以下队列抓取：")
    for index, spec in enumerate(specs, 1):
        print(f"  {index}. {spec.term_key} -> {spec.output}")
    confirm = prompt("确认开始？输入 y 继续", "y").lower()
    if confirm not in {"y", "yes"}:
        raise RuntimeError("已取消")
    return specs


def login_and_wait(driver: webdriver.Chrome) -> None:
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support import expected_conditions as EC
    from selenium.webdriver.support.ui import WebDriverWait

    driver.get(TARGET_URL)
    try:
        button = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.ID, "tysfyzdl"))
        )
        button.click()
    except Exception:
        pass
    driver.maximize_window()
    input("请在浏览器中完成登录并进入全校课表页面，然后按 Enter 继续...")


def wait_for_term_ready(spec: TermSpec) -> None:
    input(f"请在浏览器中切换到 {spec.term_key} 学期并等待表格加载完成，然后按 Enter 开始抓取...")


def table_id(driver: webdriver.Chrome) -> str:
    from selenium.webdriver.common.by import By

    tables = driver.find_elements(By.CSS_SELECTOR, "table.ui-jqgrid-btable")
    if not tables:
        raise RuntimeError("未找到 jqGrid 表格")
    value = tables[0].get_attribute("id")
    if not value:
        raise RuntimeError("jqGrid 表格缺少 id")
    return value


def total_pages(driver: webdriver.Chrome) -> int:
    return int(
        driver.execute_script(
            """
            const pageSpan = document.querySelector('span[id^="sp_1_"]');
            if (pageSpan && pageSpan.textContent.trim()) {
              return parseInt(pageSpan.textContent.trim(), 10) || 1;
            }
            return 1;
            """
        )
        or 1
    )


def goto_page(driver: webdriver.Chrome, page: int) -> None:
    from selenium.webdriver.support.ui import WebDriverWait

    ok = driver.execute_script(
        """
        const pageInputs = Array.from(document.querySelectorAll('.ui-pg-input'));
        const input = pageInputs.find((item) => window.getComputedStyle(item).display !== 'none');
        if (!input) return false;
        input.value = arguments[0].toString();
        input.dispatchEvent(new KeyboardEvent('keypress', {
          key: 'Enter', code: 'Enter', keyCode: 13, which: 13, bubbles: true
        }));
        return true;
        """,
        page,
    )
    if not ok:
        raise RuntimeError(f"无法跳转到第 {page} 页")
    WebDriverWait(driver, 15).until(
        lambda d: d.execute_script("return document.readyState") == "complete"
    )


def extract_current_page(driver: webdriver.Chrome, grid_id: str) -> list[dict[str, str]]:
    rows = driver.execute_script(
        """
        const gridId = arguments[0];
        const result = [];
        for (const tr of document.querySelectorAll(`#${gridId} tr.jqgrow`)) {
          const row = {};
          for (const td of tr.querySelectorAll('td[aria-describedby]')) {
            const describedBy = td.getAttribute('aria-describedby') || '';
            const code = describedBy.substring(describedBy.lastIndexOf('_') + 1);
            if (!code || code === 'cb') continue;
            const title = td.getAttribute('title');
            const text = (title == null || title === '') ? td.textContent : title;
            row[code] = (text || '').replace(/\\u00a0/g, ' ').trim();
          }
          if (Object.values(row).some((value) => value !== '')) result.push(row);
        }
        return result;
        """,
        grid_id,
    )
    return [{str(k): str(v) for k, v in row.items()} for row in rows]


def validate_rows(rows: list[dict[str, str]]) -> list[str]:
    errors = []
    for index, row in enumerate(rows, 1):
        missing = sorted(field for field in REQUIRED_FIELDS if not row.get(field))
        if missing:
            errors.append(f"第 {index} 行缺少字段：{', '.join(missing)}")
    return errors


def write_package(spec: TermSpec, rows: list[dict[str, str]], source: str = "jwgl_N214599_dom") -> None:
    field_codes = sorted({code for row in rows for code in row.keys()})
    canonical_rows = [
        {"type": "row", "fields": {code: row.get(code, "") for code in field_codes}}
        for row in rows
    ]
    rows_payload = "\n".join(json.dumps(row, ensure_ascii=False, separators=(",", ":")) for row in canonical_rows)
    source_checksum = "sha256:" + hashlib.sha256(rows_payload.encode("utf-8")).hexdigest()
    manifest = {
        "type": "manifest",
        "schema_version": 1,
        "term_key": spec.term_key,
        "school_year": spec.school_year,
        "term": spec.term,
        "field_codes": field_codes,
        "row_count": len(rows),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": source,
        "source_checksum": source_checksum,
    }
    Path(spec.output).parent.mkdir(parents=True, exist_ok=True)
    with gzip.open(spec.output, "wt", encoding="utf-8", newline="\n") as file:
        file.write(json.dumps(manifest, ensure_ascii=False, separators=(",", ":")))
        file.write("\n")
        file.write(rows_payload)
        file.write("\n")
    print(f"已写出 {spec.output}，共 {len(rows)} 行，checksum={source_checksum}")


def scrape_one_term(driver: webdriver.Chrome, spec: TermSpec) -> None:
    wait_for_term_ready(spec)
    grid_id = table_id(driver)
    pages = total_pages(driver)
    rows = []
    for page in range(1, pages + 1):
        if page > 1:
            goto_page(driver, page)
        page_rows = extract_current_page(driver, grid_id)
        print(f"{spec.term_key} 第 {page}/{pages} 页：{len(page_rows)} 行")
        rows.extend(page_rows)
    errors = validate_rows(rows)
    if errors:
        raise RuntimeError("\n".join(errors[:20]))
    write_package(spec, rows)


def scrape_specs(specs: list[TermSpec], headless: bool, interactive: bool) -> None:
    driver = setup_driver(headless)
    try:
        login_and_wait(driver)
        index = 0
        while index < len(specs):
            spec = specs[index]
            print(f"\n[{index + 1}/{len(specs)}] 准备抓取 {spec.term_key}")
            try:
                scrape_one_term(driver, spec)
                index += 1
            except Exception as err:
                if not interactive:
                    raise
                print(f"抓取 {spec.term_key} 失败：{err}")
                action = prompt_choice("请选择后续动作", {"1": "重试", "2": "跳过", "3": "退出"}, "1")
                if action == "2":
                    index += 1
                elif action == "3":
                    raise RuntimeError("已退出") from err
    finally:
        driver.quit()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--term-key")
    parser.add_argument("--school-year")
    parser.add_argument("--term")
    parser.add_argument("--output")
    parser.add_argument("--headless", action="store_true")
    parser.add_argument("--tui", action="store_true")
    args = parser.parse_args()

    if args.tui:
        try:
            specs = build_tui_specs()
        except RuntimeError as err:
            if str(err) == "已取消":
                print("已取消。")
                return
            raise
        scrape_specs(specs, args.headless, interactive=True)
        return

    missing = [name for name in ("term_key", "school_year", "term", "output") if not getattr(args, name)]
    if missing:
        parser.error("非 TUI 模式必须提供 --term-key、--school-year、--term 和 --output")
    if args.term not in {"1", "2"}:
        parser.error("--term 只能是 1 或 2")
    expected_year = school_year_label(parse_school_year(args.school_year))
    if args.school_year != expected_year:
        parser.error("--school-year 格式应为 YYYY-YYYY")
    spec = TermSpec(
        term_key=args.term_key,
        school_year=args.school_year,
        term=args.term,
        output=args.output,
    )
    scrape_specs([spec], args.headless, interactive=False)


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as err:
        print(f"错误：{err}")
        raise SystemExit(1)
