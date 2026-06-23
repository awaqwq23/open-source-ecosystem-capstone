package infra

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"sort"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/app"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

func (r *GormRepository) CurrentDataset(ctx context.Context) (domain.DatasetState, error) {
	var row datasetStateModel
	err := r.db.WithContext(ctx).First(&row, "id = ?", 1).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.DatasetState{SchemaVersion: 1, TermKeys: []string{}}, nil
	}
	if err != nil {
		return domain.DatasetState{}, err
	}
	return row.toDomain(), nil
}

func (r *GormRepository) ListEntities(ctx context.Context) ([]domain.EntityRecord, error) {
	var rows []entityModel
	err := r.db.WithContext(ctx).
		Order("entity_type, entity_id").
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	result := make([]domain.EntityRecord, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, nil
}

func (r *GormRepository) ListEntitiesByTerm(ctx context.Context, termKey string) ([]domain.EntityRecord, error) {
	var rows []entityModel
	err := r.db.WithContext(ctx).
		Where("term_key = ? OR (term_key = '' AND entity_type IN ?)", termKey, []string{"course", "instructor_course"}).
		Order("entity_type, entity_id").
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	result := make([]domain.EntityRecord, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, nil
}

func (r *GormRepository) ApplyImport(ctx context.Context, pkg domain.Package, preview domain.ImportPreview, progress app.ProgressFunc) error {
	now := time.Now().UTC()
	changes := preview.AllChanges
	if changes == nil {
		changes = preview.Changes
	}
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		total := len(changes)
		lastPct := -1
		for idx, change := range changes {
			if change.Sequence == 0 {
				continue
			}
			if err := tx.Create(changeModelFromDomain(change, now)).Error; err != nil {
				return err
			}
			switch change.Operation {
			case "upsert":
				sum := sha256.Sum256(change.Payload)
				entity := entityModel{
					EntityType: change.EntityType, EntityID: change.EntityID, TermKey: change.TermKey,
					PayloadJSON: string(change.Payload), PayloadChecksum: "sha256:" + hex.EncodeToString(sum[:]),
					UpdatedVersion: change.Version, UpdatedAt: now,
				}
				if err := tx.Save(&entity).Error; err != nil {
					return err
				}
			case "delete":
				if err := tx.Delete(&entityModel{}, "entity_type = ? AND entity_id = ?", change.EntityType, change.EntityID).Error; err != nil {
					return err
				}
			}
			if progress != nil {
				pct := (idx + 1) * 100 / total
				if pct != lastPct {
					lastPct = pct
					progress(idx+1, total, change.EntityType)
				}
			}
		}
		termKeys, err := listTermKeys(tx)
		if err != nil {
			return err
		}
		checksum, err := datasetChecksum(tx)
		if err != nil {
			return err
		}
		termKeysJSON, err := json.Marshal(termKeys)
		if err != nil {
			return err
		}
		state := datasetStateModel{
			ID: 1, Version: preview.NextVersion, Checksum: checksum,
			SchemaVersion: 1, TermKeysJSON: string(termKeysJSON), PublishedAt: now, UpdatedAt: now,
		}
		if err := tx.Save(&state).Error; err != nil {
			return err
		}
		return nil
	})
}

func (r *GormRepository) UpdateBundle(ctx context.Context, version int64, bundle domain.DatasetBundle) error {
	return r.db.WithContext(ctx).Model(&datasetStateModel{}).
		Where("id = ? AND version = ?", 1, version).
		Updates(map[string]any{
			"bundle_key":      bundle.Key,
			"bundle_href":     bundle.Href,
			"bundle_size":     bundle.Size,
			"bundle_checksum": bundle.Checksum,
			"updated_at":      time.Now().UTC(),
		}).Error
}

