package domain

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"time"
)

// SubjectID 由 (course_id, teacher_id) 确定性派生评价对象 ID，使客户端与服务端可独立算出同一 ID。
func SubjectID(courseID, teacherID string) string {
	sum := sha256.Sum256([]byte(courseID + ":" + teacherID))
	return hex.EncodeToString(sum[:])
}

// ReviewSource 评价来源。v1 仅 user；预留 legacy 供历史 courses.json 导入。
type ReviewSource string

const (
	ReviewSourceUser   ReviewSource = "user"
	ReviewSourceLegacy ReviewSource = "legacy"
)

// ReviewStatus 评价状态。
type ReviewStatus string

const (
	ReviewStatusPending ReviewStatus = "pending"
	ReviewStatusPublic  ReviewStatus = "published"
	ReviewStatusHidden  ReviewStatus = "hidden"
	ReviewStatusDeleted ReviewStatus = "deleted"
)

// LedgerReason 积分流水原因。
type LedgerReason string

const (
	LedgerReasonReviewPublished LedgerReason = "review_published"
	LedgerReasonRedeemAccess    LedgerReason = "redeem_access"
	LedgerReasonAdminAdjust     LedgerReason = "admin_adjust"
)

var (
	ErrInvalidArgument = errors.New("invalid_argument")
	ErrNotFound        = errors.New("not_found")
	ErrConflict        = errors.New("conflict")
	ErrForbidden       = errors.New("forbidden")
	ErrInsufficient    = errors.New("insufficient_points")
	ErrAccessRequired  = errors.New("access_required")
)

// Subject 课程评价对象 = course_id + teacher_id，聚合统计字段随评价提交/删除重算。
type Subject struct {
	ID               string
	CourseID         string
	TeacherID        string
	ReviewCount      int
	AvgDifficulty    *float64
	AvgWorkload      *float64
	AvgQuality       *float64
	AvgInterest      *float64
	GradeSampleCount int
	AvgGrade         *float64
	LatestReviewAt   *time.Time
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

// Review 单条评价。
type Review struct {
	ID              string
	SubjectID       string
	AuthorUserID    string
	Source          ReviewSource
	Status          ReviewStatus
	Difficulty      int
	Workload        int
	Quality         int
	Interest        int
	RawGradeText    string
	GradeValue      *float64
	FinalAssessment string
	AttendanceText  string
	HomeworkText    string
	ContentText     string
	CreatedAt       time.Time
	UpdatedAt       time.Time
}

// Wallet 用户积分余额。
type Wallet struct {
	UserID    string
	Balance   int
	UpdatedAt time.Time
}

// AccessGrant 查询权限授权区间。
type AccessGrant struct {
	ID        string
	UserID    string
	StartsAt  time.Time
	ExpiresAt time.Time
	CreatedAt time.Time
}

// LedgerEntry 积分流水。
type LedgerEntry struct {
	ID            string
	UserID        string
	Delta         int
	Reason        LedgerReason
	ReviewID      string
	AccessGrantID string
	CreatedAt     time.Time
}
