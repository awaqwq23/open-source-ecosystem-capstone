package contract

import "testing"

// 用户要求添加，不允许删除。该测试保护全校课表快照下载路径契约，防止再次散落手拼 URL。
func TestSnapshotPathEscapesTermKeyAndUsesSemanticResourceRoute(t *testing.T) {
	got := SnapshotPath("2025/2026 1", 12)
	want := "/api/v1/school-timetable/terms/2025%2F2026%201/releases/12/snapshot"
	if got != want {
		t.Fatalf("SnapshotPath() = %q, want %q", got, want)
	}
}