func (r *GormRepository) ChangesAfter(ctx context.Context, version int64, limit int) ([]domain.EntityChange, domain.DatasetState, error) {
	state, err := r.CurrentDataset(ctx)
	if err != nil {
		return nil, domain.DatasetState{}, err
	}
	if limit <= 0 {
		limit = 5000
	}
	var rows []changeModel
	err = r.db.WithContext(ctx).
		Where("version > ?", version).
		Order("version, sequence").
		Limit(limit).
		Find(&rows).Error
	if err != nil {
		return nil, domain.DatasetState{}, err
	}
	result := make([]domain.EntityChange, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, state, nil
}

func (r *GormRepository) ListTerms(ctx context.Context) ([]domain.Term, error) {
	var rows []entityModel
	if err := r.db.WithContext(ctx).
		Where("entity_type = ?", "term").
		Order("entity_id DESC").
		Find(&rows).Error; err != nil {
		return nil, err
	}
	result := make([]domain.Term, len(rows))
	for i, row := range rows {
		result[i] = termFromEntity(row)
	}
	return result, nil
}

type datasetStateModel struct {
	ID             int       `gorm:"primaryKey;column:id"`
	Version        int64     `gorm:"column:version"`
	Checksum       string    `gorm:"column:checksum"`
	SchemaVersion  int       `gorm:"column:schema_version"`
	TermKeysJSON   string    `gorm:"column:term_keys_json"`
	BundleKey      string    `gorm:"column:bundle_key"`
	BundleHref     string    `gorm:"column:bundle_href"`
	BundleSize     int64     `gorm:"column:bundle_size"`
	BundleChecksum string    `gorm:"column:bundle_checksum"`
	PublishedAt    time.Time `gorm:"column:published_at"`
	UpdatedAt      time.Time `gorm:"column:updated_at"`
}

func (datasetStateModel) TableName() string { return "school_timetable_dataset_state" }

func (m datasetStateModel) toDomain() domain.DatasetState {
	var termKeys []string
	_ = json.Unmarshal([]byte(m.TermKeysJSON), &termKeys)
	if termKeys == nil {
		termKeys = []string{}
	}
	state := domain.DatasetState{
		Version: m.Version, Checksum: m.Checksum, SchemaVersion: m.SchemaVersion,
		TermKeys: termKeys, PublishedAt: m.PublishedAt,
	}
	if strings.TrimSpace(m.BundleHref) != "" {
		state.Bundle = &domain.DatasetBundle{
			Version: m.Version, Key: m.BundleKey, Href: m.BundleHref,
			Size: m.BundleSize, Checksum: m.BundleChecksum,
		}
	}
	return state
}

type entityModel struct {
	EntityType      string    `gorm:"primaryKey;column:entity_type"`
	EntityID        string    `gorm:"primaryKey;column:entity_id"`
	TermKey         string    `gorm:"column:term_key"`
	PayloadJSON     string    `gorm:"column:payload_json"`
	PayloadChecksum string    `gorm:"column:payload_checksum"`
	UpdatedVersion  int64     `gorm:"column:updated_version"`
	UpdatedAt       time.Time `gorm:"column:updated_at"`
}

func (entityModel) TableName() string { return "school_timetable_entities" }

func (m entityModel) toDomain() domain.EntityRecord {
	return domain.EntityRecord{
		EntityType: m.EntityType, EntityID: m.EntityID, TermKey: m.TermKey,
		Payload: []byte(m.PayloadJSON), PayloadChecksum: m.PayloadChecksum,
		UpdatedVersion: m.UpdatedVersion,
	}
}

func termFromEntity(row entityModel) domain.Term {
	var payload struct {
		TermKey         string `json:"term_key"`
		SchoolYear      string `json:"school_year"`
		Term            string `json:"term"`
		FirstWeekMonday string `json:"first_week_monday"`
		RowCount        int    `json:"row_count"`
		Source          string `json:"source"`
		SourceChecksum  string `json:"source_checksum"`
	}
	_ = json.Unmarshal([]byte(row.PayloadJSON), &payload)
	return domain.Term{
		TermKey:         firstNonEmpty(payload.TermKey, row.EntityID),
		SchoolYear:      payload.SchoolYear,
		Term:            payload.Term,
		FirstWeekMonday: payload.FirstWeekMonday,
		RowCount:        payload.RowCount,
		Source:          payload.Source,
		SourceChecksum:  payload.SourceChecksum,
		Version:         row.UpdatedVersion,
		PublishedAt:     row.UpdatedAt,
	}
}

type changeModel struct {
	Version     int64     `gorm:"primaryKey;column:version"`
	Sequence    int       `gorm:"primaryKey;column:sequence"`
	Operation   string    `gorm:"column:operation"`
	EntityType  string    `gorm:"column:entity_type"`
	EntityID    string    `gorm:"column:entity_id"`
	TermKey     string    `gorm:"column:term_key"`
	PayloadJSON string    `gorm:"column:payload_json"`
	CreatedAt   time.Time `gorm:"column:created_at"`
}

func (changeModel) TableName() string { return "school_timetable_changes" }

func changeModelFromDomain(item domain.EntityChange, now time.Time) changeModel {
	return changeModel{
		Version: item.Version, Sequence: item.Sequence, Operation: item.Operation,
		EntityType: item.EntityType, EntityID: item.EntityID, TermKey: item.TermKey,
		PayloadJSON: string(item.Payload), CreatedAt: now,
	}
}

func (m changeModel) toDomain() domain.EntityChange {
	return domain.EntityChange{
		Version: m.Version, Sequence: m.Sequence, Operation: m.Operation,
		EntityType: m.EntityType, EntityID: m.EntityID, TermKey: m.TermKey,
		Payload: []byte(m.PayloadJSON),
	}
}

func listTermKeys(tx *gorm.DB) ([]string, error) {
	var keys []string
	err := tx.Model(&entityModel{}).
		Where("entity_type = ?", "term").
		Order("entity_id DESC").
		Pluck("entity_id", &keys).Error
	if keys == nil {
		keys = []string{}
	}
	return keys, err
}

func datasetChecksum(tx *gorm.DB) (string, error) {
	var rows []entityModel
	if err := tx.Model(&entityModel{}).Order("entity_type, entity_id").Find(&rows).Error; err != nil {
		return "", err
	}
	parts := make([]string, 0, len(rows))
	for _, row := range rows {
		parts = append(parts, row.EntityType+"\x1f"+row.EntityID+"\x1f"+row.PayloadChecksum)
	}
	sort.Strings(parts)
	sum := sha256.Sum256([]byte(strings.Join(parts, "\n")))
	return "sha256:" + hex.EncodeToString(sum[:]), nil
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			return value
		}
	}
	return ""
}
