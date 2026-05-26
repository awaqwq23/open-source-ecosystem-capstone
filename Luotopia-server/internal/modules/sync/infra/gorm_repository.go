package infra

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sync/app"
	"github.com/openwhu/luotopia/server/internal/modules/sync/domain"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

func (r *GormRepository) IsSyncAllowed(ctx context.Context, userID string) (bool, error) {
	var model syncUserAllowlistModel
	err := r.db.WithContext(ctx).First(&model, "user_id = ?", userID).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return model.Enabled, nil
}

func (r *GormRepository) ListChanges(ctx context.Context, userID string, afterChangeID int64, limit int) ([]domain.SyncChange, error) {
	var rows []syncChangeModel
	err := r.db.WithContext(ctx).
		Where("user_id = ? AND id > ?", userID, afterChangeID).
		Order("id ASC").
		Limit(limit).
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	changes := make([]domain.SyncChange, 0, len(rows))
	for _, row := range rows {
		changes = append(changes, row.toDomain())
	}
	return changes, nil
}

func (r *GormRepository) ApplyChanges(ctx context.Context, userID string, deviceID string, changes []domain.SyncChangeInput) ([]domain.SyncAppliedChange, []domain.SyncRejectedChange, error) {
	accepted := make([]domain.SyncAppliedChange, 0, len(changes))
	rejected := make([]domain.SyncRejectedChange, 0)
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		for _, change := range changes {
			applied, reject, err := r.applyChange(ctx, tx, userID, deviceID, change)
			if err != nil {
				return err
			}
			if reject != nil {
				rejected = append(rejected, *reject)
				continue
			}
			accepted = append(accepted, applied)
		}
		return nil
	})
	if err != nil {
		return nil, nil, err
	}
	return accepted, rejected, nil
}

func (r *GormRepository) applyChange(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	if change.EntityID == "" || change.EntityType == "" || change.Operation == "" {
		return domain.SyncAppliedChange{}, reject(change, "invalid_argument"), nil
	}
	switch change.EntityType {
	case domain.EntityTypeAgendaItem:
		return r.applyAgendaItemChange(ctx, tx, userID, deviceID, change)
	case domain.EntityTypeCourseTimetable:
		return r.applyCourseTimetableChange(ctx, tx, userID, deviceID, change)
	case domain.EntityTypeSelectedTimetable:
		return r.applySelectedTimetableChange(ctx, tx, userID, deviceID, change)
	default:
		return domain.SyncAppliedChange{}, reject(change, "unsupported_entity_type"), nil
	}
}

func (r *GormRepository) applyAgendaItemChange(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	if change.Operation == domain.OperationDelete {
		return r.deleteEntity(ctx, tx, userID, deviceID, change, "sync_agenda_items")
	}
	if change.Operation != domain.OperationUpsert {
		return domain.SyncAppliedChange{}, reject(change, "unsupported_operation"), nil
	}
	var payload domain.AgendaItemPayload
	if err := json.Unmarshal(change.Payload, &payload); err != nil {
		return domain.SyncAppliedChange{}, reject(change, "invalid_payload"), nil
	}
	if payload.ID == "" {
		payload.ID = change.EntityID
	}
	if payload.ID != change.EntityID {
		return domain.SyncAppliedChange{}, reject(change, "entity_id_mismatch"), nil
	}
	var current agendaItemModel
	err := tx.WithContext(ctx).First(&current, "user_id = ? AND id = ?", userID, change.EntityID).Error
	if err == nil && current.DeletedAt != nil {
		return domain.SyncAppliedChange{}, reject(change, "deleted_conflict"), nil
	}
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.SyncAppliedChange{}, nil, err
	}
	revision := int64(1)
	if err == nil {
		revision = current.Revision + 1
	}
	model := agendaItemModelFromPayload(userID, payload, revision)
	if err := tx.WithContext(ctx).Save(&model).Error; err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	canonicalPayload, err := json.Marshal(payload)
	if err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	return r.insertChange(ctx, tx, userID, deviceID, change, revision, canonicalPayload)
}

