package transport

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/backend/admin/app"
	"github.com/openwhu/luotopia/server/internal/backend/admin/domain"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
)

type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
}

func NewHandler(service *app.Service, tokenSecret string, adminUserIDs []string) Handler {
	return Handler{service: service, authMiddleware: httpserver.AdminAuthMiddleware(tokenSecret, adminUserIDs)}
}

func (h Handler) Register(router gin.IRouter) {
	admin := router.Group("")
	protected := admin.Group("")
	protected.Use(h.authMiddleware)

	protected.GET("/dashboard", h.dashboard)

	weather := protected.Group("/weather")
	weather.GET("/status", h.weatherStatus)
	weather.POST("/refresh", h.refreshWeather)

	notifications := protected.Group("/notifications")
	notifications.GET("", h.listNotifications)
	notifications.POST("", h.createNotification)
	notifications.PUT("/:id/publish", h.publishNotification)
	notifications.DELETE("/:id", h.deleteNotification)

	scripts := protected.Group("/hot-update/scripts")
	scripts.GET("", h.listScripts)
	scripts.POST("", h.createScript)
	scripts.PUT("/:id/toggle", h.toggleScript)
	scripts.POST("/:id/releases", h.publishRelease)

	users := protected.Group("/users")
	users.GET("", h.listUsers)

	allowlist := protected.Group("/sync/allowlist")
	allowlist.GET("", h.listAllowlist)
	allowlist.POST("", h.addAllowlist)
	allowlist.DELETE("/:userId", h.removeAllowlist)
}

// Dashboard

func (h Handler) dashboard(c *gin.Context) {
	result := h.service.Dashboard(c.Request.Context())
	c.JSON(http.StatusOK, result)
}

// Weather

func (h Handler) weatherStatus(c *gin.Context) {
	result := h.service.WeatherStatus(c.Request.Context())
	c.JSON(http.StatusOK, result)
}

func (h Handler) refreshWeather(c *gin.Context) {
	result, err := h.service.RefreshWeather(c.Request.Context())
	if err != nil {
		writeError(c, http.StatusBadGateway, "weather_refresh_failed", "天气刷新失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

// Notifications

func (h Handler) listNotifications(c *gin.Context) {
	offset, _ := parseIntQuery(c, "offset", 0)
	limit, _ := parseIntQuery(c, "limit", 20)
	status := strings.TrimSpace(c.Query("status"))
	result, err := h.service.ListNotifications(c.Request.Context(), status, offset, limit)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取通知列表失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) createNotification(c *gin.Context) {
	var req domain.CreateNotificationRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.CreateNotification(c.Request.Context(), req)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "创建通知失败")
		return
	}
	c.JSON(http.StatusCreated, result)
}

func (h Handler) publishNotification(c *gin.Context) {
	id := c.Param("id")
	result, err := h.service.PublishNotification(c.Request.Context(), id)
	if err != nil {
		if errors.Is(err, app.ErrNotFound) {
			writeError(c, http.StatusNotFound, "not_found", "通知不存在")
			return
		}
		writeError(c, http.StatusInternalServerError, "internal_error", "发布通知失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) deleteNotification(c *gin.Context) {
	id := c.Param("id")
	if err := h.service.DeleteNotification(c.Request.Context(), id); err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "删除通知失败")
		return
	}
	c.JSON(http.StatusOK, gin.H{"deleted": true})
}

// Hot update scripts

func (h Handler) listScripts(c *gin.Context) {
	channel := strings.TrimSpace(c.Query("channel"))
	result, err := h.service.ListScripts(c.Request.Context(), channel)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取脚本列表失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) createScript(c *gin.Context) {
	var req domain.CreateScriptRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.CreateScript(c.Request.Context(), req)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "创建脚本失败")
		return
	}
	c.JSON(http.StatusCreated, result)
}

func (h Handler) toggleScript(c *gin.Context) {
	id := c.Param("id")
	result, err := h.service.ToggleScript(c.Request.Context(), id)
	if err != nil {
		if errors.Is(err, app.ErrNotFound) {
			writeError(c, http.StatusNotFound, "not_found", "脚本不存在")
			return
		}
		writeError(c, http.StatusInternalServerError, "internal_error", "切换脚本状态失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) publishRelease(c *gin.Context) {
	scriptID := c.Param("id")
	var req domain.PublishReleaseRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	if err := h.service.PublishRelease(c.Request.Context(), scriptID, req); err != nil {
		if errors.Is(err, app.ErrNotFound) {
			writeError(c, http.StatusNotFound, "not_found", "脚本不存在")
			return
		}
		if errors.Is(err, app.ErrInvalidArg) {
			writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
			return
		}
		writeError(c, http.StatusInternalServerError, "internal_error", "发布版本失败")
		return
	}
	c.JSON(http.StatusCreated, gin.H{"published": true})
}

// User management

func (h Handler) listUsers(c *gin.Context) {
	offset, _ := parseIntQuery(c, "offset", 0)
	limit, _ := parseIntQuery(c, "limit", 20)
	result, err := h.service.ListUsers(c.Request.Context(), offset, limit)
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取用户列表失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

// Sync allowlist

func (h Handler) listAllowlist(c *gin.Context) {
	result, err := h.service.ListAllowlist(c.Request.Context())
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取白名单失败")
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) addAllowlist(c *gin.Context) {
	var req domain.AddAllowlistRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	if err := h.service.AddAllowlist(c.Request.Context(), req.UserID); err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "添加白名单失败")
		return
	}
	c.JSON(http.StatusCreated, gin.H{"added": true})
}

func (h Handler) removeAllowlist(c *gin.Context) {
	userID := c.Param("userId")
	if err := h.service.RemoveAllowlist(c.Request.Context(), userID); err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "移除白名单失败")
		return
	}
	c.JSON(http.StatusOK, gin.H{"removed": true})
}

// helpers

func parseIntQuery(c *gin.Context, key string, fallback int) (int, error) {
	raw := strings.TrimSpace(c.Query(key))
	if raw == "" {
		return fallback, nil
	}
	return strconv.Atoi(raw)
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
