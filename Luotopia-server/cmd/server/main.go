package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	authapp "github.com/openwhu/luotopia/server/internal/modules/auth/app"
	authinfra "github.com/openwhu/luotopia/server/internal/modules/auth/infra"
	authtransport "github.com/openwhu/luotopia/server/internal/modules/auth/transport"
	"github.com/openwhu/luotopia/server/internal/platform/config"
	"github.com/openwhu/luotopia/server/internal/platform/database"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
	"github.com/openwhu/luotopia/server/internal/platform/logger"
	"github.com/redis/go-redis/v9"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	cfg := config.Load()
	log := logger.New(cfg.Environment)

	server := httpserver.New(cfg.HTTP, log)
	server.RegisterHealth()
	server.RegisterRouteGroups()
	registerAuth(server, cfg, log)

	if err := server.ListenAndServe(ctx); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Error("服务启动失败", slog.String("error", err.Error()))
		os.Exit(1)
	}
}

func registerAuth(server *httpserver.Server, cfg config.Config, log *slog.Logger) {
	var users authapp.UserRepository
	if cfg.Database.URL != "" {
		db, err := database.OpenPostgres(cfg.Database.URL)
		if err != nil {
			log.Error("数据库连接失败，账号模块退回内存仓储", slog.String("error", err.Error()))
			users = authapp.NewMemoryUserRepository()
		} else {
			users = authinfra.NewGormUserRepository(db)
		}
	} else {
		users = authapp.NewMemoryUserRepository()
	}

	var codes authapp.VerificationCodeStore
	if cfg.Redis.URL != "" {
		options, err := redis.ParseURL(cfg.Redis.URL)
		if err != nil {
			log.Error("Redis 配置无效，验证码退回内存存储", slog.String("error", err.Error()))
			codes = authapp.NewMemoryVerificationCodeStore()
		} else {
			codes = authinfra.NewRedisVerificationCodeStore(redis.NewClient(options))
		}
	} else {
		codes = authapp.NewMemoryVerificationCodeStore()
	}

	service := authapp.NewService(authapp.ServiceConfig{
		Users:           users,
		Codes:           codes,
		Sender:          authinfra.CompositeVerificationSender{SMS: authinfra.NewTencentSMSSender(cfg.SMS), Email: authinfra.NewSMTPSender(cfg.Email), Logger: log},
		Hasher:          authinfra.Argon2idPasswordHasher{},
		Tokens:          authinfra.NewJWTIssuer(cfg.Auth.AccessTokenSecret, cfg.Auth.AccessTokenTTL),
		SessionDuration: cfg.Auth.RefreshTokenTTL,
	})
	authtransport.NewHandler(service, cfg.Auth.AccessTokenSecret).Register(server.ClientAPI())
}
