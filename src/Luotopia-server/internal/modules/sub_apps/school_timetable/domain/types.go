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
	SchoolYearCode  string   `json:"school_year_code"`
	TermCode        string   `json:"term_code"`
	FirstWeekMonday string   `json:"first_week_monday"`
	FieldCodes      []string `json:"field_codes"`
	RowCount        int      `json:"row_count"`
	GeneratedAt     string   `json:"generated_at"`
	Source          string   `json:"source"`
	SourceChecksum  string   `json:"source_checksum"`
}

// Package 是单学期上传包解析后的内存表示。数据模型以教学班（offering）为唯一核心：
// 跨学期共享 Course/Teacher，每学期 Offering 下挂 OfferingTeacher（多对多教师）、
// Audience（面向对象）、Meeting（排课，地点与周次都在此）。SourceRow 为可追溯归档。
type Package struct {
	Manifest         Manifest
	Courses          []Course
	Teachers         []Teacher
	Offerings        []CourseOffering
	OfferingTeachers []OfferingTeacher
	Audiences        []CourseAudience
	Meetings         []Meeting
	SourceRows       []SourceRow
}

// Term 是某学期的“当前激活发行版本”视图，供管理端学期列表展示。
// Version/PublishedAt/RowCount 取自该学期当前 active=true 的发行版本（见 Release）。
type Term struct {
	TermKey         string    `json:"term_key"`
	SchoolYear      string    `json:"school_year"`
	Term            string    `json:"term"`
	SchoolYearCode  string    `json:"school_year_code,omitempty"`
	TermCode        string    `json:"term_code,omitempty"`
	FirstWeekMonday string    `json:"first_week_monday"`
	RowCount        int       `json:"row_count"`
	Source          string    `json:"source,omitempty"`
	SourceChecksum  string    `json:"source_checksum,omitempty"`
	Version         int64     `json:"version"`
	PublishedAt     time.Time `json:"published_at"`
}

// Release 表示某学期某个数据集发行版本：唯一承载该版本的学期元维度、源数据行数、
// 离线包定位与激活状态。每学期恰好一行 Active=true 为当前激活版本；历史版本予以保留。
type Release struct {
	TermKey         string         `json:"term_key"`
	Version         int64          `json:"version"`
	SchoolYear      string         `json:"school_year"`
	Term            string         `json:"term"`
	FirstWeekMonday string         `json:"first_week_monday"`
	RowCount        int            `json:"row_count"`
	Source          string         `json:"source,omitempty"`
	SourceChecksum  string         `json:"source_checksum,omitempty"`
	PackageChecksum string         `json:"package_checksum,omitempty"`
	Bundle          *DatasetBundle `json:"bundle,omitempty"`
	Active          bool           `json:"active"`
	PublishedAt     time.Time      `json:"published_at"`
}

// Course 跨学期共享的课程目录项。
type Course struct {
	ID         string `json:"id"`
	CourseNo   string `json:"course_no"`
	CourseName string `json:"course_name"`
	Credits    string `json:"credits"`
}

// Teacher 跨学期共享的教师身份。ID 采用可扩展编码（name_key + seq），seq 默认 0，
// 靠 build 阶段的覆盖表手动区分同名的不同教师。
type Teacher struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	NameKey string `json:"name_key"`
	Seq     int    `json:"seq"`
}

// OfferingTeacher 教学班与教师的多对多链接。role: main(主讲) / other(其他)。
type OfferingTeacher struct {
	ID         string `json:"id"`
	TermKey    string `json:"term_key"`
	OfferingID string `json:"offering_id"`
	TeacherID  string `json:"teacher_id"`
	Role       string `json:"role"`
	Title      string `json:"title"`
	Ordinal    int    `json:"ordinal"`
}

// CourseOffering 教学班，模型的唯一核心。所有单值内容内联于此；课程身份引用 Course，
// 教师经 OfferingTeacher 关联，地点/周次在 Meeting。term_course_id 为分组哈希，供课程头聚合与跨模块关联。
type CourseOffering struct {
	ID                string `json:"id"`
	TermKey           string `json:"term_key"`
	CourseID          string `json:"course_id"`
	TermCourseID      string `json:"term_course_id"`
	SourceKey         string `json:"source_key"`
	TeachingClassName string `json:"teaching_class_name"`
	OpenCollege       string `json:"open_college"`
	CollegeID         string `json:"college_id"`
	OpenDeptID        string `json:"open_dept_id"`
	CourseNature      string `json:"course_nature"`
	CourseCategory    string `json:"course_category"`
	OpenType          string `json:"open_type"`
	PeopleRaw         string `json:"people_raw"`
	Capacity          int    `json:"capacity"`
	SelectedCount     int    `json:"selected_count"`
	TheoryHours       string `json:"theory_hours"`
	ComputerHours     string `json:"computer_hours"`
	ExperimentHours   string `json:"experiment_hours"`
	PracticeHours     string `json:"practice_hours"`
	Remark            string `json:"remark"`
	Note              string `json:"note"`
	OtherTeachers     string `json:"other_teachers"`
	Textbook          string `json:"textbook"`
	Publisher         string `json:"publisher"`
	SearchText        string `json:"search_text"`
}

// CourseAudience 教学班面向的学生范围切片。名称在 offering，代码在此用于筛选。
type CourseAudience struct {
	ID                 string `json:"id"`
	TermKey            string `json:"term_key"`
	OfferingID         string `json:"offering_id"`
	Grade              string `json:"grade"`
	GradeCode          string `json:"grade_code"`
	Major              string `json:"major"`
	MajorCode          string `json:"major_code"`
	PlanCollege        string `json:"plan_college"`
	CourseNatureCode   string `json:"course_nature_code"`
	CourseCategoryCode string `json:"course_category_code"`
	OpenTypeCode       string `json:"open_type_code"`
	ConditionCode      string `json:"condition_code"`
}

// Meeting 教学班的一条上课规则。地点与周次都在此粒度；周次以 WeekIndexes 数组承载（不再单列实体）。
type Meeting struct {
	ID             string `json:"id"`
	OfferingID     string `json:"offering_id"`
	TermKey        string `json:"term_key"`
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

// SourceRow 原始教务行归档，供追溯排错。服务端留档，不下发客户端。
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
	// MinReplayableVersion：该版本及其之后的 changes 可被客户端从 base 安全增量回放。
	MinReplayableVersion int64 `json:"min_replayable_version,omitempty"`
	Bundle               *DatasetBundle
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
	UpdatedAt       time.Time       `json:"updated_at"`
}

type EntityChange struct {
	Version    int64           `json:"version"`
	Sequence   int             `json:"sequence"`
	Operation  string          `json:"operation"`
	EntityType string          `json:"entity_type"`
	EntityID   string          `json:"entity_id"`
	TermKey    string          `json:"term_key"`
	Payload    json.RawMessage `json:"payload,omitempty"`
	// BaseVersion：该 change 所属连续段的基底版本（导入时 = 导入前的数据集版本）。
	BaseVersion int64 `json:"base_version,omitempty"`
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
