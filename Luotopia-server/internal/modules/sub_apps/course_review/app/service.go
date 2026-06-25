package app

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/course_review/domain"
)

// id 前缀（仅占位，仓库在 infra 中生成具体 ID）。
const (
	idPrefixReview = "rev"
	idPrefixLedger = "crl"
	idPrefixGrant  = "crag"
	idPrefixWallet = "crw"
)

// Repository 仓储端口，由 infra 实现。
type Repository interface {
	// GetSubject 按 course_id+teacher_id 取聚合；未创建时返回 ErrNotFound。
	GetSubject(ctx context.Context, courseID, teacherID string) (domain.Subject, error)
	// FindOrCreateSubject 幂等创建评价对象（确定性 id），返回 subject。
	FindOrCreateSubject(ctx context.Context, courseID, teacherID string) (domain.Subject, error)

	ListReviews(ctx context.Context, subjectID string, cursor string, limit int) (items []domain.Review, next string, err error)
	GetReview(ctx context.Context, reviewID string) (domain.Review, error)

	// SubmitReview 在单事务内：插入评价、重算 subject 聚合、给钱包加奖励并写流水。
	// 同一用户对同一 subject 的有效评价唯一；重复时返回 ErrConflict。
	SubmitReview(ctx context.Context, userID string, subject domain.Subject, input ReviewInput, rewardPoints int) (domain.Review, domain.Wallet, error)
	// DeleteReview 软删（status=deleted）并重算 subject 聚合，不退积分。
	DeleteReview(ctx context.Context, userID, reviewID string) (domain.Subject, error)

	GetWallet(ctx context.Context, userID string) (domain.Wallet, error)
	// ActiveAccessGrant 返回 now 落在 [starts_at, expires_at) 的授权；无则返回 ErrNotFound。
	ActiveAccessGrant(ctx context.Context, userID string, now time.Time) (domain.AccessGrant, error)
	// RedeemAccess 在单事务内：扣分写流水、创建授权。
	RedeemAccess(ctx context.Context, userID string, cost int, durationDays int, now time.Time) (domain.Wallet, domain.AccessGrant, error)

	ListMyReviews(ctx context.Context, userID string) ([]domain.Review, error)
}

// ServiceConfig 业务策略数值，不写死在数据库。
type ServiceConfig struct {
	Repo Repository
	// PointsPerReview 发评价奖励积分。
	PointsPerReview int
	// AccessCostPerDay 兑换查询权限的每日积分单价。
	AccessCostPerDay int
	// MaxRedeemDays 单次兑换最长天数。
	MaxRedeemDays int
	// DefaultListLimit 评价列表默认每页条数。
	DefaultListLimit int
}

// ReviewInput 用户提交的评价内容。
type ReviewInput struct {
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
}

// SubjectOverview 评价对象概览（免费可见的聚合）。
type SubjectOverview struct {
	Subject domain.Subject
	Course  CourseIdentity  `json:"course"`
	Teacher TeacherIdentity `json:"teacher"`
}

// CourseIdentity 服务端不强依赖全校课表实体内容，仅回传 ID；展示名由客户端从本地课表补全。
type CourseIdentity struct {
	ID string `json:"id"`
}

// TeacherIdentity 同上。
type TeacherIdentity struct {
	ID string `json:"id"`
}

// WalletView 钱包视图，含当前有效权限窗口（可为空）。
type WalletView struct {
	Balance     int                 `json:"balance"`
	AccessGrant *domain.AccessGrant `json:"access_grant"`
}

// Service 课程评价应用服务。
type Service struct {
	repo Repository
	cfg  ServiceConfig
}

func NewService(cfg ServiceConfig) *Service {
	return &Service{repo: cfg.Repo, cfg: cfg}
}

const (
	maxListLimit = 50
	defaultLimit = 10
	ratingMin    = 1
	ratingMax    = 5
)

func (s *Service) config() ServiceConfig {
	if s.cfg.DefaultListLimit > 0 {
		return s.cfg
	}
	cfg := s.cfg
	cfg.DefaultListLimit = defaultLimit
	return cfg
}

// GetSubject 取评价对象概览（免费）。
func (s *Service) GetSubject(ctx context.Context, courseID, teacherID string) (SubjectOverview, error) {
	if courseID == "" || teacherID == "" {
		return SubjectOverview{}, domain.ErrInvalidArgument
	}
	subject, err := s.repo.GetSubject(ctx, courseID, teacherID)
	if err != nil {
		if err == domain.ErrNotFound {
			// 评价对象尚无数据时返回零聚合概览，便于客户端展示"暂无评价"。
			return SubjectOverview{
				Subject: domain.Subject{ID: domain.SubjectID(courseID, teacherID), CourseID: courseID, TeacherID: teacherID},
				Course:  CourseIdentity{ID: courseID},
				Teacher: TeacherIdentity{ID: teacherID},
			}, nil
		}
		return SubjectOverview{}, err
	}
	return SubjectOverview{
		Subject: subject,
		Course:  CourseIdentity{ID: subject.CourseID},
		Teacher: TeacherIdentity{ID: subject.TeacherID},
	}, nil
}

