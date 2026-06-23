package app

import (
	"context"
	"time"

	hotapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/app"
	hotcontract "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/contract"
	notiapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/domain"
	statsapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/user-stats/app"
	weatherapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/app"
	schooldomain "github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
)

type SyncChecker interface {
	IsSyncEnabledForUser(ctx context.Context, userID string) (bool, error)
	LatestSyncCursor(ctx context.Context, userID string) (int64, error)
}

type Service struct {
	weatherSvc         *weatherapp.Service
	notifcSvc          *notiapp.Service
	hotUpdateSvc       *hotapp.Service
	syncChecker        SyncChecker
	statsSvc           *statsapp.Service
	schoolTimetableSvc SchoolTimetableProvider
}

type SchoolTimetableProvider interface {
	ListActiveTerms(ctx context.Context) ([]schooldomain.Term, error)
}

func NewService(weatherSvc *weatherapp.Service, notifcSvc *notiapp.Service, hotUpdateSvc *hotapp.Service, syncChecker SyncChecker, statsSvc *statsapp.Service, schoolTimetableSvc SchoolTimetableProvider) *Service {
	return &Service{
		weatherSvc:         weatherSvc,
		notifcSvc:          notifcSvc,
		hotUpdateSvc:       hotUpdateSvc,
		syncChecker:        syncChecker,
		statsSvc:           statsSvc,
		schoolTimetableSvc: schoolTimetableSvc,
	}
}

func (s *Service) Pull(ctx context.Context, userID string, req domain.PullRequest) domain.PullResponse {
	resp := domain.PullResponse{ServerTime: now()}

	// Weather: return cached data or empty
	if s.weatherSvc != nil && scopeEnabled(req.Scopes, "weather") {
		if data, err := s.weatherSvc.GetCached(ctx); err == nil && data != nil {
			ts := data.UpdatedAt.Unix()
			changed := req.ClientState.WeatherCachedAt == nil || *req.ClientState.WeatherCachedAt != ts
			resp.Weather = &domain.WeatherBlock{
				Changed:  changed,
				Data:     valueIf(changed, data),
				CachedAt: &ts,
			}
		}
	}

	// Notification: latest info
	if s.notifcSvc != nil && scopeEnabled(req.Scopes, "notification") {
		info := s.notifcSvc.GetLatestInfo(ctx, req.ClientState.NotificationLatestID)
		resp.Notification = &domain.NotificationBlock{
			Changed:  info.HasNew,
			LatestID: info.LatestID,
			HasNew:   info.HasNew,
			Count:    info.Count,
			Title:    info.Title,
			Icon:     info.Icon,
		}
		if info.PublishedAt != nil {
			resp.Notification.PublishedAt = info.PublishedAt.Format(time.RFC3339)
		}
	}

	// Hot update: script versions
	if s.hotUpdateSvc != nil && scopeEnabled(req.Scopes, "hot_update") {
		versions := s.hotUpdateSvc.GetScriptVersions(ctx)
		scripts := make(map[string]domain.ScriptVersion, len(versions))
		for name, info := range versions {
			client := req.ClientState.HotUpdateScripts[name]
			changed := client.Version != info.LatestVersion || client.Checksum != info.Checksum
			if !changed && len(req.Scopes) > 0 {
				continue
			}
			scripts[name] = domain.ScriptVersion{
				Changed:       changed,
				LatestVersion: info.LatestVersion,
				Checksum:      info.Checksum,
				Links: map[string]domain.Link{
					"content": {Href: hotcontract.ScriptContentPath(name)},
				},
			}
		}
		resp.HotUpdate = &domain.HotUpdateBlock{Scripts: scripts}
	}

	// Sync: capability
	if s.syncChecker != nil && userID != "" && scopeEnabled(req.Scopes, "sync") {
		enabled, _ := s.syncChecker.IsSyncEnabledForUser(ctx, userID)
		block := &domain.SyncBlock{Enabled: enabled}
		if enabled {
			if latest, err := s.syncChecker.LatestSyncCursor(ctx, userID); err == nil {
				block.LatestCursor = &latest
				block.HasChanges = latest > 0 && (req.ClientState.SyncCursor == nil || latest > *req.ClientState.SyncCursor)
			}
		}
		resp.Sync = block
	}

	// Stats
	if s.statsSvc != nil && scopeEnabled(req.Scopes, "stats") {
		stats := s.statsSvc.GetStats(ctx)
		resp.Stats = &domain.StatsBlock{
			TotalUsers:     stats.TotalUsers,
			ActiveSessions: stats.ActiveSessions,
		}
	}

	if s.schoolTimetableSvc != nil && scopeEnabled(req.Scopes, "school_timetable") {
		terms, err := s.schoolTimetableSvc.ListActiveTerms(ctx)
		if err == nil {
			block := &domain.SchoolTimetableBlock{
				ActiveTerms: make([]string, 0, len(terms)),
				Terms:       []domain.SchoolTimetableTerm{},
			}
			for _, term := range terms {
				block.ActiveTerms = append(block.ActiveTerms, term.TermKey)
				client := domain.ClientTermState{}
				if req.ClientState.SchoolTimetableTerms != nil {
					client = req.ClientState.SchoolTimetableTerms[term.TermKey]
				}
				changed := client.Version != term.Version || client.Checksum != term.Checksum
				if changed {
					block.Changed = true
					block.Terms = append(block.Terms, domain.SchoolTimetableTerm{
						TermKey: term.TermKey, SchoolYear: term.SchoolYear, Term: term.Term,
						FirstWeekMonday: term.FirstWeekMonday,
						Version:         term.Version, Checksum: term.Checksum,
						ArtifactType: term.ArtifactType, SchemaVersion: term.SchemaVersion,
						ArtifactSize: term.ArtifactSize, RowCount: term.RowCount,
						Links: map[string]domain.Link{
							"artifact": {Href: term.ArtifactURL},
						},
						PublishedAt: term.PublishedAt.Format(time.RFC3339),
					})
				}
			}
			resp.SchoolTimetable = block
		}
	}

	return resp
}

var now = func() time.Time { return time.Now().UTC() }

func scopeEnabled(scopes []string, target string) bool {
	if len(scopes) == 0 {
		return true
	}
	for _, scope := range scopes {
		if scope == target {
			return true
		}
	}
	return false
}

func valueIf[T any](ok bool, value T) any {
	if !ok {
		return nil
	}
	return value
}
