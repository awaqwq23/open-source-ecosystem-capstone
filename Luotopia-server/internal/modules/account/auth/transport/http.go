package transport

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
	"github.com/openwhu/luotopia/server/internal/modules/account/auth/app"
	"github.com/openwhu/luotopia/server/internal/modules/account/auth/domain"
)

type Handler struct {
	service      *app.Service
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
	protected.POST("/password", h.setPassword)
	protected.POST("/identities/email", h.bindEmail)
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
	userID := c.GetString("user_id")
	c.JSON(http.StatusOK, gin.H{"user": gin.H{"id": userID}})
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
		"user": gin.H{"id": result.User.ID},
		"tokens": gin.H{
			"access_token":  result.AccessToken,
			"refresh_token": result.RefreshToken,
			"expires_in":    result.ExpiresIn,
		},
	})
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
	case errors.Is(err, domain.ErrSocialProviderDisabled):
		writeError(c, http.StatusServiceUnavailable, "not_enabled", "能力暂未启用")
	default:
		writeError(c, http.StatusInternalServerError, "internal_error", "服务暂时不可用")
	}
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
