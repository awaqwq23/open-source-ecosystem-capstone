package transport

import (
	"errors"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/app"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
)

type Handler struct {
	service        *app.Service
	authMiddleware gin.HandlerFunc
	storageDir     string
}

func NewHandler(service *app.Service, tokenSecret string, storageDir string) Handler {
	return Handler{
		service:        service,
		authMiddleware: httpserver.AuthMiddleware(tokenSecret),
		storageDir:     storageDir,
	}
}

func (h Handler) Register(router gin.IRouter) {
	hu := router.Group("/hot-update/scripts")
	hu.Use(h.authMiddleware)
	hu.GET("", h.listScripts)
	hu.GET("/:name/content", h.downloadContent)
}

func (h Handler) listScripts(c *gin.Context) {
	scripts, err := h.service.ListScripts(c.Request.Context(), "")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": gin.H{"code": "internal_error", "message": "获取脚本列表失败"}})
		return
	}
	type item struct {
		Name        string `json:"name"`
		Description string `json:"description"`
		Channel     string `json:"channel"`
		Enabled     bool   `json:"enabled"`
		Version     int    `json:"version"`
		Checksum    string `json:"checksum"`
	}
	items := make([]item, 0, len(scripts))
	for _, sc := range scripts {
		v := item{Name: sc.Name, Description: sc.Description, Channel: string(sc.Channel), Enabled: sc.Enabled}
		if release, err := h.service.GetCurrentVersion(c.Request.Context(), sc.ID); err == nil {
			v.Version = release.Version
			v.Checksum = release.Checksum
		}
		items = append(items, v)
	}
	c.JSON(http.StatusOK, gin.H{"items": items})
}

func (h Handler) downloadContent(c *gin.Context) {
	name := c.Param("name")
	scripts, err := h.service.ListScripts(c.Request.Context(), "")
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": gin.H{"code": "internal_error", "message": "查询脚本失败"}})
		return
	}
	var scriptID string
	var found bool
	for _, sc := range scripts {
		if sc.Name == name && sc.Enabled {
			scriptID = sc.ID
			found = true
			break
		}
	}
	if !found {
		c.JSON(http.StatusNotFound, gin.H{"error": gin.H{"code": "not_found", "message": "脚本不存在或未启用"}})
		return
	}

	release, err := h.service.GetCurrentVersion(c.Request.Context(), scriptID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": gin.H{"code": "not_found", "message": "脚本暂无发布版本"}})
		return
	}

	// Read script content from storage
	filePath := filepath.Join(h.storageDir, release.FileKey)
	data, err := os.ReadFile(filePath)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			c.JSON(http.StatusNotFound, gin.H{"error": gin.H{"code": "not_found", "message": "脚本文件未找到"}})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": gin.H{"code": "internal_error", "message": "读取脚本文件失败"}})
		return
	}

	c.Header("X-Script-Version", itoa(release.Version))
	c.Header("X-Checksum", release.Checksum)
	c.Data(http.StatusOK, "application/javascript; charset=utf-8", data)
}

func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	var buf [12]byte
	i := len(buf)
	for n > 0 {
		i--
		buf[i] = byte('0' + n%10)
		n /= 10
	}
	return string(buf[i:])
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}

var _ = writeError
var _ = io.Discard
