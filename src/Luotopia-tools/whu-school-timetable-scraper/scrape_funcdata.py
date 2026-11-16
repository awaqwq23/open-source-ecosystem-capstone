"""直连正方教务 funcData_cxFuncDataList.html 全校课表抓取。

绕过原系统 jqGrid 前端的减速机制：
  - 单次请求 showCount 远大于 totalResult，一学期一次请求拿完，斩断分页 COUNT × N 次聚合往返。
  - 去掉 jqGrid 前端的 nd 时间戳抖动与空 sortName 排序，最小化后端处理。
  - 不渲染 DOM、不逐页翻 jqGrid，直接吃后端 JSON。

爬一点存一点 + 断点续抓：
  - 每学期抓完立刻落盘 <term>.json（原始）+ <term>.ndjson.gz（build_sqlite.py 可吃的格式）。
  - progress.json 记录每学期状态，断点续抓时已完成的学期直接跳过。
  - 会话失效（302 跳统一认证 / 403 / 空 items）即停手并向用户报告，不静默继续。

学期编码（正方内部码）：
  学年 xnm：2025 表示 2025-2026 学年（起始年份）。
  学期 xqm：12 = 第1学期，16 = 第2学期，20 = 第3学期（夏季）。
  按用户要求"从2025-2026-3往回拉"，迭代顺序为 20→16→12 逐年递减学年。

用法：
  # cookie 走环境变量，不落盘
  export WHU_COOKIE='_dx_uzZo5y=...; JSESSIONID=...'
  python scrape_funcdata.py --output-dir .tmp/whu-scrape [--from 2025-2026-3] [--to 起始年份] [--show-count 20000]
"""

from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import date, datetime, timedelta, timezone

FUNC_URL = (
    "https://jwgl.whu.edu.cn/design/funcData_cxFuncDataList.html"
    "?func_widget_guid=CABE8E78D4456040E0530207010A5E49&gnmkdm=N214599"
)
REFERER = (
    "https://jwgl.whu.edu.cn/design/viewFunc_cxDesignFuncPageIndex.html"
    "?gnmkdm=N214599&layout=default"
)
# 正方内部学期码（实证，非记忆推算）：
#   xqm=3  -> 第1学期(秋季)
#   xqm=12 -> 第2学期(春季)
#   xqm=16 -> 第3学期(夏季)
XQM_BY_TERM = {"1": "3", "2": "12", "3": "16"}
# 往回拉的学期内部迭代顺序：先夏季(3)再春季(2)再秋季(1)——对应自然时间从春到秋倒序
TERM_ORDER_DESC = ["3", "2", "1"]

UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36 Edg/149.0.0.0"
)


def parse_term_key(key: str) -> tuple[int, str]:
    """'2025-2026-3' -> (2025, '3')。"""
    parts = key.split("-")
    if len(parts) != 3 or parts[2] not in ("1", "2", "3"):
        raise ValueError(f"学期 key 格式应为 YYYY-YYYY-N（N=1/2/3），得到 {key}")
    start = int(parts[0])
    if int(parts[1]) != start + 1:
        raise ValueError(f"学年应为 YYYY-YYYY 连续，得到 {key}")
    return start, parts[2]


def term_key(start_year: int, term: str) -> str:
    return f"{start_year}-{start_year + 1}-{term}"


def generate_terms_desc(latest_key: str, oldest_start_year: int) -> list[tuple[int, str, str]]:
    """从 latest_key 学期往回生成到 oldest_start_year 学年第1学期。

    返回 [(start_year, term, term_key), ...]，含端点，按自然时间从新到旧。
    """
    latest_year, latest_term = parse_term_key(latest_key)
    cursor_term_idx = TERM_ORDER_DESC.index(latest_term)
    cursor_year = latest_year
    terms: list[tuple[int, str, str]] = []
    while cursor_year > oldest_start_year or (
        cursor_year == oldest_start_year and cursor_term_idx < len(TERM_ORDER_DESC)
    ):
        term = TERM_ORDER_DESC[cursor_term_idx]
        terms.append((cursor_year, term, term_key(cursor_year, term)))
        cursor_term_idx += 1
        if cursor_term_idx >= len(TERM_ORDER_DESC):
            cursor_term_idx = 0
            cursor_year -= 1
    return terms


def next_term_desc(start_year: int, term: str) -> tuple[int, str]:
    """给定一个学期，返回往回（更旧）的下一个学期。"""
    idx = TERM_ORDER_DESC.index(term)
    idx += 1
    if idx >= len(TERM_ORDER_DESC):
        return start_year - 1, TERM_ORDER_DESC[0]
    return start_year, TERM_ORDER_DESC[idx]


