package app

import (
	"compress/gzip"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/binary"
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
	SQLiteSchemaVersion   = 5
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
	if err := insertCourseInstances(ctx, tx, records.CourseInstances); err != nil {
		return err
	}
	if err := insertCourseInstanceWeeks(ctx, tx, records.CourseInstances); err != nil {
		return err
	}
	if err := insertSearchRows(ctx, tx, records.TermCourses); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, sqliteIndexes); err != nil {
		return err
	}
	return tx.Commit()
}

func insertCatalogs(ctx context.Context, tx *sql.Tx, rows []domain.CourseCatalog) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_catalog_rows (id, stable_id, catalog_key, course_no, course_name, credits, search_text) VALUES (?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), row.CatalogKey, row.CourseNo, row.CourseName, nullableFloat(row.Credits), row.SearchText); err != nil {
			return err
		}
	}
	return nil
}

func insertTermCourses(ctx context.Context, tx *sql.Tx, rows []domain.TermCourse) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_term_course_rows (id, stable_id, term_key, catalog_id, course_no, course_name, open_college, credits, course_nature, course_category, open_type, teaching_class_count, teacher_summary, weekday_summary, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), row.TermKey, stableIntID(row.CatalogID), row.CourseNo, row.CourseName, row.OpenCollege, nullableFloat(row.Credits), row.CourseNature, row.CourseCategory, row.OpenType, row.TeachingClassCount, row.TeacherSummary, row.WeekdaySummary, row.SearchText); err != nil {
			return err
		}
	}
	return nil
}

func insertInstructorCourses(ctx context.Context, tx *sql.Tx, rows []domain.InstructorCourse) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_instructor_course_rows (id, stable_id, catalog_id, course_no, course_name, credits, instructor_name, instructor_name_key, offering_count, latest_term_key, latest_open_college, latest_teaching_title, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), stableIntID(row.CatalogID), row.CourseNo, row.CourseName, nullableFloat(row.Credits), row.InstructorName, row.InstructorNameKey, row.OfferingCount, row.LatestTermKey, row.LatestOpenCollege, row.LatestTeachingTitle, row.SearchText); err != nil {
			return err
		}
	}
	return nil
}

func insertOfferings(ctx context.Context, tx *sql.Tx, rows []domain.CourseOffering) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_offering_rows
	(id, stable_id, term_key, term_course_id, catalog_id, instructor_course_id, source_key, school_year, term, teaching_class_name, teaching_class_key, course_no, course_name, open_college, plan_college, grade, major, credits, course_nature, course_category, open_type, instructor, instructor_set_key, title, people_raw, capacity, selected_count, theory_hours, computer_hours, experiment_hours, practice_hours, remark, other_teachers, textbook, publisher, schedule_key, schedule_summary, weekday_summary, search_text, detail_fields_json)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		fields := jsonString(detailFields(row.Fields))
		if _, err := stmt.ExecContext(ctx,
			stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), row.TermKey, stableIntID(row.TermCourseID), stableIntID(row.CatalogID), stableIntID(row.InstructorCourseID), row.SourceKey,
			row.SchoolYear, row.Term, row.TeachingClassName, normalizeKey(row.TeachingClassName), row.CourseNo, row.CourseName,
			row.OpenCollege, firstNonEmpty(row.PlanCollegeSummary, row.AudienceSummary), row.GradeSummary, row.MajorSummary,
			nullableFloat(row.Credits), row.CourseNature, row.CourseCategory, row.OpenType,
			row.Instructor, row.InstructorSetKey, row.Title, row.PeopleRaw, nullablePositiveInt(row.Capacity), nullablePositiveInt(row.SelectedCount), nullableInt(row.TheoryHours), nullableInt(row.ComputerHours),
			nullableInt(row.ExperimentHours), nullableInt(row.PracticeHours), row.Remark, row.OtherTeachers,
			row.Textbook, row.Publisher, row.ScheduleKey, row.ScheduleSummary, row.WeekdaySummary, row.SearchText, fields,
		); err != nil {
			return err
		}
	}
	return nil
}

func insertAudiences(ctx context.Context, tx *sql.Tx, rows []domain.CourseAudience) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_audience_rows (id, stable_id, term_key, offering_id, term_course_id, catalog_id, grade, major, plan_college, course_nature, course_nature_code, course_category, course_category_code, open_type, open_type_code, condition_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), row.TermKey, stableIntID(row.OfferingID), stableIntID(row.TermCourseID), stableIntID(row.CatalogID), row.Grade, row.Major, row.PlanCollege, row.CourseNature, row.CourseNatureCode, row.CourseCategory, row.CourseCategoryCode, row.OpenType, row.OpenTypeCode, row.ConditionCode); err != nil {
			return err
		}
	}
	return nil
}

