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
	admininfra "github.com/openwhu/luotopia/server/internal/backend/admin/infra"
	admintransport "github.com/openwhu/luotopia/server/internal/backend/admin/transport"
	authapp "github.com/openwhu/luotopia/server/internal/modules/account/auth/app"
	authinfra "github.com/openwhu/luotopia/server/internal/modules/account/auth/infra"
	authtransport "github.com/openwhu/luotopia/server/internal/modules/account/auth/transport"
	syncapp "github.com/openwhu/luotopia/server/internal/modules/agenda-sync/app"
	syncinfra "github.com/openwhu/luotopia/server/internal/modules/agenda-sync/infra"
	synctransport "github.com/openwhu/luotopia/server/internal/modules/agenda-sync/transport"
	hotapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/app"
	hotinfra "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/infra"
	hottransport "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/hot_update/transport"
	notiapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/app"
	notiinfra "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/infra"
	notitransport "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/transport"
	pullapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/app"
	pulltransport "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/pull/transport"
	weatherapp "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/app"
	weatherinfra "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/infra"
	weathercache "github.com/openwhu/luotopia/server/internal/platform/cache"
	"github.com/openwhu/luotopia/server/internal/platform/config"
	"github.com/openwhu/luotopia/server/internal/platform/database"
	httpserver "github.com/openwhu/luotopia/server/internal/platform/http"
	"github.com/openwhu/luotopia/server/internal/platform/logger"
	"github.com/openwhu/luotopia/server/internal/platform/scheduler"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	cfg := config.Load()
	log := logger.New(cfg.Environment)

	server := httpserver.New(cfg.HTTP, log)
	server.RegisterHealth()
	server.RegisterRouteGroups()

	db := openDB(cfg, log)
	rdb := openRedis(cfg, log)

	registerAuth(server, cfg, log, db, rdb)
	registerSync(server, cfg, db)
	registerPull(server, cfg, db, rdb)
	registerAdmin(server, cfg, db)
	registerNotificationAPI(server, cfg, db)
	registerHotUpdateAPI(server, cfg, db)
	registerWeatherRefresh(ctx, cfg, rdb, log)

	// Graceful shutdown
	sigCtx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	<-sigCtx.Done()
	log.Info("正在关闭服务...")
	cancel()

	if err := server.ListenAndServe(ctx); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Error("服务启动失败", slog.String("error", err.Error()))
		os.Exit(1)
	}
}

func openDB(cfg config.Config, log *slog.Logger) *gorm.DB {
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
		log.Error("数据库连接不可用", slog.String("error", err.Error()))
		os.Exit(1)
	}
	return db
}

func openRedis(cfg config.Config, log *slog.Logger) *redis.Client {
	if cfg.Redis.URL == "" {
		return nil
	}
	options, err := redis.ParseURL(cfg.Redis.URL)
	if err != nil {
		log.Warn("Redis 配置无效，缓存功能不可用", slog.String("error", err.Error()))
		return nil
	}
	client := redis.NewClient(options)
	if err := client.Ping(context.Background()).Err(); err != nil {
		log.Warn("Redis 连接失败，缓存功能不可用", slog.String("error", err.Error()))
		return nil
	}
	return client
}

func registerSync(server *httpserver.Server, cfg config.Config, db *gorm.DB) {
	service := syncapp.NewService(syncinfra.NewGormRepository(db))
	synctransport.NewHandler(service, cfg.Auth.AccessTokenSecret).Register(server.ClientAPI())
}

