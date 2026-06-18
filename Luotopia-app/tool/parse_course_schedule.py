"""Parse the 2025-2026-1 course schedule xlsx and output JSON seed data."""
import json
import openpyxl

SRC = r"D:\Github\Luotopia\Luotopia\docs\全校课表开发\2025-2026-1课表.xlsx"
OUT = r"D:\Github\Luotopia\Luotopia\Luotopia-app\assets\course_schedule\2025-2026-1.json"

wb = openpyxl.load_workbook(SRC)
ws = wb.active

# Column mapping from the xlsx (verified against first data row):
#   1: course_name, 2: academic_year, 3: semester,
#   4: teaching_class, 5: course_code, 6: school, 7: plan_school,
#   8: credits, 9: course_nature, 10: course_category, 11: course_type,
#   12: grade, 13: major, 14: teacher, 15: teacher_title,
#   16: student_count, 17: theory, 18: computer, 19: experiment, 20: practice,
#   21-27: sun..sat, 28: notes, 29: other_teachers, 30: textbook, 31: publisher

def clean(val):
    """Return None for truly empty values, else stripped string."""
    if val is None:
        return None
    s = str(val).strip()
    return s if s else None

def parse_float(val):
    s = clean(val)
    if s is None:
        return None
    try:
        return float(s)
    except ValueError:
        return None

def parse_int(val):
    s = clean(val)
    if s is None:
        return None
    try:
        return int(s)
    except ValueError:
        return None

records = []
for row in ws.iter_rows(min_row=2, values_only=True):
    # cols 17-20 are学时 counters; store raw int
    rec = {
        "course_name": clean(row[0]),
        "academic_year": clean(row[1]),
        "semester": int(row[2]) if row[2] is not None else None,
        "teaching_class_name": clean(row[3]),
        "course_code": clean(row[4]),
        "school": clean(row[5]),
        "plan_school": clean(row[6]),
        "credits": parse_float(row[7]),
        "course_nature": clean(row[8]),
        "course_category": clean(row[9]),
        "course_type": clean(row[10]),
        "grade": clean(row[11]),
        "major": clean(row[12]),
        "teacher": clean(row[13]),
        "teacher_title": clean(row[14]),
        "student_count": clean(row[15]),
        "theory_hours": parse_int(row[16]),
        "computer_hours": parse_int(row[17]),
        "experiment_hours": parse_int(row[18]),
        "practice_hours": parse_int(row[19]),
        "schedule_sun": clean(row[20]),
        "schedule_mon": clean(row[21]),
        "schedule_tue": clean(row[22]),
        "schedule_wed": clean(row[23]),
        "schedule_thu": clean(row[24]),
        "schedule_fri": clean(row[25]),
        "schedule_sat": clean(row[26]),
        "notes": clean(row[27]),
        "other_teachers": clean(row[28]),
        "textbook": clean(row[29]),
        "publisher": clean(row[30]),
    }
    records.append(rec)

print(f"Parsed {len(records)} records")

# Compact JSON
with open(OUT, "w", encoding="utf-8") as f:
    json.dump(records, f, ensure_ascii=False, separators=(",", ":"))

print(f"Written: {OUT}")
