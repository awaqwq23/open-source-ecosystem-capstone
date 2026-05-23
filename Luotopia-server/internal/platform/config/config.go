package config

import (
	"os"
	"strconv"
	"time"
)

type Config struct {
	Environment string
	HTTP        HTTPConfig
	Database    DatabaseConfig
	Redis       RedisConfig
	Storage     StorageConfig
}

type HTTPConfig struct {
	Address         string
	ReadTimeout     time.Duration
	WriteTimeout    time.Duration
	ShutdownTimeout time.Duration
}

type DatabaseConfig struct {
	URL string
}

type RedisConfig struct {
	URL string
}

type StorageConfig struct {
	Bucket string
	Region string
}

func Load() Config {
	return Config{
		Environment: env("LUOTOPIA_ENV", "development"),
		HTTP: HTTPConfig{
			Address:         env("LUOTOPIA_HTTP_ADDR", ":8080"),
			ReadTimeout:     durationEnv("LUOTOPIA_HTTP_READ_TIMEOUT", 5*time.Second),
			WriteTimeout:    durationEnv("LUOTOPIA_HTTP_WRITE_TIMEOUT", 10*time.Second),
			ShutdownTimeout: durationEnv("LUOTOPIA_HTTP_SHUTDOWN_TIMEOUT", 10*time.Second),
		},
		Database: DatabaseConfig{URL: os.Getenv("LUOTOPIA_DATABASE_URL")},
		Redis:    RedisConfig{URL: os.Getenv("LUOTOPIA_REDIS_URL")},
		Storage: StorageConfig{
			Bucket: os.Getenv("LUOTOPIA_STORAGE_BUCKET"),
			Region: os.Getenv("LUOTOPIA_STORAGE_REGION"),
		},
	}
}

func env(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}

func durationEnv(key string, fallback time.Duration) time.Duration {
	raw := os.Getenv(key)
	if raw == "" {
		return fallback
	}

	seconds, err := strconv.Atoi(raw)
	if err != nil || seconds <= 0 {
		return fallback
	}
	return time.Duration(seconds) * time.Second
}
