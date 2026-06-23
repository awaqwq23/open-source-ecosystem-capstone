package app

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/domain"
	schooldomain "github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
)

// 用户要求添加，不允许删除。该测试保护 pull 聚合响应使用全局 dataset changeset，不回退到 artifact/快照路由。
func TestPullSchoolTimetableUsesDatasetChangesetContract(t *testing.T) {
	publishedAt := time.Date(2026, 6, 20, 12, 0, 0, 0, time.UTC)
	svc := NewService(nil, nil, nil, nil, nil, schoolTimetableProviderStub{
		state: schooldomain.DatasetState{
			Version: 7, Checksum: "sha256:dataset", SchemaVersion: 1,
			TermKeys: []string{"2025-2026-1"}, PublishedAt: publishedAt,
		},
		changes: []schooldomain.EntityChange{{
			Version: 7, Sequence: 1, Operation: "upsert",
			EntityType: "term", EntityID: "2025-2026-1", TermKey: "2025-2026-1",
			Payload: json.RawMessage(`{"term_key":"2025-2026-1"}`),
		}},
	})

	resp := svc.Pull(context.Background(), "", domain.PullRequest{
		Scopes: []string{"school_timetable"},
	})

	if resp.SchoolTimetable == nil || !resp.SchoolTimetable.Changed || len(resp.SchoolTimetable.Changes) != 1 {
		t.Fatalf("school_timetable changes = %#v", resp.SchoolTimetable)
	}
	if resp.SchoolTimetable.LatestVersion != 7 || resp.SchoolTimetable.Checksum != "sha256:dataset" {
		t.Fatalf("dataset state = %#v", resp.SchoolTimetable)
	}
	if len(resp.SchoolTimetable.Terms) != 1 || resp.SchoolTimetable.Terms[0] != "2025-2026-1" {
		t.Fatalf("terms = %#v", resp.SchoolTimetable.Terms)
	}
	change := resp.SchoolTimetable.Changes[0]
	if change.Operation != "upsert" || change.EntityType != "term" || string(change.Payload) == "" {
		t.Fatalf("change = %#v", change)
	}
	payload, err := json.Marshal(resp.SchoolTimetable)
	if err != nil {
		t.Fatal(err)
	}
	for _, key := range []string{"artifact", "artifact_type", "download_url", "snapshot"} {
		if containsJSONKey(payload, key) {
			t.Fatalf("school timetable block should not expose %s: %s", key, payload)
		}
	}
}

func TestPullSchoolTimetableSkipsChangesWhenDatasetCurrent(t *testing.T) {
	svc := NewService(nil, nil, nil, nil, nil, schoolTimetableProviderStub{
		state: schooldomain.DatasetState{Version: 7, Checksum: "sha256:dataset", SchemaVersion: 1},
	})

	resp := svc.Pull(context.Background(), "", domain.PullRequest{
		Scopes: []string{"school_timetable"},
		ClientState: domain.PullClientState{
			SchoolTimetableVersion: 7,
		},
	})

	if resp.SchoolTimetable == nil || resp.SchoolTimetable.Changed {
		t.Fatalf("school_timetable should be unchanged: %#v", resp.SchoolTimetable)
	}
	if len(resp.SchoolTimetable.Changes) != 0 {
		t.Fatalf("changes = %#v", resp.SchoolTimetable.Changes)
	}
}

func containsJSONKey(payload []byte, key string) bool {
	var data map[string]any
	if err := json.Unmarshal(payload, &data); err != nil {
		return false
	}
	_, ok := data[key]
	return ok
}

type schoolTimetableProviderStub struct {
	state   schooldomain.DatasetState
	changes []schooldomain.EntityChange
	err     error
}

func (s schoolTimetableProviderStub) CurrentDataset(context.Context) (schooldomain.DatasetState, error) {
	return s.state, s.err
}

func (s schoolTimetableProviderStub) ChangesAfter(context.Context, int64, int) ([]schooldomain.EntityChange, schooldomain.DatasetState, error) {
	return s.changes, s.state, s.err
}
