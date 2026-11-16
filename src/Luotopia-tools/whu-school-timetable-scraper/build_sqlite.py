from __future__ import annotations

"""把抓取脚本输出的 .ndjson.gz 包构建为服务端可导入的 .sqlite.gz 包。

数据模型以「教学班（offering）」为唯一核心，星型展开：

    跨学期共享(term_key=''): course(课程) / teacher(教师)
    每学期: offering ──< offering_teacher >── teacher
                     ├──< audience(面向对象切片)
                     └──< meeting(排课, 地点/周次在此)
    服务端归档(不下发客户端): source_row

源 jqGrid 的全部有内容原始列都会被晋升到上述某张表的类型列里；offering 不再保留
整行 JSON 快照，完整原文仅保存在 source_row 归档。

用法：
    python build_sqlite.py --output package.sqlite.gz [--teacher-overrides overrides.json] term.ndjson.gz
"""

import argparse
import gzip
import json
import hashlib
import os
import re
import sqlite3
import time
from collections import OrderedDict


# ============================================================
# 通用工具
# ============================================================

def normalize_key(value):
    return " ".join(str(value).strip().split())


def sha256_first16(*parts):
    normalized = [normalize_key(p) for p in parts]
    raw = "\x1f".join(normalized).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()[:32]


def non_empty(values):
    return [v for v in values if str(v).strip()]


def split_teacher_names(value):
    parts = re.split(r"[,，;；、/\s]+", str(value).strip())
    return [p.strip() for p in parts if p.strip()]


# ============================================================
# 稳定 ID
# ============================================================

def course_id_of(row):
    return sha256_first16("course", row.get("yskch", ""), row.get("kcmc", ""), row.get("kcxf", ""))


def term_course_id_of(term_key, course_id):
    return sha256_first16("term_course", term_key, course_id)


def teacher_id_of(name_key, seq):
    """教师 ID 采用可扩展编码：name_key + seq。seq 默认 0，靠覆盖表手动区分同名教师。"""
    return sha256_first16("teacher", name_key, str(seq))


def teacher_set_key(names):
    seen = set()
    parts = []
    for name in names:
        key = normalize_key(name)
        if key and key not in seen:
            seen.add(key)
            parts.append(key)
    parts.sort()
    return "|".join(parts)


def offering_id_of(term_key, row):
    cid = course_id_of(row)
    teachers = teacher_set_key(split_teacher_names(row.get("jsxm", "")))
    sig = schedule_signature(row)
    return sha256_first16("offering", term_key, cid, row.get("jxbmc", ""), teachers, sig)


def offering_teacher_id_of(offering_id, teacher_id, role):
    return sha256_first16("offering_teacher", offering_id, teacher_id, role)


def audience_id_of(offering_id, row):
    return sha256_first16(
        "audience", offering_id, row.get("nj", ""), row.get("jszy", ""), row.get("jhxy", ""),
        row.get("kcxzdm", ""), row.get("kclbdm", ""), row.get("kklxdm", ""), row.get("kkbm_id2", ""),
    )


def source_row_id_of(term_key, row, ordinal):
    canon = json.dumps(
        {k: v for k, v in sorted(row.items()) if not k.startswith("_source_") and k != "type"},
        ensure_ascii=False, sort_keys=True,
    )
    return sha256_first16("source", term_key, canon, str(ordinal))


# ============================================================
# 教师覆盖表（可扩展，用于手动区分同名教师）
# ============================================================

class TeacherOverrides:
    """覆盖规则列表。每条规则形如：
        {"name": "王伟", "open_college": "计算机学院", "seq": 1}
    匹配时按 name 命中、且除 name/seq 外的键值与上下文全部相等，则返回 seq；否则 0。
    """

    def __init__(self, rules):
        self.rules = rules or []

    @classmethod
    def load(cls, path):
        if not path:
            return cls([])
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        if isinstance(data, dict):
            data = data.get("rules", [])
        return cls(data)

    def seq_for(self, name, context):
        name_norm = normalize_key(name)
        for rule in self.rules:
            if normalize_key(rule.get("name", "")) != name_norm:
                continue
            clues = {k: v for k, v in rule.items() if k not in ("name", "seq")}
            if all(normalize_key(context.get(k, "")) == normalize_key(v) for k, v in clues.items()):
                return int(rule.get("seq", 0))
        return 0


