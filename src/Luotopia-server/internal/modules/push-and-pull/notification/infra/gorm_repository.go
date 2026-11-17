package infra

import (
	"context"
	"errors"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/domain"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

func (r *GormRepository) Create(ctx context.Context, n domain.Notification) error {
	return r.db.WithContext(ctx).Create(notificationModelFromDomain(n)).Error
}

func (r *GormRepository) GetByID(ctx context.Context, id string) (domain.Notification, error) {
	var m notificationModel
	err := r.db.WithContext(ctx).First(&m, "id = ?", id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return domain.Notification{}, app.ErrNotFound
		}
		return domain.Notification{}, err
	}
	return m.toDomain(), nil
}

func (r *GormRepository) List(ctx context.Context, status domain.Status, offset, limit int) ([]domain.Notification, int64, error) {
	query := r.db.WithContext(ctx).Model(&notificationModel{})
	if status != "" {
		query = query.Where("status = ?", status)
	}
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var rows []notificationModel
	if err := query.
		Order("display_order ASC").
		Order("published_at DESC NULLS LAST").
		Order("created_at DESC").
		Offset(offset).
		Limit(limit).
		Find(&rows).Error; err != nil {
		return nil, 0, err
	}
	result := make([]domain.Notification, len(rows))
	for i, row := range rows {
		result[i] = row.toDomain()
	}
	return result, total, nil
}

func (r *GormRepository) Update(ctx context.Context, n domain.Notification) error {
	return r.db.WithContext(ctx).Save(notificationModelFromDomain(n)).Error
}

func (r *GormRepository) Delete(ctx context.Context, id string) error {
	return r.db.WithContext(ctx).Delete(&notificationModel{}, "id = ?", id).Error
}

func (r *GormRepository) GetLatestPublished(ctx context.Context) (domain.Notification, error) {
	var m notificationModel
	err := r.db.WithContext(ctx).
		Where("status = ?", "published").
		Order("published_at DESC NULLS LAST").
		Order("created_at DESC").
		First(&m).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.Notification{}, app.ErrNotFound
	}
	return m.toDomain(), err
}

func (r *GormRepository) CountPublished(ctx context.Context) (int64, error) {
	var total int64
	err := r.db.WithContext(ctx).Model(&notificationModel{}).
		Where("status = ?", "published").
		Count(&total).Error
	return total, err
}

type notificationModel struct {
	ID           string     `gorm:"primaryKey;column:id"`
	Title        string     `gorm:"column:title"`
	Content      string     `gorm:"column:content"`
	Priority     string     `gorm:"column:priority"`
	Icon         string     `gorm:"column:icon"`
	DisplayOrder int        `gorm:"column:display_order"`
	Status       string     `gorm:"column:status"`
	PublishedAt  *time.Time `gorm:"column:published_at"`
	CreatedAt    time.Time  `gorm:"column:created_at"`
	UpdatedAt    time.Time  `gorm:"column:updated_at"`
}

func (notificationModel) TableName() string { return "push_notifications" }

func notificationModelFromDomain(n domain.Notification) notificationModel {
	return notificationModel{
		ID:           n.ID,
		Title:        n.Title,
		Content:      n.Content,
		Priority:     "normal",
		Icon:         n.Icon,
		DisplayOrder: n.DisplayOrder,
		Status:       string(n.Status),
		PublishedAt:  n.PublishedAt,
		CreatedAt:    n.CreatedAt,
		UpdatedAt:    n.UpdatedAt,
	}
}

func (m notificationModel) toDomain() domain.Notification {
	icon := m.Icon
	if icon == "" {
		icon = "campaign"
	}
	return domain.Notification{
		ID:           m.ID,
		Title:        m.Title,
		Content:      m.Content,
		Icon:         icon,
		DisplayOrder: m.DisplayOrder,
		Status:       domain.Status(m.Status),
		PublishedAt:  m.PublishedAt,
		CreatedAt:    m.CreatedAt,
		UpdatedAt:    m.UpdatedAt,
	}
}
