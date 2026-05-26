package app

import (
	"context"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/domain"
	hotapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/app"
	notiapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	statsapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/user-stats/app"
	weatherapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/app"
)

type SyncChecker interface {
	IsSyncEnabledForUser(ctx context.Context, userID string) (bool, error)
}

type Service struct {
	weatherSvc   *weatherapp.Service
	notifcSvc    *notiapp.Service
	hotUpdateSvc *hotapp.Service
	syncChecker  SyncChecker
	statsSvc     *statsapp.Service
}

func NewService(weatherSvc *weatherapp.Service, notifcSvc *notiapp.Service, hotUpdateSvc *hotapp.Service, syncChecker SyncChecker, statsSvc *statsapp.Service) *Service {
	return &Service{
		weatherSvc:   weatherSvc,
		notifcSvc:    notifcSvc,
		hotUpdateSvc: hotUpdateSvc,
		syncChecker:  syncChecker,
		statsSvc:     statsSvc,
	}
}

func (s *Service) Pull(ctx context.Context, userID string) domain.PullResponse {
	resp := domain.PullResponse{}

	// Weather: return cached data or empty
	if s.weatherSvc != nil {
		if data, err := s.weatherSvc.GetCached(ctx); err == nil && data != nil {
			ts := data.UpdatedAt.Unix()
			resp.Weather = &domain.WeatherBlock{
				Data:     data,
				CachedAt: &ts,
			}
		}
	}

	// Notification: latest info
	if s.notifcSvc != nil {
		info := s.notifcSvc.GetLatestInfo(ctx)
		resp.Notification = &domain.NotificationBlock{
			LatestID: info.LatestID,
			HasNew:   info.HasNew,
			Count:    info.Count,
		}
	}

	// Hot update: script versions
	if s.hotUpdateSvc != nil {
		versions := s.hotUpdateSvc.GetScriptVersions(ctx)
		scripts := make(map[string]domain.ScriptVersion, len(versions))
		for name, info := range versions {
			scripts[name] = domain.ScriptVersion{
				LatestVersion: info.LatestVersion,
				Checksum:      info.Checksum,
			}
		}
		resp.HotUpdate = &domain.HotUpdateBlock{Scripts: scripts}
	}

	// Sync: capability
	if s.syncChecker != nil && userID != "" {
		enabled, _ := s.syncChecker.IsSyncEnabledForUser(ctx, userID)
		resp.Sync = &domain.SyncBlock{Enabled: enabled}
	}

	// Stats
	if s.statsSvc != nil {
		stats := s.statsSvc.GetStats(ctx)
		resp.Stats = &domain.StatsBlock{
			TotalUsers:     stats.TotalUsers,
			ActiveSessions: stats.ActiveSessions,
		}
	}

	return resp
}
