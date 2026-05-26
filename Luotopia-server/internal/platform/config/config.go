package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/joho/godotenv"
)

type Config struct {
	Environment string
	HTTP        HTTPConfig
	Database    DatabaseConfig
	Redis       RedisConfig
	Storage     StorageConfig
	Auth        AuthConfig
	Admin       AdminConfig
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

type AdminConfig struct {
	UserIDs []string
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
	loadDotEnv()

	return Config{
		Environment: requiredEnv("LUOTOPIA_ENV"),
		HTTP: HTTPConfig{
			Address:         requiredEnv("LUOTOPIA_HTTP_ADDR"),
			ReadTimeout:     requiredDurationEnv("LUOTOPIA_HTTP_READ_TIMEOUT"),
			WriteTimeout:    requiredDurationEnv("LUOTOPIA_HTTP_WRITE_TIMEOUT"),
			ShutdownTimeout: requiredDurationEnv("LUOTOPIA_HTTP_SHUTDOWN_TIMEOUT"),
		},
		Database: DatabaseConfig{URL: declaredEnv("LUOTOPIA_DATABASE_URL")},
		Redis:    RedisConfig{URL: declaredEnv("LUOTOPIA_REDIS_URL")},
		Storage: StorageConfig{
			Bucket: declaredEnv("LUOTOPIA_STORAGE_BUCKET"),
			Region: declaredEnv("LUOTOPIA_STORAGE_REGION"),
		},
		Auth: AuthConfig{
			AccessTokenSecret: requiredEnv("LUOTOPIA_AUTH_ACCESS_TOKEN_SECRET"),
			AccessTokenTTL:    requiredDurationEnv("LUOTOPIA_AUTH_ACCESS_TOKEN_TTL"),
			RefreshTokenTTL:   requiredDurationEnv("LUOTOPIA_AUTH_REFRESH_TOKEN_TTL"),
		},
		Admin: AdminConfig{UserIDs: parseCommaList(declaredEnv("LUOTOPIA_ADMIN_USER_IDS"))},
		SMS:   SMSConfig{
			TencentSecretID:   declaredEnv("LUOTOPIA_TENCENT_SMS_SECRET_ID"),
			TencentSecretKey:  declaredEnv("LUOTOPIA_TENCENT_SMS_SECRET_KEY"),
			TencentRegion:     requiredEnv("LUOTOPIA_TENCENT_SMS_REGION"),
			TencentAppID:      declaredEnv("LUOTOPIA_TENCENT_SMS_APP_ID"),
			TencentSignName:   declaredEnv("LUOTOPIA_TENCENT_SMS_SIGN_NAME"),
			TencentTemplateID: declaredEnv("LUOTOPIA_TENCENT_SMS_TEMPLATE_ID"),
		},
		Email: EmailConfig{
			SMTPHost:     declaredEnv("LUOTOPIA_SMTP_HOST"),
			SMTPPort:     requiredEnv("LUOTOPIA_SMTP_PORT"),
			SMTPUsername: declaredEnv("LUOTOPIA_SMTP_USERNAME"),
			SMTPPassword: declaredEnv("LUOTOPIA_SMTP_PASSWORD"),
			SMTPFrom:     declaredEnv("LUOTOPIA_SMTP_FROM"),
		},
	}
}

func loadDotEnv() {
	configErr := godotenv.Load("configs/.env")
	if configErr == nil {
		return
	}
	rootErr := godotenv.Load(".env")
	if rootErr == nil {
		return
	}
	panic(fmt.Sprintf("无法加载 .env 配置：configs/.env: %v; .env: %v", configErr, rootErr))
}

func declaredEnv(key string) string {
	value, ok := os.LookupEnv(key)
	if !ok {
		panic(fmt.Sprintf("缺少环境变量：%s", key))
	}
	return value
}

func requiredEnv(key string) string {
	value := declaredEnv(key)
	if value == "" {
		panic(fmt.Sprintf("环境变量 %s 不能为空", key))
	}
	return value
}

func parseCommaList(raw string) []string {
	if raw == "" {
		return nil
	}
	parts := strings.Split(raw, ",")
	result := make([]string, 0, len(parts))
	for _, p := range parts {
		if trimmed := strings.TrimSpace(p); trimmed != "" {
			result = append(result, trimmed)
		}
	}
	return result
}

func requiredDurationEnv(key string) time.Duration {
	raw := requiredEnv(key)
	if raw == "" {
		panic(fmt.Sprintf("缺少环境变量：%s", key))
	}

	seconds, err := strconv.Atoi(raw)
	if err != nil || seconds <= 0 {
		panic(fmt.Sprintf("环境变量 %s 必须是正整数秒数", key))
	}
	return time.Duration(seconds) * time.Second
}
