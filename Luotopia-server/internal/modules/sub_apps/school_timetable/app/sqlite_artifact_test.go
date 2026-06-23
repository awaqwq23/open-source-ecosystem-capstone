package app

import (
	"compress/gzip"
	"context"
	"database/sql"
	"io"
	"os"
	"path/filepath"
	"testing"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	_ "modernc.org/sqlite"
)

func TestBuildSQLiteArtifactCreatesQueryableSnapshot(t *testing.T) {
	pkg := domain.Package{
		Manifest: domain.Manifest{
			TermKey:         "2025-2026-2",
			SchoolYear:      "2025-2026",
			Term:            "2",
			FirstWeekMonday: "2026-02-23",
		},
		Rows: []map[string]string{{
			"xn": "2025-2026", "xq": "2", "jxbmc": "测试班", "yskch": "TEST101",
			"kcmc": "测试课程", "skxy": "测试学院", "kcxf": "2.0", "jsxm": "测试教师",
			"skrs": "10/20", "mon": "1-16周1-2节1区-101", "nj": "2025", "jszy": "测试专业",
		}},
	}
	records := BuildRecords(pkg, 3)

	artifact, err := BuildSQLiteArtifact(context.Background(), pkg, records, 3, t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	if artifact.ArtifactType != SQLiteArtifactType || artifact.SchemaVersion != SQLiteSchemaVersion {
		t.Fatalf("artifact metadata = %#v", artifact)
	}
	if artifact.Size <= 0 || artifact.Checksum == "" {
		t.Fatalf("artifact checksum/size = %#v", artifact)
	}

	dbPath := filepath.Join(t.TempDir(), "snapshot.sqlite")
	if err := gunzipForTest(artifact.Path, dbPath); err != nil {
		t.Fatal(err)
	}
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()

	var schemaVersion string
	if err := db.QueryRow(`SELECT value FROM school_timetable_meta WHERE key = 'schema_version'`).Scan(&schemaVersion); err != nil {
		t.Fatal(err)
	}
	if schemaVersion != "6" {
		t.Fatalf("schema_version = %q", schemaVersion)
	}
	var rowCount int
	if err := db.QueryRow(`SELECT row_count FROM school_timetable_term_rows WHERE term_key = ?`, pkg.Manifest.TermKey).Scan(&rowCount); err != nil {
		t.Fatal(err)
	}
	if rowCount != len(pkg.Rows) {
		t.Fatalf("row_count = %d, want %d", rowCount, len(pkg.Rows))
	}
	var courses int
	if err := db.QueryRow(`SELECT COUNT(*) FROM course_term_course_rows`).Scan(&courses); err != nil {
		t.Fatal(err)
	}
	if courses != 1 {
		t.Fatalf("course_term_course_rows count = %d, want 1", courses)
	}
	var instances int
	if err := db.QueryRow(`SELECT COUNT(*) FROM course_meeting_rule_rows`).Scan(&instances); err != nil {
		t.Fatal(err)
	}
	if instances != 1 {
		t.Fatalf("course_meeting_rule_rows count = %d, want 1", instances)
	}
	var idType string
	if err := db.QueryRow(`SELECT typeof(id) FROM course_term_course_rows LIMIT 1`).Scan(&idType); err != nil {
		t.Fatal(err)
	}
	if idType != "text" {
		t.Fatalf("course_term_course_rows.id typeof = %q, want text", idType)
	}
	var orphanCount int
	if err := db.QueryRow(`
		SELECT COUNT(*)
		FROM course_offering_rows o
		LEFT JOIN course_term_course_rows c ON c.id = o.term_course_id
		WHERE c.id IS NULL
	`).Scan(&orphanCount); err != nil {
		t.Fatal(err)
	}
	if orphanCount != 0 {
		t.Fatalf("orphan offering rows = %d", orphanCount)
	}
}

func gunzipForTest(srcPath, dstPath string) error {
	src, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer src.Close()
	reader, err := gzip.NewReader(src)
	if err != nil {
		return err
	}
	defer reader.Close()
	dst, err := os.Create(dstPath)
	if err != nil {
		return err
	}
	defer dst.Close()
	_, err = io.Copy(dst, reader)
	return err
}
