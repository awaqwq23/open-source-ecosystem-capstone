package infra

import (
	"context"
	"encoding/json"
	"errors"
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

func (r *GormRepository) NextVersion(ctx context.Context, termKey string) (int, error) {
	var maxVersion int
	err := r.db.WithContext(ctx).Model(&releaseModel{}).
		Where("term_key = ?", termKey).
		Select("COALESCE(MAX(version), 0)").
		Scan(&maxVersion).Error
	return maxVersion + 1, err
}

func (r *GormRepository) Publish(ctx context.Context, pkg domain.Package, release domain.Release, heads []domain.CourseHead, rows []domain.RawRow, meetings []domain.Meeting) error {
	now := time.Now().UTC()
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		term := termModel{
			TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			ActiveVersion: release.Version, Checksum: release.Checksum, RowCount: release.RowCount,
			PublishedAt: &release.PublishedAt, CreatedAt: now, UpdatedAt: now,
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
		if err := tx.Where("term_key = ?", pkg.Manifest.TermKey).Delete(&meetingModel{}).Error; err != nil {
			return err
		}
		if err := tx.Where("term_key = ?", pkg.Manifest.TermKey).Delete(&rawRowModel{}).Error; err != nil {
			return err
		}
		if err := tx.Where("term_key = ?", pkg.Manifest.TermKey).Delete(&courseHeadModel{}).Error; err != nil {
			return err
		}
		if len(heads) > 0 {
			models := make([]courseHeadModel, len(heads))
			for i, item := range heads {
				models[i] = courseHeadModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(rows) > 0 {
			models := make([]rawRowModel, len(rows))
			for i, item := range rows {
				models[i] = rawRowModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(meetings) > 0 {
			models := make([]meetingModel, len(meetings))
			for i, item := range meetings {
				models[i] = meetingModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
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
	TermKey       string     `gorm:"primaryKey;column:term_key"`
	SchoolYear    string     `gorm:"column:school_year"`
	Term          string     `gorm:"column:term"`
	ActiveVersion int        `gorm:"column:active_version"`
	Checksum      string     `gorm:"column:checksum"`
	RowCount      int        `gorm:"column:row_count"`
	PublishedAt   *time.Time `gorm:"column:published_at"`
	CreatedAt     time.Time  `gorm:"column:created_at"`
	UpdatedAt     time.Time  `gorm:"column:updated_at"`
}

func (termModel) TableName() string { return "school_timetable_terms" }

func (m termModel) toDomain() domain.Term {
	publishedAt := time.Time{}
	if m.PublishedAt != nil {
		publishedAt = *m.PublishedAt
	}
	return domain.Term{
		TermKey: m.TermKey, SchoolYear: m.SchoolYear, Term: m.Term, Version: m.ActiveVersion,
		Checksum: m.Checksum, RowCount: m.RowCount, PublishedAt: publishedAt,
	}
}

type releaseModel struct {
	TermKey     string    `gorm:"primaryKey;column:term_key"`
	Version     int       `gorm:"primaryKey;column:version"`
	Checksum    string    `gorm:"column:checksum"`
	FileKey     string    `gorm:"column:file_key"`
	RowCount    int       `gorm:"column:row_count"`
	Active      bool      `gorm:"column:active"`
	PublishedAt time.Time `gorm:"column:published_at"`
}

func (releaseModel) TableName() string { return "school_timetable_releases" }

func releaseModelFromDomain(item domain.Release) releaseModel {
	return releaseModel{
		TermKey: item.TermKey, Version: item.Version, Checksum: item.Checksum, FileKey: item.FileKey,
		RowCount: item.RowCount, Active: item.Active, PublishedAt: item.PublishedAt,
	}
}

func (m releaseModel) toDomain() domain.Release {
	return domain.Release{
		TermKey: m.TermKey, Version: m.Version, Checksum: m.Checksum, FileKey: m.FileKey,
		RowCount: m.RowCount, Active: m.Active, PublishedAt: m.PublishedAt,
	}
}

type courseHeadModel struct {
	ID                 string `gorm:"primaryKey;column:id"`
	TermKey            string `gorm:"column:term_key"`
	CourseHeadKey      string `gorm:"column:course_head_key"`
	CourseNo           string `gorm:"column:course_no"`
	CourseName         string `gorm:"column:course_name"`
	OpenCollege        string `gorm:"column:open_college"`
	Credits            string `gorm:"column:credits"`
	CourseNature       string `gorm:"column:course_nature"`
	CourseCategory     string `gorm:"column:course_category"`
	OpenType           string `gorm:"column:open_type"`
	TeachingClassCount int    `gorm:"column:teaching_class_count"`
	TeacherSummary     string `gorm:"column:teacher_summary"`
	WeekdaySummary     string `gorm:"column:weekday_summary"`
	SearchText         string `gorm:"column:search_text"`
}

func (courseHeadModel) TableName() string { return "school_timetable_course_heads" }

func courseHeadModelFromDomain(item domain.CourseHead) courseHeadModel {
	return courseHeadModel{
		ID: item.ID, TermKey: item.TermKey, CourseHeadKey: item.CourseHeadKey, CourseNo: item.CourseNo,
		CourseName: item.CourseName, OpenCollege: item.OpenCollege, Credits: item.Credits,
		CourseNature: item.CourseNature, CourseCategory: item.CourseCategory, OpenType: item.OpenType,
		TeachingClassCount: item.TeachingClassCount, TeacherSummary: item.TeacherSummary,
		WeekdaySummary: item.WeekdaySummary, SearchText: item.SearchText,
	}
}

type rawRowModel struct {
	ID                string `gorm:"primaryKey;column:id"`
	TermKey           string `gorm:"column:term_key"`
	CourseHeadID      string `gorm:"column:course_head_id"`
	SourceKey         string `gorm:"column:source_key"`
	SchoolYear        string `gorm:"column:school_year"`
	Term              string `gorm:"column:term"`
	TeachingClassName string `gorm:"column:teaching_class_name"`
	CourseNo          string `gorm:"column:course_no"`
	CourseName        string `gorm:"column:course_name"`
	OpenCollege       string `gorm:"column:open_college"`
	PlanCollege       string `gorm:"column:plan_college"`
	Credits           string `gorm:"column:credits"`
	CourseNature      string `gorm:"column:course_nature"`
	CourseCategory    string `gorm:"column:course_category"`
	OpenType          string `gorm:"column:open_type"`
	Grade             string `gorm:"column:grade"`
	Major             string `gorm:"column:major"`
	Instructor        string `gorm:"column:instructor"`
	Title             string `gorm:"column:title"`
	PeopleRaw         string `gorm:"column:people_raw"`
	FieldsJSON        string `gorm:"column:fields_json"`
}

func (rawRowModel) TableName() string { return "school_timetable_raw_rows" }

func rawRowModelFromDomain(item domain.RawRow) rawRowModel {
	data, _ := json.Marshal(item.Fields)
	return rawRowModel{
		ID: item.ID, TermKey: item.TermKey, CourseHeadID: item.CourseHeadID, SourceKey: item.SourceKey,
		SchoolYear: item.SchoolYear, Term: item.Term, TeachingClassName: item.TeachingClassName,
		CourseNo: item.CourseNo, CourseName: item.CourseName, OpenCollege: item.OpenCollege,
		PlanCollege: item.PlanCollege, Credits: item.Credits, CourseNature: item.CourseNature,
		CourseCategory: item.CourseCategory, OpenType: item.OpenType, Grade: item.Grade,
		Major: item.Major, Instructor: item.Instructor, Title: item.Title, PeopleRaw: item.PeopleRaw,
		FieldsJSON: string(data),
	}
}

type meetingModel struct {
	ID           string `gorm:"primaryKey;column:id"`
	RawRowID     string `gorm:"column:raw_row_id"`
	TermKey      string `gorm:"column:term_key"`
	CourseHeadID string `gorm:"column:course_head_id"`
	Weekday      int    `gorm:"column:weekday"`
	SegmentIndex int    `gorm:"column:segment_index"`
	WeekdayLabel string `gorm:"column:weekday_label"`
	RawText      string `gorm:"column:raw_text"`
	LocationText string `gorm:"column:location_text"`
	Building     string `gorm:"column:building"`
	Room         string `gorm:"column:room"`
}

func (meetingModel) TableName() string { return "school_timetable_meetings" }

func meetingModelFromDomain(item domain.Meeting) meetingModel {
	return meetingModel{
		ID: item.ID, RawRowID: item.RawRowID, TermKey: item.TermKey, CourseHeadID: item.CourseHeadID,
		Weekday: item.Weekday, SegmentIndex: item.SegmentIndex, WeekdayLabel: item.WeekdayLabel,
		RawText: item.RawText, LocationText: item.LocationText, Building: item.Building, Room: item.Room,
	}
}