# ============================================================
# 排课解析（sun..sat → meeting 多行）
# ============================================================

WEEKDAY_FIELDS = [
    (0, "sun", "周日"), (1, "mon", "周一"), (2, "tue", "周二"),
    (3, "wen", "周三"), (4, "thu", "周四"), (5, "fri", "周五"), (6, "sat", "周六"),
]


def parse_week_indexes(raw):
    pattern = r"(\d+)(?:-(\d+))?周(?:\((单|双)\))?"
    seen = set()
    result = []
    for match in re.findall(pattern, raw):
        start = int(match[0])
        end = int(match[1]) if match[1] else start
        parity = match[2]
        if start <= 0 or end < start:
            continue
        for w in range(start, end + 1):
            if parity == "单" and w % 2 == 0:
                continue
            if parity == "双" and w % 2 != 0:
                continue
            if w not in seen:
                seen.add(w)
                result.append(w)
    result.sort()
    return result


def parse_section_range(raw):
    match = re.search(r"(\d+)(?:-(\d+))?节", raw)
    if not match:
        return 0, 0, ""
    start = int(match.group(1))
    end = int(match.group(2)) if match.group(2) else start
    if start <= 0 or end < start:
        return 0, 0, ""
    return start, end, match.group(0)


def extract_location_text(raw):
    match = re.search(r"\d+(?:-\d+)?节(.*)$", raw)
    return match.group(1).strip() if match else ""


def normalize_location_key(value):
    return normalize_key(value).lower().replace(" ", "")


def int_list_key(values):
    return ",".join(str(v) for v in sorted(values))


def schedule_signature(row):
    parts = []
    for _, code, _ in WEEKDAY_FIELDS:
        raw = row.get(code, "").strip()
        if not raw:
            continue
        for seg_idx, segment in enumerate(re.split(r"[，,;；]", raw)):
            segment = segment.strip()
            if not segment:
                continue
            weeks = parse_week_indexes(segment)
            ss, se, _ = parse_section_range(segment)
            location = extract_location_text(segment)
            parts.append(f"{code}={seg_idx}={int_list_key(weeks)}={ss}={se}={normalize_location_key(location)}")
    return "|".join(parts)


def meetings_for_row(term_key, offering_id, row):
    result = []
    for idx, code, label in WEEKDAY_FIELDS:
        raw = row.get(code, "").strip()
        if not raw:
            continue
        segments = re.split(r"[，,;；]", raw)
        current = []
        for si, seg in enumerate(segments):
            seg = seg.strip()
            if not seg:
                continue
            current.append(seg)
            segment = ",".join(current)
            if not re.search(r"\d+(?:-\d+)?节", segment):
                continue
            is_last = si == len(segments) - 1
            next_is_week = not is_last and re.match(r"^\s*\d+(?:-\d+)?周", segments[si + 1])
            if not (is_last or next_is_week):
                continue
            weeks = parse_week_indexes(segment)
            ss, se, section_text = parse_section_range(segment)
            week_text_match = re.search(r"\d+(?:-\d+)?周(?:\((?:单|双)\))?", segment)
            week_text = week_text_match.group(0) if week_text_match else ""
            location = extract_location_text(segment)
            parse_status = "parsed" if (weeks and ss > 0 and se > 0) else "partial"
            meeting_id = sha256_first16(
                "meeting", offering_id, str(idx), str(len(result)),
                int_list_key(weeks), str(ss), str(se), normalize_location_key(location),
            )
            result.append(OrderedDict([
                ("id", meeting_id), ("offering_id", offering_id), ("term_key", term_key),
                ("weekday", idx), ("day_field", code), ("segment_index", len(result)),
                ("weekday_label", label), ("raw_day_text", raw), ("raw_segment_text", segment),
                ("week_text", week_text), ("section_text", section_text),
                ("section_start", ss), ("section_end", se), ("location_text", location),
                ("week_indexes", json.dumps(weeks, ensure_ascii=False)), ("parse_status", parse_status),
            ]))
            current = []
    return result


