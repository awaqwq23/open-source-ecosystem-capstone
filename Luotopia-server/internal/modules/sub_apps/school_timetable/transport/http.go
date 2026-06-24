package transport

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

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
	_ = router
}

func (h Handler) RegisterAdmin(router gin.IRouter) {
	group := router.Group(contract.ClientBase)
	group.GET("/terms", h.listTerms)
	group.POST("/uploads", h.createUpload)
	group.GET("/uploads/:id", h.getUpload)
	group.PUT("/uploads/:id/chunks/:index", h.putUploadChunk)
	group.POST("/uploads/:id/complete", h.completeUpload)
	group.POST("/imports/validate", h.validateImport)
	group.POST("/imports/publish", h.publishImport)
	group.GET("/imports/jobs/:id", h.getImportJob)
}

func (h Handler) listTerms(c *gin.Context) {
	terms, err := h.service.ListTerms(c.Request.Context())
	if err != nil {
		writeError(c, http.StatusInternalServerError, "internal_error", "获取全校课表失败")
		return
	}
	c.JSON(http.StatusOK, gin.H{"items": terms})
}

func (h Handler) createUpload(c *gin.Context) {
	var req struct {
		FileName string `json:"file_name"`
		Size     int64  `json:"size"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请求参数无效")
		return
	}
	session, err := h.service.CreateUpload(req.FileName, req.Size)
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", err.Error())
		return
	}
	c.JSON(http.StatusCreated, session)
}

func (h Handler) getUpload(c *gin.Context) {
	session, err := h.service.GetUpload(c.Param("id"))
	if err != nil {
		writeUploadError(c, err)
		return
	}
	c.JSON(http.StatusOK, session)
}

func (h Handler) putUploadChunk(c *gin.Context) {
	index, err := strconv.Atoi(c.Param("index"))
	if err != nil {
		writeError(c, http.StatusBadRequest, "invalid_argument", "分片序号无效")
		return
	}
	session, err := h.service.SaveUploadChunk(c.Param("id"), index, c.Request.Body)
	if err != nil {
		writeUploadError(c, err)
		return
	}
	c.JSON(http.StatusOK, session)
}

func (h Handler) completeUpload(c *gin.Context) {
	session, err := h.service.CompleteUpload(c.Param("id"))
	if err != nil {
		writeUploadError(c, err)
		return
	}
	c.JSON(http.StatusOK, session)
}

func (h Handler) validateImport(c *gin.Context) {
	uploadID, ok := uploadIDFromJSON(c)
	if !ok {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请先完成分片上传")
		return
	}
	jobID, err := h.service.StartValidateUpload(uploadID)
	if err != nil {
		writeUploadError(c, err)
		return
	}
	c.JSON(http.StatusAccepted, gin.H{"job_id": jobID})
}

func (h Handler) publishImport(c *gin.Context) {
	uploadID, ok := uploadIDFromJSON(c)
	if !ok {
		writeError(c, http.StatusBadRequest, "invalid_argument", "请先完成分片上传")
		return
	}
	jobID, err := h.service.StartUploadImport(uploadID)
	if err != nil {
		writeUploadError(c, err)
		return
	}
	c.JSON(http.StatusAccepted, gin.H{"job_id": jobID})
}

func (h Handler) getImportJob(c *gin.Context) {
	job, err := h.service.GetImportJob(c.Request.Context(), c.Param("id"))
	if err != nil {
		writeError(c, http.StatusNotFound, "not_found", "任务不存在")
		return
	}
	c.JSON(http.StatusOK, job)
}

func uploadIDFromJSON(c *gin.Context) (string, bool) {
	var req struct {
		UploadID string `json:"upload_id"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		return "", false
	}
	uploadID := strings.TrimSpace(req.UploadID)
	if uploadID == "" {
		return "", false
	}
	return uploadID, true
}

func writeUploadError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, app.ErrNotFound):
		writeError(c, http.StatusNotFound, "not_found", "上传会话不存在")
	case errors.Is(err, app.ErrUploadIncomplete):
		writeError(c, http.StatusBadRequest, "upload_incomplete", "文件尚未上传完成")
	case errors.Is(err, app.ErrInvalidPackage):
		writeError(c, http.StatusBadRequest, "invalid_package", err.Error())
	default:
		writeError(c, http.StatusInternalServerError, "internal_error", err.Error())
	}
}

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
