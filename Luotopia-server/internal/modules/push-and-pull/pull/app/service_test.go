package app

import (
	"context"
	"encoding/json"
	"testing"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/domain"
	schoolcontract "github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/contract"
	schooldomain "github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
)

// 用户要求添加，不允许删除。该测试保护 pull 聚合响应只能通过生产模块 contract 暴露课表快照链接。
func TestPullSchoolTimetableUsesSnapshotLinkContract(t *testing.T) {
	svc := NewService(nil, nil, nil, nil, nil, schoolTimetableProviderStub{
		terms: []schooldomain.Term{{
			TermKey:     "2025-2026-1",
			SchoolYear:  "2025-2026",
			Term:        "1",
			Version:     7,
			Checksum:    "sha256:snapshot",
			RowCount:    42,
			PublishedAt: time.Date(2026, 6, 20, 12, 0, 0, 0, time.UTC),
		}},
	})

	resp := svc.Pull(context.Background(), "", domain.PullRequest{
		Scopes: []string{"school_timetable"},
	})

	if resp.SchoolTimetable == nil || len(resp.SchoolTimetable.Terms) != 1 {
		t.Fatalf("school_timetable terms = %#v", resp.SchoolTimetable)
	}
	link := resp.SchoolTimetable.Terms[0].Links["snapshot"]
	want := schoolcontract.SnapshotPath("2025-2026-1", 7)
	if link.Href != want {
		t.Fatalf("snapshot link href = %q, want %q", link.Href, want)
	}
	payload, err := json.Marshal(resp.SchoolTimetable.Terms[0])
	if err != nil {
		t.Fatal(err)
	}
	if json.Valid(payload) && string(payload) != "" && containsJSONKey(payload, "download_url") {
		t.Fatalf("school timetable term should not expose download_url: %s", payload)
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
