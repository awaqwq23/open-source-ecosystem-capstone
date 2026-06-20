package transport

import (
	"errors"
	"net/http"
	"os"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/app"
	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/contract"
)

type Handler struct {
	service *app.Service
}

func NewHandler(service *app.Service) Handler {
	return Handler{service: service}
}

func (h Handler) RegisterClient(router gin.IRouter) {
	group := router.Group(contract.ClientBase)
	group.GET(contract.SnapshotRoute, h.downloadSnapshot)
}

func (h Handler) RegisterAdmin(router gin.IRouter) {
	group := router.Group(contract.ClientBase)
	group.GET("/terms", h.listTerms)
	group.GET("/terms/:termKey/releases", h.listReleases)
	group.POST("/imports/validate", h.validateImport)
	group.POST("/imports/publish", h.publishImport)
	group.POST("/terms/:termKey/releases/:version/activate", h.activateRelease)
}

func (h Handler) listTerms(c *gin.Context) {
	terms, err := h.service.ListActiveTerms(c.Request.Context())
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取全校课表失败")
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": terms})
}

func (h Handler) listReleases(c *gin.Context) {
	items, err := h.service.ListReleases(c.Request.Context(), c.Param("termKey"))
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取发布版本失败")
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": items})
}

func (h Handler) validateImport(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请选择数据包文件")
		return
	}
	opened, err := file.Open()
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "无法读取上传文件")
		return
	}
	defer opened.Close()
	result, err := h.service.ValidatePackage(c.Request.Context(), opened)
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_package", err.Error())
		return
	}
	c.JSON(http.StatusOK, result)
}

func (h Handler) publishImport(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请选择数据包文件")
		return
	}
	opened, err := file.Open()
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "无法读取上传文件")
		return
	}
	defer opened.Close()
	result, err := h.service.ImportAndPublish(c.Request.Context(), opened)
	if err != nil {
		writeError(c, http.StatusBadRequest, "import_failed", err.Error())
		return
	}
	c.JSON(http.StatusCreated, result)
}

func (h Handler) activateRelease(c *gin.Context) {
	version, err := strconv.Atoi(c.Param("version"))
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "版本号无效")
		return
	}
	if err := h.service.ActivateRelease(c.Request.Context(), c.Param("termKey"), version); err != nil {
		if errors.Is(err, app.ErrNotFound) {
			writeError(c, http.StatusNotFound, "not_found", "发布版本不存在")
			return
		}
		writeError(c, http.StatusInternalServerError, "internal_error", "切换发布版本失败")
		return
	}
	c.JSON(http.StatusOK, gin.H{"activated": true})
}

func (h Handler) downloadSnapshot(c *gin.Context) {
	version, err := strconv.Atoi(c.Param("version"))
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "版本号无效")
		return
	}
	path, release, err := h.service.SnapshotPath(c.Request.Context(), c.Param("termKey"), version)
	if err != nil {
		if errors.Is(err, app.ErrNotFound) {
			writeError(c, http.StatusNotFound, "not_found", "课表快照不存在")
			return
		}
		writeError(c, http.StatusInternalServerError, "internal_error", "查询课表快照失败")
		return
	}
	if _, err := os.Stat(path); err != nil {
		writeError(c, http.StatusNotFound, "not_found", "课表快照文件不存在")
		return
	}
	c.Header("X-Checksum", release.Checksum)
	c.Header("Content-Type", "application/gzip")
	c.FileAttachment(path, release.FileKey)
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