def build_request(xnm: str, xqm: str, show_count: int) -> urllib.request.Request:
    params = {
        "xnm": xnm,
        "xqm": xqm,
        "_search": "false",
        "nd": str(int(time.time() * 1000)),
        "queryModel.showCount": str(show_count),
        "queryModel.currentPage": "1",
        "queryModel.sortName": "",
        "queryModel.sortOrder": "asc",
    }
    data = urllib.parse.urlencode(params).encode("utf-8")
    headers = {
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
        "Origin": "https://jwgl.whu.edu.cn",
        "Referer": REFERER,
        "User-Agent": UA,
        "X-Requested-With": "XMLHttpRequest",
    }
    return urllib.request.Request(FUNC_URL, data=data, headers=headers, method="POST")


def is_session_lost(body: str) -> bool:
    if not body:
        return True
    head = body[:512]
    needles = ("统一身份认证", "authserver/login", "cas.whu.edu.cn", '"loginUrl"', "请先登录")
    return any(n in head for n in needles)


def fetch_once(xnm: str, xqm: str, show_count: int, cookie: str, timeout: int) -> dict:
    req = build_request(xnm, xqm, show_count)
    req.add_header("Cookie", cookie)
    err: Exception | None = None
    for attempt in range(1, 4):
        try:
            with urllib.request.urlopen(req, timeout=timeout) as r:
                if r.status != 200:
                    raise RuntimeError(f"HTTP {r.status}")
                body = r.read().decode("utf-8", errors="replace")
            if is_session_lost(body):
                raise SessionLost("会话失效：响应疑似跳转统一身份认证")
            return json.loads(body)
        except SessionLost:
            raise
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as e:
            err = e
            wait = 5 * attempt
            print(f"  重试 {attempt}/3：{type(e).__name__}: {e}，{wait}s 后重试", file=sys.stderr)
            time.sleep(wait)
    raise RuntimeError(f"3 次重试均失败：{err}")


class SessionLost(RuntimeError):
    pass


def first_week_monday_for(start_year: int, term: str) -> str:
    """占位首周周一（实际由服务端/管理员另行确定，这里给一个合理默认避免 build_sqlite 报错）。
    第1学期按9月初、第2学期按2月底/3月初、第3学期按6月底。
    精确值需用户在 build 时通过 --first-week-monday 覆盖。
    """
    anchors = {
        "1": date(start_year, 9, 1),
        "2": date(start_year + 1, 2, 23),
        "3": date(start_year + 1, 6, 23),
    }
    anchor = anchors[term]
    monday = anchor + timedelta(days=(7 - anchor.weekday()) % 7)
    return monday.isoformat()


