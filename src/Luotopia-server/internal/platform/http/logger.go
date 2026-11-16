package httpserver

import (
	"log/slog"
	"time"

	"github.com/gin-gonic/gin"
)

type LoggerMiddleware struct {
	logger *slog.Logger
}

func NewLoggerMiddleware(logger *slog.Logger) LoggerMiddleware {
	return LoggerMiddleware{logger: logger}
}

func (m LoggerMiddleware) Handler() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		c.Next()

		status := c.Writer.Status()
		latency := time.Since(start)
		args := []slog.Attr{
			slog.Int("status", status),
			slog.String("method", c.Request.Method),
			slog.String("path", path),
			slog.Duration("latency", latency),
		}
		if query != "" {
			args = append(args, slog.String("query", query))
		}
		if userID, ok := c.Get("user_id"); ok {
			args = append(args, slog.String("user_id", userID.(string)))
		}

		level := slog.LevelInfo
		if status >= 500 {
			level = slog.LevelError
		} else if status >= 400 {
			level = slog.LevelWarn
		}
		m.logger.LogAttrs(c.Request.Context(), level, "请求", args...)
	}
}
