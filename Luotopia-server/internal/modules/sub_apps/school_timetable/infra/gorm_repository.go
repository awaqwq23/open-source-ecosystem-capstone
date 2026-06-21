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

func (r *GormRepository) Publish(ctx context.Context, pkg domain.Package, release domain.Release, records app.Records) error {
	now := time.Now().UTC()
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		term := termModel{
			TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			FirstWeekMonday: pkg.Manifest.FirstWeekMonday, ActiveVersion: release.Version,
			Checksum: release.Checksum, RowCount: release.RowCount, PublishedAt: &release.PublishedAt,
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
		for _, model := range []any{
			&occurrenceModel{}, &meetingRuleModel{}, &sourceRowModel{}, &audienceModel{},
			&offeringModel{}, &termCourseModel{},
		} {
			if err := tx.Where("term_key = ?", pkg.Manifest.TermKey).Delete(model).Error; err != nil {
				return err
			}
		}
		if err := tx.Where("latest_term_key = ?", pkg.Manifest.TermKey).Delete(&instructorCourseModel{}).Error; err != nil {
			return err
		}
		if len(records.Catalogs) > 0 {
			models := make([]catalogModel, len(records.Catalogs))
			for i, item := range records.Catalogs {
				models[i] = catalogModelFromDomain(item)
			}
			if err := tx.Save(&models).Error; err != nil {
				return err
			}
		}
		if len(records.TermCourses) > 0 {
			models := make([]termCourseModel, len(records.TermCourses))
			for i, item := range records.TermCourses {
				models[i] = termCourseModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(records.InstructorCourses) > 0 {
			models := make([]instructorCourseModel, len(records.InstructorCourses))
			for i, item := range records.InstructorCourses {
				models[i] = instructorCourseModelFromDomain(item)
			}
			if err := tx.Save(&models).Error; err != nil {
				return err
			}
		}
		if len(records.Offerings) > 0 {
			models := make([]offeringModel, len(records.Offerings))
			for i, item := range records.Offerings {
				models[i] = offeringModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(records.Audiences) > 0 {
			models := make([]audienceModel, len(records.Audiences))
			for i, item := range records.Audiences {
				models[i] = audienceModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(records.SourceRows) > 0 {
			models := make([]sourceRowModel, len(records.SourceRows))
			for i, item := range records.SourceRows {
				models[i] = sourceRowModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(records.MeetingRules) > 0 {
			models := make([]meetingRuleModel, len(records.MeetingRules))
			for i, item := range records.MeetingRules {
				models[i] = meetingRuleModelFromDomain(item)
			}
			if err := tx.CreateInBatches(models, 500).Error; err != nil {
				return err
			}
		}
		if len(records.Occurrences) > 0 {
			models := make([]occurrenceModel, len(records.Occurrences))
			for i, item := range records.Occurrences {
				models[i] = occurrenceModelFromDomain(item)
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
	TermKey         string     `gorm:"primaryKey;column:term_key"`
	SchoolYear      string     `gorm:"column:school_year"`
	Term            string     `gorm:"column:term"`
	FirstWeekMonday string     `gorm:"column:first_week_monday"`
	ActiveVersion   int        `gorm:"column:active_version"`
	Checksum        string     `gorm:"column:checksum"`
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

type catalogModel struct {
	ID         string `gorm:"primaryKey;column:id"`
	CatalogKey string `gorm:"column:catalog_key"`
	CourseNo   string `gorm:"column:course_no"`
	CourseName string `gorm:"column:course_name"`
	Credits    string `gorm:"column:credits"`
	SearchText string `gorm:"column:search_text"`
}

func (catalogModel) TableName() string { return "course_catalogs" }

func catalogModelFromDomain(item domain.CourseCatalog) catalogModel {
	return catalogModel{
		ID: item.ID, CatalogKey: item.CatalogKey, CourseNo: item.CourseNo,
		CourseName: item.CourseName, Credits: item.Credits, SearchText: item.SearchText,
	}
}

type termCourseModel struct {
	ID                 string `gorm:"primaryKey;column:id"`
	TermKey            string `gorm:"column:term_key"`
	CatalogID          string `gorm:"column:catalog_id"`
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

func (termCourseModel) TableName() string { return "course_term_courses" }

func termCourseModelFromDomain(item domain.TermCourse) termCourseModel {
	return termCourseModel{
		ID: item.ID, TermKey: item.TermKey, CatalogID: item.CatalogID, CourseNo: item.CourseNo,
		CourseName: item.CourseName, OpenCollege: item.OpenCollege, Credits: item.Credits,
		CourseNature: item.CourseNature, CourseCategory: item.CourseCategory, OpenType: item.OpenType,
		TeachingClassCount: item.TeachingClassCount, TeacherSummary: item.TeacherSummary,
		WeekdaySummary: item.WeekdaySummary, SearchText: item.SearchText,
	}
}

type instructorCourseModel struct {
	ID                  string `gorm:"primaryKey;column:id"`
	CatalogID           string `gorm:"column:catalog_id"`
	CourseNo            string `gorm:"column:course_no"`
	CourseName          string `gorm:"column:course_name"`
	Credits             string `gorm:"column:credits"`
	InstructorName      string `gorm:"column:instructor_name"`
	InstructorNameKey   string `gorm:"column:instructor_name_key"`
	OfferingCount       int    `gorm:"column:offering_count"`
	LatestTermKey       string `gorm:"column:latest_term_key"`
	LatestOpenCollege   string `gorm:"column:latest_open_college"`
	LatestTeachingTitle string `gorm:"column:latest_teaching_title"`
	SearchText          string `gorm:"column:search_text"`
}

func (instructorCourseModel) TableName() string { return "course_instructor_courses" }

func instructorCourseModelFromDomain(item domain.InstructorCourse) instructorCourseModel {
	return instructorCourseModel{
		ID: item.ID, CatalogID: item.CatalogID, CourseNo: item.CourseNo, CourseName: item.CourseName,
		Credits: item.Credits, InstructorName: item.InstructorName, InstructorNameKey: item.InstructorNameKey,
		OfferingCount: item.OfferingCount, LatestTermKey: item.LatestTermKey,
		LatestOpenCollege: item.LatestOpenCollege, LatestTeachingTitle: item.LatestTeachingTitle,
		SearchText: item.SearchText,
	}
}

type offeringModel struct {
	ID                 string `gorm:"primaryKey;column:id"`
	TermKey            string `gorm:"column:term_key"`
	TermCourseID       string `gorm:"column:term_course_id"`
	CatalogID          string `gorm:"column:catalog_id"`
	InstructorCourseID string `gorm:"column:instructor_course_id"`
	TeachingClassName  string `gorm:"column:teaching_class_name"`
	CourseNo           string `gorm:"column:course_no"`
	CourseName         string `gorm:"column:course_name"`
	OpenCollege        string `gorm:"column:open_college"`
	Credits            string `gorm:"column:credits"`
	Instructor         string `gorm:"column:instructor"`
	InstructorKey      string `gorm:"column:instructor_key"`
	Title              string `gorm:"column:title"`
	PeopleRaw          string `gorm:"column:people_raw"`
	TheoryHours        string `gorm:"column:theory_hours"`
	ComputerHours      string `gorm:"column:computer_hours"`
	ExperimentHours    string `gorm:"column:experiment_hours"`
	PracticeHours      string `gorm:"column:practice_hours"`
	Remark             string `gorm:"column:remark"`
	OtherTeachers      string `gorm:"column:other_teachers"`
	Textbook           string `gorm:"column:textbook"`
	Publisher          string `gorm:"column:publisher"`
	ScheduleSignature  string `gorm:"column:schedule_signature"`
	ScheduleSummary    string `gorm:"column:schedule_summary"`
	WeekdaySummary     string `gorm:"column:weekday_summary"`
	AudienceSummary    string `gorm:"column:audience_summary"`
	SourceRowCount     int    `gorm:"column:source_row_count"`
	SearchText         string `gorm:"column:search_text"`
	FieldsJSON         string `gorm:"column:fields_json"`
}

func (offeringModel) TableName() string { return "course_offerings" }

func offeringModelFromDomain(item domain.CourseOffering) offeringModel {
	data, _ := json.Marshal(item.Fields)
	model := offeringModel{
		ID: item.ID, TermKey: item.TermKey, TermCourseID: item.TermCourseID, CatalogID: item.CatalogID,
		InstructorCourseID: item.InstructorCourseID, TeachingClassName: item.TeachingClassName,
		CourseNo: item.CourseNo, CourseName: item.CourseName, OpenCollege: item.OpenCollege, Credits: item.Credits,
		Instructor: item.Instructor, InstructorKey: item.InstructorKey, Title: item.Title, PeopleRaw: item.PeopleRaw,
		TheoryHours: item.TheoryHours, ComputerHours: item.ComputerHours, ExperimentHours: item.ExperimentHours,
		PracticeHours: item.PracticeHours, Remark: item.Remark, OtherTeachers: item.OtherTeachers,
		Textbook: item.Textbook, Publisher: item.Publisher, ScheduleSignature: item.ScheduleSignature,
		ScheduleSummary: item.ScheduleSummary, WeekdaySummary: item.WeekdaySummary, AudienceSummary: item.AudienceSummary,
		SourceRowCount: item.SourceRowCount, SearchText: item.SearchText, FieldsJSON: string(data),
	}
	return model
}

type audienceModel struct {
	ID                 string `gorm:"primaryKey;column:id"`
	TermKey            string `gorm:"column:term_key"`
	OfferingID         string `gorm:"column:offering_id"`
	TermCourseID       string `gorm:"column:term_course_id"`
	CatalogID          string `gorm:"column:catalog_id"`
	Grade              string `gorm:"column:grade"`
	Major              string `gorm:"column:major"`
	PlanCollege        string `gorm:"column:plan_college"`
	CourseNature       string `gorm:"column:course_nature"`
	CourseNatureCode   string `gorm:"column:course_nature_code"`
	CourseCategory     string `gorm:"column:course_category"`
	CourseCategoryCode string `gorm:"column:course_category_code"`
	OpenType           string `gorm:"column:open_type"`
	OpenTypeCode       string `gorm:"column:open_type_code"`
	ConditionCode      string `gorm:"column:condition_code"`
}

func (audienceModel) TableName() string { return "course_audiences" }

func audienceModelFromDomain(item domain.CourseAudience) audienceModel {
	return audienceModel{
		ID: item.ID, TermKey: item.TermKey, OfferingID: item.OfferingID,
		TermCourseID: item.TermCourseID, CatalogID: item.CatalogID, Grade: item.Grade,
		Major: item.Major, PlanCollege: item.PlanCollege, CourseNature: item.CourseNature,
		CourseNatureCode: item.CourseNatureCode, CourseCategory: item.CourseCategory,
		CourseCategoryCode: item.CourseCategoryCode, OpenType: item.OpenType,
		OpenTypeCode: item.OpenTypeCode, ConditionCode: item.ConditionCode,
	}
}

type sourceRowModel struct {
	ID           string `gorm:"primaryKey;column:id"`
	TermKey      string `gorm:"column:term_key"`
	TermCourseID string `gorm:"column:term_course_id"`
	OfferingID   string `gorm:"column:offering_id"`
	SourceKey    string `gorm:"column:source_key"`
	PackageIndex int    `gorm:"column:package_index"`
	Status       string `gorm:"column:status"`
	FieldsJSON   string `gorm:"column:fields_json"`
}

func (sourceRowModel) TableName() string { return "course_source_rows" }

func sourceRowModelFromDomain(item domain.SourceRow) sourceRowModel {
	data, _ := json.Marshal(item.Fields)
	return sourceRowModel{
		ID: item.ID, TermKey: item.TermKey, TermCourseID: item.TermCourseID, OfferingID: item.OfferingID,
		SourceKey: item.SourceKey, PackageIndex: item.PackageIndex, Status: item.Status, FieldsJSON: string(data),
	}
}

type meetingRuleModel struct {
	ID           string `gorm:"primaryKey;column:id"`
	OfferingID   string `gorm:"column:offering_id"`
	TermKey      string `gorm:"column:term_key"`
	TermCourseID string `gorm:"column:term_course_id"`
	CatalogID    string `gorm:"column:catalog_id"`
	Weekday      int    `gorm:"column:weekday"`
	SegmentIndex int    `gorm:"column:segment_index"`
	WeekdayLabel string `gorm:"column:weekday_label"`
	RawText      string `gorm:"column:raw_text"`
	WeekText     string `gorm:"column:week_text"`
	SectionText  string `gorm:"column:section_text"`
	LocationText string `gorm:"column:location_text"`
	Building     string `gorm:"column:building"`
	Room         string `gorm:"column:room"`
}

func (meetingRuleModel) TableName() string { return "course_meeting_rules" }

func meetingRuleModelFromDomain(item domain.CourseMeetingRule) meetingRuleModel {
	return meetingRuleModel{
		ID: item.ID, OfferingID: item.OfferingID, TermKey: item.TermKey,
		TermCourseID: item.TermCourseID, CatalogID: item.CatalogID, Weekday: item.Weekday,
		SegmentIndex: item.SegmentIndex, WeekdayLabel: item.WeekdayLabel, RawText: item.RawText,
		WeekText: item.WeekText, SectionText: item.SectionText, LocationText: item.LocationText,
		Building: item.Building, Room: item.Room,
	}
}

type occurrenceModel struct {
	ID           string `gorm:"primaryKey;column:id"`
	RuleID       string `gorm:"column:rule_id"`
	OfferingID   string `gorm:"column:offering_id"`
	TermKey      string `gorm:"column:term_key"`
	TermCourseID string `gorm:"column:term_course_id"`
	CatalogID    string `gorm:"column:catalog_id"`
	Date         string `gorm:"column:date"`
	WeekIndex    int    `gorm:"column:week_index"`
	Weekday      int    `gorm:"column:weekday"`
	SectionText  string `gorm:"column:section_text"`
	LocationText string `gorm:"column:location_text"`
	Building     string `gorm:"column:building"`
	Room         string `gorm:"column:room"`
}

func (occurrenceModel) TableName() string { return "course_occurrences" }

func occurrenceModelFromDomain(item domain.CourseOccurrence) occurrenceModel {
	return occurrenceModel{
		ID: item.ID, RuleID: item.RuleID, OfferingID: item.OfferingID, TermKey: item.TermKey,
		TermCourseID: item.TermCourseID, CatalogID: item.CatalogID, Date: item.Date,
		WeekIndex: item.WeekIndex, Weekday: item.Weekday, SectionText: item.SectionText,
		LocationText: item.LocationText, Building: item.Building, Room: item.Room,
	}
}