func registerAuth(server *httpserver.Server, cfg config.Config, log *slog.Logger, db *gorm.DB, rdb *redis.Client) {
	users := authinfra.NewGormUserRepository(db)

	var codes authapp.VerificationCodeStore
	if rdb != nil {
		codes = authinfra.NewRedisVerificationCodeStore(rdb)
	} else {
		log.Error("缺少 Redis 连接，验证码功能不可用")
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

func registerAdmin(server *httpserver.Server, cfg config.Config, db *gorm.DB) {
	if db == nil {
		return
	}
	notiRepo := notiinfra.NewGormRepository(db)
	notiSvc := notiapp.NewService(notiRepo)

	hotRepo := hotinfra.NewGormRepository(db)
	hotSvc := hotapp.NewService(hotRepo)

	adminRepo := admininfra.NewGormRepository(db)
	service := adminapp.NewService("0.1.0", db, adminRepo, notiSvc, hotSvc)
	admintransport.NewHandler(service, cfg.Auth.AccessTokenSecret, cfg.Admin.UserIDs).Register(server.AdminAPI())
}

func registerPull(server *httpserver.Server, cfg config.Config, db *gorm.DB, rdb *redis.Client) {
	if db == nil {
		return
	}

	// Weather
	var weatherSvc *weatherapp.Service
	if rdb != nil && cfg.Weather.APIKey != "" {
		apiClient := weatherinfra.NewQWeatherClient(cfg.Weather.APIKey, cfg.Weather.Location)
		weatherSvc = weatherapp.NewService(weathercache.NewRedisStore(rdb), apiClient, cfg.Weather.CacheTTL)
	}

	// Notification
	notiSvc := notiapp.NewService(notiinfra.NewGormRepository(db))

	// Hot update
	hotSvc := hotapp.NewService(hotinfra.NewGormRepository(db))

	// Sync checker (adapter from syncinfra)
	syncRepo := syncinfra.NewGormRepository(db)
	syncChecker := syncCheckAdapter{repo: syncRepo}

	// Pull orchestrator
	svc := pullapp.NewService(weatherSvc, notiSvc, hotSvc, syncChecker)
	authMW := httpserver.AuthMiddleware(cfg.Auth.AccessTokenSecret)
	pulltransport.NewHandler(svc, authMW).Register(server.ClientAPI())
}

func registerNotificationAPI(server *httpserver.Server, cfg config.Config, db *gorm.DB) {
	if db == nil {
		return
	}
	svc := notiapp.NewService(notiinfra.NewGormRepository(db))
	notitransport.NewHandler(svc, cfg.Auth.AccessTokenSecret).Register(server.ClientAPI())
}

func registerHotUpdateAPI(server *httpserver.Server, cfg config.Config, db *gorm.DB) {
	if db == nil {
		return
	}
	svc := hotapp.NewService(hotinfra.NewGormRepository(db))
	hottransport.NewHandler(svc, cfg.Auth.AccessTokenSecret, "scripts").Register(server.ClientAPI())
}

func registerWeatherRefresh(ctx context.Context, cfg config.Config, rdb *redis.Client, log *slog.Logger) {
	if rdb == nil || cfg.Weather.APIKey == "" {
		log.Warn("天气功能未启用：缺少 Redis 或 API Key")
		return
	}
	apiClient := weatherinfra.NewQWeatherClient(cfg.Weather.APIKey, cfg.Weather.Location)
	weatherSvc := weatherapp.NewService(weathercache.NewRedisStore(rdb), apiClient, cfg.Weather.CacheTTL)

	// Initial fetch
	go func() {
		if err := weatherSvc.FetchAndCache(ctx); err != nil {
			log.Warn("天气首次刷新失败", slog.String("error", err.Error()))
		}
	}()

	// Periodic refresh
	sched := scheduler.NewTickerScheduler()
	sched.RegisterWithInterval(weatherinfra.NewRefreshJob(weatherSvc), cfg.Weather.CacheTTL)
	go func() {
		if err := sched.Start(ctx); err != nil {
			log.Error("天气调度器异常", slog.String("error", err.Error()))
		}
	}()
	log.Info("天气定时刷新已启动", slog.Duration("interval", cfg.Weather.CacheTTL))
}

// syncCheckAdapter adapts syncinfra.GormRepository to pullapp.SyncChecker
type syncCheckAdapter struct {
	repo *syncinfra.GormRepository
}

func (a syncCheckAdapter) IsSyncEnabledForUser(ctx context.Context, userID string) (bool, error) {
	return a.repo.IsSyncAllowed(ctx, userID)
}
