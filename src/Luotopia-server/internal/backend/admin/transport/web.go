package transport

import (
	"embed"
	"io/fs"
	"net/http"
	"path/filepath"
	"strings"

	"github.com/gin-gonic/gin"
)

//go:embed web/*
var adminWebFS embed.FS

type WebHandler struct{}

func NewWebHandler() WebHandler {
	return WebHandler{}
}

func (h WebHandler) Register(router gin.IRouter) {
	router.GET("", h.index)
	router.GET("/", h.index)
	router.GET("/assets/:file", h.asset)
}

func (h WebHandler) index(c *gin.Context) {
	data, err := adminWebFS.ReadFile("web/index.html")
	if err != nil {
		c.String(http.StatusInternalServerError, "admin page unavailable")
		return
	}
	c.Data(http.StatusOK, "text/html; charset=utf-8", data)
}

func (h WebHandler) asset(c *gin.Context) {
	name := filepath.Base(strings.TrimSpace(c.Param("file")))
	if name == "." || name == "" {
		c.Status(http.StatusNotFound)
		return
	}
	data, err := fs.ReadFile(adminWebFS, "web/assets/"+name)
	if err != nil {
		c.Status(http.StatusNotFound)
		return
	}
	c.Data(http.StatusOK, contentType(name), data)
}

func contentType(name string) string {
	switch {
	case strings.HasSuffix(name, ".css"):
		return "text/css; charset=utf-8"
	case strings.HasSuffix(name, ".js"):
		return "application/javascript; charset=utf-8"
	default:
		return "application/octet-stream"
	}
}
