package transport

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/domain"
)

type Handler struct {
	service *app.Service
}

func NewHandler(service *app.Service, tokenSecret string) Handler {
	_ = tokenSecret
	return Handler{service: service}
}

func (h Handler) Register(router gin.IRouter) {
	notif := router.Group("/notifications")
	notif.GET("", h.listPublished)
	notif.GET("/latest", h.latest)
	notif.GET("/:id", h.getByID)
}

func (h Handler) listPublished(c *gin.Context) {
	offset, _ := parseIntQuery(c, "offset", 0)
	limit, _ := parseIntQuery(c, "limit", 20)
	items, total, err := h.service.List(c.Request.Context(), domain.StatusPublished, offset, limit)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": gin.H{"code": "internal_error", "message": "获取通知列表失败"}})
		return
	}
	type item struct {
		ID        string `json:"id"`
		Title     string `json:"title"`
		Priority  string `json:"priority"`
		CreatedAt string `json:"created_at"`
	}
	result := make([]item, len(items))
	for i, n := range items {
		result[i] = item{ID: n.ID, Title: n.Title, Priority: string(n.Priority), CreatedAt: n.CreatedAt.Format("2006-01-02T15:04:05Z07:00")}
	}
	c.JSON(http.StatusOK, gin.H{"total": total, "items": result})
}

func (h Handler) latest(c *gin.Context) {
	info := h.service.GetLatestInfo(c.Request.Context(), strings.TrimSpace(c.Query("latest_id")))
	if !info.HasNew {
		c.JSON(http.StatusOK, gin.H{"latest_id": info.LatestID, "has_new": false, "count": info.Count})
		return
	}
	n, err := h.service.GetByID(c.Request.Context(), info.LatestID)
	if err != nil {
		c.JSON(http.StatusOK, gin.H{"latest_id": info.LatestID, "has_new": true, "count": info.Count})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"latest_id":  n.ID,
		"has_new":    true,
		"count":      info.Count,
		"title":      n.Title,
		"content":    n.Content,
		"priority":   n.Priority,
		"created_at": n.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
	})
}

func (h Handler) getByID(c *gin.Context) {
	id := c.Param("id")
	n, err := h.service.GetByID(c.Request.Context(), id)
	if err != nil {
		if err == app.ErrNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": gin.H{"code": "not_found", "message": "通知不存在"}})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": gin.H{"code": "internal_error", "message": "获取通知失败"}})
		return
	}
	c.JSON(http.StatusOK, gin.H{
		"id":         n.ID,
		"title":      n.Title,
		"content":    n.Content,
		"priority":   n.Priority,
		"status":     n.Status,
		"created_at": n.CreatedAt.Format("2006-01-02T15:04:05Z07:00"),
		"updated_at": n.UpdatedAt.Format("2006-01-02T15:04:05Z07:00"),
	})
}

func parseIntQuery(c *gin.Context, key string, fallback int) (int, error) {
	raw := strings.TrimSpace(c.Query(key))
	if raw == "" {
		return fallback, nil
	}
	return strconv.Atoi(raw)
}
