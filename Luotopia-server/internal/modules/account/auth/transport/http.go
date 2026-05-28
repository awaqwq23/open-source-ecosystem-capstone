package transport

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/account/auth/app"
	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
)

type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
}

func NewHandler(service *app.Service, tokenSecret string) Handler {
	return Handler{service: service, authMiddleware: httpserver.AuthMiddleware(tokenSecret)}
}

func (h Handler) Register(router gin.IRouter) {
	auth := router.Group("/auth")
	auth.POST("/verification-codes", h.sendVerificationCode)
	auth.POST("/login/verification-code", h.loginWithVerificationCode)
	auth.POST("/login/password", h.loginWithPassword)
	auth.POST("/token/refresh", h.refresh)
	auth.POST("/logout", h.logout)
	auth.POST("/social/:provider", h.socialLogin)

	protected := auth.Group("")
	protected.Use(h.authMiddleware)
	protected.GET("/me", h.me)
	protected.POST("/profile/username", h.setUsername)
	protected.POST("/password", h.setPassword)
	protected.POST("/identities/phone", h.bindPhone)
	protected.POST("/identities/email", h.bindEmail)
	protected.GET("/sessions", h.sessions)
	protected.DELETE("/sessions/:session_public_id", h.logoutSession)
	protected.POST("/logout-all", h.logoutAll)
}

type sendVerificationCodeRequest struct {
	TargetType string `json:"target_type" binding:"required"`
	Target     string `json:"target" binding:"required"`
	Purpose    string `json:"purpose" binding:"required"`
}

func (h Handler) sendVerificationCode(c *gin.Context) {
	var req sendVerificationCodeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	err := h.service.SendVerificationCode(c.Request.Context(), app.SendVerificationCodeCommand{
		TargetType: domain.IdentityType(req.TargetType),
		Target:     req.Target,
		Purpose:    domain.VerificationPurpose(req.Purpose),
	})
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "sent"})
}

type verificationCodeLoginRequest struct {
	TargetType string `json:"target_type" binding:"required"`
	Target     string `json:"target" binding:"required"`
	Code       string `json:"code" binding:"required"`
	DeviceName string `json:"device_name"`
}

func (h Handler) loginWithVerificationCode(c *gin.Context) {
	var req verificationCodeLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.LoginWithVerificationCode(c.Request.Context(), app.VerificationCodeLoginCommand{
		TargetType: domain.IdentityType(req.TargetType),
		Target:     req.Target,
		Code:       req.Code,
		DeviceName: req.DeviceName,
	})
	if err != nil {
		writeDomainError(c, err)
		return
	}
	writeAuthResult(c, result)
}

type passwordLoginRequest struct {
	Identifier string `json:"identifier" binding:"required"`
	Password   string `json:"password" binding:"required"`
	DeviceName string `json:"device_name"`
}

func (h Handler) loginWithPassword(c *gin.Context) {
	var req passwordLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.LoginWithPassword(c.Request.Context(), app.PasswordLoginCommand{
		Identifier: req.Identifier,
		Password:   req.Password,
		DeviceName: req.DeviceName,
	})
	if err != nil {
		writeDomainError(c, err)
		return
	}
	writeAuthResult(c, result)
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
	DeviceName   string `json:"device_name"`
}

func (h Handler) refresh(c *gin.Context) {
	var req refreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.Refresh(c.Request.Context(), req.RefreshToken, req.DeviceName)
	if err != nil {
		writeDomainError(c, err)
		return
	}
	writeAuthResult(c, result)
}

func (h Handler) logout(c *gin.Context) {
	var req refreshRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	if err := h.service.Logout(c.Request.Context(), req.RefreshToken); err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (h Handler) socialLogin(c *gin.Context) {
	writeError(c, http.StatusServiceUnavailable, "not_enabled", c.Param("provider")+" 登录暂未启用")
}

func (h Handler) me(c *gin.Context) {
	account, err := h.service.Me(c.Request.Context(), c.GetString("user_id"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"user": accountJSON(account)})
}

type setUsernameRequest struct {
	Username string `json:"username" binding:"required"`
}

func (h Handler) setUsername(c *gin.Context) {
	var req setUsernameRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	account, err := h.service.SetUsername(c.Request.Context(), c.GetString("user_id"), req.Username)
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"user": accountJSON(account)})
}