func insertSourceRows(ctx context.Context, tx *sql.Tx, rows []domain.SourceRow) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_source_rows (id, stable_id, term_key, term_course_id, offering_id, source_key, package_index, source_status, detail_fields_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), row.TermKey, nullableStableIntID(row.TermCourseID), nullableStableIntID(row.OfferingID), row.SourceKey, row.PackageIndex, row.Status, jsonString(detailFields(row.Fields))); err != nil {
			return err
		}
	}
	return nil
}

func insertCourseInstances(ctx context.Context, tx *sql.Tx, rows []domain.CourseInstance) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_instance_rows (id, stable_id, offering_id, term_key, term_course_id, catalog_id, weekday, day_field, segment_index, weekday_label, raw_day_text, raw_segment_text, week_text, section_text, section_start, section_end, location_text, parse_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx,
			stableIntID(row.ID), nonEmptyStableID(row.StableID, row.ID), stableIntID(row.OfferingID), row.TermKey, stableIntID(row.TermCourseID), stableIntID(row.CatalogID),
			row.Weekday, row.DayField, row.SegmentIndex, row.WeekdayLabel, row.RawDayText, row.RawSegmentText,
			row.WeekText, row.SectionText, nullablePositiveInt(row.SectionStart), nullablePositiveInt(row.SectionEnd),
			row.LocationText, row.ParseStatus,
		); err != nil {
			return err
		}
	}
	return nil
}

func insertCourseInstanceWeeks(ctx context.Context, tx *sql.Tx, rows []domain.CourseInstance) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_instance_week_rows (instance_id, week_index) VALUES (?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		instanceID := stableIntID(row.ID)
		for _, week := range row.WeekIndexes {
			if _, err := stmt.ExecContext(ctx, instanceID, week); err != nil {
				return err
			}
		}
	}
	return nil
}

