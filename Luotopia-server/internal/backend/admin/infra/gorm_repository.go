package infra

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/backend/admin/app"
	"github.com/openwhu/luotopia/server/internal/backend/admin/domain"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

// Admin account auth

type adminAccountModel struct {
	ID           string     `gorm:"primaryKey;column:id"`
	Username     string     `gorm:"column:username"`
	PasswordHash string     `gorm:"column:password_hash"`
	Status       string     `gorm:"column:status"`
	CreatedAt    time.Time  `gorm:"column:created_at"`
	UpdatedAt    time.Time  `gorm:"column:updated_at"`
	LastLoginAt  *time.Time `gorm:"column:last_login_at"`
}

func (adminAccountModel) TableName() string { return "admin_accounts" }

func (r *GormRepository) FindAdminByUsername(ctx context.Context, username string) (app.AdminAccount, error) {
	var model adminAccountModel
	err := r.db.WithContext(ctx).First(&model, "username = ?", normalizeAdminUsername(username)).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return app.AdminAccount{}, app.ErrInvalidCredential
	}
	if err != nil {
		return app.AdminAccount{}, err
	}
	return app.AdminAccount{
		ID:           model.ID,
		Username:     model.Username,
		PasswordHash: model.PasswordHash,
		Status:       model.Status,
		CreatedAt:    model.CreatedAt,
		UpdatedAt:    model.UpdatedAt,
		LastLoginAt:  model.LastLoginAt,
	}, nil
}

func (r *GormRepository) SaveAdminAccount(ctx context.Context, account app.AdminAccount) error {
	now := time.Now()
	model := adminAccountModel{
		ID:           appID(),
		Username:     normalizeAdminUsername(account.Username),
		PasswordHash: account.PasswordHash,
		Status:       account.Status,
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	return r.db.WithContext(ctx).Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "username"}},
		DoUpdates: clause.Assignments(map[string]any{
			"password_hash": model.PasswordHash,
			"status":        model.Status,
			"updated_at":    model.UpdatedAt,
		}),
	}).Create(&model).Error
}

func (r *GormRepository) TouchAdminLogin(ctx context.Context, id string) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&adminAccountModel{}).Where("id = ?", id).Update("last_login_at", now).Error
}

// User queries

type userModel struct {
	ID        string    `gorm:"primaryKey;column:id"`
	Status    string    `gorm:"column:status"`
	CreatedAt time.Time `gorm:"column:created_at"`
}

func (userModel) TableName() string { return "auth_users" }

type identityModel struct {
	ID         string    `gorm:"primaryKey;column:id"`
	UserID     string    `gorm:"column:user_id"`
	Type       string    `gorm:"column:type"`
	Identifier string    `gorm:"column:identifier"`
	VerifiedAt time.Time `gorm:"column:verified_at"`
	CreatedAt  time.Time `gorm:"column:created_at"`
}

func (identityModel) TableName() string { return "auth_identities" }

type sessionModel struct {
	ID     string `gorm:"primaryKey;column:id"`
	UserID string `gorm:"column:user_id"`
}

func (sessionModel) TableName() string { return "auth_sessions" }

func (r *GormRepository) ListUsers(ctx context.Context, offset, limit int) ([]domain.UserInfo, int64, error) {
	var total int64
	if err := r.db.WithContext(ctx).Model(&userModel{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var users []userModel
	if err := r.db.WithContext(ctx).Order("created_at DESC").Offset(offset).Limit(limit).Find(&users).Error; err != nil {
		return nil, 0, err
	}
	result := make([]domain.UserInfo, len(users))
	for i, u := range users {
		result[i] = domain.UserInfo{
			ID:        u.ID,
			Status:    u.Status,
			CreatedAt: u.CreatedAt,
		}
		// Get identities
		var identities []identityModel
		if err := r.db.WithContext(ctx).Where("user_id = ?", u.ID).Find(&identities).Error; err == nil {
			for _, id := range identities {
				if id.Type == "phone" {
					result[i].Phone = id.Identifier
				} else if id.Type == "email" {
					result[i].Email = id.Identifier
				}
			}
		}
		// Count active sessions
		var cnt int64
		if err := r.db.WithContext(ctx).Model(&sessionModel{}).
			Where("user_id = ?", u.ID).
			Count(&cnt).Error; err == nil {
			result[i].SessionCnt = cnt
		}
	}
	return result, total, nil
}

func (r *GormRepository) GetUser(ctx context.Context, id string) (domain.UserInfo, error) {
	var u userModel
	if err := r.db.WithContext(ctx).First(&u, "id = ?", id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return domain.UserInfo{}, app.ErrNotFound
		}
		return domain.UserInfo{}, err
	}
	info := domain.UserInfo{
		ID:        u.ID,
		Status:    u.Status,
		CreatedAt: u.CreatedAt,
	}
	var identities []identityModel
	if err := r.db.WithContext(ctx).Where("user_id = ?", u.ID).Find(&identities).Error; err == nil {
		for _, id := range identities {
			if id.Type == "phone" {
				info.Phone = id.Identifier
			} else if id.Type == "email" {
				info.Email = id.Identifier
			}
		}
	}
	var cnt int64
	r.db.WithContext(ctx).Model(&sessionModel{}).Where("user_id = ?", u.ID).Count(&cnt)
	info.SessionCnt = cnt
	return info, nil
}

// Sync allowlist management

type syncAllowlistModel struct {
	UserID    string    `gorm:"primaryKey;column:user_id"`
	Enabled   bool      `gorm:"column:enabled"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (syncAllowlistModel) TableName() string { return "sync_user_allowlist" }

func (r *GormRepository) ListAllowlist(ctx context.Context) ([]domain.SyncAllowlistEntry, error) {
	var rows []syncAllowlistModel
	if err := r.db.WithContext(ctx).Find(&rows).Error; err != nil {
		return nil, err
	}
	result := make([]domain.SyncAllowlistEntry, len(rows))
	for i, row := range rows {
		result[i] = domain.SyncAllowlistEntry{
			UserID:    row.UserID,
			Enabled:   row.Enabled,
			CreatedAt: row.CreatedAt,
			UpdatedAt: row.UpdatedAt,
		}
	}
	return result, nil
}

func (r *GormRepository) AddAllowlist(ctx context.Context, userID string) error {
	now := time.Now()
	return r.db.WithContext(ctx).Save(&syncAllowlistModel{
		UserID:    userID,
		Enabled:   true,
		CreatedAt: now,
		UpdatedAt: now,
	}).Error
}

func (r *GormRepository) RemoveAllowlist(ctx context.Context, userID string) error {
	return r.db.WithContext(ctx).Delete(&syncAllowlistModel{}, "user_id = ?", userID).Error
}

func normalizeAdminUsername(value string) string {
	return strings.ToLower(strings.TrimSpace(value))
}

func appID() string {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return strings.ReplaceAll(time.Now().UTC().Format("20060102150405.000000000"), ".", "")
	}
	return hex.EncodeToString(bytes)
}
