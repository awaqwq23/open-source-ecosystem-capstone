package infra

import (
	"context"
	"errors"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/app"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/domain"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

func (r *GormRepository) CreateScript(ctx context.Context, s domain.Script) error {
	return r.db.WithContext(ctx).Create(scriptModelFromDomain(s)).Error
}

func (r *GormRepository) GetScriptByID(ctx context.Context, id string) (domain.Script, error) {
	var m scriptModel
	err := r.db.WithContext(ctx).First(&m, "id = ?", id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.Script{}, app.ErrNotFound
	}
	return m.toDomain(), err
}

func (r *GormRepository) ListScripts(ctx context.Context, channel domain.Channel) ([]domain.Script, error) {
	query := r.db.WithContext(ctx).Model(&scriptModel{})
	if channel != "" {
		query = query.Where("channel = ?", channel)
	}
	var rows []scriptModel
	if err := query.Order("created_at DESC").Find(&rows).Error; err != nil {
		return nil, err
	}
	result := make([]domain.Script, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, nil
}

func (r *GormRepository) UpdateScript(ctx context.Context, s domain.Script) error {
	return r.db.WithContext(ctx).Save(scriptModelFromDomain(s)).Error
}

func (r *GormRepository) CreateRelease(ctx context.Context, rel domain.ScriptRelease) error {
	return r.db.WithContext(ctx).Create(releaseModelFromDomain(rel)).Error
}

func (r *GormRepository) GetLatestRelease(ctx context.Context, scriptID string) (domain.ScriptRelease, error) {
	var m releaseModel
	err := r.db.WithContext(ctx).
		Where("script_id = ?", scriptID).
		Order("version DESC").
		First(&m).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.ScriptRelease{}, app.ErrNotFound
	}
	return m.toDomain(), err
}

func (r *GormRepository) GetReleaseByVersion(ctx context.Context, scriptID string, version int) (domain.ScriptRelease, error) {
	var m releaseModel
	err := r.db.WithContext(ctx).
		Where("script_id = ? AND version = ?", scriptID, version).
		First(&m).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.ScriptRelease{}, app.ErrNotFound
	}
	return m.toDomain(), err
}

func (r *GormRepository) ListReleases(ctx context.Context, scriptID string, offset, limit int) ([]domain.ScriptRelease, int64, error) {
	query := r.db.WithContext(ctx).Model(&releaseModel{}).Where("script_id = ?", scriptID)
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var rows []releaseModel
	if err := query.Order("version DESC").Offset(offset).Limit(limit).Find(&rows).Error; err != nil {
		return nil, 0, err
	}
	result := make([]domain.ScriptRelease, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, total, nil
}

type scriptModel struct {
	ID          string    `gorm:"primaryKey;column:id"`
	Name        string    `gorm:"column:name"`
	Description string    `gorm:"column:description"`
	Channel     string    `gorm:"column:channel"`
	Enabled     bool      `gorm:"column:enabled"`
	CreatedAt   time.Time `gorm:"column:created_at"`
	UpdatedAt   time.Time `gorm:"column:updated_at"`
}

func (scriptModel) TableName() string { return "hot_update_scripts" }

type releaseModel struct {
	ID           string    `gorm:"primaryKey;column:id"`
	ScriptID     string    `gorm:"column:script_id"`
	Version      int       `gorm:"column:version"`
	FileKey      string    `gorm:"column:file_key"`
	Checksum     string    `gorm:"column:checksum"`
	ReleaseNotes string    `gorm:"column:release_notes"`
	CreatedAt    time.Time `gorm:"column:created_at"`
}

func (releaseModel) TableName() string { return "hot_update_releases" }

func scriptModelFromDomain(s domain.Script) scriptModel {
	return scriptModel{
		ID:          s.ID,
		Name:        s.Name,
		Description: s.Description,
		Channel:     string(s.Channel),
		Enabled:     s.Enabled,
		CreatedAt:   s.CreatedAt,
		UpdatedAt:   s.UpdatedAt,
	}
}

func (m scriptModel) toDomain() domain.Script {
	return domain.Script{
		ID:          m.ID,
		Name:        m.Name,
		Description: m.Description,
		Channel:     domain.Channel(m.Channel),
		Enabled:     m.Enabled,
		CreatedAt:   m.CreatedAt,
		UpdatedAt:   m.UpdatedAt,
	}
}

func releaseModelFromDomain(r domain.ScriptRelease) releaseModel {
	return releaseModel{
		ID:           r.ID,
		ScriptID:     r.ScriptID,
		Version:      r.Version,
		FileKey:      r.FileKey,
		Checksum:     r.Checksum,
		ReleaseNotes: r.ReleaseNotes,
		CreatedAt:    r.CreatedAt,
	}
}

func (m releaseModel) toDomain() domain.ScriptRelease {
	return domain.ScriptRelease{
		ID:           m.ID,
		ScriptID:     m.ScriptID,
		Version:      m.Version,
		FileKey:      m.FileKey,
		Checksum:     m.Checksum,
		ReleaseNotes: m.ReleaseNotes,
		CreatedAt:    m.CreatedAt,
	}
}