def parse_people_count(raw):
    parts = re.split(r"[\\/／]", str(raw))
    capacity = selected = 0
    if len(parts) > 0:
        try:
            capacity = int(parts[0].strip())
        except ValueError:
            pass
    if len(parts) > 1:
        try:
            selected = int(parts[1].strip())
        except ValueError:
            pass
    return capacity, selected


# ============================================================
# 记录构建
# ============================================================

REQUIRED = ["xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs"]


def build_records(rows, term_key, overrides):
    offering_rows = {}
    offering_order = []
    source_rows = []

    for idx, row in enumerate(rows):
        can_build = all(row.get(f, "").strip() for f in REQUIRED)
        source_id = source_row_id_of(term_key, row, idx + 1)
        if not can_build:
            source_rows.append(OrderedDict([
                ("id", source_id), ("term_key", term_key), ("term_course_id", ""), ("offering_id", ""),
                ("source_key", row.get("key", "")), ("package_index", idx + 1), ("status", "incomplete"),
                ("raw_fields_json", json.dumps(row, ensure_ascii=False)),
            ]))
            continue
        cid = course_id_of(row)
        tc_id = term_course_id_of(term_key, cid)
        off_id = offering_id_of(term_key, row)
        if off_id not in offering_rows:
            offering_order.append(off_id)
        offering_rows.setdefault(off_id, []).append(row)
        source_rows.append(OrderedDict([
            ("id", source_id), ("term_key", term_key), ("term_course_id", tc_id), ("offering_id", off_id),
            ("source_key", row.get("key", "")), ("package_index", idx + 1), ("status", "active"),
            ("raw_fields_json", json.dumps(row, ensure_ascii=False)),
        ]))

    courses = {}
    teachers = {}
    offerings = []
    offering_teachers = []
    audiences = {}
    meetings = []

    for off_id in offering_order:
        group = offering_rows[off_id]
        first = group[0]
        cid = course_id_of(first)
        tc_id = term_course_id_of(term_key, cid)
        cap, sel = parse_people_count(first.get("skrs", ""))

        courses.setdefault(cid, OrderedDict([
            ("id", cid), ("course_no", first.get("yskch", "")),
            ("course_name", first.get("kcmc", "")), ("credits", first.get("kcxf", "")),
        ]))

        # 教师：jsxm 主讲 + qtjs 其他，拆分为个体教师实体 + 多对多链接
        ctx = {"open_college": first.get("skxy", ""), "course_no": first.get("yskch", "")}
        used_teacher_ids = set()
        all_teacher_names = []

        def add_teacher(name, role, ordinal, title):
            name_key = normalize_key(name)
            if not name_key:
                return
            seq = overrides.seq_for(name, ctx)
            tid = teacher_id_of(name_key, seq)
            teachers.setdefault(tid, OrderedDict([
                ("id", tid), ("name", name_key), ("name_key", name_key), ("seq", seq),
            ]))
            if tid in used_teacher_ids:
                return
            used_teacher_ids.add(tid)
            all_teacher_names.append(name_key)
            offering_teachers.append(OrderedDict([
                ("id", offering_teacher_id_of(off_id, tid, role)), ("offering_id", off_id),
                ("teacher_id", tid), ("role", role), ("title", title), ("ordinal", ordinal),
            ]))

        for i, name in enumerate(split_teacher_names(first.get("jsxm", ""))):
            add_teacher(name, "main", i, first.get("jszc", ""))
        for i, name in enumerate(split_teacher_names(first.get("qtjs", ""))):
            add_teacher(name, "other", i, "")

        grades = sorted({r.get("nj", "").strip() for r in group if r.get("nj", "").strip()})
        majors = sorted({r.get("jszy", "").strip() for r in group if r.get("jszy", "").strip()})
        search_text = " ".join(non_empty([
            first.get("kcmc", ""), first.get("yskch", ""), first.get("jxbmc", ""), first.get("skxy", ""),
            " ".join(all_teacher_names), " ".join(grades), " ".join(majors),
            first.get("xkbz", ""), first.get("bz", ""), first.get("qtjs", ""), first.get("jcmc", ""),
        ]))

        offerings.append(OrderedDict([
            ("id", off_id), ("term_key", term_key), ("course_id", cid), ("term_course_id", tc_id),
            ("source_key", first.get("key", "")), ("teaching_class_name", first.get("jxbmc", "")),
            ("open_college", first.get("skxy", "")), ("college_id", first.get("jg_id", "")),
            ("open_dept_id", first.get("kkbm_id", "")),
            ("course_nature", first.get("kcxzmc", "")), ("course_category", first.get("kclbmc", "")),
            ("open_type", first.get("kklxmc", "")),
            ("people_raw", first.get("skrs", "")), ("capacity", cap), ("selected_count", sel),
            ("theory_hours", first.get("xsdm_01", "")), ("computer_hours", first.get("xsdm_02", "")),
            ("experiment_hours", first.get("xsdm_03", "")), ("practice_hours", first.get("xsdm_04", "")),
            ("remark", first.get("xkbz", "")), ("note", first.get("bz", "")),
            ("other_teachers", first.get("qtjs", "")),
            ("textbook", first.get("jcmc", "")), ("publisher", first.get("cbs", "")),
            ("search_text", search_text),
        ]))

        meetings.extend(meetings_for_row(term_key, off_id, first))

        for r in group:
            aud_id = audience_id_of(off_id, r)
            audiences.setdefault(aud_id, OrderedDict([
                ("id", aud_id), ("term_key", term_key), ("offering_id", off_id),
                ("grade", r.get("nj", "")), ("grade_code", r.get("njdm_id", "")),
                ("major", r.get("jszy", "")), ("major_code", r.get("zyh_id", "")),
                ("plan_college", r.get("jhxy", "")),
                ("course_nature_code", r.get("kcxzdm", "")), ("course_category_code", r.get("kclbdm", "")),
                ("open_type_code", r.get("kklxdm", "")), ("condition_code", r.get("kkbm_id2", "")),
            ]))

    return {
        "courses": sorted(courses.values(), key=lambda x: x["id"]),
        "teachers": sorted(teachers.values(), key=lambda x: x["id"]),
        "offerings": sorted(offerings, key=lambda x: x["id"]),
        "offering_teachers": sorted(offering_teachers, key=lambda x: x["id"]),
        "audiences": sorted(audiences.values(), key=lambda x: x["id"]),
        "meetings": sorted(meetings, key=lambda x: x["id"]),
        "source_rows": sorted(source_rows, key=lambda x: x["package_index"]),
    }


