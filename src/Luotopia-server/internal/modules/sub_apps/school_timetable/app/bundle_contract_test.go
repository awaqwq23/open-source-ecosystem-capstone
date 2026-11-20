package app

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
)

// CI passes the resulting production-format bundle to the Flutter consumer.
func TestBuildClientContractBundle(t *testing.T) {
	ctx := t.Context()
	pkg, err := ParsePackage(ctx, bytes.NewReader(sqlitePackageBytes(t)))
	if err != nil {
		t.Fatal(err)
	}
	records, _, err := flattenRecords(pkg, BuildRecords(pkg, 1))
	if err != nil {
		t.Fatal(err)
	}
	entities := make([]domain.EntityRecord, 0, len(records))
	for _, record := range records {
		entities = append(entities, record)
	}
	path := filepath.Join(t.TempDir(), "contract.sqlite")
	if err := writeBundleDatabase(ctx, path, 1, entities, nil); err != nil {
		t.Fatal(err)
	}
	data, err := gzipFile(path)
	if err != nil {
		t.Fatal(err)
	}
	if output := os.Getenv("TIMETABLE_CONTRACT_BUNDLE"); output != "" {
		if err := os.WriteFile(output, data, 0600); err != nil {
			t.Fatal(err)
		}
	}
}
