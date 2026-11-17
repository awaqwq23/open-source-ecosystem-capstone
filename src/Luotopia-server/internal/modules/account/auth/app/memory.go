package app

import (
	"context"
	"fmt"
	"strings"
	"sync"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	profiledomain "github.com/openwhu/luotopia/server/internal/modules/account/profile/domain"
	"github.com/openwhu/luotopia/server/internal/platform/id"
)

type MemoryUserRepository struct {
	mu         sync.Mutex
	users      map[string]domain.User
	profiles   map[string]domain.AccountSummary
	identities map[string]domain.Identity
	passwords  map[string]string
	sessions   map[string]domain.Session
}

func NewMemoryUserRepository() *MemoryUserRepository {
	return &MemoryUserRepository{
		users:      map[string]domain.User{},
		profiles:   map[string]domain.AccountSummary{},
		identities: map[string]domain.Identity{},
		passwords:  map[string]string{},
		sessions:   map[string]domain.Session{},
	}
}

func (r *MemoryUserRepository) FindUserByIdentity(_ context.Context, identityType domain.IdentityType, identifier string) (*domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	identity, ok := r.identities[identityKey(identityType, identifier)]
	if !ok {
		return nil, domain.ErrIdentityNotFound
	}
	user := r.users[identity.UserID]
	return &user, nil
}

func (r *MemoryUserRepository) CreateUserWithIdentity(_ context.Context, identityType domain.IdentityType, identifier string) (*domain.User, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	key := identityKey(identityType, identifier)
	if _, exists := r.identities[key]; exists {
		return nil, domain.ErrIdentityAlreadyBound
	}
	now := time.Now()
	user := domain.User{ID: id.New(id.TypeUser), Status: domain.UserStatusActive, CreatedAt: now}
	externalID, err := profiledomain.NewExternalID()
	if err != nil {
		return nil, err
	}
	r.users[user.ID] = user
	r.profiles[user.ID] = domain.AccountSummary{
		UserID:     user.ID,
		ExternalID: externalID,
		CreatedAt:  now,
		UpdatedAt:  now,
	}
	r.identities[key] = domain.Identity{
		ID:         id.New(id.TypeIdentity),
		UserID:     user.ID,
		Type:       identityType,
		Identifier: identifier,
		VerifiedAt: now,
		CreatedAt:  now,
	}
	return &user, nil
}

func (r *MemoryUserRepository) FindAccountByUserID(_ context.Context, userID string) (domain.AccountSummary, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	user, ok := r.users[userID]
	if !ok {
		return domain.AccountSummary{}, domain.ErrInvalidArgument
	}
	account := r.profiles[userID]
	if account.ExternalID == "" {
		externalID, err := profiledomain.NewExternalID()
		if err != nil {
			return domain.AccountSummary{}, err
		}
		account = domain.AccountSummary{UserID: user.ID, ExternalID: externalID, CreatedAt: user.CreatedAt, UpdatedAt: time.Now()}
		r.profiles[userID] = account
	}
	account.HasPassword = r.passwords[userID] != ""
	account.Identities = r.identitySummaryLocked(userID)
	return account, nil
}

func (r *MemoryUserRepository) UpdateUsername(_ context.Context, userID string, username string) (domain.AccountSummary, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	account, ok := r.profiles[userID]
	if !ok {
		return domain.AccountSummary{}, domain.ErrInvalidArgument
	}
	normalized, err := profiledomain.NormalizeUsername(username)
	if err != nil {
		return domain.AccountSummary{}, domain.ErrInvalidArgument
	}
	account.Username = normalized
	account.UpdatedAt = time.Now()
	account.HasPassword = r.passwords[userID] != ""
	account.Identities = r.identitySummaryLocked(userID)
	r.profiles[userID] = account
	return account, nil
}

func (r *MemoryUserRepository) FindUserByLoginIdentifier(ctx context.Context, identifier string) (*domain.User, error) {
	if user, err := r.FindUserByIdentity(ctx, domain.IdentityPhone, identifier); err == nil {
		return user, nil
	}
	return r.FindUserByIdentity(ctx, domain.IdentityEmail, strings.ToLower(identifier))
}

func (r *MemoryUserRepository) BindIdentity(_ context.Context, userID string, identityType domain.IdentityType, identifier string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	if _, ok := r.users[userID]; !ok {
		return domain.ErrInvalidArgument
	}
	key := identityKey(identityType, identifier)
	if existing, exists := r.identities[key]; exists && existing.UserID != userID {
		return domain.ErrIdentityAlreadyBound
	}
	now := time.Now()
	for id, existing := range r.identities {
		if existing.UserID == userID && existing.Type == identityType {
			existing.Identifier = identifier
			existing.VerifiedAt = now
			r.identities[id] = existing
			if id != key {
				delete(r.identities, id)
				r.identities[key] = existing
			}
			return nil
		}
	}
	if existing, exists := r.identities[key]; exists && existing.UserID == userID {
		r.identities[key] = domain.Identity{ID: existing.ID, UserID: userID, Type: identityType, Identifier: identifier, VerifiedAt: now, CreatedAt: existing.CreatedAt}
		return nil
	}
	r.identities[key] = domain.Identity{ID: id.New(id.TypeIdentity), UserID: userID, Type: identityType, Identifier: identifier, VerifiedAt: now, CreatedAt: now}
	return nil
}

