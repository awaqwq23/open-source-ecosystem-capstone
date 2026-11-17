package app

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/domain"
)

var (
	ErrNotFound = errors.New("notification: not found")
)

type Repository interface {
	Create(ctx context.Context, notification domain.Notification) error
	GetByID(ctx context.Context, id string) (domain.Notification, error)
	List(ctx context.Context, status domain.Status, offset, limit int) ([]domain.Notification, int64, error)
	Update(ctx context.Context, notification domain.Notification) error
	Delete(ctx context.Context, id string) error
	GetLatestPublished(ctx context.Context) (domain.Notification, error)
	CountPublished(ctx context.Context) (int64, error)
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Create(ctx context.Context, title, content, icon string, displayOrder int) (domain.Notification, error) {
	now := time.Now()
	n := domain.Notification{
		ID:           now.Format("20060102150405") + generateSuffix(),
		Title:        title,
		Content:      content,
		Icon:         normalizeIcon(icon),
		DisplayOrder: displayOrder,
		Status:       domain.StatusDraft,
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	return n, s.repo.Create(ctx, n)
}

func (s *Service) List(ctx context.Context, status domain.Status, offset, limit int) ([]domain.Notification, int64, error) {
	return s.repo.List(ctx, status, offset, limit)
}

func (s *Service) GetByID(ctx context.Context, id string) (domain.Notification, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *Service) Update(ctx context.Context, id, title, content, icon string, displayOrder int) (domain.Notification, error) {
	n, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return domain.Notification{}, err
	}
	n.Title = title
	n.Content = content
	n.Icon = normalizeIcon(icon)
	n.DisplayOrder = displayOrder
	n.UpdatedAt = time.Now()
	return n, s.repo.Update(ctx, n)
}

func (s *Service) Publish(ctx context.Context, id string) (domain.Notification, error) {
	n, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return domain.Notification{}, err
	}
	if n.Status == domain.StatusPublished {
		return n, nil
	}
	now := time.Now()
	n.Status = domain.StatusPublished
	n.PublishedAt = &now
	n.UpdatedAt = now
	return n, s.repo.Update(ctx, n)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}

type LatestInfo struct {
	LatestID    string     `json:"latest_id"`
	HasNew      bool       `json:"has_new"`
	Count       int        `json:"count"`
	Title       string     `json:"title"`
	Icon        string     `json:"icon"`
	PublishedAt *time.Time `json:"published_at,omitempty"`
}

func (s *Service) GetLatestInfo(ctx context.Context, clientLatestID string) LatestInfo {
	latest, err := s.repo.GetLatestPublished(ctx)
	latestID := ""
	hasNew := false
	if err == nil {
		latestID = latest.ID
		hasNew = latest.ID != clientLatestID
	}
	total, _ := s.repo.CountPublished(ctx)
	info := LatestInfo{
		LatestID: latestID,
		HasNew:   hasNew,
		Count:    int(total),
	}
	if err == nil {
		info.Title = latest.Title
		info.Icon = latest.Icon
		info.PublishedAt = latest.PublishedAt
	}
	return info
}

func normalizeIcon(icon string) string {
	icon = strings.TrimSpace(icon)
	if icon == "" {
		return "campaign"
	}
	return icon
}

func generateSuffix() string {
	return time.Now().Format(".000000000")[1:7]
}
