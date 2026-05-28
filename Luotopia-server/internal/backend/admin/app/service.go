package app

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/backend/admin/domain"
	authdomain "github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	hotapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/app"
	hotdomain "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/domain"
	notiapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	notidomain "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/domain"
	weatherapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/app"
	"gorm.io/gorm"
)

type IdentityRepository interface {
	FindIdentitiesByUserID(ctx context.Context, userID string) ([]authdomain.Identity, error)
}

type Repository interface {
	ListUsers(ctx context.Context, offset, limit int) ([]domain.UserInfo, int64, error)
	GetUser(ctx context.Context, id string) (domain.UserInfo, error)
	ListAllowlist(ctx context.Context) ([]domain.SyncAllowlistEntry, error)
	AddAllowlist(ctx context.Context, userID string) error
	RemoveAllowlist(ctx context.Context, userID string) error
}

type Service struct {
	version      string
	startedAt    time.Time
	db           *gorm.DB
	repo         Repository
	identityRepo IdentityRepository
	adminPhone   string
	adminEmail   string
	notifcSvc    *notiapp.Service
	hotUpdateSvc *hotapp.Service
	weatherSvc   *weatherapp.Service
	scriptDir    string
}

func NewService(version string, db *gorm.DB, repo Repository, identityRepo IdentityRepository, adminPhone, adminEmail string, notifcSvc *notiapp.Service, hotUpdateSvc *hotapp.Service, weatherSvc *weatherapp.Service, scriptDir string) *Service {
	return &Service{
		version:      version,
		startedAt:    time.Now(),
		db:           db,
		repo:         repo,
		identityRepo: identityRepo,
		adminPhone:   normalizeAdminIdentifier(authdomain.IdentityPhone, adminPhone),
		adminEmail:   normalizeAdminIdentifier(authdomain.IdentityEmail, adminEmail),
		notifcSvc:    notifcSvc,
		hotUpdateSvc: hotUpdateSvc,
		weatherSvc:   weatherSvc,
		scriptDir:    scriptDir,
	}
}

func (s *Service) IsAdmin(c *gin.Context) bool {
	userID, ok := c.Get("user_id")
	if !ok {
		return false
	}
	uid, ok := userID.(string)
	if !ok || uid == "" {
		return false
	}
	if s.adminPhone == "" && s.adminEmail == "" {
		return false
	}
	identities, err := s.identityRepo.FindIdentitiesByUserID(c.Request.Context(), uid)
	if err != nil {
		return false
	}
	for _, ident := range identities {
		if s.adminPhone != "" && ident.Type == authdomain.IdentityPhone && ident.Identifier == s.adminPhone {
			return true
		}
		if s.adminEmail != "" && ident.Type == authdomain.IdentityEmail && ident.Identifier == s.adminEmail {
			return true
		}
	}
	return false
}

func normalizeAdminIdentifier(identityType authdomain.IdentityType, value string) string {
	value = strings.TrimSpace(value)
	if identityType == authdomain.IdentityEmail {
		return strings.ToLower(value)
	}
	return value
}

func (s *Service) Dashboard(ctx context.Context) domain.Dashboard {
	var healthy bool
	if s.db != nil {
		sqlDB, err := s.db.DB()
		if err == nil {
			healthy = sqlDB.PingContext(ctx) == nil
		}
	}
	uptime := int64(0)
	if !s.startedAt.IsZero() {
		uptime = int64(time.Since(s.startedAt).Seconds())
	}
	_ = healthy
	return domain.Dashboard{Version: s.version, Uptime: uptime}
}

// Notification management

func (s *Service) CreateNotification(ctx context.Context, req domain.CreateNotificationRequest) (domain.Notification, error) {
	n, err := s.notifcSvc.Create(ctx, req.Title, req.Content, req.Icon, req.DisplayOrder)
	if err != nil {
		return domain.Notification{}, err
	}
	return domain.NewNotification(n), nil
}

func (s *Service) UpdateNotification(ctx context.Context, id string, req domain.UpdateNotificationRequest) (domain.Notification, error) {
	n, err := s.notifcSvc.Update(ctx, id, req.Title, req.Content, req.Icon, req.DisplayOrder)
	if err != nil {
		if errors.Is(err, notiapp.ErrNotFound) {
			return domain.Notification{}, ErrNotFound
		}
		return domain.Notification{}, err
	}
	return domain.NewNotification(n), nil
}

func (s *Service) ListNotifications(ctx context.Context, status string, offset, limit int) (domain.NotificationList, error) {
	items, total, err := s.notifcSvc.List(ctx, notidomain.Status(status), offset, limit)
	if err != nil {
		return domain.NotificationList{}, err
	}
	result := make([]domain.Notification, len(items))
	for i, n := range items {
		result[i] = domain.NewNotification(n)
	}
	return domain.NotificationList{Total: total, Items: result}, nil
}

func (s *Service) PublishNotification(ctx context.Context, id string) (domain.Notification, error) {
	n, err := s.notifcSvc.Publish(ctx, id)
	if err != nil {
		if errors.Is(err, notiapp.ErrNotFound) {
			return domain.Notification{}, ErrNotFound
		}
		return domain.Notification{}, err
	}
	return domain.NewNotification(n), nil
}

func (s *Service) DeleteNotification(ctx context.Context, id string) error {
	return s.notifcSvc.Delete(ctx, id)
}

// Hot update management

