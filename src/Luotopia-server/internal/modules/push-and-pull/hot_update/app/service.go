package app

import (
	"context"
	"errors"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/domain"
)

var (
	ErrNotFound      = errors.New("hot_update: not found")
	ErrDuplicateName = errors.New("hot_update: duplicate script name")
)

type Repository interface {
	CreateScript(ctx context.Context, script domain.Script) error
	GetScriptByID(ctx context.Context, id string) (domain.Script, error)
	ListScripts(ctx context.Context, channel domain.Channel) ([]domain.Script, error)
	UpdateScript(ctx context.Context, script domain.Script) error
	ListEnabledScripts(ctx context.Context) ([]domain.Script, error)

	CreateRelease(ctx context.Context, release domain.ScriptRelease) error
	GetLatestRelease(ctx context.Context, scriptID string) (domain.ScriptRelease, error)
	GetReleaseByVersion(ctx context.Context, scriptID string, version int) (domain.ScriptRelease, error)
	ListReleases(ctx context.Context, scriptID string, offset, limit int) ([]domain.ScriptRelease, int64, error)
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) CreateScript(ctx context.Context, name, description string, channel domain.Channel) (domain.Script, error) {
	now := time.Now()
	script := domain.Script{
		ID:          now.Format("150405") + generateSuffix(),
		Name:        name,
		Description: description,
		Channel:     channel,
		Enabled:     true,
		CreatedAt:   now,
		UpdatedAt:   now,
	}
	return script, s.repo.CreateScript(ctx, script)
}

func (s *Service) ListScripts(ctx context.Context, channel domain.Channel) ([]domain.Script, error) {
	return s.repo.ListScripts(ctx, channel)
}

func (s *Service) ToggleEnabled(ctx context.Context, id string) (domain.Script, error) {
	script, err := s.repo.GetScriptByID(ctx, id)
	if err != nil {
		return domain.Script{}, err
	}
	script.Enabled = !script.Enabled
	script.UpdatedAt = time.Now()
	return script, s.repo.UpdateScript(ctx, script)
}

func (s *Service) PublishRelease(ctx context.Context, scriptID, fileKey, checksum, releaseNotes string) (domain.ScriptRelease, error) {
	script, err := s.repo.GetScriptByID(ctx, scriptID)
	if err != nil {
		return domain.ScriptRelease{}, err
	}
	latest, err := s.repo.GetLatestRelease(ctx, scriptID)
	if err != nil && !errors.Is(err, ErrNotFound) {
		return domain.ScriptRelease{}, err
	}
	nextVersion := 1
	if err == nil {
		nextVersion = latest.Version + 1
	}
	release := domain.ScriptRelease{
		ID:           script.ID + "-v" + itoa(nextVersion),
		ScriptID:     scriptID,
		Version:      nextVersion,
		FileKey:      fileKey,
		Checksum:     checksum,
		ReleaseNotes: releaseNotes,
		CreatedAt:    time.Now(),
	}
	_ = script
	return release, s.repo.CreateRelease(ctx, release)
}

func (s *Service) GetCurrentVersion(ctx context.Context, scriptID string) (domain.ScriptRelease, error) {
	return s.repo.GetLatestRelease(ctx, scriptID)
}

func (s *Service) ListReleases(ctx context.Context, scriptID string, offset, limit int) ([]domain.ScriptRelease, int64, error) {
	return s.repo.ListReleases(ctx, scriptID, offset, limit)
}

type ScriptVersionInfo struct {
	LatestVersion int    `json:"latest_version"`
	Checksum      string `json:"checksum"`
}

func (s *Service) GetScriptVersions(ctx context.Context) map[string]ScriptVersionInfo {
	scripts, err := s.repo.ListEnabledScripts(ctx)
	if err != nil {
		return nil
	}
	result := make(map[string]ScriptVersionInfo, len(scripts))
	for _, sc := range scripts {
		release, err := s.repo.GetLatestRelease(ctx, sc.ID)
		if err != nil {
			continue
		}
		result[sc.Name] = ScriptVersionInfo{
			LatestVersion: release.Version,
			Checksum:      release.Checksum,
		}
	}
	return result
}

func generateSuffix() string {
	return time.Now().Format(".000000000")[1:7]
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	var buf [12]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	return string(buf[i:])
}
