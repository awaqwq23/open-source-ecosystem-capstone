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
	if len(pkg.Catalogs) != 1 || pkg.Catalogs[0].ID != "course-1" {
		t.Fatalf("catalogs = %#v", pkg.Catalogs)
	}
	if len(pkg.TermCourses) != 1 || pkg.TermCourses[0].CatalogID != "course-1" {
		t.Fatalf("term courses = %#v", pkg.TermCourses)
	}
	if len(pkg.CourseInstances) != 1 || len(pkg.CourseInstances[0].WeekIndexes) != 2 {
		t.Fatalf("course instances = %#v", pkg.CourseInstances)
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
		INSERT INTO school_timetable_term_rows VALUES
		('2025-2026-1', '2025-2026', '1', '2025-09-01', 'v1', 1, 1, 1);
		INSERT INTO school_timetable_courses VALUES
		('course-1', 'catalog-1', 'CS101', '软件工程', '4.0', '软件工程 CS101');
		INSERT INTO school_timetable_course_terms VALUES
		('term-course-1', '2025-2026-1', 'course-1', '计算机学院', '必修', '专业课', '主修', 1, '教师', '周五', '软件工程 教师');
		INSERT INTO school_timetable_instructors VALUES
		('instructor-1', 'course-1', '教师', '教师', 1, '2025-2026-1', '计算机学院', '教授', '软件工程 教师');
		INSERT INTO school_timetable_offerings VALUES
		('offering-1', '2025-2026-1', 'term-course-1', 'course-1', 'instructor-1', 'K1', '教学班',
		 '教师', '教授', '80/70', 80, 70, '32', '0', '0', '0', '', '', '', '',
		 '周五1-2节', '周五', '{"key":"K1"}', '软件工程 教师');
		INSERT INTO school_timetable_audiences VALUES
		('audience-1', '2025-2026-1', 'offering-1', '2025', '软件工程', '计算机学院', '必修', '01', '专业课', '02', '主修', '03', '');
		INSERT INTO school_timetable_source_rows VALUES
		('source-1', '2025-2026-1', 'term-course-1', 'offering-1', 'K1', 1, 'active', '{"key":"K1"}');
		INSERT INTO school_timetable_meeting_rules VALUES
		('rule-1', 'offering-1', '2025-2026-1', 5, 'fri', 0, '周五', '1-2周1-2节', '1-2周1-2节', '1-2周', '1-2节', 1, 2, '3区1-101', 'parsed');
		INSERT INTO school_timetable_meeting_weeks VALUES ('rule-1', 1), ('rule-1', 2);
	`); err != nil {
		t.Fatal(err)
	}
	for _, term := range extraTerms {
		if _, err := db.Exec(`INSERT INTO school_timetable_term_rows VALUES (?, '2025-2026', '2', '2026-02-23', 'v1', 0, 1, 1)`, term); err != nil {
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
		`CREATE TABLE school_timetable_term_rows (term_key TEXT PRIMARY KEY, school_year TEXT NOT NULL, term TEXT NOT NULL, first_week_monday TEXT NOT NULL, source_version TEXT NOT NULL, row_count INTEGER NOT NULL, imported_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)`,
		`CREATE TABLE school_timetable_courses (id TEXT PRIMARY KEY, catalog_key TEXT NOT NULL DEFAULT '', course_no TEXT NOT NULL DEFAULT '', course_name TEXT NOT NULL DEFAULT '', credits TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_course_terms (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, course_id TEXT NOT NULL, open_college TEXT NOT NULL DEFAULT '', course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '', teaching_class_count INTEGER NOT NULL DEFAULT 0, teacher_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_instructors (id TEXT PRIMARY KEY, course_id TEXT NOT NULL, instructor_name TEXT NOT NULL DEFAULT '', instructor_name_key TEXT NOT NULL DEFAULT '', offering_count INTEGER NOT NULL DEFAULT 0, latest_term_key TEXT NOT NULL DEFAULT '', latest_open_college TEXT NOT NULL DEFAULT '', latest_teaching_title TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_offerings (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT NOT NULL, course_id TEXT NOT NULL, instructor_id TEXT NOT NULL, source_key TEXT NOT NULL DEFAULT '', teaching_class_name TEXT NOT NULL DEFAULT '', instructor TEXT NOT NULL DEFAULT '', title TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '', capacity INTEGER NOT NULL DEFAULT 0, selected_count INTEGER NOT NULL DEFAULT 0, theory_hours TEXT NOT NULL DEFAULT '', computer_hours TEXT NOT NULL DEFAULT '', experiment_hours TEXT NOT NULL DEFAULT '', practice_hours TEXT NOT NULL DEFAULT 0, remark TEXT NOT NULL DEFAULT '', other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '', publisher TEXT NOT NULL DEFAULT '', schedule_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '', detail_fields_json TEXT NOT NULL DEFAULT '{}', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_audiences (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, offering_id TEXT NOT NULL, grade TEXT NOT NULL DEFAULT '', major TEXT NOT NULL DEFAULT '', plan_college TEXT NOT NULL DEFAULT '', course_nature TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '', condition_code TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_source_rows (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT, offering_id TEXT, source_key TEXT NOT NULL DEFAULT '', package_index INTEGER NOT NULL DEFAULT 0, source_status TEXT NOT NULL DEFAULT '', raw_fields_json TEXT NOT NULL DEFAULT '{}')`,
		`CREATE TABLE school_timetable_meeting_rules (id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, term_key TEXT NOT NULL, weekday INTEGER NOT NULL DEFAULT 0, day_field TEXT NOT NULL DEFAULT '', segment_index INTEGER NOT NULL DEFAULT 0, weekday_label TEXT NOT NULL DEFAULT '', raw_day_text TEXT NOT NULL DEFAULT '', raw_segment_text TEXT NOT NULL DEFAULT '', week_text TEXT NOT NULL DEFAULT '', section_text TEXT NOT NULL DEFAULT '', section_start INTEGER NOT NULL DEFAULT 0, section_end INTEGER NOT NULL DEFAULT 0, location_text TEXT NOT NULL DEFAULT '', parse_status TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_meeting_weeks (meeting_rule_id TEXT NOT NULL, week_index INTEGER NOT NULL, PRIMARY KEY (meeting_rule_id, week_index))`,
	}
}
