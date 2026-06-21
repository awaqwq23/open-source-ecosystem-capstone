package app

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/domain"
	schooldomain "github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
)

// 用户要求添加，不允许删除。该测试保护 pull 聚合响应只暴露对象存储 artifact 链接，不回退到旧快照路由。
func TestPullSchoolTimetableUsesArtifactLinkContract(t *testing.T) {
	svc := NewService(nil, nil, nil, nil, nil, schoolTimetableProviderStub{
		terms: []schooldomain.Term{{
			TermKey:       "2025-2026-1",
			SchoolYear:    "2025-2026",
			Term:          "1",
			Version:       7,
			Checksum:      "sha256:artifact",
			ArtifactType:  "school_timetable_sqlite_gzip",
			SchemaVersion: 3,
			ArtifactSize:  2048,
			ArtifactURL:   "https://cdn.example.com/school-timetable/2025-2026-1/v7.sqlite.gz",
			RowCount:      42,
			PublishedAt:   time.Date(2026, 6, 20, 12, 0, 0, 0, time.UTC),
		}},
	})

	resp := svc.Pull(context.Background(), "", domain.PullRequest{
		Scopes: []string{"school_timetable"},
	})

	if resp.SchoolTimetable == nil || len(resp.SchoolTimetable.Terms) != 1 {
		t.Fatalf("school_timetable terms = %#v", resp.SchoolTimetable)
	}
	term := resp.SchoolTimetable.Terms[0]
	link := term.Links["artifact"]
	want := "https://cdn.example.com/school-timetable/2025-2026-1/v7.sqlite.gz"
	if link.Href != want {
		t.Fatalf("artifact link href = %q, want %q", link.Href, want)
	}
	if term.ArtifactType != "school_timetable_sqlite_gzip" || term.SchemaVersion != 3 || term.ArtifactSize != 2048 {
		t.Fatalf("artifact metadata = %#v", term)
	}
	payload, err := json.Marshal(resp.SchoolTimetable.Terms[0])
	if err != nil {
		t.Fatal(err)
	}
	if json.Valid(payload) && string(payload) != "" && containsJSONKey(payload, "download_url") {
		t.Fatalf("school timetable term should not expose download_url: %s", payload)
	}
	if json.Valid(payload) && string(payload) != "" && containsJSONKey(payload, "snapshot") {
		t.Fatalf("school timetable term should not expose snapshot link: %s", payload)
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
	terms []schooldomain.Term
	err   error
}

func (s schoolTimetableProviderStub) ListActiveTerms(context.Context) ([]schooldomain.Term, error) {
	return s.terms, s.err
}
