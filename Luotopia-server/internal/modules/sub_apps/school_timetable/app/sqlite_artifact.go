package app

import (
	"compress/gzip"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/contract"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	_ "modernc.org/sqlite"
)

const (
	SQLiteArtifactType    = "school_timetable_sqlite_gzip"
	SQLiteSchemaVersion   = 3
	SQLiteArtifactContent = "application/gzip"
)

type Artifact struct {
	Key           string
	Path          string
	Checksum      string
	Size          int64
	ArtifactType  string
	SchemaVersion int
}

func BuildSQLiteArtifact(ctx context.Context, pkg domain.Package, records Records, version int, dir string) (Artifact, error) {
	if err := os.MkdirAll(dir, 0755); err != nil {
		return Artifact{}, err
	}
	fileBase := fmt.Sprintf("%s-v%d-unified.sqlite", sanitizeFilePart(pkg.Manifest.TermKey), version)
	dbPath := filepath.Join(dir, fileBase)
	gzipPath := dbPath + ".gz"
	_ = os.Remove(dbPath)
	_ = os.Remove(gzipPath)

	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return Artifact{}, err
	}
	defer db.Close()
	if err := createSQLiteSnapshot(ctx, db, pkg, records, version); err != nil {
		_ = os.Remove(dbPath)
		return Artifact{}, err
	}
	if err := db.Close(); err != nil {
		_ = os.Remove(dbPath)
		return Artifact{}, err
	}
	if err := gzipFile(dbPath, gzipPath); err != nil {
		_ = os.Remove(dbPath)
		_ = os.Remove(gzipPath)
		return Artifact{}, err
	}
	_ = os.Remove(dbPath)

	checksum, size, err := checksumFile(gzipPath)
	if err != nil {
		_ = os.Remove(gzipPath)
		return Artifact{}, err
	}
	return Artifact{
		Key:           contract.ArtifactKey(pkg.Manifest.TermKey, version),
		Path:          gzipPath,
		Checksum:      checksum,
		Size:          size,
		ArtifactType:  SQLiteArtifactType,
		SchemaVersion: SQLiteSchemaVersion,
	}, nil
}