func (s *Service) CreateScript(ctx context.Context, req domain.CreateScriptRequest) (domain.HotUpdateScript, error) {
	script, err := s.hotUpdateSvc.CreateScript(ctx, req.Name, req.Description, hotdomain.Channel(req.Channel))
	if err != nil {
		return domain.HotUpdateScript{}, err
	}
	return domain.HotUpdateScript{
		ID:          script.ID,
		Name:        script.Name,
		Description: script.Description,
		Channel:     string(script.Channel),
		Enabled:     script.Enabled,
		CreatedAt:   script.CreatedAt,
		UpdatedAt:   script.UpdatedAt,
	}, nil
}

func (s *Service) ListScripts(ctx context.Context, channel string) (domain.HotUpdateScriptList, error) {
	scripts, err := s.hotUpdateSvc.ListScripts(ctx, hotdomain.Channel(channel))
	if err != nil {
		return domain.HotUpdateScriptList{}, err
	}
	items := make([]domain.HotUpdateScript, len(scripts))
	for i, sc := range scripts {
		items[i] = domain.HotUpdateScript{
			ID:          sc.ID,
			Name:        sc.Name,
			Description: sc.Description,
			Channel:     string(sc.Channel),
			Enabled:     sc.Enabled,
			CreatedAt:   sc.CreatedAt,
			UpdatedAt:   sc.UpdatedAt,
		}
		// Attempt to get latest version
		if release, err := s.hotUpdateSvc.GetCurrentVersion(ctx, sc.ID); err == nil {
			items[i].LatestVersion = release.Version
		}
	}
	return domain.HotUpdateScriptList{Items: items}, nil
}

func (s *Service) ToggleScript(ctx context.Context, id string) (domain.HotUpdateScript, error) {
	sc, err := s.hotUpdateSvc.ToggleEnabled(ctx, id)
	if err != nil {
		return domain.HotUpdateScript{}, err
	}
	item := domain.HotUpdateScript{
		ID:          sc.ID,
		Name:        sc.Name,
		Description: sc.Description,
		Channel:     string(sc.Channel),
		Enabled:     sc.Enabled,
		CreatedAt:   sc.CreatedAt,
		UpdatedAt:   sc.UpdatedAt,
	}
	if release, err := s.hotUpdateSvc.GetCurrentVersion(ctx, sc.ID); err == nil {
		item.LatestVersion = release.Version
	}
	return item, nil
}

func (s *Service) PublishRelease(ctx context.Context, scriptID string, req domain.PublishReleaseRequest) error {
	fileKey, checksum, err := s.resolveReleaseFile(scriptID, req)
	if err != nil {
		return err
	}
	_, err = s.hotUpdateSvc.PublishRelease(ctx, scriptID, fileKey, checksum, req.ReleaseNotes)
	return err
}

func (s *Service) resolveReleaseFile(scriptID string, req domain.PublishReleaseRequest) (string, string, error) {
	if strings.TrimSpace(req.Content) == "" {
		fileKey := strings.TrimSpace(req.FileKey)
		if fileKey == "" {
			return "", "", ErrInvalidArg
		}
		return fileKey, strings.TrimSpace(req.Checksum), nil
	}
	sum := sha256.Sum256([]byte(req.Content))
	checksum := hex.EncodeToString(sum[:])
	dir := s.scriptDir
	if strings.TrimSpace(dir) == "" {
		dir = "scripts"
	}
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", "", err
	}
	fileKey := fmt.Sprintf("%s-%d.js", scriptID, time.Now().UnixNano())
	path := filepath.Join(dir, fileKey)
	if err := os.WriteFile(path, []byte(req.Content), 0644); err != nil {
		return "", "", err
	}
	return fileKey, checksum, nil
}

// User management

func (s *Service) ListUsers(ctx context.Context, offset, limit int) (domain.UserList, error) {
	users, total, err := s.repo.ListUsers(ctx, offset, limit)
	if err != nil {
		return domain.UserList{}, err
	}
	return domain.UserList{Total: total, Items: users}, nil
}

// Sync allowlist management

func (s *Service) ListAllowlist(ctx context.Context) (domain.SyncAllowlist, error) {
	entries, err := s.repo.ListAllowlist(ctx)
	if err != nil {
		return domain.SyncAllowlist{}, err
	}
	if entries == nil {
		entries = []domain.SyncAllowlistEntry{}
	}
	return domain.SyncAllowlist{Items: entries}, nil
}

func (s *Service) AddAllowlist(ctx context.Context, userID string) error {
	return s.repo.AddAllowlist(ctx, userID)
}

func (s *Service) RemoveAllowlist(ctx context.Context, userID string) error {
	return s.repo.RemoveAllowlist(ctx, userID)
}

// Weather management

func (s *Service) WeatherStatus(ctx context.Context) domain.WeatherStatus {
	if s.weatherSvc == nil {
		return domain.WeatherStatus{Enabled: false}
	}
	return s.weatherSvc.Status(ctx)
}

func (s *Service) RefreshWeather(ctx context.Context) (domain.WeatherStatus, error) {
	if s.weatherSvc == nil {
		return domain.WeatherStatus{Enabled: false}, ErrInvalidArg
	}
	if err := s.weatherSvc.FetchAndCache(ctx); err != nil {
		return s.weatherSvc.Status(ctx), err
	}
	return s.weatherSvc.Status(ctx), nil
}

// error helpers used by transport
var (
	ErrNotFound   = errors.New("admin: not found")
	ErrInvalidArg = errors.New("admin: invalid argument")
)