func (r *GormRepository) applyCourseTimetableChange(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	if change.Operation == domain.OperationDelete {
		return r.deleteEntity(ctx, tx, userID, deviceID, change, "sync_course_timetables")
	}
	if change.Operation != domain.OperationUpsert {
		return domain.SyncAppliedChange{}, reject(change, "unsupported_operation"), nil
	}
	var payload domain.CourseTimetablePayload
	if err := json.Unmarshal(change.Payload, &payload); err != nil {
		return domain.SyncAppliedChange{}, reject(change, "invalid_payload"), nil
	}
	if payload.ID == "" {
		payload.ID = change.EntityID
	}
	if payload.ID != change.EntityID {
		return domain.SyncAppliedChange{}, reject(change, "entity_id_mismatch"), nil
	}
	var current courseTimetableModel
	err := tx.WithContext(ctx).First(&current, "user_id = ? AND id = ?", userID, change.EntityID).Error
	if err == nil && current.DeletedAt != nil {
		return domain.SyncAppliedChange{}, reject(change, "deleted_conflict"), nil
	}
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.SyncAppliedChange{}, nil, err
	}
	revision := int64(1)
	if err == nil {
		revision = current.Revision + 1
	}
	model := courseTimetableModelFromPayload(userID, payload, revision)
	if err := tx.WithContext(ctx).Save(&model).Error; err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	canonicalPayload, err := json.Marshal(payload)
	if err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	return r.insertChange(ctx, tx, userID, deviceID, change, revision, canonicalPayload)
}

func (r *GormRepository) applySelectedTimetableChange(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	if change.Operation == domain.OperationDelete {
		return r.deleteSelectedTimetable(ctx, tx, userID, deviceID, change)
	}
	if change.Operation != domain.OperationUpsert {
		return domain.SyncAppliedChange{}, reject(change, "unsupported_operation"), nil
	}
	var payload domain.SelectedTimetablePayload
	if err := json.Unmarshal(change.Payload, &payload); err != nil {
		return domain.SyncAppliedChange{}, reject(change, "invalid_payload"), nil
	}
	if payload.TimetableID == "" {
		payload.TimetableID = change.EntityID
	}
	if payload.TimetableID != change.EntityID {
		return domain.SyncAppliedChange{}, reject(change, "entity_id_mismatch"), nil
	}
	var current selectedTimetableModel
	err := tx.WithContext(ctx).First(&current, "user_id = ? AND timetable_id = ?", userID, change.EntityID).Error
	if err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.SyncAppliedChange{}, nil, err
	}
	revision := int64(1)
	if err == nil {
		revision = current.Revision + 1
	}
	model := selectedTimetableModel{
		UserID:      userID,
		TimetableID: payload.TimetableID,
		SortOrder:   payload.SortOrder,
		Revision:    revision,
		UpdatedAt:   payload.UpdatedAt,
	}
	if model.UpdatedAt.IsZero() {
		model.UpdatedAt = time.Now()
	}
	if err := tx.WithContext(ctx).Save(&model).Error; err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	canonicalPayload, err := json.Marshal(payload)
	if err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	return r.insertChange(ctx, tx, userID, deviceID, change, revision, canonicalPayload)
}

func (r *GormRepository) deleteEntity(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput, table string) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	now := time.Now()
	revision, alreadyDeleted, err := r.markDeleted(ctx, tx, userID, change.EntityID, change.EntityType, table, now)
	if err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	if alreadyDeleted {
		return domain.SyncAppliedChange{
			EntityType: change.EntityType,
			EntityID:   change.EntityID,
			Operation:  domain.OperationDelete,
			Revision:   revision,
		}, nil, nil
	}
	return r.insertChange(ctx, tx, userID, deviceID, change, revision, []byte("null"))
}

func (r *GormRepository) deleteSelectedTimetable(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	var current selectedTimetableModel
	err := tx.WithContext(ctx).First(&current, "user_id = ? AND timetable_id = ?", userID, change.EntityID).Error
	revision := int64(1)
	if err == nil {
		revision = current.Revision + 1
		if err := tx.WithContext(ctx).Delete(&current).Error; err != nil {
			return domain.SyncAppliedChange{}, nil, err
		}
	} else if !errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.SyncAppliedChange{}, nil, err
	}
	if err := r.upsertTombstone(ctx, tx, userID, change.EntityType, change.EntityID, revision, time.Now()); err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	return r.insertChange(ctx, tx, userID, deviceID, change, revision, []byte("null"))
}

