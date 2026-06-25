package infra

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/course_review/app"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/course_review/domain"
	"github.com/openwhu/luotopia/server/internal/platform/id"
	"gorm.io/gorm"
)

var _ app.Repository = (*GormRepository)(nil)

type GormRepository struct {
	db *gorm.DB
}

func NewGormRepository(db *gorm.DB) *GormRepository {
	return &GormRepository{db: db}
}

// id 前缀。
const (
	idPrefixReview = "rev"
	idPrefixLedger = "crl"
	idPrefixGrant  = "crag"
)

func newReviewID() string { return id.New(idPrefixReview) }
func newLedgerID() string { return id.New(idPrefixLedger) }
func newGrantID() string  { return id.New(idPrefixGrant) }

// ---- gorm 模型 ----

type subjectModel struct {
	ID               string     `gorm:"primaryKey;column:id"`
	CourseID         string     `gorm:"column:course_id"`
	TeacherID        string     `gorm:"column:teacher_id"`
	ReviewCount      int        `gorm:"column:review_count"`
	AvgDifficulty    *float64   `gorm:"column:avg_difficulty"`
	AvgWorkload      *float64   `gorm:"column:avg_workload"`
	AvgQuality       *float64   `gorm:"column:avg_quality"`
	AvgInterest      *float64   `gorm:"column:avg_interest"`
	GradeSampleCount int        `gorm:"column:grade_sample_count"`
	AvgGrade         *float64   `gorm:"column:avg_grade"`
	LatestReviewAt   *time.Time `gorm:"column:latest_review_at"`
	CreatedAt        time.Time  `gorm:"column:created_at"`
	UpdatedAt        time.Time  `gorm:"column:updated_at"`
}

func (subjectModel) TableName() string { return "course_review_subjects" }

type reviewModel struct {
	ID              string    `gorm:"primaryKey;column:id"`
	SubjectID       string    `gorm:"column:subject_id"`
	AuthorUserID    *string   `gorm:"column:author_user_id"`
	Source          string    `gorm:"column:source"`
	Status          string    `gorm:"column:status"`
	Difficulty      int       `gorm:"column:difficulty"`
	Workload        int       `gorm:"column:workload"`
	Quality         int       `gorm:"column:quality"`
	Interest        int       `gorm:"column:interest"`
	RawGradeText    *string   `gorm:"column:raw_grade_text"`
	GradeValue      *float64  `gorm:"column:grade_value"`
	FinalAssessment *string   `gorm:"column:final_assessment_text"`
	AttendanceText  *string   `gorm:"column:attendance_text"`
	HomeworkText    *string   `gorm:"column:homework_text"`
	ContentText     string    `gorm:"column:content_text"`
	CreatedAt       time.Time `gorm:"column:created_at"`
	UpdatedAt       time.Time `gorm:"column:updated_at"`
}

func (reviewModel) TableName() string { return "course_reviews" }

