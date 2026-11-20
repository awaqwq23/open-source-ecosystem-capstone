"""Check a UTF-8 CSV export against the course acceptance fixture."""

import argparse
import csv
import json
from collections import Counter
from pathlib import Path

SAMPLE = Path(__file__).resolve().parents[1] / "samples/timetable-date-export.json"


def check_export(stream, date_column):
    expected = json.loads(SAMPLE.read_text(encoding="utf-8"))["expected"]
    rows = csv.DictReader(stream, strict=True)
    if (rows.fieldnames or []).count(date_column) != 1:
        raise ValueError(f"Expected one column named {date_column!r}")
    dates = []
    for row in rows:
        if None in row or None in row.values():
            raise ValueError(f"Wrong column count at line {rows.line_num}")
        dates.append(row[date_column])
    if len(dates) != expected["rowCount"] or Counter(dates) != Counter(expected["dates"]):
        raise ValueError(f"Expected {expected['dates']}, received {dates}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("csv_file", type=Path)
    parser.add_argument("--date-column", default="date")
    args = parser.parse_args()
    with args.csv_file.open(encoding="utf-8-sig", newline="") as stream:
        try:
            check_export(stream, args.date_column)
        except (ValueError, csv.Error) as error:
            parser.exit(1, f"{error}\n")
