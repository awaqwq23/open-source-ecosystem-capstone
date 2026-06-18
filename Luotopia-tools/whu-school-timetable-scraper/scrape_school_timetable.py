import argparse
import gzip
import hashlib
import json
from datetime import datetime, timezone

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


TARGET_URL = "https://jwgl.whu.edu.cn/design/viewFunc_cxDesignFuncPageIndex.html?gnmkdm=N214599&layout=default"
REQUIRED_FIELDS = {"key", "xn", "xq", "jxbmc", "yskch", "kcmc"}


def setup_driver(headless: bool) -> webdriver.Chrome:
    options = Options()
    if headless:
        options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    return webdriver.Chrome(service=Service(executable_path=None), options=options)


def login_and_wait(driver: webdriver.Chrome) -> None:
    driver.get(TARGET_URL)
    try:
        button = WebDriverWait(driver, 5).until(
            EC.element_to_be_clickable((By.ID, "tysfyzdl"))
        )
        button.click()
    except Exception:
        pass
    driver.maximize_window()
    input("请在浏览器中登录、选择筛选条件并等待表格加载完成，然后按 Enter 开始抓取...")


def table_id(driver: webdriver.Chrome) -> str:
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
    seen = set()
    for index, row in enumerate(rows, 1):
        missing = sorted(field for field in REQUIRED_FIELDS if not row.get(field))
        if missing:
            errors.append(f"第 {index} 行缺少字段：{', '.join(missing)}")
        key = row.get("key", "")
        if key in seen:
            errors.append(f"第 {index} 行 key 重复：{key}")
        if key:
            seen.add(key)
    return errors


def write_package(args: argparse.Namespace, rows: list[dict[str, str]]) -> None:
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
        "term_key": args.term_key,
        "school_year": args.school_year,
        "term": args.term,
        "field_codes": field_codes,
        "row_count": len(rows),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": "jwgl_N214599_dom",
        "source_checksum": source_checksum,
    }
    with gzip.open(args.output, "wt", encoding="utf-8", newline="\n") as file:
        file.write(json.dumps(manifest, ensure_ascii=False, separators=(",", ":")))
        file.write("\n")
        file.write(rows_payload)
        file.write("\n")
    print(f"已写出 {args.output}，共 {len(rows)} 行，checksum={source_checksum}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--term-key", required=True)
    parser.add_argument("--school-year", required=True)
    parser.add_argument("--term", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--headless", action="store_true")
    args = parser.parse_args()

    driver = setup_driver(args.headless)
    try:
        login_and_wait(driver)
        grid_id = table_id(driver)
        pages = total_pages(driver)
        rows = []
        for page in range(1, pages + 1):
            if page > 1:
                goto_page(driver, page)
            page_rows = extract_current_page(driver, grid_id)
            print(f"第 {page}/{pages} 页：{len(page_rows)} 行")
            rows.extend(page_rows)
        errors = validate_rows(rows)
        if errors:
            raise RuntimeError("\n".join(errors[:20]))
        write_package(args, rows)
    finally:
        driver.quit()


if __name__ == "__main__":
    main()
