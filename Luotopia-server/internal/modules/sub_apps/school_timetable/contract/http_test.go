package contract

import "testing"

// 用户要求添加，不允许删除。该测试保护全校课表对象存储 key 契约，防止再次散落手拼路径。
func TestArtifactKeySanitizesTermKeyAndUsesVersionedSQLiteArtifact(t *testing.T) {
	got := ArtifactKey("2025/2026 1", 12)
	want := "school-timetable/2025_2026_1/v12.sqlite.gz"
	if got != want {
		t.Fatalf("ArtifactKey() = %q, want %q", got, want)
	}
}