# ============================================================
# 写出 SQLite
# ============================================================

def create_sqlite(db_path, records, manifest):
    if os.path.exists(db_path):
        os.remove(db_path)
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute("PRAGMA journal_mode=OFF")

    cur.executescript("""
        CREATE TABLE school_timetable_terms (
            term_key TEXT PRIMARY KEY, school_year TEXT NOT NULL, term TEXT NOT NULL,
            school_year_code TEXT NOT NULL DEFAULT '', term_code TEXT NOT NULL DEFAULT '',
            first_week_monday TEXT NOT NULL, source_version TEXT NOT NULL,
            row_count INTEGER NOT NULL, imported_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
        );
        CREATE TABLE school_timetable_courses (
            id TEXT PRIMARY KEY, course_no TEXT NOT NULL DEFAULT '',
            course_name TEXT NOT NULL DEFAULT '', credits TEXT NOT NULL DEFAULT ''
        );
        CREATE TABLE school_timetable_teachers (
            id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '',
            name_key TEXT NOT NULL DEFAULT '', seq INTEGER NOT NULL DEFAULT 0
        );
        CREATE TABLE school_timetable_offerings (
            id TEXT PRIMARY KEY, term_key TEXT NOT NULL, course_id TEXT NOT NULL,
            term_course_id TEXT NOT NULL, source_key TEXT NOT NULL DEFAULT '',
            teaching_class_name TEXT NOT NULL DEFAULT '', open_college TEXT NOT NULL DEFAULT '',
            college_id TEXT NOT NULL DEFAULT '', open_dept_id TEXT NOT NULL DEFAULT '',
            course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '',
            open_type TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '',
            capacity INTEGER NOT NULL DEFAULT 0, selected_count INTEGER NOT NULL DEFAULT 0,
            theory_hours TEXT NOT NULL DEFAULT '', computer_hours TEXT NOT NULL DEFAULT '',
            experiment_hours TEXT NOT NULL DEFAULT '', practice_hours TEXT NOT NULL DEFAULT '',
            remark TEXT NOT NULL DEFAULT '', note TEXT NOT NULL DEFAULT '',
            other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '',
            publisher TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT ''
        );
        CREATE TABLE school_timetable_offering_teachers (
            id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, teacher_id TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'main', title TEXT NOT NULL DEFAULT '',
            ordinal INTEGER NOT NULL DEFAULT 0
        );
        CREATE TABLE school_timetable_audiences (
            id TEXT PRIMARY KEY, term_key TEXT NOT NULL, offering_id TEXT NOT NULL,
            grade TEXT NOT NULL DEFAULT '', grade_code TEXT NOT NULL DEFAULT '',
            major TEXT NOT NULL DEFAULT '', major_code TEXT NOT NULL DEFAULT '',
            plan_college TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '',
            course_category_code TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '',
            condition_code TEXT NOT NULL DEFAULT ''
        );
        CREATE TABLE school_timetable_meetings (
            id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, term_key TEXT NOT NULL,
            weekday INTEGER NOT NULL DEFAULT 0, day_field TEXT NOT NULL DEFAULT '',
            segment_index INTEGER NOT NULL DEFAULT 0, weekday_label TEXT NOT NULL DEFAULT '',
            raw_day_text TEXT NOT NULL DEFAULT '', raw_segment_text TEXT NOT NULL DEFAULT '',
            week_text TEXT NOT NULL DEFAULT '', section_text TEXT NOT NULL DEFAULT '',
            section_start INTEGER NOT NULL DEFAULT 0, section_end INTEGER NOT NULL DEFAULT 0,
            location_text TEXT NOT NULL DEFAULT '', week_indexes TEXT NOT NULL DEFAULT '[]',
            parse_status TEXT NOT NULL DEFAULT ''
        );
        CREATE TABLE school_timetable_source_rows (
            id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT, offering_id TEXT,
            source_key TEXT NOT NULL DEFAULT '', package_index INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT '', raw_fields_json TEXT NOT NULL DEFAULT '{}'
        );
    """)

    now = int(time.time() * 1000)
    cur.execute(
        "INSERT INTO school_timetable_terms VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        (manifest["term_key"], manifest["school_year"], manifest["term"],
         manifest.get("school_year_code", ""), manifest.get("term_code", ""),
         manifest["first_week_monday"], "1", manifest["row_count"], now, now),
    )

    def insert_all(table, items, cols):
        if not items:
            return
        placeholders = ", ".join(["?"] * len(cols))
        cur.executemany(
            f"INSERT OR REPLACE INTO {table} VALUES ({placeholders})",
            [tuple(item[c] for c in cols) for item in items],
        )

    insert_all("school_timetable_courses", records["courses"],
               ["id", "course_no", "course_name", "credits"])
    insert_all("school_timetable_teachers", records["teachers"],
               ["id", "name", "name_key", "seq"])
    insert_all("school_timetable_offerings", records["offerings"], [
        "id", "term_key", "course_id", "term_course_id", "source_key", "teaching_class_name",
        "open_college", "college_id", "open_dept_id", "course_nature", "course_category", "open_type",
        "people_raw", "capacity", "selected_count", "theory_hours", "computer_hours",
        "experiment_hours", "practice_hours", "remark", "note", "other_teachers",
        "textbook", "publisher", "search_text",
    ])
    insert_all("school_timetable_offering_teachers", records["offering_teachers"],
               ["id", "offering_id", "teacher_id", "role", "title", "ordinal"])
    insert_all("school_timetable_audiences", records["audiences"], [
        "id", "term_key", "offering_id", "grade", "grade_code", "major", "major_code",
        "plan_college", "course_nature_code", "course_category_code", "open_type_code", "condition_code",
    ])
    insert_all("school_timetable_meetings", records["meetings"], [
        "id", "offering_id", "term_key", "weekday", "day_field", "segment_index", "weekday_label",
        "raw_day_text", "raw_segment_text", "week_text", "section_text", "section_start",
        "section_end", "location_text", "week_indexes", "parse_status",
    ])
    insert_all("school_timetable_source_rows", records["source_rows"],
               ["id", "term_key", "term_course_id", "offering_id", "source_key", "package_index",
                "status", "raw_fields_json"])

    conn.commit()
    conn.close()


