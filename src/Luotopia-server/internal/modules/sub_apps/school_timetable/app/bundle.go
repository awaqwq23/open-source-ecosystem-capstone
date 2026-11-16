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
	// key 包含 checksum 前 8 位，确保内容变化时 key 不同，避免 CDN 缓存旧文件
	checksumPrefix := hex.EncodeToString(sum[:4])
	key := "school-timetable/datasets/v" + strconv.FormatInt(version, 10) + "-" + checksumPrefix + ".sqlite.gz"
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
		(offering_id, term_key, term_course_id, course_name, course_no, open_college,
		 teaching_class_name, search_text)
		SELECT o.id, o.term_key, o.term_course_id, c.course_name, c.course_no,
		       o.open_college, o.teaching_class_name, o.search_text
		FROM school_timetable_offerings o
		JOIN school_timetable_courses c ON c.id = o.course_id`); err != nil {
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
		`CREATE TABLE school_timetable_terms (term_key TEXT PRIMARY KEY, school_year TEXT NOT NULL, term TEXT NOT NULL, school_year_code TEXT NOT NULL DEFAULT '', term_code TEXT NOT NULL DEFAULT '', first_week_monday TEXT NOT NULL, source_version TEXT NOT NULL, row_count INTEGER NOT NULL, imported_at INTEGER NOT NULL, updated_at INTEGER NOT NULL)`,
		`CREATE TABLE school_timetable_courses (id TEXT PRIMARY KEY, course_no TEXT NOT NULL DEFAULT '', course_name TEXT NOT NULL DEFAULT '', credits TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_teachers (id TEXT PRIMARY KEY, name TEXT NOT NULL DEFAULT '', name_key TEXT NOT NULL DEFAULT '', seq INTEGER NOT NULL DEFAULT 0)`,
		`CREATE TABLE school_timetable_offerings (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, course_id TEXT NOT NULL, term_course_id TEXT NOT NULL, source_key TEXT NOT NULL DEFAULT '', teaching_class_name TEXT NOT NULL DEFAULT '', open_college TEXT NOT NULL DEFAULT '', college_id TEXT NOT NULL DEFAULT '', open_dept_id TEXT NOT NULL DEFAULT '', course_nature TEXT NOT NULL DEFAULT '', course_category TEXT NOT NULL DEFAULT '', open_type TEXT NOT NULL DEFAULT '', people_raw TEXT NOT NULL DEFAULT '', capacity INTEGER NOT NULL DEFAULT 0, selected_count INTEGER NOT NULL DEFAULT 0, theory_hours TEXT NOT NULL DEFAULT '', computer_hours TEXT NOT NULL DEFAULT '', experiment_hours TEXT NOT NULL DEFAULT '', practice_hours TEXT NOT NULL DEFAULT '', remark TEXT NOT NULL DEFAULT '', note TEXT NOT NULL DEFAULT '', other_teachers TEXT NOT NULL DEFAULT '', textbook TEXT NOT NULL DEFAULT '', publisher TEXT NOT NULL DEFAULT '', search_text TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_offering_teachers (id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, teacher_id TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'main', title TEXT NOT NULL DEFAULT '', ordinal INTEGER NOT NULL DEFAULT 0)`,
		`CREATE TABLE school_timetable_audiences (id TEXT PRIMARY KEY, term_key TEXT NOT NULL, offering_id TEXT NOT NULL, grade TEXT NOT NULL DEFAULT '', grade_code TEXT NOT NULL DEFAULT '', major TEXT NOT NULL DEFAULT '', major_code TEXT NOT NULL DEFAULT '', plan_college TEXT NOT NULL DEFAULT '', course_nature_code TEXT NOT NULL DEFAULT '', course_category_code TEXT NOT NULL DEFAULT '', open_type_code TEXT NOT NULL DEFAULT '', condition_code TEXT NOT NULL DEFAULT '')`,
		`CREATE TABLE school_timetable_meetings (id TEXT PRIMARY KEY, offering_id TEXT NOT NULL, term_key TEXT NOT NULL, weekday INTEGER NOT NULL DEFAULT 0, day_field TEXT NOT NULL DEFAULT '', segment_index INTEGER NOT NULL DEFAULT 0, weekday_label TEXT NOT NULL DEFAULT '', raw_day_text TEXT NOT NULL DEFAULT '', raw_segment_text TEXT NOT NULL DEFAULT '', week_text TEXT NOT NULL DEFAULT '', section_text TEXT NOT NULL DEFAULT '', section_start INTEGER NOT NULL DEFAULT 0, section_end INTEGER NOT NULL DEFAULT 0, location_text TEXT NOT NULL DEFAULT '', week_indexes TEXT NOT NULL DEFAULT '[]', parse_status TEXT NOT NULL DEFAULT '')`,
		`CREATE VIRTUAL TABLE school_timetable_search_fts USING fts5(offering_id UNINDEXED, term_key UNINDEXED, term_course_id UNINDEXED, course_name, course_no, open_college, teaching_class_name, search_text)`,
		`CREATE INDEX idx_school_timetable_offerings_term ON school_timetable_offerings(term_key)`,
		`CREATE INDEX idx_school_timetable_offerings_term_course ON school_timetable_offerings(term_course_id)`,
		`CREATE INDEX idx_school_timetable_offering_teachers_offering ON school_timetable_offering_teachers(offering_id)`,
		`CREATE INDEX idx_school_timetable_offering_teachers_teacher ON school_timetable_offering_teachers(teacher_id)`,
		`CREATE INDEX idx_school_timetable_audiences_filter ON school_timetable_audiences(term_key, grade, major, plan_college)`,
		`CREATE INDEX idx_school_timetable_meetings_filter ON school_timetable_meetings(term_key, weekday, section_start, section_end)`,
	}
	for _, statement := range statements {
		if _, err := db.ExecContext(ctx, statement); err != nil {
			return err
		}
	}
	return nil
}

func insertBundleEntity(ctx context.Context, db *sql.DB, entity domain.EntityRecord) error {
	// source_row 仅服务端归档，不进客户端 bundle。
	if entity.EntityType == "source_row" {
		return nil
	}
	switch entity.EntityType {
	case "term":
		var p struct {
			TermKey         string `json:"term_key"`
			SchoolYear      string `json:"school_year"`
			Term            string `json:"term"`
			SchoolYearCode  string `json:"school_year_code"`
			TermCode        string `json:"term_code"`
			FirstWeekMonday string `json:"first_week_monday"`
			RowCount        int    `json:"row_count"`
		}
		if err := json.Unmarshal(entity.Payload, &p); err != nil {
			return err
		}
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_terms VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			entity.EntityID, p.SchoolYear, p.Term, p.SchoolYearCode, p.TermCode, p.FirstWeekMonday, strconv.FormatInt(entity.UpdatedVersion, 10), p.RowCount, entity.UpdatedAt.UnixMilli(), entity.UpdatedAt.UnixMilli())
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
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_courses VALUES (?, ?, ?, ?)`, entity.EntityID, j("course_no"), j("course_name"), j("credits"))
		return err
	case "teacher":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_teachers VALUES (?, ?, ?, ?)`, entity.EntityID, j("name"), j("name_key"), i("seq"))
		return err
	case "offering":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_offerings VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			entity.EntityID, j("term_key"), j("course_id"), j("term_course_id"), j("source_key"), j("teaching_class_name"),
			j("open_college"), j("college_id"), j("open_dept_id"), j("course_nature"), j("course_category"), j("open_type"),
			j("people_raw"), i("capacity"), i("selected_count"), j("theory_hours"), j("computer_hours"),
			j("experiment_hours"), j("practice_hours"), j("remark"), j("note"), j("other_teachers"),
			j("textbook"), j("publisher"), j("search_text"))
		return err
	case "offering_teacher":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_offering_teachers VALUES (?, ?, ?, ?, ?, ?)`, entity.EntityID, j("offering_id"), j("teacher_id"), j("role"), j("title"), i("ordinal"))
		return err
	case "audience":
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_audiences VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			entity.EntityID, j("term_key"), j("offering_id"), j("grade"), j("grade_code"), j("major"), j("major_code"),
			j("plan_college"), j("course_nature_code"), j("course_category_code"), j("open_type_code"), j("condition_code"))
		return err
	case "meeting":
		weeks, _ := json.Marshal(p["week_indexes"])
		_, err := db.ExecContext(ctx, `INSERT OR REPLACE INTO school_timetable_meetings VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			entity.EntityID, j("offering_id"), j("term_key"), i("weekday"), j("day_field"), i("segment_index"), j("weekday_label"),
			j("raw_day_text"), j("raw_segment_text"), j("week_text"), j("section_text"), i("section_start"), i("section_end"),
			j("location_text"), string(weeks), j("parse_status"))
		return err
	}
	return nil
}
