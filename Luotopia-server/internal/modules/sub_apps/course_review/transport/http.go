package transport

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/course_review/app"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/course_review/contract"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/course_review/domain"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
)

// Handler 课程评价客户端 API。
type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
}

func NewHandler(service *app.Service, tokenSecret string) Handler {
	return Handler{service: service, authMiddleware: httpserver.AuthMiddleware(tokenSecret)}
}

// Register 挂载到 /api/v1/course-reviews。概览免费；其余需登录。
func (h Handler) Register(router gin.IRouter) {
	g := router.Group(contract.ClientBase)
	g.GET("/policy", h.getPolicy)
	g.GET("/courses/:courseId/teachers/:teacherId", h.getSubject)

	protected := g.Group("")
	protected.Use(h.authMiddleware)
	protected.GET("/courses/:courseId/teachers/:teacherId/reviews", h.listReviews)
	protected.POST("/courses/:courseId/teachers/:teacherId/reviews", h.submitReview)
	protected.DELETE("/reviews/:reviewId", h.deleteReview)
	protected.GET("/me/wallet", h.getWallet)
	protected.GET("/me/reviews", h.myReviews)
	protected.POST("/access/redeem", h.redeemAccess)
}

func (h Handler) getPolicy(c *gin.Context) {
	c.JSON(http.StatusOK, policyJSON(h.service.GetPolicy()))
}

func (h Handler) getSubject(c *gin.Context) {
	overview, err := h.service.GetSubject(c.Request.Context(), c.Param("courseId"), c.Param("teacherId"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, subjectOverviewJSON(overview))
}

func (h Handler) listReviews(c *gin.Context) {
	limit, _ := strconv.Atoi(c.Query("limit"))
	reviews, next, err := h.service.ListReviews(
		c.Request.Context(),
		c.GetString("user_id"),
		c.Param("courseId"),
		c.Param("teacherId"),
		c.Query("cursor"),
		limit,
	)
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": reviewListJSON(reviews), "next_cursor": next})
}

type submitReviewRequest struct {
	Difficulty      int    `json:"difficulty" binding:"required"`
	Workload        int    `json:"workload" binding:"required"`
	Quality         int    `json:"quality" binding:"required"`
	Interest        int    `json:"interest" binding:"required"`
	RawGradeText    string `json:"raw_grade_text"`
	FinalAssessment string `json:"final_assessment"`
	AttendanceText  string `json:"attendance_text"`
	HomeworkText    string `json:"homework_text"`
	ContentText     string `json:"content_text" binding:"required"`
}

func (h Handler) submitReview(c *gin.Context) {
	var req submitReviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	review, wallet, err := h.service.SubmitReview(c.Request.Context(), c.GetString("user_id"),
		c.Param("courseId"), c.Param("teacherId"), app.ReviewInput{
			Difficulty:      req.Difficulty,
			Workload:        req.Workload,
			Quality:         req.Quality,
			Interest:        req.Interest,
			RawGradeText:    req.RawGradeText,
			FinalAssessment: req.FinalAssessment,
			AttendanceText:  req.AttendanceText,
			HomeworkText:    req.HomeworkText,
			ContentText:     req.ContentText,
		})
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusCreated, gin.H{"review": reviewJSON(review), "wallet": walletJSON(wallet)})
}