func createSQLiteSnapshot(ctx context.Context, db *sql.DB, pkg domain.Package, records Records, version int) error {
	if _, err := db.ExecContext(ctx, sqliteSchema); err != nil {
		return err
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	now := time.Now().UTC()
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO school_timetable_meta
		 (key, value) VALUES
		 ('schema_version', ?), ('artifact_type', ?), ('term_key', ?), ('version', ?),
		 ('row_count', ?), ('generated_at', ?), ('first_week_monday', ?)`,
		strconv.Itoa(SQLiteSchemaVersion), SQLiteArtifactType, pkg.Manifest.TermKey,
		strconv.Itoa(version), strconv.Itoa(len(pkg.Rows)), now.Format(time.RFC3339), pkg.Manifest.FirstWeekMonday,
	); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO school_timetable_term_rows
		 (term_key, school_year, term, first_week_monday, source_version, row_count, imported_at, updated_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		pkg.Manifest.TermKey, pkg.Manifest.SchoolYear, pkg.Manifest.Term, pkg.Manifest.FirstWeekMonday,
		fmt.Sprintf("%d", version), len(pkg.Rows), now.UnixMilli(), now.UnixMilli(),
	); err != nil {
		return err
	}
	if err := insertCatalogs(ctx, tx, records.Catalogs); err != nil {
		return err
	}
	if err := insertTermCourses(ctx, tx, records.TermCourses); err != nil {
		return err
	}
	if err := insertInstructorCourses(ctx, tx, records.InstructorCourses); err != nil {
		return err
	}
	if err := insertOfferings(ctx, tx, records.Offerings); err != nil {
		return err
	}
	if err := insertAudiences(ctx, tx, records.Audiences); err != nil {
		return err
	}
	if err := insertSourceRows(ctx, tx, records.SourceRows); err != nil {
		return err
	}
	if err := insertMeetingRules(ctx, tx, records.MeetingRules); err != nil {
		return err
	}
	if err := insertOccurrences(ctx, tx, records.Occurrences); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, sqliteIndexes); err != nil {
		return err
	}
	return tx.Commit()
}

func insertCatalogs(ctx context.Context, tx *sql.Tx, rows []domain.CourseCatalog) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_catalog_rows (id, catalog_key, course_no, course_name, credits, search_text) VALUES (?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.CatalogKey, row.CourseNo, row.CourseName, nullableFloat(row.Credits), row.SearchText); err != nil {
			return err
		}
	}
	return nil
}

func insertTermCourses(ctx context.Context, tx *sql.Tx, rows []domain.TermCourse) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_term_course_rows (id, term_key, catalog_id, course_no, course_name, open_college, credits, course_nature, course_category, open_type, teaching_class_count, teacher_summary, weekday_summary, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.TermKey, row.CatalogID, row.CourseNo, row.CourseName, row.OpenCollege, nullableFloat(row.Credits), row.CourseNature, row.CourseCategory, row.OpenType, row.TeachingClassCount, row.TeacherSummary, row.WeekdaySummary, row.SearchText); err != nil {
			return err
		}
	}
	return nil
}

func insertInstructorCourses(ctx context.Context, tx *sql.Tx, rows []domain.InstructorCourse) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_instructor_course_rows (id, catalog_id, course_no, course_name, credits, instructor_name, instructor_name_key, offering_count, latest_term_key, latest_open_college, latest_teaching_title, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.CatalogID, row.CourseNo, row.CourseName, nullableFloat(row.Credits), row.InstructorName, row.InstructorNameKey, row.OfferingCount, row.LatestTermKey, row.LatestOpenCollege, row.LatestTeachingTitle, row.SearchText); err != nil {
			return err
		}
	}
	return nil
}

func insertOfferings(ctx context.Context, tx *sql.Tx, rows []domain.CourseOffering) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_offering_rows
	(id, term_key, term_course_id, catalog_id, instructor_course_id, source_key, school_year, term, teaching_class_name, course_no, course_name, open_college, plan_college, credits, course_nature, course_category, open_type, instructor, title, people_raw, theory_hours, computer_hours, experiment_hours, practice_hours, remark, other_teachers, textbook, publisher, schedule_summary, weekday_summary, search_text, original_fields_json)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		fields := jsonString(row.Fields)
		if _, err := stmt.ExecContext(ctx,
			row.ID, row.TermKey, row.TermCourseID, row.CatalogID, row.InstructorCourseID, row.SourceKey,
			row.SchoolYear, row.Term, row.TeachingClassName, row.CourseNo, row.CourseName,
			row.OpenCollege, row.AudienceSummary, nullableFloat(row.Credits), "", "", "",
			row.Instructor, row.Title, row.PeopleRaw, nullableInt(row.TheoryHours), nullableInt(row.ComputerHours),
			nullableInt(row.ExperimentHours), nullableInt(row.PracticeHours), row.Remark, row.OtherTeachers,
			row.Textbook, row.Publisher, row.ScheduleSummary, row.WeekdaySummary, row.SearchText, fields,
		); err != nil {
			return err
		}
	}
	return nil
}

func insertAudiences(ctx context.Context, tx *sql.Tx, rows []domain.CourseAudience) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_audience_rows (id, term_key, offering_id, term_course_id, catalog_id, grade, major, plan_college, course_nature, course_nature_code, course_category, course_category_code, open_type, open_type_code, condition_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.TermKey, row.OfferingID, row.TermCourseID, row.CatalogID, row.Grade, row.Major, row.PlanCollege, row.CourseNature, row.CourseNatureCode, row.CourseCategory, row.CourseCategoryCode, row.OpenType, row.OpenTypeCode, row.ConditionCode); err != nil {
			return err
		}
	}
	return nil
}

func insertSourceRows(ctx context.Context, tx *sql.Tx, rows []domain.SourceRow) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_source_rows (id, term_key, term_course_id, offering_id, source_key, package_index, source_status, original_fields_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.TermKey, row.TermCourseID, row.OfferingID, row.SourceKey, row.PackageIndex, row.Status, jsonString(row.Fields)); err != nil {
			return err
		}
	}
	return nil
}

func insertMeetingRules(ctx context.Context, tx *sql.Tx, rows []domain.CourseMeetingRule) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_meeting_rule_rows (id, offering_id, term_key, term_course_id, catalog_id, weekday, segment_index, weekday_label, raw_text, week_text, section_text, location_text, building, room) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.OfferingID, row.TermKey, row.TermCourseID, row.CatalogID, row.Weekday, row.SegmentIndex, row.WeekdayLabel, row.RawText, row.WeekText, row.SectionText, row.LocationText, row.Building, row.Room); err != nil {
			return err
		}
	}
	return nil
}

func insertOccurrences(ctx context.Context, tx *sql.Tx, rows []domain.CourseOccurrence) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_occurrence_rows (id, rule_id, offering_id, term_key, term_course_id, catalog_id, date, week_index, weekday, section_text, location_text, building, room) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, row.ID, row.RuleID, row.OfferingID, row.TermKey, row.TermCourseID, row.CatalogID, row.Date, row.WeekIndex, row.Weekday, row.SectionText, row.LocationText, row.Building, row.Room); err != nil {
			return err
		}
	}
	return nil
}

func gzipFile(srcPath, dstPath string) error {
	src, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer src.Close()
	dst, err := os.Create(dstPath)
	if err != nil {
		return err
	}
	defer dst.Close()
	writer := gzip.NewWriter(dst)
	if _, err := io.Copy(writer, src); err != nil {
		writer.Close()
		return err
	}
	return writer.Close()
}

func checksumFile(path string) (string, int64, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", 0, err
	}
	defer file.Close()
	hash := sha256.New()
	size, err := io.Copy(hash, file)
	if err != nil {
		return "", 0, err
	}
	return "sha256:" + hex.EncodeToString(hash.Sum(nil)), size, nil
}

func nullableFloat(raw string) any {
	if raw == "" {
		return nil
	}
	value, err := strconv.ParseFloat(raw, 64)
	if err != nil {
		return nil
	}
	return value
}

func nullableInt(raw string) any {
	if raw == "" {
		return nil
	}
	value, err := strconv.Atoi(raw)
	if err != nil {
		return nil
	}
	return value
}

func jsonString(value map[string]string) string {
	data, err := json.Marshal(value)
	if err != nil {
		return "{}"
	}
	return string(data)
}

const sqliteSchema = `
PRAGMA journal_mode = OFF;
PRAGMA synchronous = OFF;
CREATE TABLE school_timetable_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
CREATE TABLE school_timetable_term_rows (
  term_key TEXT PRIMARY KEY, school_year TEXT NOT NULL, term TEXT NOT NULL,
  first_week_monday TEXT NOT NULL, source_version TEXT NOT NULL DEFAULT '',
  row_count INTEGER NOT NULL DEFAULT 0, imported_at INTEGER NOT NULL, updated_at INTEGER NOT NULL
);
CREATE TABLE course_catalog_rows (
  id TEXT PRIMARY KEY, catalog_key TEXT NOT NULL, course_no TEXT NOT NULL,
  course_name TEXT NOT NULL, credits REAL, search_text TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_term_course_rows (
  id TEXT PRIMARY KEY, term_key TEXT NOT NULL, catalog_id TEXT NOT NULL,
  course_no TEXT NOT NULL, course_name TEXT NOT NULL, open_college TEXT NOT NULL DEFAULT '',
  credits REAL, course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '', teaching_class_count INTEGER NOT NULL DEFAULT 0,
  teacher_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_instructor_course_rows (
  id TEXT PRIMARY KEY, catalog_id TEXT NOT NULL, course_no TEXT NOT NULL,
  course_name TEXT NOT NULL, credits REAL, instructor_name TEXT NOT NULL DEFAULT '',
  instructor_name_key TEXT NOT NULL DEFAULT '', offering_count INTEGER NOT NULL DEFAULT 0,
  latest_term_key TEXT NOT NULL DEFAULT '', latest_open_college TEXT NOT NULL DEFAULT '',
  latest_teaching_title TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_offering_rows (
  id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT NOT NULL,
  catalog_id TEXT NOT NULL, instructor_course_id TEXT NOT NULL, source_key TEXT NOT NULL,
  package_index INTEGER NOT NULL DEFAULT 0, source_status TEXT NOT NULL DEFAULT 'active',
  school_year TEXT NOT NULL, term TEXT NOT NULL, teaching_class_name TEXT NOT NULL,
  course_no TEXT NOT NULL, course_name TEXT NOT NULL, open_college TEXT NOT NULL DEFAULT '',
  plan_college TEXT NOT NULL DEFAULT '', credits REAL, course_nature TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '',
  grade TEXT NOT NULL DEFAULT '', major TEXT NOT NULL DEFAULT '', instructor TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '', theory_hours INTEGER,
  computer_hours INTEGER, experiment_hours INTEGER, practice_hours INTEGER,
  sunday_raw TEXT NOT NULL DEFAULT '', monday_raw TEXT NOT NULL DEFAULT '',
  tuesday_raw TEXT NOT NULL DEFAULT '', wednesday_raw TEXT NOT NULL DEFAULT '',
  thursday_raw TEXT NOT NULL DEFAULT '', friday_raw TEXT NOT NULL DEFAULT '',
  saturday_raw TEXT NOT NULL DEFAULT '', remark TEXT NOT NULL DEFAULT '',
  other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '',
  publisher TEXT NOT NULL DEFAULT '', open_department_code TEXT NOT NULL DEFAULT '',
  college_code TEXT NOT NULL DEFAULT '', major_code TEXT NOT NULL DEFAULT '',
  grade_code TEXT NOT NULL DEFAULT '', school_year_code TEXT NOT NULL DEFAULT '',
  term_code TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '',
  condition_code TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '',
  course_nature_code TEXT NOT NULL DEFAULT '', note TEXT NOT NULL DEFAULT '',
  schedule_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT '', original_fields_json TEXT NOT NULL DEFAULT '{}'
);
CREATE TABLE course_audience_rows (
  id TEXT PRIMARY KEY, term_key TEXT NOT NULL, offering_id TEXT NOT NULL,
  term_course_id TEXT NOT NULL, catalog_id TEXT NOT NULL, grade TEXT NOT NULL DEFAULT '',
  major TEXT NOT NULL DEFAULT '', plan_college TEXT NOT NULL DEFAULT '',
  course_nature TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '',
  condition_code TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_source_rows (
  id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT NOT NULL DEFAULT '',
  offering_id TEXT NOT NULL DEFAULT '', source_key TEXT NOT NULL DEFAULT '',
  package_index INTEGER NOT NULL DEFAULT 0, source_status TEXT NOT NULL DEFAULT 'active',
  original_fields_json TEXT NOT NULL DEFAULT '{}'
);
CREATE TABLE course_meeting_rule_rows (
  id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, term_key TEXT NOT NULL,
  term_course_id TEXT NOT NULL, catalog_id TEXT NOT NULL, weekday INTEGER NOT NULL,
  segment_index INTEGER NOT NULL, weekday_label TEXT NOT NULL DEFAULT '',
  raw_text TEXT NOT NULL DEFAULT '', week_text TEXT NOT NULL DEFAULT '',
  section_text TEXT NOT NULL DEFAULT '', location_text TEXT NOT NULL DEFAULT '',
  building TEXT NOT NULL DEFAULT '', room TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_occurrence_rows (
  id TEXT PRIMARY KEY, rule_id TEXT NOT NULL, offering_id TEXT NOT NULL,
  term_key TEXT NOT NULL, term_course_id TEXT NOT NULL, catalog_id TEXT NOT NULL,
  date TEXT NOT NULL, week_index INTEGER NOT NULL, weekday INTEGER NOT NULL,
  section_text TEXT NOT NULL DEFAULT '', location_text TEXT NOT NULL DEFAULT '',
  building TEXT NOT NULL DEFAULT '', room TEXT NOT NULL DEFAULT ''
);
`

const sqliteIndexes = `
CREATE INDEX idx_course_term_course_rows_term ON course_term_course_rows(term_key);
CREATE INDEX idx_course_term_course_rows_course_no ON course_term_course_rows(term_key, course_no);
CREATE INDEX idx_course_offering_rows_term_course ON course_offering_rows(term_course_id);
CREATE INDEX idx_course_offering_rows_course_no ON course_offering_rows(term_key, course_no);
CREATE INDEX idx_course_audience_rows_filter ON course_audience_rows(term_key, grade, major, plan_college);
CREATE INDEX idx_course_meeting_rule_rows_offering ON course_meeting_rule_rows(offering_id);
CREATE INDEX idx_course_meeting_rule_rows_filter ON course_meeting_rule_rows(term_key, weekday, building);
CREATE INDEX idx_course_occurrence_rows_offering_date ON course_occurrence_rows(offering_id, date);
`
