package database

import (
	"context"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

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

func OpenPostgres(dsn string) (*gorm.DB, error) {
	return gorm.Open(postgres.Open(dsn), &gorm.Config{})
}
