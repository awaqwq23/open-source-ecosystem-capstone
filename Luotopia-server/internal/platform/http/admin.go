package httpserver

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func AdminAuthMiddleware(secret string, adminUserIDs []string) gin.HandlerFunc {
	adminSet := make(map[string]struct{}, len(adminUserIDs))
	for _, id := range adminUserIDs {
		adminSet[id] = struct{}{}
	}

	auth := AuthMiddleware(secret)
	return func(c *gin.Context) {
		auth(c)
		if c.IsAborted() {
			return
		}

		userID, _ := c.Get("user_id")
		uid, ok := userID.(string)
		if !ok {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": gin.H{"code": "forbidden", "message": "需要管理员权限"},
			})
			return
		}

		if _, isAdmin := adminSet[uid]; !isAdmin {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
				"error": gin.H{"code": "forbidden", "message": "需要管理员权限"},
			})
			return
		}

		c.Next()
	}
}
