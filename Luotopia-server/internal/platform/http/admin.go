package httpserver

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func AdminAuthMiddleware(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		token := strings.TrimPrefix(header, "Bearer ")
		if token == header || token == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": gin.H{"code": "unauthenticated", "message": "请先登录后台"},
			})
			return
		}

		adminID, err := ParseAdminAccessToken(secret, token)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"error": gin.H{"code": "unauthenticated", "message": "后台登录凭证无效"},
			})
			return
		}
		c.Set("admin_id", adminID)
		c.Next()
	}
}

func ParseAdminAccessToken(secret string, raw string) (string, error) {
	token, err := jwt.Parse(raw, func(token *jwt.Token) (any, error) {
		return []byte(secret), nil
	}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))
	if err != nil {
		return "", err
	}
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return "", jwt.ErrTokenInvalidClaims
	}
	tokenType, _ := claims["typ"].(string)
	adminID, _ := claims["sub"].(string)
	if tokenType != "admin" || adminID == "" {
		return "", jwt.ErrTokenInvalidClaims
	}
	return adminID, nil
}
