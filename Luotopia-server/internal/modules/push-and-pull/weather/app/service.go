package app

import (
	"context"
	"encoding/json"
	"errors"
	"sync"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/domain"
)

var ErrNoCacheData = errors.New("weather: no cached data")

type CacheStore interface {
	Get(ctx context.Context, key string) ([]byte, error)
	Set(ctx context.Context, key string, value []byte, ttl time.Duration) error
}

type WeatherAPI interface {
	FetchWeather() (*domain.WeatherData, error)
}

type Service struct {
	cache         CacheStore
	api           WeatherAPI
	ttl           time.Duration
	mu            sync.RWMutex
	lastRefreshAt *time.Time
	lastError     string
}

func NewService(cache CacheStore, api WeatherAPI, ttl time.Duration) *Service {
	return &Service{cache: cache, api: api, ttl: ttl}
}

func (s *Service) GetCached(ctx context.Context) (*domain.WeatherData, error) {
	data, err := s.cache.Get(ctx, "weather:current")
	if err != nil {
		return nil, err
	}
	if data == nil {
		return nil, ErrNoCacheData
	}
	var weather domain.WeatherData
	if err := json.Unmarshal(data, &weather); err != nil {
		return nil, err
	}
	return &weather, nil
}

func (s *Service) FetchAndCache(ctx context.Context) error {
	weather, err := s.api.FetchWeather()
	if err != nil {
		s.recordRefresh(nil, err)
		return err
	}
	data, err := json.Marshal(weather)
	if err != nil {
		s.recordRefresh(nil, err)
		return err
	}
	if err := s.cache.Set(ctx, "weather:current", data, s.ttl); err != nil {
		s.recordRefresh(nil, err)
		return err
	}
	s.recordRefresh(&weather.UpdatedAt, nil)
	return nil
}

func (s *Service) Status(ctx context.Context) domain.WeatherStatus {
	data, err := s.GetCached(ctx)
	s.mu.RLock()
	lastRefreshAt := s.lastRefreshAt
	lastError := s.lastError
	s.mu.RUnlock()

	if err != nil && !errors.Is(err, ErrNoCacheData) && lastError == "" {
		lastError = err.Error()
	}

	var cachedAt *time.Time
	if data != nil {
		cachedAt = &data.UpdatedAt
	}
	return domain.WeatherStatus{
		Enabled:       s.api != nil && s.cache != nil,
		CacheTTL:      int64(s.ttl.Seconds()),
		CachedAt:      cachedAt,
		LastRefreshAt: lastRefreshAt,
		LastError:     lastError,
		Data:          data,
	}
}

func (s *Service) recordRefresh(refreshedAt *time.Time, err error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if refreshedAt != nil {
		t := *refreshedAt
		s.lastRefreshAt = &t
	} else {
		now := time.Now()
		s.lastRefreshAt = &now
	}
	if err != nil {
		s.lastError = err.Error()
		return
	}
	s.lastError = ""
}