func (r *GormRepository) markDeleted(ctx context.Context, tx *gorm.DB, userID string, entityID string, entityType domain.EntityType, table string, deletedAt time.Time) (int64, bool, error) {
	var revision int64 = 1
	var deletedAtPtr *time.Time
	row := tx.WithContext(ctx).Table(table).
		Select("revision", "deleted_at").
		Where("user_id = ? AND id = ?", userID, entityID).
		Row()
	if err := row.Scan(&revision, &deletedAtPtr); err != nil {
		if !errors.Is(err, sql.ErrNoRows) {
			return 0, false, err
		}
	} else {
		if deletedAtPtr != nil {
			return revision, true, nil
		}
		revision++
		if err := tx.WithContext(ctx).Table(table).
			Where("user_id = ? AND id = ?", userID, entityID).
			Updates(map[string]any{
				"revision":   revision,
				"deleted_at": deletedAt,
				"updated_at": deletedAt,
			}).Error; err != nil {
			return 0, false, err
		}
	}
	if err := r.upsertTombstone(ctx, tx, userID, entityType, entityID, revision, deletedAt); err != nil {
		return 0, false, err
	}
	return revision, false, nil
}

func (r *GormRepository) upsertTombstone(ctx context.Context, tx *gorm.DB, userID string, entityType domain.EntityType, entityID string, revision int64, deletedAt time.Time) error {
	return tx.WithContext(ctx).Save(&syncTombstoneModel{
		UserID:     userID,
		EntityType: string(entityType),
		EntityID:   entityID,
		Revision:   revision,
		DeletedAt:  deletedAt,
	}).Error
}

func (r *GormRepository) insertChange(ctx context.Context, tx *gorm.DB, userID string, deviceID string, change domain.SyncChangeInput, revision int64, payload []byte) (domain.SyncAppliedChange, *domain.SyncRejectedChange, error) {
	model := syncChangeModel{
		UserID:     userID,
		DeviceID:   deviceID,
		EntityType: string(change.EntityType),
		EntityID:   change.EntityID,
		Operation:  string(change.Operation),
		Revision:   revision,
		Payload:    payload,
		CreatedAt:  time.Now(),
	}
	if len(model.Payload) == 0 {
		model.Payload = []byte("null")
	}
	if err := tx.WithContext(ctx).Create(&model).Error; err != nil {
		return domain.SyncAppliedChange{}, nil, err
	}
	return domain.SyncAppliedChange{
		ChangeID:   model.ID,
		EntityType: change.EntityType,
		EntityID:   change.EntityID,
		Operation:  change.Operation,
		Revision:   revision,
	}, nil, nil
}

func reject(change domain.SyncChangeInput, reason string) *domain.SyncRejectedChange {
	return &domain.SyncRejectedChange{
		EntityType: change.EntityType,
		EntityID:   change.EntityID,
		Operation:  change.Operation,
		Reason:     reason,
	}
}

func agendaItemModelFromPayload(userID string, payload domain.AgendaItemPayload, revision int64) agendaItemModel {
	return agendaItemModel{
		UserID:                   userID,
		ID:                       payload.ID,
		Type:                     payload.Type,
		Title:                    payload.Title,
		Notes:                    payload.Notes,
		Location:                 payload.Location,
		Color:                    payload.Color,
		Reminder:                 payload.Reminder,
		RepeatRule:               payload.RepeatRule,
		StartAt:                  payload.StartAt,
		EndAt:                    payload.EndAt,
		IsAllDay:                 payload.IsAllDay,
		Deadline:                 payload.Deadline,
		EstimatedDurationMinutes: payload.EstimatedDurationMinutes,
		IsCompleted:              payload.IsCompleted,
		CompletedAt:              payload.CompletedAt,
		SortOrder:                payload.SortOrder,
		SourceKind:               payload.SourceKind,
		SourceRef:                payload.SourceRef,
		CourseTimetableID:        payload.CourseTimetableID,
		CourseSourceKind:         payload.CourseSourceKind,
		CourseSourceCourseID:     payload.CourseSourceCourseID,
		CourseNature:             payload.CourseNature,
		Instructor:               payload.Instructor,
		WeekMeta:                 payload.WeekMeta,
		Revision:                 revision,
		CreatedAt:                payload.CreatedAt,
		UpdatedAt:                payload.UpdatedAt,
	}
}

