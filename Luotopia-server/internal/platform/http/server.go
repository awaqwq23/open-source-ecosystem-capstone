package httpserver

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"time"

	"github.com/openwhu/luotopia/server/internal/platform/config"
)

type Server struct {
	config config.HTTPConfig
	logger *slog.Logger
	mux    *http.ServeMux
}

func New(cfg config.HTTPConfig, logger *slog.Logger) *Server {
	if logger == nil {
		logger = slog.Default()
	}

	return &Server{
		config: cfg,
		logger: logger,
		mux:    http.NewServeMux(),
	}
}

func (s *Server) RegisterHealth() {
	s.mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})
}

func (s *Server) RegisterRouteGroups() {
	s.mux.HandleFunc("GET /api/v1/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"group": "client", "status": "ok"})
	})
	s.mux.HandleFunc("GET /admin/api/v1/healthz", func(w http.ResponseWriter, r *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"group": "admin", "status": "ok"})
	})
}

func (s *Server) ListenAndServe(ctx context.Context) error {
	server := &http.Server{
		Addr:         s.config.Address,
		Handler:      s.mux,
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

func writeJSON(w http.ResponseWriter, statusCode int, payload any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(statusCode)
	_ = json.NewEncoder(w).Encode(payload)
}
