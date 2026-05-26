package app

import (
	"context"
	"errors"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/domain"
)

var ErrNoCacheData = errors.New("weather: no cached data")

type CacheStore interface {
	Get(ctx context.Context, key string) ([]byte, error)
	Set(ctx context.Context, key string, value []byte, ttl time.Duration) error
}

type Service struct {
	cache CacheStore
}

func NewService(cache CacheStore) *Service {
	return &Service{cache: cache}
}

func (s *Service) GetCached(ctx context.Context) (*domain.WeatherData, error) {
	data, err := s.cache.Get(ctx, "weather:current")
	if err != nil {
		return nil, err
	}
	if data == nil {
		return nil, ErrNoCacheData
	}
	return nil, ErrNoCacheData
}