type setPasswordRequest struct {
	Password string `json:"password" binding:"required"`
}

func (h Handler) setPassword(c *gin.Context) {
	var req setPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	if err := h.service.SetPassword(c.Request.Context(), c.GetString("user_id"), req.Password); err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

type bindEmailRequest struct {
	Email string `json:"email" binding:"required"`
	Code  string `json:"code" binding:"required"`
}

type bindPhoneRequest struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required"`
}

func (h Handler) bindPhone(c *gin.Context) {
	var req bindPhoneRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	if err := h.service.BindPhone(c.Request.Context(), c.GetString("user_id"), req.Phone, req.Code); err != nil {
		writeDomainError(c, err)
		return
	}
	account, err := h.service.Me(c.Request.Context(), c.GetString("user_id"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"user": accountJSON(account)})
}

func (h Handler) bindEmail(c *gin.Context) {
	var req bindEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	if err := h.service.BindEmail(c.Request.Context(), c.GetString("user_id"), req.Email, req.Code); err != nil {
		writeDomainError(c, err)
		return
	}
	account, err := h.service.Me(c.Request.Context(), c.GetString("user_id"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"user": accountJSON(account)})
}

func (h Handler) sessions(c *gin.Context) {
	sessions, err := h.service.ListSessions(c.Request.Context(), c.GetString("user_id"), c.GetString("session_id"))
	if err != nil {
		writeDomainError(c, err)
		return
	}
	items := make([]gin.H, len(sessions))
	for i, session := range sessions {
		items[i] = gin.H{
			"id":          session.PublicID,
			"device_name": session.DeviceName,
			"current":     session.Current,
			"created_at":  session.CreatedAt,
			"expires_at":  session.ExpiresAt,
		}
	}
	c.JSON(http.StatusOK, gin.H{"sessions": items})
}

func (h Handler) logoutSession(c *gin.Context) {
	if err := h.service.LogoutSession(c.Request.Context(), c.GetString("user_id"), c.Param("session_public_id"), c.GetString("session_id")); err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func (h Handler) logoutAll(c *gin.Context) {
	if err := h.service.LogoutAll(c.Request.Context(), c.GetString("user_id")); err != nil {
		writeDomainError(c, err)
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "ok"})
}

func writeAuthResult(c *gin.Context, result app.AuthResult) {
	c.JSON(http.StatusOK, gin.H{
		"user": accountJSON(result.Account),
		"tokens": gin.H{
			"access_token":  result.AccessToken,
			"refresh_token": result.RefreshToken,
			"expires_in":    result.ExpiresIn,
		},
	})
}

func accountJSON(account domain.AccountSummary) gin.H {
	return gin.H{
		"external_id":  account.ExternalID,
		"username":     nullableString(account.Username),
		"avatar_url":   nullableString(account.AvatarURL),
		"has_password": account.HasPassword,
		"identities": gin.H{
			"phone":  nullableString(account.Identities.Phone),
			"email":  nullableString(account.Identities.Email),
			"wechat": nullableString(account.Identities.Wechat),
			"qq":     nullableString(account.Identities.QQ),
		},
	}
}

func nullableString(value string) any {
	if value == "" {
		return nil
	}
	return value
}

func writeDomainError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, domain.ErrInvalidArgument):
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
	case errors.Is(err, domain.ErrVerificationFailed):
		writeError(c, http.StatusBadRequest, "verification_failed", "验证码错误或已过期")
	case errors.Is(err, domain.ErrInvalidCredential):
		writeError(c, http.StatusUnauthorized, "invalid_credential", "账号或密码错误")
	case errors.Is(err, domain.ErrIdentityNotFound):
		writeError(c, http.StatusNotFound, "identity_not_found", "登录身份不存在")
	case errors.Is(err, domain.ErrIdentityAlreadyBound):
		writeError(c, http.StatusConflict, "identity_already_bound", "该身份已被其他账户绑定")
	case errors.Is(err, domain.ErrSessionNotFound):
		writeError(c, http.StatusNotFound, "session_not_found", "设备会话不存在")
	case errors.Is(err, domain.ErrSocialProviderDisabled):
		writeError(c, http.StatusServiceUnavailable, "not_enabled", "能力暂未启用")
	default:
		writeError(c, http.StatusInternalServerError, "internal_error", "服务暂时不可用")
	}
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
