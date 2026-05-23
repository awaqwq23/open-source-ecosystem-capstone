package database

import "context"

type DB interface {
	Ping(ctx context.Context) error
	Close() error
}

type NoopDB struct{}

func (NoopDB) Ping(context.Context) error {
	return nil
}

func (NoopDB) Close() error {
	return nil
}
