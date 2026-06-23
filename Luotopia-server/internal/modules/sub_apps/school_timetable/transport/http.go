package transport

import (
	"net/http"

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
	jobID, err := h.service.StartImport(opened)
	if err != nil {
		writeError(c, http.StatusBadRequest, "import_failed", err.Error())
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

func writeError(c *gin.Context, status int, code string, message string) {
	c.JSON(status, gin.H{"error": gin.H{"code": code, "message": message}})
}