type walletModel struct {
	UserID    string    `gorm:"primaryKey;column:user_id"`
	Balance   int       `gorm:"column:balance"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (walletModel) TableName() string { return "course_review_user_wallets" }

type ledgerModel struct {
	ID            string    `gorm:"primaryKey;column:id"`
	UserID        string    `gorm:"column:user_id"`
	Delta         int       `gorm:"column:delta"`
	Reason        string    `gorm:"column:reason"`
	ReviewID      *string   `gorm:"column:review_id"`
	AccessGrantID *string   `gorm:"column:access_grant_id"`
	CreatedAt     time.Time `gorm:"column:created_at"`
}

func (ledgerModel) TableName() string { return "course_review_point_ledger" }

type grantModel struct {
	ID           string    `gorm:"primaryKey;column:id"`
	UserID       string    `gorm:"column:user_id"`
	StartsAt     time.Time `gorm:"column:starts_at"`
	ExpiresAt    time.Time `gorm:"column:expires_at"`
	SourceLedger *string   `gorm:"column:source_ledger_id"`
	CreatedAt    time.Time `gorm:"column:created_at"`
}

func (grantModel) TableName() string { return "course_review_access_grants" }

// ---- Repository 实现 ----

func (r *GormRepository) GetSubject(ctx context.Context, courseID, teacherID string) (domain.Subject, error) {
	var m subjectModel
	err := r.db.WithContext(ctx).
		Where("course_id = ? AND teacher_id = ?", courseID, teacherID).
		First(&m).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.Subject{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Subject{}, err
	}
	return subjectToDomain(m), nil
}

func (r *GormRepository) FindOrCreateSubject(ctx context.Context, courseID, teacherID string) (domain.Subject, error) {
	if subject, err := r.GetSubject(ctx, courseID, teacherID); err == nil {
		return subject, nil
	} else if err != domain.ErrNotFound {
		return domain.Subject{}, err
	}
	now := time.Now()
	m := subjectModel{
		ID:        domain.SubjectID(courseID, teacherID),
		CourseID:  courseID,
		TeacherID: teacherID,
		CreatedAt: now,
		UpdatedAt: now,
	}
	err := r.db.WithContext(ctx).Create(&m).Error
	if err != nil {
		// 并发下 UNIQUE(course_id, teacher_id) 冲突 → 重新读取。
		if isDuplicateErr(err) {
			return r.GetSubject(ctx, courseID, teacherID)
		}
		return domain.Subject{}, err
	}
	return subjectToDomain(m), nil
}

func (r *GormRepository) ListReviews(ctx context.Context, subjectID string, cursor string, limit int) ([]domain.Review, string, error) {
	q := r.db.WithContext(ctx).
		Model(&reviewModel{}).
		Where("subject_id = ? AND status = ?", subjectID, string(domain.ReviewStatusPublic)).
		Order("created_at DESC, id DESC").
		Limit(limit + 1)
	if cursor != "" {
		created, id, ok := decodeReviewCursor(cursor)
		if ok {
			q = q.Where("(created_at, id) < (?, ?)", created, id)
		}
	}
	var rows []reviewModel
	if err := q.Find(&rows).Error; err != nil {
		return nil, "", err
	}
	next := ""
	if len(rows) > limit {
		last := rows[limit-1]
		next = encodeReviewCursor(last.CreatedAt, last.ID)
		rows = rows[:limit]
	}
	reviews := make([]domain.Review, len(rows))
	for i, row := range rows {
		reviews[i] = reviewToDomain(row)
	}
	return reviews, next, nil
}

func (r *GormRepository) GetReview(ctx context.Context, reviewID string) (domain.Review, error) {
	var m reviewModel
	err := r.db.WithContext(ctx).First(&m, "id = ?", reviewID).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.Review{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Review{}, err
	}
	return reviewToDomain(m), nil
}

func (r *GormRepository) SubmitReview(ctx context.Context, userID string, subject domain.Subject, input app.ReviewInput, rewardPoints int) (domain.Review, domain.Wallet, error) {
	now := time.Now()
	reviewID := newReviewID()
	review := reviewModel{
		ID:           reviewID,
		SubjectID:    subject.ID,
		AuthorUserID: &userID,
		Source:       string(domain.ReviewSourceUser),
		Status:       string(domain.ReviewStatusPublic),
		Difficulty:   input.Difficulty,
		Workload:     input.Workload,
		Quality:      input.Quality,
		Interest:     input.Interest,
		GradeValue:   input.GradeValue,
		ContentText:  input.ContentText,
		CreatedAt:    now,
		UpdatedAt:    now,
	}
	review.RawGradeText = nullableString(input.RawGradeText)
	review.FinalAssessment = nullableString(input.FinalAssessment)
	review.AttendanceText = nullableString(input.AttendanceText)
	review.HomeworkText = nullableString(input.HomeworkText)

	var wallet walletModel
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 唯一性约束兜底：先查同用户同 subject 是否已有有效评价。
		var existing reviewModel
		err := tx.Where("author_user_id = ? AND subject_id = ? AND source = ? AND status <> ?",
			userID, subject.ID, string(domain.ReviewSourceUser), string(domain.ReviewStatusDeleted)).
			First(&existing).Error
		if err == nil {
			return domain.ErrConflict
		}
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			return err
		}
		if err := tx.Create(&review).Error; err != nil {
			if isDuplicateErr(err) {
				return domain.ErrConflict
			}
			return err
		}
		if err := recomputeSubject(tx, subject.ID, now); err != nil {
			return err
		}
		// 钱包加奖励：不存在则建零余额行再加分。
		if err := tx.Where("user_id = ?", userID).First(&wallet).Error; err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				return err
			}
			wallet = walletModel{UserID: userID, Balance: 0, UpdatedAt: now}
			if err := tx.Create(&wallet).Error; err != nil {
				return err
			}
		}
		if rewardPoints > 0 {
			wallet.Balance += rewardPoints
			wallet.UpdatedAt = now
			if err := tx.Model(&walletModel{}).Where("user_id = ?", userID).
				Updates(map[string]any{"balance": wallet.Balance, "updated_at": now}).Error; err != nil {
				return err
			}
			ledgerID := newLedgerID()
			ledger := ledgerModel{
				ID:        ledgerID,
				UserID:    userID,
				Delta:     rewardPoints,
				Reason:    string(domain.LedgerReasonReviewPublished),
				ReviewID:  &reviewID,
				CreatedAt: now,
			}
			if err := tx.Create(&ledger).Error; err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return domain.Review{}, domain.Wallet{}, err
	}
	return reviewToDomain(review), domain.Wallet{UserID: wallet.UserID, Balance: wallet.Balance, UpdatedAt: wallet.UpdatedAt}, nil
}

func (r *GormRepository) DeleteReview(ctx context.Context, userID, reviewID string) (domain.Subject, error) {
	now := time.Now()
	var subject domain.Subject
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		var m reviewModel
		if err := tx.First(&m, "id = ?", reviewID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return domain.ErrNotFound
			}
			return err
		}
		if m.AuthorUserID == nil || *m.AuthorUserID != userID {
			return domain.ErrForbidden
		}
		if m.Status == string(domain.ReviewStatusDeleted) {
			subject = domain.Subject{ID: m.SubjectID}
			return nil
		}
		if err := tx.Model(&reviewModel{}).Where("id = ?", reviewID).
			Updates(map[string]any{"status": string(domain.ReviewStatusDeleted), "updated_at": now}).Error; err != nil {
			return err
		}
		if err := recomputeSubject(tx, m.SubjectID, now); err != nil {
			return err
		}
		subject = domain.Subject{ID: m.SubjectID}
		return nil
	})
	if err != nil {
		return domain.Subject{}, err
	}
	return subject, nil
}

func (r *GormRepository) GetWallet(ctx context.Context, userID string) (domain.Wallet, error) {
	var m walletModel
	err := r.db.WithContext(ctx).First(&m, "user_id = ?", userID).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.Wallet{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.Wallet{}, err
	}
	return domain.Wallet{UserID: m.UserID, Balance: m.Balance, UpdatedAt: m.UpdatedAt}, nil
}

func (r *GormRepository) ActiveAccessGrant(ctx context.Context, userID string, now time.Time) (domain.AccessGrant, error) {
	var m grantModel
	err := r.db.WithContext(ctx).
		Where("user_id = ? AND starts_at <= ? AND expires_at > ?", userID, now, now).
		Order("expires_at DESC").
		First(&m).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return domain.AccessGrant{}, domain.ErrNotFound
	}
	if err != nil {
		return domain.AccessGrant{}, err
	}
	return domain.AccessGrant{ID: m.ID, UserID: m.UserID, StartsAt: m.StartsAt, ExpiresAt: m.ExpiresAt, CreatedAt: m.CreatedAt}, nil
}

func (r *GormRepository) RedeemAccess(ctx context.Context, userID string, cost, durationDays int, now time.Time) (domain.Wallet, domain.AccessGrant, error) {
	grantID := newGrantID()
	ledgerID := newLedgerID()
	expires := now.Add(time.Duration(durationDays) * 24 * time.Hour)
	var wallet walletModel
	grant := domain.AccessGrant{ID: grantID, UserID: userID, StartsAt: now, ExpiresAt: expires, CreatedAt: now}
	err := r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Where("user_id = ?", userID).First(&wallet).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return domain.ErrInsufficient
			}
			return err
		}
		if wallet.Balance < cost {
			return domain.ErrInsufficient
		}
		wallet.Balance -= cost
		wallet.UpdatedAt = now
		if err := tx.Model(&walletModel{}).Where("user_id = ?", userID).
			Updates(map[string]any{"balance": wallet.Balance, "updated_at": now}).Error; err != nil {
			return err
		}
		ledger := ledgerModel{
			ID:            ledgerID,
			UserID:        userID,
			Delta:         -cost,
			Reason:        string(domain.LedgerReasonRedeemAccess),
			AccessGrantID: &grantID,
			CreatedAt:     now,
		}
		if err := tx.Create(&ledger).Error; err != nil {
			return err
		}
		g := grantModel{
			ID:           grantID,
			UserID:       userID,
			StartsAt:     now,
			ExpiresAt:    expires,
			SourceLedger: &ledgerID,
			CreatedAt:    now,
		}
		if err := tx.Create(&g).Error; err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return domain.Wallet{}, domain.AccessGrant{}, err
	}
	return domain.Wallet{UserID: wallet.UserID, Balance: wallet.Balance, UpdatedAt: wallet.UpdatedAt}, grant, nil
}

func (r *GormRepository) ListMyReviews(ctx context.Context, userID string) ([]domain.Review, error) {
	var rows []reviewModel
	err := r.db.WithContext(ctx).
		Where("author_user_id = ? AND status <> ?", userID, string(domain.ReviewStatusDeleted)).
		Order("created_at DESC").
		Find(&rows).Error
	if err != nil {
		return nil, err
	}
	reviews := make([]domain.Review, len(rows))
	for i, row := range rows {
		reviews[i] = reviewToDomain(row)
	}
	return reviews, nil
}

// ---- 聚合重算 ----

func recomputeSubject(tx *gorm.DB, subjectID string, now time.Time) error {
	type agg struct {
		Count            int
		AvgDifficulty    *float64
		AvgWorkload      *float64
		AvgQuality       *float64
		AvgInterest      *float64
		GradeSampleCount int
		AvgGrade         *float64
		LatestAt         *time.Time
	}
	var a agg
	err := tx.Model(&reviewModel{}).
		Select(`COUNT(*) AS count,
			AVG(difficulty) AS avg_difficulty,
			AVG(workload) AS avg_workload,
			AVG(quality) AS avg_quality,
			AVG(interest) AS avg_interest,
			COUNT(grade_value) AS grade_sample_count,
			AVG(grade_value) AS avg_grade,
			MAX(created_at) AS latest_at`).
		Where("subject_id = ? AND status = ?", subjectID, string(domain.ReviewStatusPublic)).
		Scan(&a).Error
	if err != nil {
		return err
	}
	updates := map[string]any{
		"review_count":       a.Count,
		"avg_difficulty":     a.AvgDifficulty,
		"avg_workload":       a.AvgWorkload,
		"avg_quality":        a.AvgQuality,
		"avg_interest":       a.AvgInterest,
		"grade_sample_count": a.GradeSampleCount,
		"avg_grade":          a.AvgGrade,
		"latest_review_at":   a.LatestAt,
		"updated_at":         now,
	}
	return tx.Model(&subjectModel{}).Where("id = ?", subjectID).Updates(updates).Error
}

// ---- 转换 ----

func subjectToDomain(m subjectModel) domain.Subject {
	return domain.Subject{
		ID:               m.ID,
		CourseID:         m.CourseID,
		TeacherID:        m.TeacherID,
		ReviewCount:      m.ReviewCount,
		AvgDifficulty:    m.AvgDifficulty,
		AvgWorkload:      m.AvgWorkload,
		AvgQuality:       m.AvgQuality,
		AvgInterest:      m.AvgInterest,
		GradeSampleCount: m.GradeSampleCount,
		AvgGrade:         m.AvgGrade,
		LatestReviewAt:   m.LatestReviewAt,
		CreatedAt:        m.CreatedAt,
		UpdatedAt:        m.UpdatedAt,
	}
}

func reviewToDomain(m reviewModel) domain.Review {
	var author string
	if m.AuthorUserID != nil {
		author = *m.AuthorUserID
	}
	return domain.Review{
		ID:              m.ID,
		SubjectID:       m.SubjectID,
		AuthorUserID:    author,
		Source:          domain.ReviewSource(m.Source),
		Status:          domain.ReviewStatus(m.Status),
		Difficulty:      m.Difficulty,
		Workload:        m.Workload,
		Quality:         m.Quality,
		Interest:        m.Interest,
		RawGradeText:    nullableValue(m.RawGradeText),
		GradeValue:      m.GradeValue,
		FinalAssessment: nullableValue(m.FinalAssessment),
		AttendanceText:  nullableValue(m.AttendanceText),
		HomeworkText:    nullableValue(m.HomeworkText),
		ContentText:     m.ContentText,
		CreatedAt:       m.CreatedAt,
		UpdatedAt:       m.UpdatedAt,
	}
}

// ---- 辅助 ----

func nullableString(s string) *string {
	if s == "" {
		return nil
	}
	return &s
}

func nullableValue(p *string) string {
	if p == nil {
		return ""
	}
	return *p
}

func isDuplicateErr(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, gorm.ErrDuplicatedKey) {
		return true
	}
	msg := err.Error()
	return strings.Contains(msg, "duplicate") || strings.Contains(msg, "unique")
}

func encodeReviewCursor(t time.Time, id string) string {
	return t.UTC().Format(time.RFC3339Nano) + "|" + id
}

func decodeReviewCursor(cursor string) (time.Time, string, bool) {
	idx := lastIndexOf(cursor, '|')
	if idx <= 0 {
		return time.Time{}, "", false
	}
	created, err := time.Parse(time.RFC3339Nano, cursor[:idx])
	if err != nil {
		return time.Time{}, "", false
	}
	return created, cursor[idx+1:], true
}

func lastIndexOf(s string, b byte) int {
	for i := len(s) - 1; i >= 0; i-- {
		if s[i] == b {
			return i
		}
	}
	return -1
}
