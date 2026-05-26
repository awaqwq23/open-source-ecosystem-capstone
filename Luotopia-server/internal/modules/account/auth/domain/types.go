package domain

import (
	"errors"
	"time"
)

type IdentityType string

const (
	IdentityPhone  IdentityType = "phone"
	IdentityEmail  IdentityType = "email"
	IdentityQQ     IdentityType = "qq"
	IdentityWechat IdentityType = "wechat"
)

type VerificationPurpose string

const (
	VerificationPurposeLogin        VerificationPurpose = "login"
	VerificationPurposeBind         VerificationPurpose = "bind"
	VerificationPurposeReset        VerificationPurpose = "reset_password"
	VerificationPurposeConfirmation VerificationPurpose = "sensitive_confirmation"
)

type UserStatus string

const (
	UserStatusActive   UserStatus = "active"
	UserStatusDisabled UserStatus = "disabled"
)

var (
	ErrInvalidArgument        = errors.New("invalid_argument")
	ErrVerificationFailed     = errors.New("verification_failed")
	ErrIdentityAlreadyBound   = errors.New("identity_already_bound")
	ErrIdentityNotFound       = errors.New("identity_not_found")
	ErrPasswordNotSet         = errors.New("password_not_set")
	ErrInvalidCredential      = errors.New("invalid_credential")
	ErrSessionNotFound        = errors.New("session_not_found")
	ErrSocialProviderDisabled = errors.New("not_enabled")
)

type User struct {
	ID        string
	Status    UserStatus
	CreatedAt time.Time
}

type Identity struct {
	ID         string
	UserID     string
	Type       IdentityType
	Identifier string
	VerifiedAt time.Time
	CreatedAt  time.Time
}

type PublicProfile struct {
	UserID    string
	PublicID  string
	Nickname  string
	AvatarURL string
	CreatedAt time.Time
	UpdatedAt time.Time
}

type Session struct {
	ID               string
	UserID           string
	RefreshTokenHash string
	DeviceName       string
	CreatedAt        time.Time
	ExpiresAt        time.Time
	RevokedAt        *time.Time
}

type TokenPair struct {
	AccessToken  string
	RefreshToken string
	ExpiresIn    int64
}
