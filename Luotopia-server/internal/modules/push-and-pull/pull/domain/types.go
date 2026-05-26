package domain

type PullResponse struct {
	Weather      *WeatherBlock      `json:"weather,omitempty"`
	Notification *NotificationBlock `json:"notification,omitempty"`
	HotUpdate    *HotUpdateBlock    `json:"hot_update,omitempty"`
	Sync         *SyncBlock         `json:"sync,omitempty"`
}

type WeatherBlock struct {
	Data     interface{} `json:"data,omitempty"`
	CachedAt *int64      `json:"cached_at,omitempty"`
}

type NotificationBlock struct {
	LatestID string `json:"latest_id"`
	HasNew   bool   `json:"has_new"`
	Count    int    `json:"count"`
}

type HotUpdateBlock struct {
	Scripts map[string]ScriptVersion `json:"scripts"`
}

type ScriptVersion struct {
	LatestVersion int    `json:"latest_version"`
	Checksum      string `json:"checksum"`
}

type SyncBlock struct {
	Enabled bool `json:"enabled"`
}
