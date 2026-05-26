package transport

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/backend/admin/app"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
)

type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
}

func NewHandler(service *app.Service, tokenSecret string) Handler {
	return Handler{service: service, authMiddleware: httpserver.AdminAuthMiddleware(tokenSecret)}
}

func (h Handler) Register(router gin.IRouter) {
	admin := router.Group("")
	protected := admin.Group("")
	protected.Use(h.authMiddleware)

	protected.GET("/dashboard", h.dashboard)
}

func (h Handler) dashboard(c *gin.Context) {
	result := h.service.Dashboard(c.Request.Context())
	c.JSON(http.StatusOK, result)
}
