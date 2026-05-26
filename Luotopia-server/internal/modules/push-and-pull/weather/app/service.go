package app

import (
	"context"
	"encoding/json"
	"errors"
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
	cache CacheStore
	api   WeatherAPI
	ttl   time.Duration
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
		return err
	}
	data, err := json.Marshal(weather)
	if err != nil {
		return err
	}
	return s.cache.Set(ctx, "weather:current", data, s.ttl)
}
