package infra

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/app"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

func releaseID(termKey string, version int) string {
	return termKey + "@" + strconv.Itoa(version)
}

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

func (r *GormRepository) NextVersion(ctx context.Context, termKey string) (int, error) {
	var maxVersion int
	err := r.db.WithContext(ctx).Model(&releaseModel{}).
		Where("term_key = ?", termKey).
		Select("COALESCE(MAX(version), 0)").
		Scan(&maxVersion).Error
	return maxVersion + 1, err
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

func (r *GormRepository) ApplyImport(ctx context.Context, pkg domain.Package, preview domain.ImportPreview) error {
	now := time.Now().UTC()
	changes := preview.AllChanges
	if changes == nil {
		changes = preview.Changes
	}
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		for _, change := range changes {
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
		term := termModel{
			TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			FirstWeekMonday: pkg.Manifest.FirstWeekMonday, ActiveVersion: int(preview.NextVersion),
			Checksum: preview.Checksum, SchemaVersion: 1, RowCount: pkg.Manifest.RowCount,
			PublishedAt: &now, CreatedAt: now, UpdatedAt: now,
		}
		if term.RowCount == 0 {
			term.RowCount = preview.EntityCounts["source_row"]
		}
		if err := tx.Save(&term).Error; err != nil {
			return err
		}
		release := releaseModel{
			ID: releaseID(pkg.Manifest.TermKey, int(preview.NextVersion)), TermKey: pkg.Manifest.TermKey,
			Version: int(preview.NextVersion), Checksum: preview.Checksum, SchemaVersion: 1,
			RowCount: term.RowCount, Active: true, PublishedAt: now,
		}
		if err := tx.Model(&releaseModel{}).Where("term_key = ?", release.TermKey).Update("active", false).Error; err != nil {
			return err
		}
		return tx.Create(release).Error
	})
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

func (r *GormRepository) Publish(ctx context.Context, pkg domain.Package, release domain.Release, records app.Records) error {
	now := time.Now().UTC()
	if release.ID == "" {
		release.ID = releaseID(release.TermKey, release.Version)
	}
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		term := termModel{
			TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			FirstWeekMonday: pkg.Manifest.FirstWeekMonday, ActiveVersion: release.Version,
			Checksum: release.Checksum, FileKey: release.FileKey, ArtifactType: release.ArtifactType,
			SchemaVersion: release.SchemaVersion, ArtifactSize: release.ArtifactSize,
			RawFileKey: release.RawFileKey, RawChecksum: release.RawChecksum, RawSize: release.RawSize,
			RowCount: release.RowCount, PublishedAt: &release.PublishedAt,
			CreatedAt: now, UpdatedAt: now,
		}
		if err := tx.Save(&term).Error; err != nil {
			return err
		}
		if err := tx.Model(&releaseModel{}).Where("term_key = ?", release.TermKey).Update("active", false).Error; err != nil {
			return err
		}
		if err := tx.Create(releaseModelFromDomain(release)).Error; err != nil {
			return err
		}
		return nil
	})
}

func (r *GormRepository) ListActiveTerms(ctx context.Context) ([]domain.Term, error) {
	var rows []termModel
	if err := r.db.WithContext(ctx).Where("active_version > 0").Order("term_key DESC").Find(&rows).Error; err != nil {
		return nil, err
	}
	result := make([]domain.Term, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, nil
}

func (r *GormRepository) ListReleases(ctx context.Context, termKey string) ([]domain.Release, error) {
	var rows []releaseModel
	if err := r.db.WithContext(ctx).Where("term_key = ?", termKey).Order("version DESC").Find(&rows).Error; err != nil {
		return nil, err
	}
	result := make([]domain.Release, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, nil
}

func (r *GormRepository) ActivateRelease(ctx context.Context, termKey string, version int) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var rel releaseModel
		if err := tx.First(&rel, "term_key = ? AND version = ?", termKey, version).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return app.ErrNotFound
			}
			return err
		}
		if err := tx.Model(&releaseModel{}).Where("term_key = ?", termKey).Update("active", false).Error; err != nil {
			return err
		}
		if err := tx.Model(&releaseModel{}).Where("term_key = ? AND version = ?", termKey, version).Update("active", true).Error; err != nil {
			return err
		}
		return tx.Model(&termModel{}).Where("term_key = ?", termKey).Updates(map[string]any{
			"active_version": version,
			"checksum":       rel.Checksum,
			"file_key":       rel.FileKey,
			"artifact_type":  rel.ArtifactType,
			"schema_version": rel.SchemaVersion,
			"artifact_size":  rel.ArtifactSize,
			"raw_file_key":   rel.RawFileKey,
			"raw_checksum":   rel.RawChecksum,
			"raw_size":       rel.RawSize,
			"row_count":      rel.RowCount,
			"published_at":   rel.PublishedAt,
			"updated_at":     time.Now().UTC(),
		}).Error
	})
}

func (r *GormRepository) GetRelease(ctx context.Context, termKey string, version int) (domain.Release, error) {
	var row releaseModel
	err := r.db.WithContext(ctx).First(&row, "term_key = ? AND version = ?", termKey, version).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.Release{}, app.ErrNotFound
	}
	return row.toDomain(), err
}