// ListReviews 列出评价正文（需有效查询权限）。
func (s *Service) ListReviews(ctx context.Context, userID, courseID, teacherID, cursor string, limit int) ([]domain.Review, string, error) {
	if courseID == "" || teacherID == "" {
		return nil, "", domain.ErrInvalidArgument
	}
	if userID == "" {
		return nil, "", domain.ErrAccessRequired
	}
	if err := s.ensureAccess(ctx, userID); err != nil {
		return nil, "", err
	}
	if limit <= 0 {
		limit = s.config().DefaultListLimit
	}
	if limit > maxListLimit {
		limit = maxListLimit
	}
	subject, err := s.repo.GetSubject(ctx, courseID, teacherID)
	if err != nil {
		if err == domain.ErrNotFound {
			return nil, "", nil
		}
		return nil, "", err
	}
	return s.repo.ListReviews(ctx, subject.ID, cursor, limit)
}

// ensureAccess 校验当前用户持有有效查询权限。
func (s *Service) ensureAccess(ctx context.Context, userID string) error {
	if _, err := s.repo.ActiveAccessGrant(ctx, userID, time.Now()); err != nil {
		if err == domain.ErrNotFound {
			return domain.ErrAccessRequired
		}
		return err
	}
	return nil
}

// SubmitReview 用户提交评价，返回评价与最新钱包余额。
func (s *Service) SubmitReview(ctx context.Context, userID, courseID, teacherID string, input ReviewInput) (domain.Review, WalletView, error) {
	if userID == "" {
		return domain.Review{}, WalletView{}, domain.ErrForbidden
	}
	if courseID == "" || teacherID == "" {
		return domain.Review{}, WalletView{}, domain.ErrInvalidArgument
	}
	if err := validateRatings(input); err != nil {
		return domain.Review{}, WalletView{}, err
	}
	if strings.TrimSpace(input.ContentText) == "" {
		return domain.Review{}, WalletView{}, domain.ErrInvalidArgument
	}
	input.GradeValue = parseGradeValue(input.RawGradeText)
	reward := s.cfg.PointsPerReview
	if reward < 0 {
		reward = 0
	}
	subject, err := s.repo.FindOrCreateSubject(ctx, courseID, teacherID)
	if err != nil {
		return domain.Review{}, WalletView{}, err
	}
	review, wallet, err := s.repo.SubmitReview(ctx, userID, subject, input, reward)
	if err != nil {
		return domain.Review{}, WalletView{}, err
	}
	grant, _ := s.repo.ActiveAccessGrant(ctx, userID, time.Now())
	return review, WalletView{Balance: wallet.Balance, AccessGrant: grantOrNil(grant)}, nil
}

// DeleteReview 作者软删评价，不退积分。
func (s *Service) DeleteReview(ctx context.Context, userID, reviewID string) error {
	if userID == "" {
		return domain.ErrForbidden
	}
	if reviewID == "" {
		return domain.ErrInvalidArgument
	}
	_, err := s.repo.DeleteReview(ctx, userID, reviewID)
	return err
}

// GetWallet 当前余额与有效权限窗口。
func (s *Service) GetWallet(ctx context.Context, userID string) (WalletView, error) {
	if userID == "" {
		return WalletView{}, domain.ErrForbidden
	}
	wallet, err := s.repo.GetWallet(ctx, userID)
	if err != nil {
		if err == domain.ErrNotFound {
			return WalletView{Balance: 0}, nil
		}
		return WalletView{}, err
	}
	grant, _ := s.repo.ActiveAccessGrant(ctx, userID, time.Now())
	return WalletView{Balance: wallet.Balance, AccessGrant: grantOrNil(grant)}, nil
}

// ListMyReviews 我发表的评价。
func (s *Service) ListMyReviews(ctx context.Context, userID string) ([]domain.Review, error) {
	if userID == "" {
		return nil, domain.ErrForbidden
	}
	return s.repo.ListMyReviews(ctx, userID)
}

// RedeemAccess 兑换一段查询权限。
func (s *Service) RedeemAccess(ctx context.Context, userID string, durationDays int) (WalletView, domain.AccessGrant, error) {
	if userID == "" {
		return WalletView{}, domain.AccessGrant{}, domain.ErrForbidden
	}
	if durationDays <= 0 || (s.cfg.MaxRedeemDays > 0 && durationDays > s.cfg.MaxRedeemDays) {
		return WalletView{}, domain.AccessGrant{}, domain.ErrInvalidArgument
	}
	costPerDay := s.cfg.AccessCostPerDay
	if costPerDay <= 0 {
		return WalletView{}, domain.AccessGrant{}, domain.ErrInvalidArgument
	}
	cost := durationDays * costPerDay
	wallet, grant, err := s.repo.RedeemAccess(ctx, userID, cost, durationDays, time.Now())
	if err != nil {
		return WalletView{}, domain.AccessGrant{}, err
	}
	return WalletView{Balance: wallet.Balance, AccessGrant: &grant}, grant, nil
}

func validateRatings(input ReviewInput) error {
	for _, v := range []int{input.Difficulty, input.Workload, input.Quality, input.Interest} {
		if v < ratingMin || v > ratingMax {
			return domain.ErrInvalidArgument
		}
	}
	return nil
}

// parseGradeText 将原始成绩文本解析为可展示的数字成绩（保留 RawGradeText 原文）。
func parseGradeValue(raw string) *float64 {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return nil
	}
	// 兼容 "95" / "95.5" / "95分"。
	numStr := trimmed
	if i := strings.IndexAny(numStr, "0123456789."); i >= 0 {
		numStr = numStr[i:]
	} else {
		return nil
	}
	if v, err := strconv.ParseFloat(numStr, 64); err == nil {
		return &v
	}
	return nil
}

func grantOrNil(g domain.AccessGrant) *domain.AccessGrant {
	return &g
}
