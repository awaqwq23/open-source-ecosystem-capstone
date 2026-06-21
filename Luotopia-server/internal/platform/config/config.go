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
	Environment     string
	HTTP            HTTPConfig
	Database        DatabaseConfig
	Redis           RedisConfig
	Storage         StorageConfig
	Auth            AuthConfig
	Admin           AdminConfig
	Weather         WeatherConfig
	SchoolTimetable SchoolTimetableConfig
	SMS             SMSConfig
	Email           EmailConfig
}

type WeatherConfig struct {
	APIKey   string
	APIHost  string
	Location string
	CacheTTL time.Duration
}

type SchoolTimetableConfig struct {
	SnapshotDir string
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
	Endpoint       string
	Bucket         string
	Region         string
	AccessKey      string
	SecretKey      string
	PublicBaseURL  string
	UseSSL         bool
	ForcePathStyle bool
}

type AuthConfig struct {
	AccessTokenSecret string
	AccessTokenTTL    time.Duration
	RefreshTokenTTL   time.Duration
}

type AdminConfig struct {
	Phone string
	Email string
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
		Database: DatabaseConfig{URL: runtimeEndpointEnv("LUOTOPIA_DATABASE_URL")},
		Redis:    RedisConfig{URL: runtimeEndpointEnv("LUOTOPIA_REDIS_URL")},
		Storage: StorageConfig{
			Endpoint:       optionalEnv("LUOTOPIA_STORAGE_ENDPOINT", ""),
			Bucket:         optionalEnv("LUOTOPIA_STORAGE_BUCKET", ""),
			Region:         optionalEnv("LUOTOPIA_STORAGE_REGION", ""),
			AccessKey:      optionalEnv("LUOTOPIA_STORAGE_ACCESS_KEY", ""),
			SecretKey:      optionalEnv("LUOTOPIA_STORAGE_SECRET_KEY", ""),
			PublicBaseURL:  optionalEnv("LUOTOPIA_STORAGE_PUBLIC_BASE_URL", ""),
			UseSSL:         optionalBoolEnv("LUOTOPIA_STORAGE_USE_SSL", true),
			ForcePathStyle: optionalBoolEnv("LUOTOPIA_STORAGE_FORCE_PATH_STYLE", true),
		},
		Auth: AuthConfig{
			AccessTokenSecret: requiredEnv("LUOTOPIA_AUTH_ACCESS_TOKEN_SECRET"),
			AccessTokenTTL:    requiredDurationEnv("LUOTOPIA_AUTH_ACCESS_TOKEN_TTL"),
			RefreshTokenTTL:   requiredDurationEnv("LUOTOPIA_AUTH_REFRESH_TOKEN_TTL"),
		},
		Admin: AdminConfig{
			Phone: os.Getenv("LUOTOPIA_ADMIN_PHONE"),
			Email: os.Getenv("LUOTOPIA_ADMIN_EMAIL"),
		},
		Weather: WeatherConfig{
			APIKey:   declaredEnv("LUOTOPIA_WEATHER_API_KEY"),
			APIHost:  declaredEnv("LUOTOPIA_WEATHER_API_HOST"),
			Location: declaredEnv("LUOTOPIA_WEATHER_LOCATION"),
			CacheTTL: requiredDurationEnv("LUOTOPIA_WEATHER_CACHE_TTL"),
		},
		SchoolTimetable: SchoolTimetableConfig{
			SnapshotDir: optionalEnv("LUOTOPIA_SCHOOL_TIMETABLE_SNAPSHOT_DIR", "school_timetable_snapshots"),
		},
		SMS: SMSConfig{
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
	if err := godotenv.Load("configs/.env"); err == nil {
		return
	}
	if err := godotenv.Load(".env"); err == nil {
		return
	}
	panic("无法加载 .env 配置")
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

func optionalEnv(key string, fallback string) string {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	return value
}

func optionalBoolEnv(key string, fallback bool) bool {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	parsed, err := strconv.ParseBool(value)
	if err != nil {
		panic(fmt.Sprintf("环境变量 %s 必须是布尔值", key))
	}
	return parsed
}

func runtimeEndpointEnv(key string) string {
	value := declaredEnv(key)
	if os.Getenv("LUOTOPIA_RUNTIME") != "container" {
		return value
	}
	containerKey := strings.Replace(key, "LUOTOPIA_", "LUOTOPIA_CONTAINER_", 1)
	if containerValue := strings.TrimSpace(os.Getenv(containerKey)); containerValue != "" {
		return containerValue
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
