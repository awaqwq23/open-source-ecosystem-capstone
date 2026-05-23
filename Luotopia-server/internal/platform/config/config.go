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
	Auth        AuthConfig
	SMS         SMSConfig
	Email       EmailConfig
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

type AuthConfig struct {
	AccessTokenSecret string
	AccessTokenTTL    time.Duration
	RefreshTokenTTL   time.Duration
}

type SMSConfig struct {
	TencentSecretID   string
	TencentSecretKey  string
	TencentRegion     string
	TencentAppID      string
	TencentSignName   string
	TencentTemplateID string
}

type EmailConfig struct {
	SMTPHost     string
	SMTPPort     string
	SMTPUsername string
	SMTPPassword string
	SMTPFrom     string
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
		Auth: AuthConfig{
			AccessTokenSecret: env("LUOTOPIA_AUTH_ACCESS_TOKEN_SECRET", "development-only-change-me"),
			AccessTokenTTL:    durationEnv("LUOTOPIA_AUTH_ACCESS_TOKEN_TTL", 10*time.Minute),
			RefreshTokenTTL:   durationEnv("LUOTOPIA_AUTH_REFRESH_TOKEN_TTL", 30*24*time.Hour),
		},
		SMS: SMSConfig{
			TencentSecretID:   os.Getenv("LUOTOPIA_TENCENT_SMS_SECRET_ID"),
			TencentSecretKey:  os.Getenv("LUOTOPIA_TENCENT_SMS_SECRET_KEY"),
			TencentRegion:     env("LUOTOPIA_TENCENT_SMS_REGION", "ap-guangzhou"),
			TencentAppID:      os.Getenv("LUOTOPIA_TENCENT_SMS_APP_ID"),
			TencentSignName:   os.Getenv("LUOTOPIA_TENCENT_SMS_SIGN_NAME"),
			TencentTemplateID: os.Getenv("LUOTOPIA_TENCENT_SMS_TEMPLATE_ID"),
		},
		Email: EmailConfig{
			SMTPHost:     os.Getenv("LUOTOPIA_SMTP_HOST"),
			SMTPPort:     env("LUOTOPIA_SMTP_PORT", "587"),
			SMTPUsername: os.Getenv("LUOTOPIA_SMTP_USERNAME"),
			SMTPPassword: os.Getenv("LUOTOPIA_SMTP_PASSWORD"),
			SMTPFrom:     os.Getenv("LUOTOPIA_SMTP_FROM"),
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
