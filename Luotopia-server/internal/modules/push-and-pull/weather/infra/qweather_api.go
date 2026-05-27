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
	apiHost  string
	location string
	client   *http.Client
}

func NewQWeatherClient(apiKey, apiHost, location string) *QWeatherClient {
	return &QWeatherClient{
		apiKey:   apiKey,
		apiHost:  apiHost,
		location: location,
		client:   &http.Client{Timeout: 10 * time.Second},
	}
}

type qweatherNowResponse struct {
	Code string `json:"code"`
	Now  struct {
		ObsTime   string `json:"obsTime"`
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
	Code   string `json:"code"`
	Hourly []struct {
		Time string `json:"fxTime"`
		Temp string `json:"temp"`
		Icon string `json:"icon"`
		Text string `json:"text"`
	} `json:"hourly"`
}

type qweather3DResponse struct {
	Code  string `json:"code"`
	Daily []struct {
		Time    string `json:"fxDate"`
		TempMax string `json:"tempMax"`
		TempMin string `json:"tempMin"`
	} `json:"daily"`
}

type qweatherAQIResponse struct {
	Code string `json:"code"`
	Now  struct {
		AQI string `json:"aqi"`
	} `json:"now"`
}

func (c *QWeatherClient) FetchWeather() (*domain.WeatherData, error) {
	// Fetch current weather
	nowUrl := fmt.Sprintf("https://%s/v7/weather/now?location=%s&key=%s", c.apiHost, c.location, c.apiKey)
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
	fcUrl := fmt.Sprintf("https://%s/v7/weather/24h?location=%s&key=%s", c.apiHost, c.location, c.apiKey)
	fcData, err := c.fetchJSON(fcUrl)
	if err != nil {
		return nil, fmt.Errorf("qweather 24h: %w", err)
	}
	var fc qweather24HResponse
	if err := json.Unmarshal(fcData, &fc); err != nil {
		return nil, fmt.Errorf("qweather 24h parse: %w", err)
	}
	if fc.Code != "200" {
		return nil, fmt.Errorf("qweather 24h api error: code=%s", fc.Code)
	}

	// Fetch 3d forecast for high/low temperature.
	dailyUrl := fmt.Sprintf("https://%s/v7/weather/3d?location=%s&key=%s", c.apiHost, c.location, c.apiKey)
	dailyData, err := c.fetchJSON(dailyUrl)
	if err != nil {
		return nil, fmt.Errorf("qweather 3d: %w", err)
	}
	var daily qweather3DResponse
	if err := json.Unmarshal(dailyData, &daily); err != nil {
		return nil, fmt.Errorf("qweather 3d parse: %w", err)
	}
	if daily.Code != "200" {
		return nil, fmt.Errorf("qweather 3d api error: code=%s", daily.Code)
	}

	// Fetch AQI
	aqiUrl := fmt.Sprintf("https://%s/v7/air/now?location=%s&key=%s", c.apiHost, c.location, c.apiKey)
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
	tempHigh := temp
	tempLow := temp
	if len(daily.Daily) > 0 {
		tempHigh = parseFloat(daily.Daily[0].TempMax)
		tempLow = parseFloat(daily.Daily[0].TempMin)
	}

	hourly := make([]domain.HourlyForecast, 0, len(fc.Hourly))
	for _, h := range fc.Hourly {
		t, err := parseQWeatherTime(h.Time)
		if err != nil {
			t = time.Time{}
		}
		hourly = append(hourly, domain.HourlyForecast{
			Time:      t,
			TimeText:  formatHourText(t, h.Time),
			Temp:      parseFloat(h.Temp),
			Condition: h.Text,
			Icon:      h.Icon,
		})
	}

	updatedAt := time.Now()
	if t, err := parseQWeatherTime(now.Now.ObsTime); err == nil {
		updatedAt = t
	}

	return &domain.WeatherData{
		Temperature:    temp,
		Condition:      now.Now.Text,
		ConditionCode:  parseInt(now.Now.Icon),
		FeelsLike:      feelsLike,
		TempHigh:       tempHigh,
		TempLow:        tempLow,
		AQI:            aqi,
		Humidity:       parseInt(now.Now.Humidity),
		WindSpeed:      parseFloat(now.Now.WindSpeed),
		WindDir:        now.Now.WindDir,
		Icon:           now.Now.Icon,
		HourlyForecast: hourly,
		UpdatedAt:      updatedAt,
	}, nil
}

func (c *QWeatherClient) fetchJSON(url string) ([]byte, error) {
	resp, err := c.client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("http status %d", resp.StatusCode)
	}
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

func parseQWeatherTime(s string) (time.Time, error) {
	if s == "" {
		return time.Time{}, fmt.Errorf("empty qweather time")
	}
	if t, err := time.Parse("2006-01-02T15:04-07:00", s); err == nil {
		return t, nil
	}
	return time.Parse(time.RFC3339, s)
}

func formatHourText(t time.Time, raw string) string {
	if !t.IsZero() {
		return t.Format("15:04")
	}
	if len(raw) >= 16 {
		return raw[11:16]
	}
	return ""
}
