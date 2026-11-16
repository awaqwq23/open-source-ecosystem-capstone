package storage

import (
	"context"
	"io"
)

type Object struct {
	Key         string
	ContentType string
	Size        int64
	Body        io.ReadCloser
}

type Store interface {
	Put(ctx context.Context, object Object) error
	Get(ctx context.Context, key string) (Object, error)
	Delete(ctx context.Context, key string) error
}