# ============================================================
# 读取 .ndjson.gz 输入
# ============================================================

def read_ndjson(paths):
    manifest = None
    rows = []
    for path in paths:
        with gzip.open(path, "rt", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                obj = json.loads(line)
                if obj.get("type") == "manifest":
                    if manifest is None:
                        manifest = obj
                    continue
                fields = obj.get("fields", obj)
                rows.append({str(k): str(v) for k, v in fields.items()})
    if manifest is None:
        raise RuntimeError("输入包缺少 manifest 行")
    return manifest, rows


def main():
    parser = argparse.ArgumentParser(description="把 .ndjson.gz 全校课表包构建为 .sqlite.gz")
    parser.add_argument("inputs", nargs="+", help="一个或多个 .ndjson.gz（须为同一学期）")
    parser.add_argument("--output", required=True, help="输出 .sqlite.gz 路径")
    parser.add_argument("--teacher-overrides", help="可选的教师区分覆盖表 JSON")
    args = parser.parse_args()

    manifest, rows = read_ndjson(args.inputs)
    overrides = TeacherOverrides.load(args.teacher_overrides)

    # 学年码/学期码取首个非空行
    manifest.setdefault("school_year_code", next((r.get("xnm", "") for r in rows if r.get("xnm")), ""))
    manifest.setdefault("term_code", next((r.get("xqm", "") for r in rows if r.get("xqm")), ""))
    manifest["row_count"] = manifest.get("row_count", len(rows))

    print(f"处理 {len(rows)} 行（学期 {manifest['term_key']}）...")
    records = build_records(rows, manifest["term_key"], overrides)
    for name in ("courses", "teachers", "offerings", "offering_teachers", "audiences", "meetings", "source_rows"):
        print(f"  {name}: {len(records[name])}")

    db_path = args.output[:-3] if args.output.endswith(".gz") else args.output + ".sqlite"
    if not db_path.endswith(".sqlite"):
        db_path = db_path + ".sqlite"
    create_sqlite(db_path, records, manifest)

    with open(db_path, "rb") as f:
        data = f.read()
    parent = os.path.dirname(args.output)
    if parent:
        os.makedirs(parent, exist_ok=True)
    with gzip.open(args.output, "wb") as f:
        f.write(data)
    os.remove(db_path)
    print(f"已写出 {args.output}（{os.path.getsize(args.output):,} 字节）")


if __name__ == "__main__":
    try:
        main()
    except RuntimeError as err:
        print(f"错误：{err}")
        raise SystemExit(1)
