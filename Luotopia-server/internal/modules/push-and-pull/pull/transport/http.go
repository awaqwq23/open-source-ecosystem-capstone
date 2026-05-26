package transport

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/app"
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
}

func (h Handler) pull(c *gin.Context) {
	userID := c.GetString("user_id")
	result := h.service.Pull(c.Request.Context(), userID)
	c.JSON(http.StatusOK, result)
}
