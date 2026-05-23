package cache

import (
	"context"
	"time"
)

type Store interface {
	Get(ctx context.Context, key string) ([]byte, error)
	Set(ctx context.Context, key string, value []byte, ttl time.Duration) error
	Delete(ctx context.Context, key string) error
}

type NoopStore struct{}

func (NoopStore) Get(context.Context, string) ([]byte, error) {
	return nil, nil
}

func (NoopStore) Set(context.Context, string, []byte, time.Duration) error {
	return nil
}

func (NoopStore) Delete(context.Context, string) error {
	return nil
}
