package httpserver

import (
	"context"
	"log/slog"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/openwhu/luotopia/server/internal/platform/config"
)

type Server struct {
	config config.HTTPConfig
	logger *slog.Logger
	engine *gin.Engine
}

func New(cfg config.HTTPConfig, logger *slog.Logger) *Server {
	if logger == nil {
		logger = slog.Default()
	}

	gin.SetMode(gin.ReleaseMode)
	engine := gin.New()
	engine.Use(gin.Recovery())

	return &Server{
		config: cfg,
		logger: logger,
		engine: engine,
	}
}

func (s *Server) RegisterHealth() {
	s.engine.GET("/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})
}

func (s *Server) RegisterRouteGroups() {
	s.engine.GET("/api/v1/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"group": "client", "status": "ok"})
	})
	s.engine.GET("/admin/api/v1/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"group": "admin", "status": "ok"})
	})
}

func (s *Server) ClientAPI() gin.IRouter {
	return s.engine.Group("/api/v1")
}

func (s *Server) ListenAndServe(ctx context.Context) error {
	server := &http.Server{
		Addr:         s.config.Address,
		Handler:      s.engine,
		ReadTimeout:  s.config.ReadTimeout,
		WriteTimeout: s.config.WriteTimeout,
	}

	errCh := make(chan error, 1)
	go func() {
		s.logger.Info("HTTP 服务启动", slog.String("address", s.config.Address))
		errCh <- server.ListenAndServe()
	}()

	select {
	case <-ctx.Done():
		timeout := s.config.ShutdownTimeout
		if timeout <= 0 {
			timeout = 10 * time.Second
		}
		shutdownCtx, cancel := context.WithTimeout(context.Background(), timeout)
		defer cancel()
		return server.Shutdown(shutdownCtx)
	case err := <-errCh:
		return err
	}
}
