package infra

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/account/auth/app"
	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	"gorm.io/gorm"
)

var _ app.UserRepository = (*GormUserRepository)(nil)

type GormUserRepository struct {
	db *gorm.DB
}

func NewGormUserRepository(db *gorm.DB) *GormUserRepository {
	return &GormUserRepository{db: db}
}

type userModel struct {
	ID        string `gorm:"primaryKey;column:id"`
	Status    string
	CreatedAt time.Time
}

func (userModel) TableName() string { return "auth_users" }

type identityModel struct {
	ID         string `gorm:"primaryKey;column:id"`
	UserID     string
	Type       string
	Identifier string
	VerifiedAt time.Time
	CreatedAt  time.Time
}

func (identityModel) TableName() string { return "auth_identities" }

type passwordModel struct {
	UserID       string `gorm:"primaryKey;column:user_id"`
	PasswordHash string
	UpdatedAt    time.Time
}

func (passwordModel) TableName() string { return "auth_password_credentials" }

type sessionModel struct {
	ID               string `gorm:"primaryKey;column:id"`
	UserID           string
	RefreshTokenHash string
	DeviceName       string
	CreatedAt        time.Time
	ExpiresAt        time.Time
	RevokedAt        *time.Time
}

func (sessionModel) TableName() string { return "auth_sessions" }

func (r *GormUserRepository) FindUserByIdentity(ctx context.Context, identityType domain.IdentityType, identifier string) (*domain.User, error) {
	var identity identityModel
	err := r.db.WithContext(ctx).Where("type = ? AND identifier = ?", string(identityType), normalizeIdentifier(identityType, identifier)).First(&identity).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, domain.ErrIdentityNotFound
	}
	if err != nil {
		return nil, err
	}
	var user userModel
	if err := r.db.WithContext(ctx).First(&user, "id = ?", identity.UserID).Error; err != nil {
		return nil, err
	}
	return toDomainUser(user), nil
}

func (r *GormUserRepository) CreateUserWithIdentity(ctx context.Context, identityType domain.IdentityType, identifier string) (*domain.User, error) {
	now := time.Now()
	user := userModel{ID: appID(), Status: string(domain.UserStatusActive), CreatedAt: now}
	identity := identityModel{ID: appID(), UserID: user.ID, Type: string(identityType), Identifier: normalizeIdentifier(identityType, identifier), VerifiedAt: now, CreatedAt: now}
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(&user).Error; err != nil {
			return err
		}
		return tx.Create(&identity).Error
	})
	if err != nil {
		return nil, err
	}
	return toDomainUser(user), nil
}

func (r *GormUserRepository) FindUserByLoginIdentifier(ctx context.Context, identifier string) (*domain.User, error) {
	if user, err := r.FindUserByIdentity(ctx, domain.IdentityPhone, identifier); err == nil {
		return user, nil
	}
	return r.FindUserByIdentity(ctx, domain.IdentityEmail, strings.ToLower(identifier))
}

func (r *GormUserRepository) BindIdentity(ctx context.Context, userID string, identityType domain.IdentityType, identifier string) error {
	now := time.Now()
	identity := identityModel{ID: appID(), UserID: userID, Type: string(identityType), Identifier: normalizeIdentifier(identityType, identifier), VerifiedAt: now, CreatedAt: now}
	if err := r.db.WithContext(ctx).Create(&identity).Error; err != nil {
		return err
	}
	return nil
}

func (r *GormUserRepository) SetPassword(ctx context.Context, userID string, passwordHash string) error {
	model := passwordModel{UserID: userID, PasswordHash: passwordHash, UpdatedAt: time.Now()}
	return r.db.WithContext(ctx).Save(&model).Error
}

func (r *GormUserRepository) PasswordHash(ctx context.Context, userID string) (string, error) {
	var model passwordModel
	err := r.db.WithContext(ctx).First(&model, "user_id = ?", userID).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return "", domain.ErrPasswordNotSet
	}
	if err != nil {
		return "", err
	}
	return model.PasswordHash, nil
}

func (r *GormUserRepository) CreateSession(ctx context.Context, session domain.Session) error {
	return r.db.WithContext(ctx).Create(&sessionModel{
		ID:               session.ID,
		UserID:           session.UserID,
		RefreshTokenHash: session.RefreshTokenHash,
		DeviceName:       session.DeviceName,
		CreatedAt:        session.CreatedAt,
		ExpiresAt:        session.ExpiresAt,
		RevokedAt:        session.RevokedAt,
	}).Error
}

func (r *GormUserRepository) FindSessionByRefreshHash(ctx context.Context, refreshHash string) (*domain.Session, error) {
	var model sessionModel
	err := r.db.WithContext(ctx).First(&model, "refresh_token_hash = ?", refreshHash).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, domain.ErrSessionNotFound
	}
	if err != nil {
		return nil, err
	}
	return toDomainSession(model), nil
}

func (r *GormUserRepository) RevokeSession(ctx context.Context, sessionID string) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&sessionModel{}).Where("id = ?", sessionID).Update("revoked_at", now).Error
}

func (r *GormUserRepository) RevokeUserSessions(ctx context.Context, userID string) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&sessionModel{}).Where("user_id = ? AND revoked_at IS NULL", userID).Update("revoked_at", now).Error
}

func toDomainUser(model userModel) *domain.User {
	return &domain.User{ID: model.ID, Status: domain.UserStatus(model.Status), CreatedAt: model.CreatedAt}
}

func toDomainSession(model sessionModel) *domain.Session {
	return &domain.Session{ID: model.ID, UserID: model.UserID, RefreshTokenHash: model.RefreshTokenHash, DeviceName: model.DeviceName, CreatedAt: model.CreatedAt, ExpiresAt: model.ExpiresAt, RevokedAt: model.RevokedAt}
}

func normalizeIdentifier(identityType domain.IdentityType, value string) string {
	if identityType == domain.IdentityEmail {
		return strings.ToLower(strings.TrimSpace(value))
	}
	return strings.TrimSpace(value)
}

func appID() string {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return strings.ReplaceAll(time.Now().UTC().Format("20060102150405.000000000"), ".", "")
	}
	return hex.EncodeToString(bytes)
}
