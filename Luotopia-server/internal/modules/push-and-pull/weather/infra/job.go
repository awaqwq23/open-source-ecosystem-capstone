package infra

import (
	"context"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/app"
)

type RefreshJob struct {
	service *app.Service
}

func NewRefreshJob(service *app.Service) *RefreshJob {
	return &RefreshJob{service: service}
}

func (j *RefreshJob) Name() string {
	return "weather_refresh"
}

func (j *RefreshJob) Run(ctx context.Context) error {
	return j.service.FetchAndCache(ctx)
}
