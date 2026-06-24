package infra

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
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
	var ds datasetModel
	err := r.db.WithContext(ctx).First(&ds, "id = ?", 1).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.DatasetState{SchemaVersion: 1, TermKeys: []string{}}, nil
	}
	if err != nil {
		return domain.DatasetState{}, err
	}
	termKeys, err := listActiveTermKeys(ctx, r.db)
	if err != nil {
		return domain.DatasetState{}, err
	}
	bundle, err := r.bundleByVersion(ctx, ds.Version)
	if err != nil {
		return domain.DatasetState{}, err
	}
	return domain.DatasetState{
		Version: ds.Version, Checksum: ds.Checksum, SchemaVersion: ds.SchemaVersion,
		TermKeys: termKeys, Bundle: bundle, PublishedAt: ds.PublishedAt,
	}, nil
}

// bundleByVersion 取某全局版本对应发行版本的离线包定位；版本未发布或包未上传时返回 nil。
func (r *GormRepository) bundleByVersion(ctx context.Context, version int64) (*domain.DatasetBundle, error) {
	var rel releaseModel
	err := r.db.WithContext(ctx).Where("version = ?", version).First(&rel).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return rel.toBundle(), nil
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
		// 写数据集全局头：版本、聚合校验、发布时间（学期绑定与离线包定位已下沉到 release）
		checksum, err := datasetChecksum(tx)
		if err != nil {
			return err
		}
		dataset := datasetModel{
			ID: 1, Version: preview.NextVersion, Checksum: checksum,
			SchemaVersion: 1, PublishedAt: now, UpdatedAt: now,
		}
		if err := tx.Save(&dataset).Error; err != nil {
			return err
		}
		// 写该学期发行版本行：同 term 旧版本置为非激活，新版本置为激活（历史版本予以保留）
		if err := tx.Model(&releaseModel{}).
			Where("term_key = ?", pkg.Manifest.TermKey).
			Update("active", false).Error; err != nil {
			return err
		}
		release := releaseModel{
			TermKey: pkg.Manifest.TermKey, Version: preview.NextVersion,
			SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			FirstWeekMonday: pkg.Manifest.FirstWeekMonday,
			RowCount: releaseRowCount(preview), Source: pkg.Manifest.Source,
			SourceChecksum: pkg.Manifest.SourceChecksum, PackageChecksum: preview.Checksum,
			Active: true, PublishedAt: now,
		}
		if err := tx.Save(&release).Error; err != nil {
			return err
		}
		return nil
	})
}

func (r *GormRepository) UpdateBundle(ctx context.Context, version int64, bundle domain.DatasetBundle) error {
	return r.db.WithContext(ctx).Model(&releaseModel{}).
		Where("version = ?", version).
		Updates(map[string]any{
			"bundle_key":      bundle.Key,
			"bundle_href":     bundle.Href,
			"bundle_size":     bundle.Size,
			"bundle_checksum": bundle.Checksum,
			"published_at":     time.Now().UTC(),
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
	var rows []releaseModel
	if err := r.db.WithContext(ctx).
		Where("active = ?", true).
		Order("term_key DESC").
		Find(&rows).Error; err != nil {
		return nil, err
	}
	result := make([]domain.Term, len(rows))
	for i, row := range rows {
		result[i] = domain.Term{
			TermKey: row.TermKey, SchoolYear: row.SchoolYear, Term: row.Term,
			FirstWeekMonday: row.FirstWeekMonday, RowCount: row.RowCount,
			Source: row.Source, SourceChecksum: row.SourceChecksum,
			Version: row.Version, PublishedAt: row.PublishedAt,
		}
	}
	return result, nil
}

// datasetModel 对应 school_timetable_dataset，数据集全局头（单行，id=1）。
// 仅承载全局版本、聚合校验、schema 版本与发布时间；学期元维度与离线包定位已下沉到 release。
type datasetModel struct {
	ID            int       `gorm:"primaryKey;column:id"`
	Version       int64     `gorm:"column:version"`
	Checksum      string    `gorm:"column:checksum"`
	SchemaVersion int       `gorm:"column:schema_version"`
	PublishedAt   time.Time `gorm:"column:published_at"`
	UpdatedAt     time.Time `gorm:"column:updated_at"`
}

func (datasetModel) TableName() string { return "school_timetable_dataset" }

// releaseModel 对应 school_timetable_releases，每学期每发行版本一行。
// 唯一承载学期元维度、源数据行数、源/包校验、离线包定位与激活标志。
type releaseModel struct {
	TermKey         string    `gorm:"primaryKey;column:term_key"`
	Version         int64     `gorm:"primaryKey;column:version"`
	SchoolYear      string    `gorm:"column:school_year"`
	Term            string    `gorm:"column:term"`
	FirstWeekMonday string    `gorm:"column:first_week_monday"`
	RowCount        int       `gorm:"column:row_count"`
	Source          string    `gorm:"column:source"`
	SourceChecksum  string    `gorm:"column:source_checksum"`
	PackageChecksum string    `gorm:"column:package_checksum"`
	BundleKey       string    `gorm:"column:bundle_key"`
	BundleHref      string    `gorm:"column:bundle_href"`
	BundleSize      int64     `gorm:"column:bundle_size"`
	BundleChecksum  string    `gorm:"column:bundle_checksum"`
	Active          bool      `gorm:"column:active"`
	PublishedAt     time.Time `gorm:"column:published_at"`
}

func (releaseModel) TableName() string { return "school_timetable_releases" }

func (m releaseModel) toBundle() *domain.DatasetBundle {
	if strings.TrimSpace(m.BundleHref) == "" {
		return nil
	}
	return &domain.DatasetBundle{
		Version: m.Version, Key: m.BundleKey, Href: m.BundleHref,
		Size: m.BundleSize, Checksum: m.BundleChecksum,
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

func listActiveTermKeys(ctx context.Context, db *gorm.DB) ([]string, error) {
	var keys []string
	err := db.WithContext(ctx).Model(&releaseModel{}).
		Where("active = ?", true).
		Order("term_key DESC").
		Pluck("term_key", &keys).Error
	if keys == nil {
		keys = []string{}
	}
	return keys, err
}

// releaseRowCount 以源数据行数（source_row 实体计数）作为发行版本的行数，避免依赖源包自报 RowCount。
func releaseRowCount(preview domain.ImportPreview) int {
	if preview.EntityCounts == nil {
		return 0
	}
	return preview.EntityCounts["source_row"]
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

