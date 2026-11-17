package infra

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/account/auth/app"
	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	profiledomain "github.com/openwhu/luotopia/server/internal/modules/account/profile/domain"
	"github.com/openwhu/luotopia/server/internal/platform/id"
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
	ID           string `gorm:"primaryKey;column:id"`
	Status       string
	PasswordHash *string
	CreatedAt    time.Time
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

type sessionModel struct {
	ID               string `gorm:"primaryKey;column:id"`
	PublicID         *string
	UserID           string
	RefreshTokenHash string
	DeviceName       string
	CreatedAt        time.Time
	ExpiresAt        time.Time
	RevokedAt        *time.Time
}

func (sessionModel) TableName() string { return "auth_sessions" }

type profileModel struct {
	UserID     string `gorm:"primaryKey;column:user_id"`
	ExternalID string
	Username   *string
	AvatarURL  *string
	CreatedAt  time.Time
	UpdatedAt  time.Time
}

func (profileModel) TableName() string { return "account_profiles" }

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
	for attempt := 0; attempt < 8; attempt++ {
		now := time.Now()
		user := userModel{ID: id.New(id.TypeUser), Status: string(domain.UserStatusActive), CreatedAt: now}
		identity := identityModel{ID: id.New(id.TypeIdentity), UserID: user.ID, Type: string(identityType), Identifier: normalizeIdentifier(identityType, identifier), VerifiedAt: now, CreatedAt: now}
		externalID, err := profiledomain.NewExternalID()
		if err != nil {
			return nil, err
		}
		profile := profileModel{UserID: user.ID, ExternalID: externalID, CreatedAt: now, UpdatedAt: now}
		err = r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
			if err := tx.Create(&user).Error; err != nil {
				return err
			}
			if err := tx.Create(&identity).Error; err != nil {
				return err
			}
			return tx.Create(&profile).Error
		})
		if err == nil {
			return toDomainUser(user), nil
		}
		if strings.Contains(err.Error(), "account_profiles") && strings.Contains(err.Error(), "duplicate") {
			continue
		}
		return nil, err
	}
	return nil, domain.ErrInvalidArgument
}

func (r *GormUserRepository) FindAccountByUserID(ctx context.Context, userID string) (domain.AccountSummary, error) {
	var user userModel
	if err := r.db.WithContext(ctx).First(&user, "id = ?", userID).Error; err != nil {
		return domain.AccountSummary{}, err
	}
	profile, err := r.ensureProfile(ctx, user)
	if err != nil {
		return domain.AccountSummary{}, err
	}
	identities, err := r.FindIdentitiesByUserID(ctx, userID)
	if err != nil {
		return domain.AccountSummary{}, err
	}
	return toAccountSummary(user, profile, identities), nil
}

func (r *GormUserRepository) UpdateUsername(ctx context.Context, userID string, username string) (domain.AccountSummary, error) {
	normalized, err := profiledomain.NormalizeUsername(username)
	if err != nil {
		return domain.AccountSummary{}, domain.ErrInvalidArgument
	}
	var user userModel
	if err := r.db.WithContext(ctx).First(&user, "id = ?", userID).Error; err != nil {
		return domain.AccountSummary{}, err
	}
	if _, err := r.ensureProfile(ctx, user); err != nil {
		return domain.AccountSummary{}, err
	}
	now := time.Now()
	if err := r.db.WithContext(ctx).Model(&profileModel{}).Where("user_id = ?", userID).Updates(map[string]any{
		"username":   normalized,
		"updated_at": now,
	}).Error; err != nil {
		return domain.AccountSummary{}, err
	}
	return r.FindAccountByUserID(ctx, userID)
}

func (r *GormUserRepository) FindUserByLoginIdentifier(ctx context.Context, identifier string) (*domain.User, error) {
	if user, err := r.FindUserByIdentity(ctx, domain.IdentityPhone, identifier); err == nil {
		return user, nil
	}
	return r.FindUserByIdentity(ctx, domain.IdentityEmail, strings.ToLower(identifier))
}

func (r *GormUserRepository) BindIdentity(ctx context.Context, userID string, identityType domain.IdentityType, identifier string) error {
	now := time.Now()
	normalized := normalizeIdentifier(identityType, identifier)
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var existing identityModel
		err := tx.Where("user_id = ? AND type = ?", userID, string(identityType)).First(&existing).Error
		if err == nil {
			return tx.Model(&identityModel{}).
				Where("id = ?", existing.ID).
				Updates(map[string]any{"identifier": normalized, "verified_at": now}).Error
		}
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return err
		}
		identity := identityModel{ID: id.New(id.TypeIdentity), UserID: userID, Type: string(identityType), Identifier: normalized, VerifiedAt: now, CreatedAt: now}
		return tx.Create(&identity).Error
	})
	if err != nil {
		if strings.Contains(err.Error(), "duplicate") {
			return domain.ErrIdentityAlreadyBound
		}
		return err
	}
	return nil
}

func (r *GormUserRepository) SetPassword(ctx context.Context, userID string, passwordHash string) error {
	return r.db.WithContext(ctx).Model(&userModel{}).Where("id = ?", userID).Update("password_hash", passwordHash).Error
}

func (r *GormUserRepository) PasswordHash(ctx context.Context, userID string) (string, error) {
	var model userModel
	err := r.db.WithContext(ctx).Select("password_hash").First(&model, "id = ?", userID).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", domain.ErrPasswordNotSet
		}
		return "", err
	}
	if model.PasswordHash == nil {
		return "", domain.ErrPasswordNotSet
	}
	return *model.PasswordHash, nil
}

