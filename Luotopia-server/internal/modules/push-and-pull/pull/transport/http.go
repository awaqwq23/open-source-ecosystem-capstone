package transport

import (
	"errors"
	"io"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/app"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/domain"
)

type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
}

func NewHandler(service *app.Service, authMiddleware gin.HandlerFunc) Handler {
	return Handler{service: service, authMiddleware: authMiddleware}
}

func (h Handler) Register(router gin.IRouter) {
	pull := router.Group("/pull")
	pull.Use(h.authMiddleware)
	pull.GET("", h.pull)
	pull.POST("", h.pullPost)

	public := router.Group("/pull/public")
	public.POST("", h.publicPullPost)
}

func (h Handler) pull(c *gin.Context) {
	userID := c.GetString("user_id")
	result := h.service.Pull(c.Request.Context(), userID, domain.PullRequest{})
	c.JSON(http.StatusOK, result)
}

func (h Handler) pullPost(c *gin.Context) {
	var req domain.PullRequest
	if err := c.ShouldBindJSON(&req); err != nil && !errors.Is(err, io.EOF) {
		c.JSON(http.StatusBadRequest, gin.H{"error": gin.H{"code": "invalid_argument", "message": "请求参数无效"}})
		return
	}
	userID := c.GetString("user_id")
	result := h.service.Pull(c.Request.Context(), userID, req)
	c.JSON(http.StatusOK, result)
}

func (h Handler) publicPullPost(c *gin.Context) {
	var req domain.PullRequest
	if err := c.ShouldBindJSON(&req); err != nil && !errors.Is(err, io.EOF) {
		c.JSON(http.StatusBadRequest, gin.H{"error": gin.H{"code": "invalid_argument", "message": "请求参数无效"}})
		return
	}
	req.Scopes = publicScopes(req.Scopes)
	result := h.service.Pull(c.Request.Context(), "", req)
	result.Sync = nil
	result.Stats = nil
	c.JSON(http.StatusOK, result)
}

func publicScopes(scopes []string) []string {
	if len(scopes) == 0 {
		return []string{"weather", "notification", "hot_update"}
	}
	allowed := make([]string, 0, len(scopes))
	for _, scope := range scopes {
		switch scope {
		case "weather", "notification", "hot_update":
			allowed = append(allowed, scope)
		}
	}
	if len(allowed) == 0 {
		return []string{"__public_none"}
	}
	return allowed
}
