package app

import (
	"context"

	"github.com/openwhu/luotopia/server/internal/backend/admin/domain"
)

type Service struct {
	version string
}

func NewService(version string) *Service {
	return &Service{version: version}
}

func (s *Service) Dashboard(ctx context.Context) domain.Dashboard {
	return domain.Dashboard{Version: s.version}
}
