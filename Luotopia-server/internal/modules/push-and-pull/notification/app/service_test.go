package app_test

import (
	"context"
	"testing"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/domain"
)

func TestLatestInfoComparesClientLatestID(t *testing.T) {
	ctx := context.Background()
	latest := domain.Notification{
		ID:          "notice_2",
		Title:       "新版通知",
		Content:     "正文",
		Icon:        "campaign",
		Status:      domain.StatusPublished,
		PublishedAt: ptrTime(time.Date(2026, 5, 26, 10, 0, 0, 0, time.UTC)),
		CreatedAt:   time.Date(2026, 5, 26, 9, 0, 0, 0, time.UTC),
		UpdatedAt:   time.Date(2026, 5, 26, 9, 0, 0, 0, time.UTC),
	}
	service := app.NewService(&notificationRepoStub{
		latest: latest,
		count:  2,
	})

	info := service.GetLatestInfo(ctx, "notice_1")
	if !info.HasNew {
		t.Fatal("客户端 latest_id 落后时应返回 has_new=true")
	}
	if info.LatestID != "notice_2" {
		t.Fatalf("latest_id = %s, want notice_2", info.LatestID)
	}

	info = service.GetLatestInfo(ctx, "notice_2")
	if info.HasNew {
		t.Fatal("客户端 latest_id 已是最新时应返回 has_new=false")
	}
}

type notificationRepoStub struct {
	latest domain.Notification
	count  int64
}

func (r *notificationRepoStub) Create(context.Context, domain.Notification) error {
	return nil
}

func (r *notificationRepoStub) GetByID(context.Context, string) (domain.Notification, error) {
	return r.latest, nil
}

func (r *notificationRepoStub) List(context.Context, domain.Status, int, int) ([]domain.Notification, int64, error) {
	return []domain.Notification{r.latest}, r.count, nil
}

func (r *notificationRepoStub) Update(context.Context, domain.Notification) error {
	return nil
}

func (r *notificationRepoStub) Delete(context.Context, string) error {
	return nil
}

func (r *notificationRepoStub) GetLatestPublished(context.Context) (domain.Notification, error) {
	return r.latest, nil
}

func (r *notificationRepoStub) CountPublished(context.Context) (int64, error) {
	return r.count, nil
}

func ptrTime(value time.Time) *time.Time {
	return &value
}