func (r *GormUserRepository) CreateSession(ctx context.Context, session domain.Session) error {
	publicID := session.PublicID
	return r.db.WithContext(ctx).Create(&sessionModel{
		ID:               session.ID,
		PublicID:         &publicID,
		UserID:           session.UserID,
		RefreshTokenHash: session.RefreshTokenHash,
		DeviceName:       session.DeviceName,
		CreatedAt:        session.CreatedAt,
		ExpiresAt:        session.ExpiresAt,
		RevokedAt:        session.RevokedAt,
	}).Error
}

func (r *GormUserRepository) FindSessionsByUserID(ctx context.Context, userID string) ([]domain.Session, error) {
	var models []sessionModel
	err := r.db.WithContext(ctx).
		Where("user_id = ? AND revoked_at IS NULL", userID).
		Order("created_at DESC").
		Find(&models).Error
	if err != nil {
		return nil, err
	}
	result := make([]domain.Session, len(models))
	for i, model := range models {
		result[i] = *toDomainSession(model)
	}
	return result, nil
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

func (r *GormUserRepository) RevokeSessionByPublicID(ctx context.Context, userID string, publicID string) error {
	now := time.Now()
	result := r.db.WithContext(ctx).Model(&sessionModel{}).
		Where("user_id = ? AND public_id = ? AND revoked_at IS NULL", userID, publicID).
		Update("revoked_at", now)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return domain.ErrSessionNotFound
	}
	return nil
}

func (r *GormUserRepository) RevokeUserSessions(ctx context.Context, userID string) error {
	now := time.Now()
	return r.db.WithContext(ctx).Model(&sessionModel{}).Where("user_id = ? AND revoked_at IS NULL", userID).Update("revoked_at", now).Error
}

func toDomainUser(model userModel) *domain.User {
	return &domain.User{ID: model.ID, Status: domain.UserStatus(model.Status), CreatedAt: model.CreatedAt}
}

func (r *GormUserRepository) ensureProfile(ctx context.Context, user userModel) (profileModel, error) {
	var profile profileModel
	err := r.db.WithContext(ctx).First(&profile, "user_id = ?", user.ID).Error
	if err == nil {
		return profile, nil
	}
	if !errors.Is(err, gorm.ErrRecordNotFound) {
		return profileModel{}, err
	}
	for attempt := 0; attempt < 8; attempt++ {
		externalID, err := profiledomain.NewExternalID()
		if err != nil {
			return profileModel{}, err
		}
		now := time.Now()
		profile = profileModel{UserID: user.ID, ExternalID: externalID, CreatedAt: user.CreatedAt, UpdatedAt: now}
		err = r.db.WithContext(ctx).Create(&profile).Error
		if err == nil {
			return profile, nil
		}
		if strings.Contains(err.Error(), "duplicate") {
			continue
		}
		if errors.Is(err, gorm.ErrDuplicatedKey) {
			continue
		}
		return profileModel{}, err
	}
	return profileModel{}, domain.ErrInvalidArgument
}

func toAccountSummary(user userModel, profile profileModel, identities []domain.Identity) domain.AccountSummary {
	summary := domain.AccountIdentitySummary{}
	for _, identity := range identities {
		switch identity.Type {
		case domain.IdentityPhone:
			summary.Phone = identity.Identifier
		case domain.IdentityEmail:
			summary.Email = identity.Identifier
		case domain.IdentityWechat:
			summary.Wechat = identity.Identifier
		case domain.IdentityQQ:
			summary.QQ = identity.Identifier
		}
	}
	var username string
	if profile.Username != nil {
		username = *profile.Username
	}
	var avatarURL string
	if profile.AvatarURL != nil {
		avatarURL = *profile.AvatarURL
	}
	return domain.AccountSummary{
		UserID:      user.ID,
		ExternalID:  profile.ExternalID,
		Username:    username,
		AvatarURL:   avatarURL,
		HasPassword: user.PasswordHash != nil && *user.PasswordHash != "",
		Identities:  summary,
		CreatedAt:   profile.CreatedAt,
		UpdatedAt:   profile.UpdatedAt,
	}
}

func (r *GormUserRepository) FindIdentitiesByUserID(ctx context.Context, userID string) ([]domain.Identity, error) {
	var models []identityModel
	if err := r.db.WithContext(ctx).Where("user_id = ?", userID).Find(&models).Error; err != nil {
		return nil, err
	}
	result := make([]domain.Identity, len(models))
	for i, m := range models {
		result[i] = domain.Identity{
			ID:         m.ID,
			UserID:     m.UserID,
			Type:       domain.IdentityType(m.Type),
			Identifier: m.Identifier,
			VerifiedAt: m.VerifiedAt,
			CreatedAt:  m.CreatedAt,
		}
	}
	return result, nil
}

func toDomainSession(model sessionModel) *domain.Session {
	var publicID string
	if model.PublicID != nil {
		publicID = *model.PublicID
	}
	return &domain.Session{ID: model.ID, PublicID: publicID, UserID: model.UserID, RefreshTokenHash: model.RefreshTokenHash, DeviceName: model.DeviceName, CreatedAt: model.CreatedAt, ExpiresAt: model.ExpiresAt, RevokedAt: model.RevokedAt}
}

func normalizeIdentifier(identityType domain.IdentityType, value string) string {
	if identityType == domain.IdentityEmail {
		return strings.ToLower(strings.TrimSpace(value))
	}
	return strings.TrimSpace(value)
}
