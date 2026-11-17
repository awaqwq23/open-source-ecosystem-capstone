package app

import (
	"context"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/user-stats/domain"
)

type Repository interface {
	CountUsers(ctx context.Context) (int, error)
	CountActiveSessions(ctx context.Context) (int, error)
}

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) GetStats(ctx context.Context) domain.Stats {
	users, _ := s.repo.CountUsers(ctx)
	sessions, _ := s.repo.CountActiveSessions(ctx)
	return domain.Stats{
		TotalUsers:     users,
		ActiveSessions: sessions,
	}
}
