package domain

import "time"

type WeatherData struct {
	Temperature   float64   `json:"temperature"`
	Condition     string    `json:"condition"`
	ConditionCode int       `json:"condition_code"`
	AQI           int       `json:"aqi"`
	Humidity      int       `json:"humidity"`
	WindSpeed     float64   `json:"wind_speed"`
	Icon          string    `json:"icon"`
	UpdatedAt     time.Time `json:"updated_at"`
}