func (h Handler) deleteReview(c *gin.Context) {
	if err := h.service.DeleteReview(c.Request.Context(), c.GetString("user_id"), c.Param("reviewId")); err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (h Handler) getWallet(c *gin.Context) {
	wallet, err := h.service.GetWallet(c.Request.Context(), c.GetString("user_id"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, walletJSON(wallet))
}

func (h Handler) myReviews(c *gin.Context) {
	reviews, err := h.service.ListMyReviews(c.Request.Context(), c.GetString("user_id"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": reviewListJSON(reviews)})
}

type redeemRequest struct {
	DurationDays int `json:"duration_days" binding:"required"`
}

func (h Handler) redeemAccess(c *gin.Context) {
	var req redeemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	wallet, _, err := h.service.RedeemAccess(c.Request.Context(), c.GetString("user_id"), req.DurationDays)
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, walletJSON(wallet))
}

// ---- JSON 序列化 ----

func subjectOverviewJSON(o app.SubjectOverview) gin.H {
	s := o.Subject
	return gin.H{
		"subject": gin.H{
			"id":                 s.ID,
			"course_id":          s.CourseID,
			"teacher_id":         s.TeacherID,
			"review_count":       s.ReviewCount,
			"avg_difficulty":     nullableFloat(s.AvgDifficulty),
			"avg_workload":       nullableFloat(s.AvgWorkload),
			"avg_quality":        nullableFloat(s.AvgQuality),
			"avg_interest":       nullableFloat(s.AvgInterest),
			"grade_sample_count": s.GradeSampleCount,
			"avg_grade":          nullableFloat(s.AvgGrade),
			"latest_review_at":   nullableTime(s.LatestReviewAt),
		},
		"course":  gin.H{"id": o.Course.ID},
		"teacher": gin.H{"id": o.Teacher.ID},
	}
}

func reviewListJSON(reviews []domain.Review) []gin.H {
	items := make([]gin.H, len(reviews))
	for i, r := range reviews {
		items[i] = reviewJSON(r)
	}
	return items
}

func reviewJSON(r domain.Review) gin.H {
	return gin.H{
		"id":               r.ID,
		"subject_id":       r.SubjectID,
		"difficulty":       r.Difficulty,
		"workload":         r.Workload,
		"quality":          r.Quality,
		"interest":         r.Interest,
		"raw_grade_text":   nullableString(r.RawGradeText),
		"grade_value":      nullableFloat(r.GradeValue),
		"final_assessment": nullableString(r.FinalAssessment),
		"attendance_text":  nullableString(r.AttendanceText),
		"homework_text":    nullableString(r.HomeworkText),
		"content_text":     r.ContentText,
		"created_at":       r.CreatedAt,
	}
}

func walletJSON(w app.WalletView) gin.H {
	grant := any(nil)
	if w.AccessGrant != nil {
		grant = gin.H{
			"id":         w.AccessGrant.ID,
			"starts_at":  w.AccessGrant.StartsAt,
			"expires_at": w.AccessGrant.ExpiresAt,
		}
	}
	return gin.H{"balance": w.Balance, "access_grant": grant}
}

func policyJSON(p app.PolicyView) gin.H {
	return gin.H{
		"points_per_review":   p.PointsPerReview,
		"access_cost_per_day": p.AccessCostPerDay,
		"max_redeem_days":     p.MaxRedeemDays,
	}
}

func nullableFloat(v *float64) any {
	if v == nil {
		return nil
	}
	return *v
}

func nullableString(v string) any {
	if v == "" {
		return nil
	}
	return v
}

func nullableTime(v *time.Time) any {
	if v == nil {
		return nil
	}
	return *v
}

// ---- 错误映射 ----

func writeDomainError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, domain.ErrInvalidArgument):
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
	case errors.Is(err, domain.ErrAccessRequired):
		writeError(c, http.StatusForbidden, "access_required", "需要兑换查询权限后查看")
	case errors.Is(err, domain.ErrForbidden):
		writeError(c, http.StatusForbidden, "forbidden", "无权操作")
	case errors.Is(err, domain.ErrNotFound):
		writeError(c, http.StatusNotFound, "not_found", "资源不存在")
	case errors.Is(err, domain.ErrConflict):
		writeError(c, http.StatusConflict, "conflict", "已评价过该课程与教师组合")
	case errors.Is(err, domain.ErrInsufficient):
		writeError(c, http.StatusBadRequest, "insufficient_points", "积分不足")
	default:
		writeError(c, http.StatusInternalServerError, "internal_error", "服务暂时不可用")
	}
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
