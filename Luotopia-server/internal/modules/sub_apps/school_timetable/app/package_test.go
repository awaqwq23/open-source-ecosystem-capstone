package app

import (
	"bytes"
	"compress/gzip"
	"context"
	"encoding/json"
	"testing"
)

func TestParsePackageAcceptsValidRows(t *testing.T) {
	data := packageBytes(t, map[string]any{
		"type":              "manifest",
		"schema_version":    1,
		"term_key":          "2025-2026-1",
		"school_year":       "2025-2026",
		"term":              "1",
		"field_codes":       []string{"key", "xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs", "fri"},
		"row_count":         1,
		"first_week_monday": "2025-09-01",
		"generated_at":      "2026-06-18T00:00:00Z",
		"source":            "test",
		"source_checksum":   "sha256:test",
	}, []map[string]string{
		{
			"key": "K1", "xn": "2025-2026", "xq": "1", "jxbmc": "教学班",
			"yskch": "3200520011014", "kcmc": "软件工程", "skxy": "计算机学院",
			"kcxf": "4.0", "jsxm": "教师", "skrs": "80\\70", "fri": "1-16周1-2节3区1-101",
		},
	})

	pkg, err := ParsePackage(context.Background(), bytes.NewReader(data))
	if err != nil {
		t.Fatalf("ParsePackage returned error: %v", err)
	}
	if pkg.Manifest.TermKey != "2025-2026-1" {
		t.Fatalf("term key = %q", pkg.Manifest.TermKey)
	}
	if len(pkg.Rows) != 1 || pkg.Rows[0]["key"] != "K1" {
		t.Fatalf("rows not parsed: %#v", pkg.Rows)
	}
}

func TestParsePackageAcceptsMissingSourceKey(t *testing.T) {
	data := packageBytes(t, map[string]any{
		"type":              "manifest",
		"schema_version":    1,
		"term_key":          "2025-2026-1",
		"school_year":       "2025-2026",
		"term":              "1",
		"field_codes":       []string{"xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs", "fri"},
		"row_count":         1,
		"first_week_monday": "2025-09-01",
	}, []map[string]string{
		{
			"xn": "2025-2026", "xq": "1", "jxbmc": "教学班", "yskch": "3200520011014",
			"kcmc": "软件工程", "skxy": "计算机学院", "kcxf": "4.0", "jsxm": "教师",
			"skrs": "80\\70", "fri": "1-16周1-2节3区1-101",
		},
	})

	pkg, err := ParsePackage(context.Background(), bytes.NewReader(data))
	if err != nil {
		t.Fatalf("ParsePackage returned error: %v", err)
	}
	if len(pkg.Rows) != 1 || pkg.Rows[0]["key"] != "" {
		t.Fatalf("missing key row not preserved: %#v", pkg.Rows)
	}
}

func TestParsePackageRejectsRowsMissingEntityFields(t *testing.T) {
	data := packageBytes(t, map[string]any{
		"type":              "manifest",
		"schema_version":    1,
		"term_key":          "2025-2026-1",
		"school_year":       "2025-2026",
		"term":              "1",
		"field_codes":       []string{"xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs"},
		"row_count":         1,
		"first_week_monday": "2025-09-01",
	}, []map[string]string{
		{
			"xn": "2025-2026", "xq": "1", "jxbmc": "教学班", "yskch": "3200520011014",
			"kcmc": "软件工程", "skxy": "计算机学院", "kcxf": "4.0", "skrs": "80\\70",
		},
	})

	_, err := ParsePackage(context.Background(), bytes.NewReader(data))
	if err == nil {
		t.Fatal("ParsePackage returned nil error for row missing jsxm")
	}
}

func packageBytes(t *testing.T, manifest map[string]any, rows []map[string]string) []byte {
	t.Helper()
	var raw bytes.Buffer
	if err := json.NewEncoder(&raw).Encode(manifest); err != nil {
		t.Fatal(err)
	}
	for _, row := range rows {
		if err := json.NewEncoder(&raw).Encode(map[string]any{"type": "row", "fields": row}); err != nil {
			t.Fatal(err)
		}
	}
	var compressed bytes.Buffer
	writer := gzip.NewWriter(&compressed)
	if _, err := writer.Write(raw.Bytes()); err != nil {
		t.Fatal(err)
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}
	return compressed.Bytes()
}
