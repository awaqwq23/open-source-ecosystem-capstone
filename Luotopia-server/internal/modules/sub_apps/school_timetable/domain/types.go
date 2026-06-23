package domain

import (
	"encoding/json"
	"time"
)

type Manifest struct {
	Type            string   `json:"type"`
	SchemaVersion   int      `json:"schema_version"`
	TermKey         string   `json:"term_key"`
	SchoolYear      string   `json:"school_year"`
	Term            string   `json:"term"`
	FirstWeekMonday string   `json:"first_week_monday"`
	FieldCodes      []string `json:"field_codes"`
	RowCount        int      `json:"row_count"`
	GeneratedAt     string   `json:"generated_at"`
	Source          string   `json:"source"`
	SourceChecksum  string   `json:"source_checksum"`
}

type Package struct {
	Manifest          Manifest
	Rows              []map[string]string
	Catalogs          []CourseCatalog
	TermCourses       []TermCourse
	InstructorCourses []InstructorCourse
	Offerings         []CourseOffering
	Audiences         []CourseAudience
	CourseInstances   []CourseInstance
	SourceRows        []SourceRow
}

type Term struct {
	TermKey         string    `json:"term_key"`
	SchoolYear      string    `json:"school_year"`
	Term            string    `json:"term"`
	FirstWeekMonday string    `json:"first_week_monday"`
	RowCount        int       `json:"row_count"`
	Source          string    `json:"source,omitempty"`
	SourceChecksum  string    `json:"source_checksum,omitempty"`
	Version         int64     `json:"version"`
	PublishedAt     time.Time `json:"published_at"`
}

type CourseCatalog struct {
	ID         string `json:"id"`
	CatalogKey string `json:"catalog_key"`
	CourseNo   string `json:"course_no"`
	CourseName string `json:"course_name"`
	Credits    string `json:"credits"`
	SearchText string `json:"search_text"`
}

type TermCourse struct {
	ID                 string `json:"id"`
	TermKey            string `json:"term_key"`
	CatalogID          string `json:"catalog_id"`
	CourseNo           string `json:"course_no"`
	CourseName         string `json:"course_name"`
	OpenCollege        string `json:"open_college"`
	Credits            string `json:"credits"`
	CourseNature       string `json:"course_nature"`
	CourseCategory     string `json:"course_category"`
	OpenType           string `json:"open_type"`
	TeachingClassCount int    `json:"teaching_class_count"`
	TeacherSummary     string `json:"teacher_summary"`
	WeekdaySummary     string `json:"weekday_summary"`
	SearchText         string `json:"search_text"`
}

type InstructorCourse struct {
	ID                  string `json:"id"`
	CatalogID           string `json:"catalog_id"`
	CourseNo            string `json:"course_no"`
	CourseName          string `json:"course_name"`
	Credits             string `json:"credits"`
	InstructorName      string `json:"instructor_name"`
	InstructorNameKey   string `json:"instructor_name_key"`
	OfferingCount       int    `json:"offering_count"`
	LatestTermKey       string `json:"latest_term_key"`
	LatestOpenCollege   string `json:"latest_open_college"`
	LatestTeachingTitle string `json:"latest_teaching_title"`
	SearchText          string `json:"search_text"`
}

type CourseOffering struct {
	ID                 string            `json:"id"`
	TermKey            string            `json:"term_key"`
	SchoolYear         string            `json:"school_year"`
	Term               string            `json:"term"`
	TermCourseID       string            `json:"term_course_id"`
	CatalogID          string            `json:"catalog_id"`
	InstructorCourseID string            `json:"instructor_course_id"`
	SourceKey          string            `json:"source_key"`
	TeachingClassName  string            `json:"teaching_class_name"`
	CourseNo           string            `json:"course_no"`
	CourseName         string            `json:"course_name"`
	OpenCollege        string            `json:"open_college"`
	Credits            string            `json:"credits"`
	CourseNature       string            `json:"course_nature"`
	CourseCategory     string            `json:"course_category"`
	OpenType           string            `json:"open_type"`
	Instructor         string            `json:"instructor"`
	InstructorKey      string            `json:"instructor_key"`
	InstructorSetKey   string            `json:"instructor_set_key"`
	Title              string            `json:"title"`
	PeopleRaw          string            `json:"people_raw"`
	Capacity           int               `json:"capacity"`
	SelectedCount      int               `json:"selected_count"`
	TheoryHours        string            `json:"theory_hours"`
	ComputerHours      string            `json:"computer_hours"`
	ExperimentHours    string            `json:"experiment_hours"`
	PracticeHours      string            `json:"practice_hours"`
	Remark             string            `json:"remark"`
	OtherTeachers      string            `json:"other_teachers"`
	Textbook           string            `json:"textbook"`
	Publisher          string            `json:"publisher"`
	ScheduleSignature  string            `json:"schedule_signature"`
	ScheduleKey        string            `json:"schedule_key"`
	ScheduleSummary    string            `json:"schedule_summary"`
	WeekdaySummary     string            `json:"weekday_summary"`
	AudienceSummary    string            `json:"audience_summary"`
	GradeSummary       string            `json:"grade_summary"`
	MajorSummary       string            `json:"major_summary"`
	PlanCollegeSummary string            `json:"plan_college_summary"`
	SourceRowCount     int               `json:"source_row_count"`
	SearchText         string            `json:"search_text"`
	Fields             map[string]string `json:"fields,omitempty"`
}

