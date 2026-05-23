package transport

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/auth/infra"
	"github.com/openwhu/luotopia/server/internal/modules/sync/app"
	"github.com/openwhu/luotopia/server/internal/modules/sync/domain"
)

type Handler struct {
	service     *app.Service
	tokenSecret string
}

func NewHandler(service *app.Service, tokenSecret string) Handler {
	return Handler{service: service, tokenSecret: tokenSecret}
}

func (h Handler) Register(router gin.IRouter) {
	sync := router.Group("/sync", h.requireAuth)
	sync.GET("/changes", h.pullChanges)
	sync.POST("/changes", h.pushChanges)
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

func (h Handler) requireAuth(c *gin.Context) {
	header := c.GetHeader("Authorization")
	token := strings.TrimPrefix(header, "Bearer ")
	if token == header || token == "" {
		writeError(c, http.StatusUnauthorized, "unauthenticated", "请先登录")
		c.Abort()
		return
	}
	userID, sessionID, err := infra.ParseAccessToken(h.tokenSecret, token)
	if err != nil {
		writeError(c, http.StatusUnauthorized, "unauthenticated", "登录凭证无效")
		c.Abort()
		return
	}
	c.Set("user_id", userID)
	c.Set("session_id", sessionID)
	c.Next()
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
	default:
		writeError(c, http.StatusInternalServerError, "internal_error", "服务暂时不可用")
	}
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
