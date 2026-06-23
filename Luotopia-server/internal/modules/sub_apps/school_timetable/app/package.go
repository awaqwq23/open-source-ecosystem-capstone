package app

import (
	"bufio"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"sort"
	"strings"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
)

var (
	ErrInvalidPackage = errors.New("school timetable: invalid package")
	ErrNotFound       = errors.New("school timetable: not found")
)

var requiredFields = []string{
	"xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs",
}

func ParsePackage(ctx context.Context, reader io.Reader) (domain.Package, error) {
	gzipReader, err := gzip.NewReader(reader)
	if err != nil {
		return domain.Package{}, fmt.Errorf("%w: gzip", ErrInvalidPackage)
	}
	defer gzipReader.Close()

	scanner := bufio.NewScanner(gzipReader)
	scanner.Buffer(make([]byte, 64*1024), 8*1024*1024)
	if !scanner.Scan() {
		if err := scanner.Err(); err != nil {
			return domain.Package{}, err
		}
		return domain.Package{}, fmt.Errorf("%w: missing manifest", ErrInvalidPackage)
	}

	var manifest domain.Manifest
	if err := json.Unmarshal(scanner.Bytes(), &manifest); err != nil {
		return domain.Package{}, fmt.Errorf("%w: manifest json", ErrInvalidPackage)
	}
	if err := validateManifest(manifest); err != nil {
		return domain.Package{}, err
	}

	rows := make([]map[string]string, 0, manifest.RowCount)
	for scanner.Scan() {
		select {
		case <-ctx.Done():
			return domain.Package{}, ctx.Err()
		default:
		}
		line := strings.TrimSpace(scanner.Text())
		if line == "" {
			continue
		}
		var wrapper struct {
			Type   string            `json:"type"`
			Fields map[string]string `json:"fields"`
		}
		if err := json.Unmarshal([]byte(line), &wrapper); err != nil {
			return domain.Package{}, fmt.Errorf("%w: row json", ErrInvalidPackage)
		}
		if wrapper.Type != "row" || wrapper.Fields == nil {
			return domain.Package{}, fmt.Errorf("%w: row type", ErrInvalidPackage)
		}
		row := normalizeRow(wrapper.Fields)
		if err := validateRow(manifest, len(rows)+1, row); err != nil {
			return domain.Package{}, err
		}
		rows = append(rows, row)
	}
	if err := scanner.Err(); err != nil {
		return domain.Package{}, err
	}
	if len(rows) != manifest.RowCount {
		return domain.Package{}, fmt.Errorf("%w: row_count expected %d got %d", ErrInvalidPackage, manifest.RowCount, len(rows))
	}
	return domain.Package{Manifest: manifest, Rows: rows}, nil
}

func PackageChecksum(data []byte) string {
	sum := sha256.Sum256(data)
	return "sha256:" + hex.EncodeToString(sum[:])
}

func StableRowsPayload(rows []map[string]string) []byte {
	lines := make([]string, 0, len(rows))
	for _, row := range rows {
		keys := make([]string, 0, len(row))
		for key := range row {
			keys = append(keys, key)
		}
		sort.Strings(keys)
		ordered := make(map[string]string, len(row))
		for _, key := range keys {
			ordered[key] = row[key]
		}
		data, _ := json.Marshal(struct {
			Type   string            `json:"type"`
			Fields map[string]string `json:"fields"`
		}{Type: "row", Fields: ordered})
		lines = append(lines, string(data))
	}
	return []byte(strings.Join(lines, "\n"))
}

func validateManifest(manifest domain.Manifest) error {
	if manifest.Type != "manifest" {
		return fmt.Errorf("%w: manifest type", ErrInvalidPackage)
	}
	if manifest.SchemaVersion != 1 {
		return fmt.Errorf("%w: schema_version", ErrInvalidPackage)
	}
	if strings.TrimSpace(manifest.TermKey) == "" || strings.TrimSpace(manifest.SchoolYear) == "" || strings.TrimSpace(manifest.Term) == "" {
		return fmt.Errorf("%w: term metadata", ErrInvalidPackage)
	}
	if strings.TrimSpace(manifest.FirstWeekMonday) == "" {
		return fmt.Errorf("%w: first_week_monday", ErrInvalidPackage)
	}
	if manifest.RowCount <= 0 {
		return fmt.Errorf("%w: row_count", ErrInvalidPackage)
	}
	fields := make(map[string]struct{}, len(manifest.FieldCodes))
	for _, code := range manifest.FieldCodes {
		fields[strings.TrimSpace(code)] = struct{}{}
	}
	for _, required := range requiredFields {
		if _, ok := fields[required]; !ok {
			return fmt.Errorf("%w: field_codes missing %s", ErrInvalidPackage, required)
		}
	}
	return nil
}

func validateRow(manifest domain.Manifest, index int, row map[string]string) error {
	for _, required := range requiredFields {
		if strings.TrimSpace(row[required]) == "" {
			return fmt.Errorf("%w: row %d missing %s", ErrInvalidPackage, index, required)
		}
	}
	if row["xn"] != manifest.SchoolYear || row["xq"] != manifest.Term {
		return fmt.Errorf("%w: row %d term mismatch", ErrInvalidPackage, index)
	}
	return nil
}

func normalizeRow(row map[string]string) map[string]string {
	normalized := make(map[string]string, len(row))
	for key, value := range row {
		normalized[strings.TrimSpace(key)] = strings.TrimSpace(strings.ReplaceAll(value, "\u00a0", " "))
	}
	return normalized
}