type CourseAudience struct {
	ID                 string `json:"id"`
	TermKey            string `json:"term_key"`
	OfferingID         string `json:"offering_id"`
	TermCourseID       string `json:"term_course_id"`
	CatalogID          string `json:"catalog_id"`
	Grade              string `json:"grade"`
	Major              string `json:"major"`
	PlanCollege        string `json:"plan_college"`
	CourseNature       string `json:"course_nature"`
	CourseNatureCode   string `json:"course_nature_code"`
	CourseCategory     string `json:"course_category"`
	CourseCategoryCode string `json:"course_category_code"`
	OpenType           string `json:"open_type"`
	OpenTypeCode       string `json:"open_type_code"`
	ConditionCode      string `json:"condition_code"`
}

type CourseInstance struct {
	ID             string `json:"id"`
	OfferingID     string `json:"offering_id"`
	TermKey        string `json:"term_key"`
	TermCourseID   string `json:"term_course_id"`
	CatalogID      string `json:"catalog_id"`
	Weekday        int    `json:"weekday"`
	DayField       string `json:"day_field"`
	SegmentIndex   int    `json:"segment_index"`
	WeekdayLabel   string `json:"weekday_label"`
	RawDayText     string `json:"raw_day_text"`
	RawSegmentText string `json:"raw_segment_text"`
	WeekText       string `json:"week_text"`
	SectionText    string `json:"section_text"`
	SectionStart   int    `json:"section_start"`
	SectionEnd     int    `json:"section_end"`
	LocationText   string `json:"location_text"`
	WeekIndexes    []int  `json:"week_indexes"`
	ParseStatus    string `json:"parse_status"`
}

type SourceRow struct {
	ID           string            `json:"id"`
	TermKey      string            `json:"term_key"`
	TermCourseID string            `json:"term_course_id"`
	OfferingID   string            `json:"offering_id"`
	SourceKey    string            `json:"source_key"`
	PackageIndex int               `json:"package_index"`
	Status       string            `json:"status"`
	Fields       map[string]string `json:"fields"`
}

type ImportResult struct {
	Manifest Manifest       `json:"manifest"`
	Checksum string         `json:"checksum"`
	RowCount int            `json:"row_count"`
	Version  int64          `json:"version,omitempty"`
	Preview  *ImportPreview `json:"preview,omitempty"`
}

type ImportJobStatus string

const (
	JobStatusPending   ImportJobStatus = "pending"
	JobStatusRunning   ImportJobStatus = "running"
	JobStatusCompleted ImportJobStatus = "completed"
	JobStatusFailed    ImportJobStatus = "failed"
)

type ImportJob struct {
	ID        string          `json:"id"`
	Status    ImportJobStatus `json:"status"`
	Progress  string          `json:"progress"`
	Result    *ImportResult   `json:"result,omitempty"`
	Error     string          `json:"error,omitempty"`
	CreatedAt int64           `json:"created_at"`
	UpdatedAt int64           `json:"updated_at"`
}

type DatasetState struct {
	Version       int64     `json:"version"`
	Checksum      string    `json:"checksum"`
	SchemaVersion int       `json:"schema_version"`
	TermKeys      []string  `json:"term_keys"`
	PublishedAt   time.Time `json:"published_at"`
	Bundle        *DatasetBundle
}

type DatasetBundle struct {
	Version   int64  `json:"version"`
	Href      string `json:"href"`
	Key       string `json:"key,omitempty"`
	Size      int64  `json:"size"`
	Checksum  string `json:"checksum"`
	CreatedAt string `json:"created_at,omitempty"`
}

type EntityRecord struct {
	EntityType      string          `json:"entity_type"`
	EntityID        string          `json:"entity_id"`
	TermKey         string          `json:"term_key"`
	Payload         json.RawMessage `json:"payload"`
	PayloadChecksum string          `json:"payload_checksum"`
	UpdatedVersion  int64           `json:"updated_version"`
}

type EntityChange struct {
	Version    int64           `json:"version"`
	Sequence   int             `json:"sequence"`
	Operation  string          `json:"operation"`
	EntityType string          `json:"entity_type"`
	EntityID   string          `json:"entity_id"`
	TermKey    string          `json:"term_key"`
	Payload    json.RawMessage `json:"payload,omitempty"`
}

type ImportPreview struct {
	BaseVersion  int64          `json:"base_version"`
	NextVersion  int64          `json:"next_version"`
	TermKey      string         `json:"term_key"`
	Checksum     string         `json:"checksum"`
	Upserts      int            `json:"upserts"`
	Deletes      int            `json:"deletes"`
	EntityCounts map[string]int `json:"entity_counts"`
	Changes      []EntityChange `json:"changes"`
	AllChanges   []EntityChange `json:"-"`
}
