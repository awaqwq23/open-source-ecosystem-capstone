package transport

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
	"github.com/openwhu/luotopia/server/internal/modules/agenda-sync/app"
	"github.com/openwhu/luotopia/server/internal/modules/agenda-sync/domain"
)

type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
}

func NewHandler(service *app.Service, tokenSecret string) Handler {
	return Handler{service: service, authMiddleware: httpserver.AuthMiddleware(tokenSecret)}
}

func (h Handler) Register(router gin.IRouter) {
	sync := router.Group("/sync")
	sync.Use(h.authMiddleware)
	sync.GET("/capability", h.capability)
	sync.GET("/changes", h.pullChanges)
	sync.POST("/changes", h.pushChanges)
}

func (h Handler) capability(c *gin.Context) {
	result, err := h.service.Capability(c.Request.Context(), c.GetString("user_id"))
	if err != nil {
		writeSyncError(c, err)
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) pullChanges(c *gin.Context) {
	cursor, err := parseInt64Query(c, "cursor", 0)
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	limit, err := parseIntQuery(c, "limit", 500)
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.PullChanges(c.Request.Context(), c.GetString("user_id"), cursor, limit)
	if err != nil {
		writeSyncError(c, err)
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) pushChanges(c *gin.Context) {
	var req domain.SyncPushRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	result, err := h.service.PushChanges(c.Request.Context(), c.GetString("user_id"), req)
	if err != nil {
		writeSyncError(c, err)
		return
	}
	c.JSON(http.StatusOK, result)
}

func parseInt64Query(c *gin.Context, key string, fallback int64) (int64, error) {
	raw := strings.TrimSpace(c.Query(key))
	if raw == "" {
		return fallback, nil
	}
	return strconv.ParseInt(raw, 10, 64)
}

func parseIntQuery(c *gin.Context, key string, fallback int) (int, error) {
	raw := strings.TrimSpace(c.Query(key))
	if raw == "" {
		return fallback, nil
	}
	return strconv.Atoi(raw)
}

func writeSyncError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, app.ErrInvalidArgument):
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
	case errors.Is(err, app.ErrSyncDisabled):
		writeError(c, http.StatusForbidden, "sync_disabled", "当前账号未开通同步")
	default:
		writeError(c, http.StatusInternalServerError, "internal_error", "服务暂时不可用")
	}
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
