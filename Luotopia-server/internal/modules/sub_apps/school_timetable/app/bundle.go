package app

import (
	"bytes"
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
	"sort"
	"strconv"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	"github.com/openwhu/luotopia/server/internal/platform/storage"
	_ "modernc.org/sqlite"
)

func (s *Service) publishBundle(ctx context.Context, version int64, progress ProgressFunc) error {
	if s.bundleStore == nil {
		return nil
	}
	entities, err := s.repo.ListEntities(ctx)
	if err != nil {
		return err
	}
	tempDir, err := os.MkdirTemp("", "school-timetable-bundle-*")
	if err != nil {
		return err
	}
	defer os.RemoveAll(tempDir)
	dbPath := filepath.Join(tempDir, "dataset.sqlite")
	if err := writeBundleDatabase(ctx, dbPath, version, entities, progress); err != nil {
		return err
	}
	compressed, err := gzipFile(dbPath)
	if err != nil {
		return err
	}
	sum := sha256.Sum256(compressed)
	checksum := "sha256:" + hex.EncodeToString(sum[:])
	key := "school-timetable/datasets/v" + strconv.FormatInt(version, 10) + ".sqlite.gz"
	if err := s.bundleStore.Put(ctx, storage.Object{
		Key: key, ContentType: "application/gzip", Size: int64(len(compressed)),
		Body: io.NopCloser(bytes.NewReader(compressed)),
	}); err != nil {
		return err
	}
	bundle := domain.DatasetBundle{
		Version: version, Key: key, Href: s.bundleStore.PublicURL(key),
		Size: int64(len(compressed)), Checksum: checksum,
		CreatedAt: time.Now().UTC().Format(time.RFC3339),
	}
	return s.repo.UpdateBundle(ctx, version, bundle)
}

func writeBundleDatabase(ctx context.Context, path string, version int64, entities []domain.EntityRecord, progress ProgressFunc) error {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return err
	}
	defer db.Close()
	if err := createBundleSchema(ctx, db); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `INSERT INTO school_timetable_meta (key, value) VALUES ('dataset_version', ?)`, strconv.FormatInt(version, 10)); err != nil {
		return err
	}
	sort.Slice(entities, func(i, j int) bool {
		if entities[i].EntityType == entities[j].EntityType {
			return entities[i].EntityID < entities[j].EntityID
		}
		return entities[i].EntityType < entities[j].EntityType
	})
	totalBundle := len(entities)
	for i, entity := range entities {
		if err := insertBundleEntity(ctx, db, entity); err != nil {
			return err
		}
		if progress != nil && (i%2000 == 0 || i == totalBundle-1) {
			progress(i+1, totalBundle, entity.EntityType)
		}
	}
	if _, err := db.ExecContext(ctx, `
		INSERT INTO school_timetable_search_fts
		(term_course_id, term_key, course_name, course_no, open_college, course_nature,
		 course_category, teacher_summary, weekday_summary, search_text)
		SELECT c.id, c.term_key, cc.course_name, cc.course_no, c.open_college,
		       c.course_nature, c.course_category, c.teacher_summary,
		       c.weekday_summary, c.search_text
		FROM school_timetable_course_terms c
		JOIN school_timetable_courses cc ON cc.id = c.course_id`); err != nil {
		return err
	}
	return nil
}

func gzipFile(path string) ([]byte, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var compressed bytes.Buffer
	writer := gzip.NewWriter(&compressed)
	if _, err := writer.Write(data); err != nil {
		return nil, err
	}
	if err := writer.Close(); err != nil {
		return nil, err
	}
	return compressed.Bytes(), nil
}