func courseTimetableModelFromPayload(userID string, payload domain.CourseTimetablePayload, revision int64) courseTimetableModel {
	return courseTimetableModel{
		UserID:    userID,
		ID:        payload.ID,
		Name:      payload.Name,
		Source:    payload.Source,
		TermLabel: payload.TermLabel,
		Revision:  revision,
		CreatedAt: payload.CreatedAt,
		UpdatedAt: payload.UpdatedAt,
	}
}

type agendaItemModel struct {
	UserID                   string `gorm:"primaryKey;column:user_id"`
	ID                       string `gorm:"primaryKey;column:id"`
	Type                     string
	Title                    string
	Notes                    string
	Location                 string
	Color                    string
	Reminder                 string
	RepeatRule               string
	StartAt                  time.Time
	EndAt                    time.Time
	IsAllDay                 bool
	Deadline                 *time.Time
	EstimatedDurationMinutes int
	IsCompleted              bool
	CompletedAt              *time.Time
	SortOrder                float64
	SourceKind               string
	SourceRef                string
	CourseTimetableID        string
	CourseSourceKind         string
	CourseSourceCourseID     string
	CourseNature             string
	Instructor               string
	WeekMeta                 string
	Revision                 int64
	DeletedAt                *time.Time
	CreatedAt                time.Time
	UpdatedAt                time.Time
}

func (agendaItemModel) TableName() string { return "sync_agenda_items" }

type courseTimetableModel struct {
	UserID    string `gorm:"primaryKey;column:user_id"`
	ID        string `gorm:"primaryKey;column:id"`
	Name      string
	Source    string
	TermLabel string
	Revision  int64
	DeletedAt *time.Time
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (courseTimetableModel) TableName() string { return "sync_course_timetables" }

type selectedTimetableModel struct {
	UserID      string `gorm:"primaryKey;column:user_id"`
	TimetableID string `gorm:"primaryKey;column:timetable_id"`
	SortOrder   float64
	Revision    int64
	UpdatedAt   time.Time
}

func (selectedTimetableModel) TableName() string { return "sync_selected_course_timetables" }

type syncTombstoneModel struct {
	UserID     string `gorm:"primaryKey;column:user_id"`
	EntityType string `gorm:"primaryKey;column:entity_type"`
	EntityID   string `gorm:"primaryKey;column:entity_id"`
	Revision   int64
	DeletedAt  time.Time
}

func (syncTombstoneModel) TableName() string { return "sync_tombstones" }

type syncChangeModel struct {
	ID         int64 `gorm:"primaryKey;column:id"`
	UserID     string
	DeviceID   string
	EntityType string
	EntityID   string
	Operation  string
	Revision   int64
	Payload    []byte `gorm:"type:jsonb"`
	CreatedAt  time.Time
}

func (syncChangeModel) TableName() string { return "sync_changes" }

type syncUserAllowlistModel struct {
	UserID    string `gorm:"primaryKey;column:user_id"`
	Enabled   bool
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (syncUserAllowlistModel) TableName() string { return "sync_user_allowlist" }

func (m syncChangeModel) toDomain() domain.SyncChange {
	return domain.SyncChange{
		ChangeID:   m.ID,
		UserID:     m.UserID,
		DeviceID:   m.DeviceID,
		EntityType: domain.EntityType(m.EntityType),
		EntityID:   m.EntityID,
		Operation:  domain.Operation(m.Operation),
		Revision:   m.Revision,
		Payload:    append([]byte(nil), m.Payload...),
		CreatedAt:  m.CreatedAt,
	}
}
