package app

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	"github.com/openwhu/luotopia/server/internal/platform/id"
)

type UserRepository interface {
	FindUserByIdentity(ctx context.Context, identityType domain.IdentityType, identifier string) (*domain.User, error)
	CreateUserWithIdentity(ctx context.Context, identityType domain.IdentityType, identifier string) (*domain.User, error)
	FindUserByLoginIdentifier(ctx context.Context, identifier string) (*domain.User, error)
	BindIdentity(ctx context.Context, userID string, identityType domain.IdentityType, identifier string) error
	SetPassword(ctx context.Context, userID string, passwordHash string) error
	PasswordHash(ctx context.Context, userID string) (string, error)
	CreateSession(ctx context.Context, session domain.Session) error
	FindSessionByRefreshHash(ctx context.Context, refreshHash string) (*domain.Session, error)
	RevokeSession(ctx context.Context, sessionID string) error
	RevokeUserSessions(ctx context.Context, userID string) error
	FindIdentitiesByUserID(ctx context.Context, userID string) ([]domain.Identity, error)
}

type VerificationCodeStore interface {
	Save(ctx context.Context, target string, purpose domain.VerificationPurpose, code string, expiresAt time.Time) error
	Verify(ctx context.Context, target string, purpose domain.VerificationPurpose, code string) error
}

type VerificationSender interface {
	Send(ctx context.Context, targetType domain.IdentityType, target string, code string, purpose domain.VerificationPurpose) error
}

type PasswordHasher interface {
	Hash(password string) (string, error)
	Verify(password string, encodedHash string) bool
}

type TokenIssuer interface {
	Issue(ctx context.Context, user domain.User, session domain.Session) (string, int64, error)
}

type ServiceConfig struct {
	Users           UserRepository
	Codes           VerificationCodeStore
	Sender          VerificationSender
	Hasher          PasswordHasher
	Tokens          TokenIssuer
	Now             func() time.Time
	SessionDuration time.Duration
}

type Service struct {
	users           UserRepository
	codes           VerificationCodeStore
	sender          VerificationSender
	hasher          PasswordHasher
	tokens          TokenIssuer
	now             func() time.Time
	sessionDuration time.Duration
}

func NewService(cfg ServiceConfig) *Service {
	now := cfg.Now
	if now == nil {
		now = time.Now
	}
	sessionDuration := cfg.SessionDuration
	if sessionDuration <= 0 {
		sessionDuration = 30 * 24 * time.Hour
	}
	return &Service{
		users:           cfg.Users,
		codes:           cfg.Codes,
		sender:          cfg.Sender,
		hasher:          cfg.Hasher,
		tokens:          cfg.Tokens,
		now:             now,
		sessionDuration: sessionDuration,
	}
}

type SendVerificationCodeCommand struct {
	TargetType domain.IdentityType
	Target     string
	Purpose    domain.VerificationPurpose
}

func (s *Service) SendVerificationCode(ctx context.Context, cmd SendVerificationCodeCommand) error {
	target := normalizeIdentifier(cmd.TargetType, cmd.Target)
	if target == "" || cmd.Purpose == "" {
		return domain.ErrInvalidArgument
	}
	code := randomDigits(6)
	if err := s.codes.Save(ctx, target, cmd.Purpose, code, s.now().Add(10*time.Minute)); err != nil {
		return err
	}
	return s.sender.Send(ctx, cmd.TargetType, target, code, cmd.Purpose)
}

type VerificationCodeLoginCommand struct {
	TargetType domain.IdentityType
	Target     string
	Code       string
	DeviceName string
}

type AuthResult struct {
	User         domain.User
	AccessToken  string
	RefreshToken string
	ExpiresIn    int64
}

func (s *Service) LoginWithVerificationCode(ctx context.Context, cmd VerificationCodeLoginCommand) (AuthResult, error) {
	target := normalizeIdentifier(cmd.TargetType, cmd.Target)
	if cmd.TargetType != domain.IdentityPhone && cmd.TargetType != domain.IdentityEmail {
		return AuthResult{}, domain.ErrInvalidArgument
	}
	if err := s.codes.Verify(ctx, target, domain.VerificationPurposeLogin, cmd.Code); err != nil {
		return AuthResult{}, domain.ErrVerificationFailed
	}

	user, err := s.users.FindUserByIdentity(ctx, cmd.TargetType, target)
	if errors.Is(err, domain.ErrIdentityNotFound) {
		if cmd.TargetType != domain.IdentityPhone && cmd.TargetType != domain.IdentityEmail {
			return AuthResult{}, domain.ErrIdentityNotFound
		}
		user, err = s.users.CreateUserWithIdentity(ctx, cmd.TargetType, target)
	}
	if err != nil {
		return AuthResult{}, err
	}
	return s.issueSession(ctx, *user, cmd.DeviceName)
}

