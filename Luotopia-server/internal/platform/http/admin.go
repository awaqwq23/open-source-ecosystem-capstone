package httpserver

import (
	"github.com/gin-gonic/gin"
)

// AdminAuthMiddleware 验证管理员身份的中间件。
// 目前：基于 JWT 用户认证，管理员权限判定留待后续接入统一的角色系统。
// TODO: 接入管理员角色/权限系统后，在此处添加角色校验逻辑。
func AdminAuthMiddleware(secret string) gin.HandlerFunc {
	auth := AuthMiddleware(secret)
	return func(c *gin.Context) {
		auth(c)
		if c.IsAborted() {
			return
		}
		c.Next()
	}
}
