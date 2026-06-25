package app

import (
	"bytes"
	"compress/gzip"
	"context"
	"database/sql"
	"os"
	"path/filepath"
	"testing"

	_ "modernc.org/sqlite"
)

func TestParsePackageAcceptsSQLiteDatabasePackage(t *testing.T) {
	data := sqlitePackageBytes(t)

	pkg, err := ParsePackage(context.Background(), bytes.NewReader(data))
	if err != nil {
		t.Fatalf("ParsePackage returned error: %v", err)
	}
	if pkg.Manifest.TermKey != "2025-2026-1" {
		t.Fatalf("term key = %q", pkg.Manifest.TermKey)
	}
	if len(pkg.Courses) != 1 || pkg.Courses[0].ID != "course-1" {
		t.Fatalf("courses = %#v", pkg.Courses)
	}
	if len(pkg.Teachers) != 1 || pkg.Teachers[0].ID != "teacher-1" {
		t.Fatalf("teachers = %#v", pkg.Teachers)
	}
	if len(pkg.Offerings) != 1 || pkg.Offerings[0].CourseID != "course-1" {
		t.Fatalf("offerings = %#v", pkg.Offerings)
	}
	if len(pkg.OfferingTeachers) != 1 || pkg.OfferingTeachers[0].TeacherID != "teacher-1" {
		t.Fatalf("offering teachers = %#v", pkg.OfferingTeachers)
	}
	if len(pkg.Meetings) != 1 || len(pkg.Meetings[0].WeekIndexes) != 2 {
		t.Fatalf("meetings = %#v", pkg.Meetings)
	}
	if len(pkg.SourceRows) != 1 {
		t.Fatalf("source rows = %#v", pkg.SourceRows)
	}
}

func TestParsePackageRejectsMultiTermSQLitePackage(t *testing.T) {
	data := sqlitePackageBytes(t, "extra-term")

	_, err := ParsePackage(context.Background(), bytes.NewReader(data))
	if err == nil {
		t.Fatal("ParsePackage returned nil error for multi-term package")
	}
}

func sqlitePackageBytes(t *testing.T, extraTerms ...string) []byte {
	t.Helper()
	tempDir := t.TempDir()
	dbPath := filepath.Join(tempDir, "package.sqlite")
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	for _, statement := range sqlitePackageSchema() {
		if _, err := db.Exec(statement); err != nil {
			t.Fatal(err)
		}
	}
	if _, err := db.Exec(`
		INSERT INTO school_timetable_terms VALUES
		('2025-2026-1', '2025-2026', '1', '2025', '1', '2025-09-01', 'v1', 1, 1, 1);
		INSERT INTO school_timetable_courses VALUES
		('course-1', 'CS101', '软件工程', '4.0');
		INSERT INTO school_timetable_teachers VALUES
		('teacher-1', '教师', '教师', 0);
		INSERT INTO school_timetable_offerings VALUES
		('offering-1', '2025-2026-1', 'course-1', 'term-course-1', 'K1', '教学班',
		 '计算机学院', '01', '02', '必修', '专业课', '主修', '80/70', 80, 70, '32', '0', '0', '0',
		 '', '', '', '', '', '软件工程 教师');
		INSERT INTO school_timetable_offering_teachers VALUES
		('ot-1', 'offering-1', 'teacher-1', 'main', '教授', 0);
		INSERT INTO school_timetable_audiences VALUES
		('audience-1', '2025-2026-1', 'offering-1', '2025', 'g01', '软件工程', 'm01', '计算机学院', '01', '02', '03', '');
		INSERT INTO school_timetable_source_rows VALUES
		('source-1', '2025-2026-1', 'term-course-1', 'offering-1', 'K1', 1, 'active', '{"key":"K1"}');
		INSERT INTO school_timetable_meetings VALUES
		('rule-1', 'offering-1', '2025-2026-1', 5, 'fri', 0, '周五', '1-2周1-2节', '1-2周1-2节', '1-2周', '1-2节', 1, 2, '3区1-101', '[1,2]', 'parsed');
	`); err != nil {
		t.Fatal(err)
	}
	for _, term := range extraTerms {
		if _, err := db.Exec(`INSERT INTO school_timetable_terms VALUES (?, '2025-2026', '2', '2025', '2', '2026-02-23', 'v1', 0, 1, 1)`, term); err != nil {
			t.Fatal(err)
		}
	}
	if err := db.Close(); err != nil {
		t.Fatal(err)
	}
	raw, err := os.ReadFile(dbPath)
	if err != nil {
		t.Fatal(err)
	}
	var compressed bytes.Buffer
	writer := gzip.NewWriter(&compressed)
	if _, err := writer.Write(raw); err != nil {
		t.Fatal(err)
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}
	return compressed.Bytes()
}

