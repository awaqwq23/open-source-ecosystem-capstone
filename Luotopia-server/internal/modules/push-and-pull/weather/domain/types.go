package domain

import "time"

type WeatherData struct {
	Temperature    float64          `json:"temperature"`
	Condition      string           `json:"condition"`
	ConditionCode  int              `json:"condition_code"`
	FeelsLike      float64          `json:"feels_like"`
	TempHigh       float64          `json:"temp_high"`
	TempLow        float64          `json:"temp_low"`
	AQI            int              `json:"aqi"`
	Humidity       int              `json:"humidity"`
	WindSpeed      float64          `json:"wind_speed"`
	WindDir        string           `json:"wind_dir"`
	Icon           string           `json:"icon"`
	HourlyForecast []HourlyForecast `json:"hourly_forecast,omitempty"`
	UpdatedAt      time.Time        `json:"updated_at"`
}

type HourlyForecast struct {
	Time      time.Time `json:"time"`
	TimeText  string    `json:"time_text,omitempty"`
	Temp      float64   `json:"temp"`
	Condition string    `json:"condition"`
	Icon      string    `json:"icon"`
}

type WeatherStatus struct {
	Enabled       bool         `json:"enabled"`
	CacheTTL      int64        `json:"cache_ttl"`
	CachedAt      *time.Time   `json:"cached_at,omitempty"`
	LastRefreshAt *time.Time   `json:"last_refresh_at,omitempty"`
	LastError     string       `json:"last_error,omitempty"`
	Data          *WeatherData `json:"data,omitempty"`
}