func createBundleSchema(ctx context.Context, db *sql.DB) error {
	statements := []string{
		`CREATE TABLE school_timetable_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)`,
		`CREATE TABLE school_timetable_term_rows (term_key TEXT PRIMARY KEY, school_year TEXT NOT NULL, term TEXT NOT NULL, first_week_monday TEXT NOT NULL, source_version TEXT NOT NULL, row_count INTEGER NOT NULL, imported_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)`,
		`CREATE TABLE school_timetable_courses (id TEXT PRIMARY KEY, catalog_key TEXT NOT NULL DEFAULT '', course_no TEXT NOT NULL DEFAULT '', course_name TEXT NOT NULL DEFAULT '', credits TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_course_terms (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, course_id TEXT NOT NULL, open_college TEXT NOT NULL DEFAULT '', course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '', teaching_class_count INTEGER NOT NULL DEFAULT 0, teacher_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_instructors (id TEXT PRIMARY KEY, course_id TEXT NOT NULL, instructor_name TEXT NOT NULL DEFAULT '', instructor_name_key TEXT NOT NULL DEFAULT '', offering_count INTEGER NOT NULL DEFAULT 0, latest_term_key TEXT NOT NULL DEFAULT '', latest_open_college TEXT NOT NULL DEFAULT '', latest_teaching_title TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_offerings (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT NOT NULL, course_id TEXT NOT NULL, instructor_id TEXT NOT NULL, source_key TEXT NOT NULL DEFAULT '', teaching_class_name TEXT NOT NULL DEFAULT '', instructor TEXT NOT NULL DEFAULT '', title TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '', capacity INTEGER NOT NULL DEFAULT 0, selected_count INTEGER NOT NULL DEFAULT 0, theory_hours TEXT NOT NULL DEFAULT '', computer_hours TEXT NOT NULL DEFAULT '', experiment_hours TEXT NOT NULL DEFAULT '', practice_hours TEXT NOT NULL DEFAULT '', remark TEXT NOT NULL DEFAULT '', other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '', publisher TEXT NOT NULL DEFAULT '', schedule_summary TEXT NOT NULL DEFAULT '', weekday_summary TEXT NOT NULL DEFAULT '', detail_fields_json TEXT NOT NULL DEFAULT '{}', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_audiences (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, offering_id TEXT NOT NULL, grade TEXT NOT NULL DEFAULT '', major TEXT NOT NULL DEFAULT '', plan_college TEXT NOT NULL DEFAULT '', course_nature TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '', condition_code TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_source_rows (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, term_course_id TEXT, offering_id TEXT, source_key TEXT NOT NULL DEFAULT '', package_index INTEGER NOT NULL DEFAULT 0, source_status TEXT NOT NULL DEFAULT '', raw_fields_json TEXT NOT NULL DEFAULT '{}')`,
		`CREATE TABLE school_timetable_meeting_rules (id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, term_key TEXT NOT NULL, weekday INTEGER NOT NULL DEFAULT 0, day_field TEXT NOT NULL DEFAULT '', segment_index INTEGER NOT NULL DEFAULT 0, weekday_label TEXT NOT NULL DEFAULT '', raw_day_text TEXT NOT NULL DEFAULT '', raw_segment_text TEXT NOT NULL DEFAULT '', week_text TEXT NOT NULL DEFAULT '', section_text TEXT NOT NULL DEFAULT '', section_start INTEGER NOT NULL DEFAULT 0, section_end INTEGER NOT NULL DEFAULT 0, location_text TEXT NOT NULL DEFAULT '', parse_status TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_meeting_weeks (meeting_rule_id TEXT NOT NULL, week_index INTEGER NOT NULL, PRIMARY KEY (meeting_rule_id, week_index))`,
		`CREATE VIRTUAL TABLE school_timetable_search_fts USING fts5(term_course_id UNINDEXED, term_key UNINDEXED, course_name, course_no, open_college, course_nature, course_category, teacher_summary, weekday_summary, search_text)`,
		`CREATE INDEX idx_school_timetable_course_terms_term ON school_timetable_course_terms(term_key)`,
		`CREATE INDEX idx_school_timetable_offerings_term_course ON school_timetable_offerings(term_course_id, instructor, teaching_class_name)`,
		`CREATE INDEX idx_school_timetable_audiences_filter ON school_timetable_audiences(term_key, grade, major, plan_college)`,
		`CREATE INDEX idx_school_timetable_meeting_rules_filter ON school_timetable_meeting_rules(term_key, weekday, section_start, section_end)`,
	}
	for _, statement := range statements {
		if _, err := db.ExecContext(ctx, statement); err != nil {
			return err
		}
	}
	return nil
}

