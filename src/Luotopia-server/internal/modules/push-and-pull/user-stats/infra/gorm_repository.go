package infra

import (
	"context"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/user-stats/app"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

func (r *GormRepository) CountUsers(ctx context.Context) (int, error) {
	var count int64
	err := r.db.WithContext(ctx).Table("auth_users").Count(&count).Error
	return int(count), err
}

func (r *GormRepository) CountActiveSessions(ctx context.Context) (int, error) {
	var count int64
	err := r.db.WithContext(ctx).Table("auth_sessions").
		Where("expires_at > ? AND revoked_at IS NULL", time.Now()).
		Count(&count).Error
	return int(count), err
}
