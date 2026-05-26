package main

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	adminapp "github.com/openwhu/luotopia/server/internal/backend/admin/app"
	admintransport "github.com/openwhu/luotopia/server/internal/backend/admin/transport"
	authapp "github.com/openwhu/luotopia/server/internal/modules/account/auth/app"
	authinfra "github.com/openwhu/luotopia/server/internal/modules/account/auth/infra"
	authtransport "github.com/openwhu/luotopia/server/internal/modules/account/auth/transport"
	syncapp "github.com/openwhu/luotopia/server/internal/modules/agenda-sync/app"
	syncinfra "github.com/openwhu/luotopia/server/internal/modules/agenda-sync/infra"
	synctransport "github.com/openwhu/luotopia/server/internal/modules/agenda-sync/transport"
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
	registerSync(server, cfg, log)
	registerAdmin(server, cfg)

	if err := server.ListenAndServe(ctx); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Error("服务启动失败", slog.String("error", err.Error()))
		os.Exit(1)
	}
}

func registerSync(server *httpserver.Server, cfg config.Config, log *slog.Logger) {
	if cfg.Database.URL == "" {
		log.Error("缺少数据库连接配置", slog.String("env", "LUOTOPIA_DATABASE_URL"))
		os.Exit(1)
	}
	db, err := database.OpenPostgres(cfg.Database.URL)
	if err != nil {
		log.Error("数据库连接失败", slog.String("error", err.Error()))
		os.Exit(1)
	}
	sqlDB, err := db.DB()
	if err != nil {
		log.Error("数据库句柄获取失败", slog.String("error", err.Error()))
		os.Exit(1)
	}
	if err := sqlDB.PingContext(context.Background()); err != nil {
		log.Error("数据库连接失败", slog.String("error", err.Error()))
		os.Exit(1)
	}

	service := syncapp.NewService(syncinfra.NewGormRepository(db))
	synctransport.NewHandler(service, cfg.Auth.AccessTokenSecret).Register(server.ClientAPI())
}

func registerAuth(server *httpserver.Server, cfg config.Config, log *slog.Logger) {
	var users authapp.UserRepository
	if cfg.Database.URL != "" {
		db, err := database.OpenPostgres(cfg.Database.URL)
		if err != nil {
			log.Error("数据库连接失败", slog.String("error", err.Error()))
			os.Exit(1)
		}
		sqlDB, err := db.DB()
		if err != nil {
			log.Error("数据库句柄获取失败", slog.String("error", err.Error()))
			os.Exit(1)
		}
		if err := sqlDB.PingContext(context.Background()); err != nil {
			log.Error("数据库连接失败", slog.String("error", err.Error()))
			os.Exit(1)
		}
		users = authinfra.NewGormUserRepository(db)
	} else {
		log.Error("缺少数据库连接配置", slog.String("env", "LUOTOPIA_DATABASE_URL"))
		os.Exit(1)
	}

	var codes authapp.VerificationCodeStore
	if cfg.Redis.URL != "" {
		options, err := redis.ParseURL(cfg.Redis.URL)
		if err != nil {
			log.Error("Redis 配置无效", slog.String("error", err.Error()))
			os.Exit(1)
		}
		client := redis.NewClient(options)
		if err := client.Ping(context.Background()).Err(); err != nil {
			log.Error("Redis 连接失败", slog.String("error", err.Error()))
			os.Exit(1)
		}
		codes = authinfra.NewRedisVerificationCodeStore(client)
	} else {
		log.Error("缺少 Redis 连接配置", slog.String("env", "LUOTOPIA_REDIS_URL"))
		os.Exit(1)
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

func registerAdmin(server *httpserver.Server, cfg config.Config) {
	service := adminapp.NewService("0.1.0")
	admintransport.NewHandler(service, cfg.Auth.AccessTokenSecret).Register(server.AdminAPI())
}