def write_outputs(term_key_str: str, rows: list[dict], raw: dict, output_dir: str, xnm: str, xqm: str) -> None:
    # 原始 JSON 整包
    raw_path = os.path.join(output_dir, f"{term_key_str}.json")
    with open(raw_path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(raw, f, ensure_ascii=False, indent=2)

    # build_sqlite.py 可吃的 ndjson.gz：manifest + rows（字段对齐现有工具）
    field_codes = sorted({k for r in rows for k in r.keys()})
    canonical = [
        {"type": "row", "fields": {c: r.get(c, "") for c in field_codes}}
        for r in rows
    ]
    rows_payload = "\n".join(
        json.dumps(o, ensure_ascii=False, separators=(",", ":")) for o in canonical
    )
    checksum = "sha256:" + hashlib.sha256(rows_payload.encode("utf-8")).hexdigest()
    start_year, term = parse_term_key(term_key_str)
    manifest = {
        "type": "manifest",
        "schema_version": 1,
        "term_key": term_key_str,
        "school_year": f"{start_year}-{start_year + 1}",
        "term": term,
        "first_week_monday": first_week_monday_for(start_year, term),
        "field_codes": field_codes,
        "row_count": len(rows),
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source": "jwgl_funcData_direct",
        "source_checksum": checksum,
        "school_year_code": xnm,
        "term_code": xqm,
    }
    ndjson_path = os.path.join(output_dir, f"{term_key_str}.ndjson.gz")
    with gzip.open(ndjson_path, "wt", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(manifest, ensure_ascii=False, separators=(",", ":")))
        f.write("\n")
        f.write(rows_payload)
        f.write("\n")


def load_progress(path: str) -> dict:
    if not os.path.exists(path):
        return {"done": {}, "terms": []}
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_progress(path: str, progress: dict) -> None:
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(progress, f, ensure_ascii=False, indent=2)


def main() -> None:
    ap = argparse.ArgumentParser(description="直连 funcData 全校课表抓取（绕过前端分页减速）")
    ap.add_argument("--output-dir", required=True, help="落盘目录（建议 .tmp/whu-scrape）")
    ap.add_argument("--from", dest="from_key", default="2025-2026-3", help="起始学期 key，默认 2025-2026-3")
    ap.add_argument("--floor-year", type=int, default=1990, help="绝底下界学年（兜底防失控，默认1990）")
    ap.add_argument("--consecutive-empty-year", type=int, default=1,
                    help="连续N个完整学年全空即停止（默认1学年=3学期全空则停）")
    ap.add_argument("--show-count", type=int, default=20000, help="单次请求拉取条数（拉满整学期），默认 20000")
    ap.add_argument("--timeout", type=int, default=300, help="单次请求超时秒，默认 300")
    cookie = os.environ.get("WHU_COOKIE")
    if not cookie:
        print("error: WHU_COOKIE 环境变量未设置", file=sys.stderr)
        sys.exit(2)

    args = ap.parse_args()
    os.makedirs(args.output_dir, exist_ok=True)
    progress_path = os.path.join(args.output_dir, "progress.json")
    progress = load_progress(progress_path)

    start_year, start_term = parse_term_key(args.from_key)
    stop_threshold = args.consecutive_empty_year * 3  # 连续这么多学期全空才停
    consecutive_empty = 0
    cursor_year, cursor_term = start_year, start_term
    idx = 0
    total_done = len(progress.get("done", {}))
    print(f"从 {term_key(cursor_year, cursor_term)} 往回抓取，连 {stop_threshold} 个学期全空即停（floor={args.floor_year}）")
    print(f"已完成 {total_done} 个：{sorted(progress.get('done', {}).keys()) or '无'}")

    while cursor_year >= args.floor_year:
        tkey = term_key(cursor_year, cursor_term)
        idx += 1
        if tkey in progress.get("done", {}):
            print(f"[{idx}] {tkey} 已完成，跳过")
            consecutive_empty = 0
            cursor_year, cursor_term = next_term_desc(cursor_year, cursor_term)
            continue
        xnm = str(cursor_year)
        xqm = XQM_BY_TERM[cursor_term]
        sys.stdout.flush()
        print(f"\n[{idx}] {tkey} (xnm={xnm} xqm={xqm}) 抓取中...", flush=True)
        t0 = time.time()
        raw = fetch_once(xnm, xqm, args.show_count, cookie, args.timeout)
        elapsed = time.time() - t0
        items = raw.get("items", [])
        total = raw.get("totalCount", raw.get("totalResult", 0))
        if not items:
            # 第3学期(夏季)常无排课；如实记录空学期。秋季/春季无数据是强停止信号。
            print(f"  [empty] {tkey} 无数据（totalCount={total}），用时 {elapsed:.1f}s", flush=True)
            progress.setdefault("empty", {})[tkey] = {
                "totalCount": total, "elapsed_s": round(elapsed, 1), "at": now_iso()
            }
            save_progress(progress_path, progress)
            consecutive_empty += 1
            if consecutive_empty >= stop_threshold:
                print(f"\n>> 连续 {consecutive_empty} 个学期全空，达到停止判据，停止抓取。")
                break
            cursor_year, cursor_term = next_term_desc(cursor_year, cursor_term)
            continue
        rows = [{str(k): ("" if v is None else str(v)) for k, v in it.items()} for it in items]
        write_outputs(tkey, rows, raw, args.output_dir, xnm, xqm)
        progress.setdefault("done", {})[tkey] = {
            "row_count": len(rows),
            "totalCount_raw": total,
            "elapsed_s": round(elapsed, 1),
            "at": now_iso(),
            "ttfb_aprox": round(elapsed, 1),
        }
        save_progress(progress_path, progress)
        print(f"  [ok] {tkey} 完成：{len(rows)} 行 / 后端 totalCount={total} / 用时 {elapsed:.1f}s", flush=True)
        print(f"    落盘：{tkey}.json + {tkey}.ndjson.gz", flush=True)
        consecutive_empty = 0
        cursor_year, cursor_term = next_term_desc(cursor_year, cursor_term)

    # 收尾汇总
    progress["terms"] = sorted(progress.get("done", {}).keys())
    save_progress(progress_path, progress)
    done = progress.get("done", {})
    total_rows = sum(v.get("row_count", 0) for v in done.values())
    print(f"\n=== 全部结束 ===")
    print(f"有数据学期 {len(done)} 个，共 {total_rows} 行")
    print(f"空学期：{sorted(progress.get('empty', {}).keys())}")


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


if __name__ == "__main__":
    try:
        main()
    except SessionLost as e:
        print(f"\n[FAIL] 会话失效，已停止：{e}", file=sys.stderr)
        print("请重新从浏览器复制 cookie 后用新 WHU_COOKIE 续抓（progress.json 保留进度）", file=sys.stderr)
        sys.exit(3)
    except KeyboardInterrupt:
        print("\n用户中断，进度已保存，可断点续抓", file=sys.stderr)
        sys.exit(130)
