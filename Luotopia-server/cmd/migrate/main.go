package main

import (
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"sort"

	"github.com/openwhu/luotopia/server/internal/platform/config"
	"github.com/openwhu/luotopia/server/internal/platform/database"
	"github.com/openwhu/luotopia/server/internal/platform/logger"
)

func main() {
	cfg := config.Load()
	log := logger.New(cfg.Environment)

	if cfg.Database.URL == "" {
		log.Error("缺少数据库连接配置", slog.String("env", "LUOTOPIA_DATABASE_URL"))
		os.Exit(1)
	}

	db, err := database.OpenPostgres(cfg.Database.URL)
	if err != nil {
		log.Error("数据库连接失败", slog.String("error", err.Error()))
		os.Exit(1)
	}

	files, err := filepath.Glob(filepath.Join("internal", "database", "migrations", "*", "*.sql"))
	if err != nil {
		log.Error("读取迁移文件失败", slog.String("error", err.Error()))
		os.Exit(1)
	}
	sort.Strings(files)
	for _, file := range files {
		sql, err := os.ReadFile(file)
		if err != nil {
			log.Error("读取迁移文件失败", slog.String("file", file), slog.String("error", err.Error()))
			os.Exit(1)
		}
		if err := db.Exec(string(sql)).Error; err != nil {
			log.Error("执行迁移失败", slog.String("file", file), slog.String("error", err.Error()))
			os.Exit(1)
		}
		fmt.Println("applied", file)
	}
	os.Exit(0)
}