func sqlitePackageSchema() []string {
	return []string{
		`CREATE TABLE school_timetable_terms (term_key TEXT PRIMARY KEY, school_year TEXT NOT NULL, term TEXT NOT NULL, school_year_code TEXT NOT NULL DEFAULT '', term_code TEXT NOT NULL DEFAULT '', first_week_monday TEXT NOT NULL, source_version TEXT NOT NULL, row_count INTEGER NOT NULL, imported_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)`,
		`CREATE TABLE school_timetable_courses (id TEXT PRIMARY KEY, course_no TEXT NOT NULL DEFAULT '', course_name TEXT NOT NULL DEFAULT '', credits TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_teachers (id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '', name_key TEXT NOT NULL DEFAULT '', seq INTEGER NOT NULL DEFAULT 0)`,
		`CREATE TABLE school_timetable_offerings (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, course_id TEXT NOT NULL, term_course_id TEXT NOT NULL, source_key TEXT NOT NULL DEFAULT '', teaching_class_name TEXT NOT NULL DEFAULT '', open_college TEXT NOT NULL DEFAULT '', college_id TEXT NOT NULL DEFAULT '', open_dept_id TEXT NOT NULL DEFAULT '', course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '', capacity INTEGER NOT NULL DEFAULT 0, selected_count INTEGER NOT NULL DEFAULT 0, theory_hours TEXT NOT NULL DEFAULT '', computer_hours TEXT NOT NULL DEFAULT '', experiment_hours TEXT NOT NULL DEFAULT '', practice_hours TEXT NOT NULL DEFAULT '', remark TEXT NOT NULL DEFAULT '', note TEXT NOT NULL DEFAULT '', other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '', publisher TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_offering_teachers (id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, teacher_id TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'main', title TEXT NOT NULL DEFAULT '', ordinal INTEGER NOT NULL DEFAULT 0)`,
		`CREATE TABLE school_timetable_audiences (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, offering_id TEXT NOT NULL, grade TEXT NOT NULL DEFAULT '', grade_code TEXT NOT NULL DEFAULT '', major TEXT NOT NULL DEFAULT '', major_code TEXT NOT NULL DEFAULT '', plan_college TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '', condition_code TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_source_rows (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT, offering_id TEXT, source_key TEXT NOT NULL DEFAULT '', package_index INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT '', raw_fields_json TEXT NOT NULL DEFAULT '{}')`,
		`CREATE TABLE school_timetable_meetings (id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, term_key TEXT NOT NULL, weekday INTEGER NOT NULL DEFAULT 0, day_field TEXT NOT NULL DEFAULT '', segment_index INTEGER NOT NULL DEFAULT 0, weekday_label TEXT NOT NULL DEFAULT '', raw_day_text TEXT NOT NULL DEFAULT '', raw_segment_text TEXT NOT NULL DEFAULT '', week_text TEXT NOT NULL DEFAULT '', section_text TEXT NOT NULL DEFAULT '', section_start INTEGER NOT NULL DEFAULT 0, section_end INTEGER NOT NULL DEFAULT 0, location_text TEXT NOT NULL DEFAULT '', week_indexes TEXT NOT NULL DEFAULT '[]', parse_status TEXT NOT NULL DEFAULT '')`,
	}
}
