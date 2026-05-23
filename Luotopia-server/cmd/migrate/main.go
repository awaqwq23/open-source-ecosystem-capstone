package main

import (
	"log/slog"
	"os"

	"github.com/openwhu/luotopia/server/internal/platform/config"
	"github.com/openwhu/luotopia/server/internal/platform/logger"
)

func main() {
	cfg := config.Load()
	log := logger.New(cfg.Environment)

	log.Info("迁移入口已就绪", slog.String("database_url_configured", boolText(cfg.Database.URL != "")))
	os.Exit(0)
}

func boolText(value bool) string {
	if value {
		return "true"
	}
	return "false"
}