type termModel struct {
	TermKey         string     `gorm:"primaryKey;column:term_key"`
	SchoolYear      string     `gorm:"column:school_year"`
	Term            string     `gorm:"column:term"`
	FirstWeekMonday string     `gorm:"column:first_week_monday"`
	ActiveVersion   int        `gorm:"column:active_version"`
	Checksum        string     `gorm:"column:checksum"`
	FileKey         string     `gorm:"column:file_key"`
	ArtifactType    string     `gorm:"column:artifact_type"`
	SchemaVersion   int        `gorm:"column:schema_version"`
	ArtifactSize    int64      `gorm:"column:artifact_size"`
	RawFileKey      string     `gorm:"column:raw_file_key"`
	RawChecksum     string     `gorm:"column:raw_checksum"`
	RawSize         int64      `gorm:"column:raw_size"`
	RowCount        int        `gorm:"column:row_count"`
	PublishedAt     *time.Time `gorm:"column:published_at"`
	CreatedAt       time.Time  `gorm:"column:created_at"`
	UpdatedAt       time.Time  `gorm:"column:updated_at"`
}

func (termModel) TableName() string { return "school_timetable_terms" }

func (m termModel) toDomain() domain.Term {
	publishedAt := time.Time{}
	if m.PublishedAt != nil {
		publishedAt = *m.PublishedAt
	}
	return domain.Term{
		TermKey: m.TermKey, SchoolYear: m.SchoolYear, Term: m.Term,
		FirstWeekMonday: m.FirstWeekMonday, Version: m.ActiveVersion,
		Checksum: m.Checksum, FileKey: m.FileKey, ArtifactType: m.ArtifactType,
		SchemaVersion: m.SchemaVersion, ArtifactSize: m.ArtifactSize,
		RawFileKey: m.RawFileKey, RawChecksum: m.RawChecksum, RawSize: m.RawSize,
		RowCount: m.RowCount, PublishedAt: publishedAt,
	}
}

type releaseModel struct {
	ID            string    `gorm:"column:release_id"`
	TermKey       string    `gorm:"primaryKey;column:term_key"`
	Version       int       `gorm:"primaryKey;column:version"`
	Checksum      string    `gorm:"column:checksum"`
	FileKey       string    `gorm:"column:file_key"`
	ArtifactType  string    `gorm:"column:artifact_type"`
	SchemaVersion int       `gorm:"column:schema_version"`
	ArtifactSize  int64     `gorm:"column:artifact_size"`
	RawFileKey    string    `gorm:"column:raw_file_key"`
	RawChecksum   string    `gorm:"column:raw_checksum"`
	RawSize       int64     `gorm:"column:raw_size"`
	RowCount      int       `gorm:"column:row_count"`
	Active        bool      `gorm:"column:active"`
	PublishedAt   time.Time `gorm:"column:published_at"`
}

func (releaseModel) TableName() string { return "school_timetable_releases" }

func releaseModelFromDomain(item domain.Release) releaseModel {
	if item.ID == "" {
		item.ID = releaseID(item.TermKey, item.Version)
	}
	return releaseModel{
		ID: item.ID, TermKey: item.TermKey, Version: item.Version, Checksum: item.Checksum, FileKey: item.FileKey,
		ArtifactType: item.ArtifactType, SchemaVersion: item.SchemaVersion, ArtifactSize: item.ArtifactSize,
		RawFileKey: item.RawFileKey, RawChecksum: item.RawChecksum, RawSize: item.RawSize,
		RowCount: item.RowCount, Active: item.Active, PublishedAt: item.PublishedAt,
	}
}

func (m releaseModel) toDomain() domain.Release {
	return domain.Release{
		ID: m.ID, TermKey: m.TermKey, Version: m.Version, Checksum: m.Checksum, FileKey: m.FileKey,
		ArtifactType: m.ArtifactType, SchemaVersion: m.SchemaVersion, ArtifactSize: m.ArtifactSize,
		RawFileKey: m.RawFileKey, RawChecksum: m.RawChecksum, RawSize: m.RawSize,
		RowCount: m.RowCount, Active: m.Active, PublishedAt: m.PublishedAt,
	}
}

type datasetStateModel struct {
	ID            int       `gorm:"primaryKey;column:id"`
	Version       int64     `gorm:"column:version"`
	Checksum      string    `gorm:"column:checksum"`
	SchemaVersion int       `gorm:"column:schema_version"`
	TermKeysJSON  string    `gorm:"column:term_keys_json"`
	PublishedAt   time.Time `gorm:"column:published_at"`
	UpdatedAt     time.Time `gorm:"column:updated_at"`
}

func (datasetStateModel) TableName() string { return "school_timetable_dataset_state" }

func (m datasetStateModel) toDomain() domain.DatasetState {
	var termKeys []string
	_ = json.Unmarshal([]byte(m.TermKeysJSON), &termKeys)
	if termKeys == nil {
		termKeys = []string{}
	}
	return domain.DatasetState{
		Version: m.Version, Checksum: m.Checksum, SchemaVersion: m.SchemaVersion,
		TermKeys: termKeys, PublishedAt: m.PublishedAt,
	}
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
