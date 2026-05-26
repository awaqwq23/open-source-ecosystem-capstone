package app

import (
	"context"
	"errors"
	"strings"

	"github.com/openwhu/luotopia/server/internal/modules/sync/domain"
)

var (
	ErrInvalidArgument = errors.New("sync: invalid argument")
	ErrSyncDisabled    = errors.New("sync: disabled")
)

type Repository interface {
	IsSyncAllowed(ctx context.Context, userID string) (bool, error)
	ListChanges(ctx context.Context, userID string, afterChangeID int64, limit int) ([]domain.SyncChange, error)
	ApplyChanges(ctx context.Context, userID string, deviceID string, changes []domain.SyncChangeInput) ([]domain.SyncAppliedChange, []domain.SyncRejectedChange, error)
}

type Service struct {
	repository Repository
}

func NewService(repository Repository) *Service {
	return &Service{repository: repository}
}

func (s *Service) Capability(ctx context.Context, userID string) (domain.SyncCapability, error) {
	if userID == "" {
		return domain.SyncCapability{}, ErrInvalidArgument
	}
	enabled, err := s.repository.IsSyncAllowed(ctx, userID)
	if err != nil {
		return domain.SyncCapability{}, err
	}
	return domain.SyncCapability{Enabled: enabled}, nil
}

func (s *Service) PullChanges(ctx context.Context, userID string, cursor int64, limit int) (domain.SyncPullResult, error) {
	if userID == "" || cursor < 0 {
		return domain.SyncPullResult{}, ErrInvalidArgument
	}
	if err := s.requireAllowed(ctx, userID); err != nil {
		return domain.SyncPullResult{}, err
	}
	limit = normalizeLimit(limit)
	changes, err := s.repository.ListChanges(ctx, userID, cursor, limit+1)
	if err != nil {
		return domain.SyncPullResult{}, err
	}
	hasMore := len(changes) > limit
	if hasMore {
		changes = changes[:limit]
	}
	nextCursor := cursor
	if len(changes) > 0 {
		nextCursor = changes[len(changes)-1].ChangeID
	}
	return domain.SyncPullResult{
		Cursor:     cursor,
		NextCursor: nextCursor,
		HasMore:    hasMore,
		Changes:    changes,
	}, nil
}

func (s *Service) PushChanges(ctx context.Context, userID string, request domain.SyncPushRequest) (domain.SyncPushResponse, error) {
	if userID == "" || request.BaseCursor < 0 || strings.TrimSpace(request.DeviceID) == "" {
		return domain.SyncPushResponse{}, ErrInvalidArgument
	}
	if err := s.requireAllowed(ctx, userID); err != nil {
		return domain.SyncPushResponse{}, err
	}
	if len(request.Changes) == 0 {
		return s.emptyPushResponse(ctx, userID, request.BaseCursor)
	}
	accepted, rejected, err := s.repository.ApplyChanges(
		ctx,
		userID,
		strings.TrimSpace(request.DeviceID),
		request.Changes,
	)
	if err != nil {
		return domain.SyncPushResponse{}, err
	}
	changes, err := s.repository.ListChanges(ctx, userID, request.BaseCursor, 1000)
	if err != nil {
		return domain.SyncPushResponse{}, err
	}
	acceptedIDs := make(map[int64]struct{}, len(accepted))
	for _, change := range accepted {
		if change.ChangeID > 0 {
			acceptedIDs[change.ChangeID] = struct{}{}
		}
	}
	serverChanges := make([]domain.SyncChange, 0, len(changes))
	nextCursor := request.BaseCursor
	for _, change := range changes {
		if change.ChangeID > nextCursor {
			nextCursor = change.ChangeID
		}
		if _, ok := acceptedIDs[change.ChangeID]; ok {
			continue
		}
		serverChanges = append(serverChanges, change)
	}
	return domain.SyncPushResponse{
		Accepted:      accepted,
		Rejected:      rejected,
		NextCursor:    nextCursor,
		ServerChanges: serverChanges,
	}, nil
}

func (s *Service) emptyPushResponse(ctx context.Context, userID string, cursor int64) (domain.SyncPushResponse, error) {
	result, err := s.PullChanges(ctx, userID, cursor, 500)
	if err != nil {
		return domain.SyncPushResponse{}, err
	}
	return domain.SyncPushResponse{
		Accepted:      []domain.SyncAppliedChange{},
		Rejected:      []domain.SyncRejectedChange{},
		NextCursor:    result.NextCursor,
		ServerChanges: result.Changes,
	}, nil
}

func (s *Service) requireAllowed(ctx context.Context, userID string) error {
	allowed, err := s.repository.IsSyncAllowed(ctx, userID)
	if err != nil {
		return err
	}
	if !allowed {
		return ErrSyncDisabled
	}
	return nil
}

func normalizeLimit(limit int) int {
	if limit <= 0 {
		return 500
	}
	if limit > 1000 {
		return 1000
	}
	return limit
}