func (r *MemoryUserRepository) SetPassword(_ context.Context, userID string, passwordHash string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.passwords[userID] = passwordHash
	return nil
}

func (r *MemoryUserRepository) PasswordHash(_ context.Context, userID string) (string, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	hash, ok := r.passwords[userID]
	if !ok {
		return "", domain.ErrPasswordNotSet
	}
	return hash, nil
}

func (r *MemoryUserRepository) CreateSession(_ context.Context, session domain.Session) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.sessions[session.ID] = session
	return nil
}

func (r *MemoryUserRepository) FindSessionsByUserID(_ context.Context, userID string) ([]domain.Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var result []domain.Session
	for _, session := range r.sessions {
		if session.UserID == userID && session.RevokedAt == nil {
			result = append(result, session)
		}
	}
	return result, nil
}

func (r *MemoryUserRepository) FindSessionByRefreshHash(_ context.Context, refreshHash string) (*domain.Session, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for _, session := range r.sessions {
		if session.RefreshTokenHash == refreshHash {
			copy := session
			return &copy, nil
		}
	}
	return nil, domain.ErrSessionNotFound
}

func (r *MemoryUserRepository) RevokeSession(_ context.Context, sessionID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	session, ok := r.sessions[sessionID]
	if !ok {
		return domain.ErrSessionNotFound
	}
	now := time.Now()
	session.RevokedAt = &now
	r.sessions[sessionID] = session
	return nil
}

func (r *MemoryUserRepository) RevokeSessionByPublicID(_ context.Context, userID string, publicID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for id, session := range r.sessions {
		if session.UserID == userID && session.PublicID == publicID {
			now := time.Now()
			session.RevokedAt = &now
			r.sessions[id] = session
			return nil
		}
	}
	return domain.ErrSessionNotFound
}

func (r *MemoryUserRepository) FindIdentitiesByUserID(_ context.Context, userID string) ([]domain.Identity, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	var result []domain.Identity
	for _, ident := range r.identities {
		if ident.UserID == userID {
			result = append(result, ident)
		}
	}
	return result, nil
}

func (r *MemoryUserRepository) RevokeUserSessions(_ context.Context, userID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	now := time.Now()
	for id, session := range r.sessions {
		if session.UserID == userID {
			session.RevokedAt = &now
			r.sessions[id] = session
		}
	}
	return nil
}

func (r *MemoryUserRepository) identitySummaryLocked(userID string) domain.AccountIdentitySummary {
	var summary domain.AccountIdentitySummary
	for _, identity := range r.identities {
		if identity.UserID != userID {
			continue
		}
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
	return summary
}

type MemoryVerificationCodeStore struct {
	mu    sync.Mutex
	codes map[string]verificationCode
}

type verificationCode struct {
	code      string
	expiresAt time.Time
}

func NewMemoryVerificationCodeStore() *MemoryVerificationCodeStore {
	return &MemoryVerificationCodeStore{codes: map[string]verificationCode{}}
}

func (s *MemoryVerificationCodeStore) Save(_ context.Context, target string, purpose domain.VerificationPurpose, code string, expiresAt time.Time) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.codes[codeKey(target, purpose)] = verificationCode{code: code, expiresAt: expiresAt}
	return nil
}

func (s *MemoryVerificationCodeStore) Verify(_ context.Context, target string, purpose domain.VerificationPurpose, code string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	item, ok := s.codes[codeKey(target, purpose)]
	if !ok || item.code != code || item.expiresAt.Before(time.Now()) {
		return domain.ErrVerificationFailed
	}
	delete(s.codes, codeKey(target, purpose))
	return nil
}

func (s *MemoryVerificationCodeStore) LastCode(target string, purpose domain.VerificationPurpose) string {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.codes[codeKey(target, purpose)].code
}

type StaticTokenIssuer struct{}

func NewStaticTokenIssuer() StaticTokenIssuer {
	return StaticTokenIssuer{}
}

func (StaticTokenIssuer) Issue(_ context.Context, user domain.User, session domain.Session) (string, int64, error) {
	return "access-" + user.ID + "-" + session.ID, 600, nil
}

func identityKey(identityType domain.IdentityType, identifier string) string {
	return fmt.Sprintf("%s:%s", identityType, identifier)
}

func codeKey(target string, purpose domain.VerificationPurpose) string {
	return fmt.Sprintf("%s:%s", purpose, target)
}
