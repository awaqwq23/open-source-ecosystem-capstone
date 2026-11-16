package httpserver

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func AdminCheckMiddleware(isAdmin func(c *gin.Context) bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		if !isAdmin(c) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": gin.H{"code": "forbidden", "message": "无后台访问权限"},
			})
			return
		}
		c.Next()
	}
}