func insertSearchRows(ctx context.Context, tx *sql.Tx, rows []domain.TermCourse) error {
	stmt, err := tx.PrepareContext(ctx, `INSERT INTO course_search_fts (term_course_id, term_key, course_name, course_no, open_college, course_nature, course_category, teacher_summary, weekday_summary, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`)
	if err != nil {
		return err
	}
	defer stmt.Close()
	for _, row := range rows {
		if _, err := stmt.ExecContext(ctx, stableIntID(row.ID), row.TermKey, row.CourseName, row.CourseNo, row.OpenCollege, row.CourseNature, row.CourseCategory, row.TeacherSummary, row.WeekdaySummary, row.SearchText); err != nil {
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

func nullablePositiveInt(value int) any {
	if value <= 0 {
		return nil
	}
	return value
}

func stableIntID(stableID string) int64 {
	sum := sha256.Sum256([]byte(stableID))
	value := binary.BigEndian.Uint64(sum[:8]) & ((uint64(1) << 63) - 1)
	if value == 0 {
		return 1
	}
	return int64(value)
}

func nullableStableIntID(stableID string) any {
	if stableID == "" {
		return nil
	}
	return stableIntID(stableID)
}

func nonEmptyStableID(stableID, fallback string) string {
	if stableID != "" {
		return stableID
	}
	return fallback
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if value != "" {
			return value
		}
	}
	return ""
}

func detailFields(fields map[string]string) map[string]string {
	keys := []string{
		"key", "jxbmc", "yskch", "kcmc", "skxy", "jhxy", "kcxf", "kcxzmc", "kclbmc", "kklxmc",
		"jsxm", "jszc", "skrs", "xsdm_01", "xsdm_02", "xsdm_03", "xsdm_04", "xkbz", "qtjs", "jcmc", "cbs",
	}
	result := make(map[string]string, len(keys))
	for _, key := range keys {
		if value := fields[key]; value != "" {
			result[key] = value
		}
	}
	return result
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
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  catalog_key TEXT NOT NULL, course_no TEXT NOT NULL,
  course_name TEXT NOT NULL, credits REAL, search_text TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_term_course_rows (
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  term_key TEXT NOT NULL, catalog_id INTEGER NOT NULL,
  course_no TEXT NOT NULL, course_name TEXT NOT NULL, open_college TEXT NOT NULL DEFAULT '',
  credits REAL, course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '', teaching_class_count INTEGER NOT NULL DEFAULT 0,
  teacher_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_instructor_course_rows (
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  catalog_id INTEGER NOT NULL, course_no TEXT NOT NULL,
  course_name TEXT NOT NULL, credits REAL, instructor_name TEXT NOT NULL DEFAULT '',
  instructor_name_key TEXT NOT NULL DEFAULT '', offering_count INTEGER NOT NULL DEFAULT 0,
  latest_term_key TEXT NOT NULL DEFAULT '', latest_open_college TEXT NOT NULL DEFAULT '',
  latest_teaching_title TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_offering_rows (
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  term_key TEXT NOT NULL, term_course_id INTEGER NOT NULL,
  catalog_id INTEGER NOT NULL, instructor_course_id INTEGER NOT NULL, source_key TEXT NOT NULL,
  school_year TEXT NOT NULL, term TEXT NOT NULL, teaching_class_name TEXT NOT NULL,
  teaching_class_key TEXT NOT NULL DEFAULT '',
  course_no TEXT NOT NULL, course_name TEXT NOT NULL, open_college TEXT NOT NULL DEFAULT '',
  plan_college TEXT NOT NULL DEFAULT '', grade TEXT NOT NULL DEFAULT '',
  major TEXT NOT NULL DEFAULT '', credits REAL, course_nature TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '',
  instructor TEXT NOT NULL DEFAULT '', instructor_set_key TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '',
  capacity INTEGER, selected_count INTEGER, theory_hours INTEGER,
  computer_hours INTEGER, experiment_hours INTEGER, practice_hours INTEGER,
  remark TEXT NOT NULL DEFAULT '',
  other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '',
  publisher TEXT NOT NULL DEFAULT '', schedule_key TEXT NOT NULL DEFAULT '',
  schedule_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT '', detail_fields_json TEXT NOT NULL DEFAULT '{}'
);
CREATE TABLE course_audience_rows (
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  term_key TEXT NOT NULL, offering_id INTEGER NOT NULL,
  term_course_id INTEGER NOT NULL, catalog_id INTEGER NOT NULL, grade TEXT NOT NULL DEFAULT '',
  major TEXT NOT NULL DEFAULT '', plan_college TEXT NOT NULL DEFAULT '',
  course_nature TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '',
  condition_code TEXT NOT NULL DEFAULT ''
);
CREATE TABLE course_source_rows (
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  term_key TEXT NOT NULL, term_course_id INTEGER,
  offering_id INTEGER, source_key TEXT NOT NULL DEFAULT '',
  package_index INTEGER NOT NULL DEFAULT 0, source_status TEXT NOT NULL DEFAULT 'active',
  detail_fields_json TEXT NOT NULL DEFAULT '{}'
);
CREATE TABLE course_instance_rows (
  id INTEGER PRIMARY KEY, stable_id TEXT NOT NULL UNIQUE,
  offering_id INTEGER NOT NULL, term_key TEXT NOT NULL,
  term_course_id INTEGER NOT NULL, catalog_id INTEGER NOT NULL, weekday INTEGER NOT NULL,
  day_field TEXT NOT NULL DEFAULT '', segment_index INTEGER NOT NULL,
  weekday_label TEXT NOT NULL DEFAULT '',
  raw_day_text TEXT NOT NULL DEFAULT '', raw_segment_text TEXT NOT NULL DEFAULT '',
  week_text TEXT NOT NULL DEFAULT '', section_text TEXT NOT NULL DEFAULT '',
  section_start INTEGER, section_end INTEGER,
  location_text TEXT NOT NULL DEFAULT '',
  parse_status TEXT NOT NULL DEFAULT 'parsed'
);
CREATE TABLE course_instance_week_rows (
  instance_id INTEGER NOT NULL, week_index INTEGER NOT NULL,
  PRIMARY KEY(instance_id, week_index)
);
CREATE VIRTUAL TABLE course_search_fts USING fts5(
  term_course_id UNINDEXED,
  term_key UNINDEXED,
  course_name,
  course_no,
  open_college,
  course_nature,
  course_category,
  teacher_summary,
  weekday_summary,
  search_text
);
`

const sqliteIndexes = `
CREATE INDEX idx_course_term_course_rows_term ON course_term_course_rows(term_key);
CREATE INDEX idx_course_term_course_rows_course_no ON course_term_course_rows(term_key, course_no);
CREATE INDEX idx_course_offering_rows_term_course ON course_offering_rows(term_course_id, instructor, teaching_class_name);
CREATE INDEX idx_course_offering_rows_course_no ON course_offering_rows(term_key, course_no);
CREATE INDEX idx_course_offering_rows_stable ON course_offering_rows(stable_id);
CREATE INDEX idx_course_audience_rows_filter ON course_audience_rows(term_key, grade, major, plan_college);
CREATE INDEX idx_course_audience_rows_offering ON course_audience_rows(offering_id);
CREATE INDEX idx_course_instance_rows_offering ON course_instance_rows(offering_id, weekday, segment_index);
CREATE INDEX idx_course_instance_rows_filter ON course_instance_rows(term_key, weekday, section_start, section_end);
CREATE INDEX idx_course_instance_rows_location ON course_instance_rows(term_key, location_text);
CREATE INDEX idx_course_instance_week_rows_week ON course_instance_week_rows(week_index, instance_id);
`