type PasswordLoginCommand struct {
	Identifier string
	Password   string
	DeviceName string
}

func (s *Service) LoginWithPassword(ctx context.Context, cmd PasswordLoginCommand) (AuthResult, error) {
	identifier := normalizeLooseIdentifier(cmd.Identifier)
	if identifier == "" || cmd.Password == "" {
		return AuthResult{}, domain.ErrInvalidArgument
	}
	user, err := s.users.FindUserByLoginIdentifier(ctx, identifier)
	if err != nil {
		return AuthResult{}, domain.ErrInvalidCredential
	}
	hash, err := s.users.PasswordHash(ctx, user.ID)
	if err != nil || !s.hasher.Verify(cmd.Password, hash) {
		return AuthResult{}, domain.ErrInvalidCredential
	}
	return s.issueSession(ctx, *user, cmd.DeviceName)
}

func (s *Service) SetPassword(ctx context.Context, userID string, password string) error {
	if userID == "" || len(password) < 8 {
		return domain.ErrInvalidArgument
	}
	hash, err := s.hasher.Hash(password)
	if err != nil {
		return err
	}
	return s.users.SetPassword(ctx, userID, hash)
}

func (s *Service) BindEmail(ctx context.Context, userID string, email string, code string) error {
	normalized := normalizeIdentifier(domain.IdentityEmail, email)
	if userID == "" || normalized == "" {
		return domain.ErrInvalidArgument
	}
	if err := s.codes.Verify(ctx, normalized, domain.VerificationPurposeBind, code); err != nil {
		return domain.ErrVerificationFailed
	}
	return s.users.BindIdentity(ctx, userID, domain.IdentityEmail, normalized)
}

func (s *Service) Refresh(ctx context.Context, refreshToken string, deviceName string) (AuthResult, error) {
	hash := hashToken(refreshToken)
	session, err := s.users.FindSessionByRefreshHash(ctx, hash)
	if err != nil {
		return AuthResult{}, domain.ErrSessionNotFound
	}
	if session.ExpiresAt.Before(s.now()) || session.RevokedAt != nil {
		return AuthResult{}, domain.ErrSessionNotFound
	}
	if err := s.users.RevokeSession(ctx, session.ID); err != nil {
		return AuthResult{}, err
	}
	user := domain.User{ID: session.UserID, Status: domain.UserStatusActive, CreatedAt: session.CreatedAt}
	return s.issueSession(ctx, user, deviceName)
}

func (s *Service) Logout(ctx context.Context, refreshToken string) error {
	session, err := s.users.FindSessionByRefreshHash(ctx, hashToken(refreshToken))
	if err != nil {
		return nil
	}
	return s.users.RevokeSession(ctx, session.ID)
}

func (s *Service) LogoutAll(ctx context.Context, userID string) error {
	if userID == "" {
		return domain.ErrInvalidArgument
	}
	return s.users.RevokeUserSessions(ctx, userID)
}

func (s *Service) issueSession(ctx context.Context, user domain.User, deviceName string) (AuthResult, error) {
	refreshToken := id.NewRaw()
	session := domain.Session{
		ID:               id.New(id.TypeSession),
		UserID:           user.ID,
		RefreshTokenHash: hashToken(refreshToken),
		DeviceName:       strings.TrimSpace(deviceName),
		CreatedAt:        s.now(),
		ExpiresAt:        s.now().Add(s.sessionDuration),
	}
	if err := s.users.CreateSession(ctx, session); err != nil {
		return AuthResult{}, err
	}
	accessToken, expiresIn, err := s.tokens.Issue(ctx, user, session)
	if err != nil {
		return AuthResult{}, err
	}
	return AuthResult{User: user, AccessToken: accessToken, RefreshToken: refreshToken, ExpiresIn: expiresIn}, nil
}

func normalizeIdentifier(identityType domain.IdentityType, value string) string {
	value = strings.TrimSpace(value)
	if identityType == domain.IdentityEmail {
		return strings.ToLower(value)
	}
	return value
}

func normalizeLooseIdentifier(value string) string {
	return strings.ToLower(strings.TrimSpace(value))
}

func randomDigits(length int) string {
	bytes := make([]byte, length)
	if _, err := rand.Read(bytes); err != nil {
		return strings.Repeat("0", length)
	}
	for i := range bytes {
		bytes[i] = '0' + bytes[i]%10
	}
	return string(bytes)
}

func hashToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}