func insertBundleEntity(ctx context.Context, db *sql.DB, entity domain.EntityRecord) error {
	switch entity.EntityType {
	case "term":
		var p struct {
			TermKey         string `json:"term_key"`
			SchoolYear      string `json:"school_year"`
			Term            string `json:"term"`
			FirstWeekMonday string `json:"first_week_monday"`
			RowCount        int    `json:"row_count"`
		}
		if err := json.Unmarshal(entity.Payload, &p); err != nil {
			return err
		}
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_term_rows VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			entity.EntityID, p.SchoolYear, p.Term, p.FirstWeekMonday, strconv.FormatInt(entity.UpdatedVersion, 10), p.RowCount, time.Now().UnixMilli(), time.Now().UnixMilli())
		return err
	default:
		return insertBundlePayload(ctx, db, entity)
	}
}

func insertBundlePayload(ctx context.Context, db *sql.DB, entity domain.EntityRecord) error {
	var p map[string]any
	if err := json.Unmarshal(entity.Payload, &p); err != nil {
		return err
	}
	j := func(key string) string {
		value, ok := p[key]
		if !ok || value == nil {
			return ""
		}
		return fmt.Sprint(value)
	}
	i := func(key string) int {
		switch value := p[key].(type) {
		case float64:
			return int(value)
		case int:
			return value
		default:
			n, _ := strconv.Atoi(fmt.Sprint(value))
			return n
		}
	}
	switch entity.EntityType {
	case "course":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_courses VALUES (?, ?, ?, ?, ?, ?)`, entity.EntityID, j("catalog_key"), j("course_no"), j("course_name"), j("credits"), j("search_text"))
		return err
	case "term_course":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_course_terms VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, entity.EntityID, j("term_key"), j("catalog_id"), j("open_college"), j("course_nature"), j("course_category"), j("open_type"), i("teaching_class_count"), j("teacher_summary"), j("weekday_summary"), j("search_text"))
		return err
	case "instructor_course":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_instructors VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`, entity.EntityID, j("catalog_id"), j("instructor_name"), j("instructor_name_key"), i("offering_count"), j("latest_term_key"), j("latest_open_college"), j("latest_teaching_title"), j("search_text"))
		return err
	case "offering":
		fields, _ := json.Marshal(p["fields"])
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_offerings VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, entity.EntityID, j("term_key"), j("term_course_id"), j("catalog_id"), j("instructor_course_id"), j("source_key"), j("teaching_class_name"), j("instructor"), j("title"), j("people_raw"), i("capacity"), i("selected_count"), j("theory_hours"), j("computer_hours"), j("experiment_hours"), j("practice_hours"), j("remark"), j("other_teachers"), j("textbook"), j("publisher"), j("schedule_summary"), j("weekday_summary"), string(fields), j("search_text"))
		return err
	case "audience":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_audiences VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, entity.EntityID, j("term_key"), j("offering_id"), j("grade"), j("major"), j("plan_college"), j("course_nature"), j("course_nature_code"), j("course_category"), j("course_category_code"), j("open_type"), j("open_type_code"), j("condition_code"))
		return err
	case "source_row":
		fields, _ := json.Marshal(p["fields"])
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_source_rows VALUES (?, ?, ?, ?, ?, ?, ?, ?)`, entity.EntityID, j("term_key"), j("term_course_id"), j("offering_id"), j("source_key"), i("package_index"), j("status"), string(fields))
		return err
	case "meeting_rule":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_meeting_rules VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, entity.EntityID, j("offering_id"), j("term_key"), i("weekday"), j("day_field"), i("segment_index"), j("weekday_label"), j("raw_day_text"), j("raw_segment_text"), j("week_text"), j("section_text"), i("section_start"), i("section_end"), j("location_text"), j("parse_status"))
		return err
	case "meeting_week":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_meeting_weeks VALUES (?, ?)`, j("meeting_rule_id"), i("week_index"))
		return err
	}
	return nil
}
