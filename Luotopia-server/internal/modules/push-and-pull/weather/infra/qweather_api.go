package infra

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/push-and-pull/weather/domain"
)

type QWeatherClient struct {
	apiKey   string
	location string
	client   *http.Client
}

func NewQWeatherClient(apiKey, location string) *QWeatherClient {
	return &QWeatherClient{
		apiKey:   apiKey,
		location: location,
		client:   &http.Client{Timeout: 10 * time.Second},
	}
}

type qweatherNowResponse struct {
	Code       string `json:"code"`
	Now        struct {
		Temp      string `json:"temp"`
		FeelsLike string `json:"feelsLike"`
		Icon      string `json:"icon"`
		Text      string `json:"text"`
		WindDir   string `json:"windDir"`
		WindSpeed string `json:"windSpeed"`
		Humidity  string `json:"humidity"`
	} `json:"now"`
	Refer struct {
		Sources []string `json:"sources"`
	} `json:"refer"`
}

type qweather24HResponse struct {
	Code      string `json:"code"`
	Hourly    []struct {
		Time string `json:"fxTime"`
		Temp string `json:"temp"`
		Icon string `json:"icon"`
		Text string `json:"text"`
	} `json:"hourly"`
}

type qweatherAQIResponse struct {
	Code string `json:"code"`
	Now  struct {
		AQI string `json:"aqi"`
	} `json:"now"`
}

func (c *QWeatherClient) FetchWeather() (*domain.WeatherData, error) {
	// Fetch current weather
	nowUrl := fmt.Sprintf("https://devapi.qweather.com/v7/weather/now?location=%s&key=%s", c.location, c.apiKey)
	nowData, err := c.fetchJSON(nowUrl)
	if err != nil {
		return nil, fmt.Errorf("qweather now: %w", err)
	}
	var now qweatherNowResponse
	if err := json.Unmarshal(nowData, &now); err != nil {
		return nil, fmt.Errorf("qweather now parse: %w", err)
	}
	if now.Code != "200" {
		return nil, fmt.Errorf("qweather now api error: code=%s", now.Code)
	}

	// Fetch 24h forecast
	fcUrl := fmt.Sprintf("https://devapi.qweather.com/v7/weather/24h?location=%s&key=%s", c.location, c.apiKey)
	fcData, err := c.fetchJSON(fcUrl)
	if err != nil {
		return nil, fmt.Errorf("qweather 24h: %w", err)
	}
	var fc qweather24HResponse
	if err := json.Unmarshal(fcData, &fc); err != nil {
		return nil, fmt.Errorf("qweather 24h parse: %w", err)
	}

	// Fetch AQI
	aqiUrl := fmt.Sprintf("https://devapi.qweather.com/v7/air/now?location=%s&key=%s", c.location, c.apiKey)
	aqiData, err := c.fetchJSON(aqiUrl)
	aqi := 0
	if err == nil {
		var aqiResp qweatherAQIResponse
		if json.Unmarshal(aqiData, &aqiResp) == nil && aqiResp.Code == "200" {
			fmt.Sscanf(aqiResp.Now.AQI, "%d", &aqi)
		}
	}

	// Parse values
	temp := parseFloat(now.Now.Temp)
	feelsLike := parseFloat(now.Now.FeelsLike)

	hourly := make([]domain.HourlyForecast, 0, len(fc.Hourly))
	for _, h := range fc.Hourly {
		t, _ := time.Parse(time.RFC3339, h.Time)
		hourly = append(hourly, domain.HourlyForecast{
			Time:      t,
			Temp:      parseFloat(h.Temp),
			Condition: h.Text,
			Icon:      h.Icon,
		})
	}

	return &domain.WeatherData{
		Temperature:    temp,
		Condition:      now.Now.Text,
		ConditionCode:  0,
		FeelsLike:      feelsLike,
		TempHigh:       temp,
		TempLow:        temp,
		AQI:            aqi,
		Humidity:       parseInt(now.Now.Humidity),
		WindSpeed:      parseFloat(now.Now.WindSpeed),
		WindDir:        now.Now.WindDir,
		Icon:           now.Now.Icon,
		HourlyForecast: hourly,
		UpdatedAt:      time.Now(),
	}, nil
}

func (c *QWeatherClient) fetchJSON(url string) ([]byte, error) {
	resp, err := c.client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	return body, nil
}

func parseFloat(s string) float64 {
	var v float64
	fmt.Sscanf(s, "%f", &v)
	return v
}

func parseInt(s string) int {
	var v int
	fmt.Sscanf(s, "%d", &v)
	return v
}
