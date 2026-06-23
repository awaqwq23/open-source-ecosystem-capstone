package domain

import (
	"encoding/json"
	"time"
)

type PullRequest struct {
	Trigger     string          `json:"trigger"`
	Scopes      []string        `json:"scopes"`
	ClientState PullClientState `json:"client_state"`
}

type PullClientState struct {
	WeatherCachedAt        *int64                       `json:"weather_cached_at,omitempty"`
	NotificationLatestID   string                       `json:"notification_latest_id,omitempty"`
	HotUpdateScripts       map[string]ClientScriptState `json:"hot_update_scripts,omitempty"`
	SyncCursor             *int64                       `json:"sync_cursor,omitempty"`
	SchoolTimetableVersion int64                        `json:"school_timetable_version,omitempty"`
}

type ClientScriptState struct {
	Version  int    `json:"version"`
	Checksum string `json:"checksum"`
}

type PullResponse struct {
	ServerTime      time.Time             `json:"server_time"`
	Weather         *WeatherBlock         `json:"weather,omitempty"`
	Notification    *NotificationBlock    `json:"notification,omitempty"`
	HotUpdate       *HotUpdateBlock       `json:"hot_update,omitempty"`
	Sync            *SyncBlock            `json:"sync,omitempty"`
	Stats           *StatsBlock           `json:"stats,omitempty"`
	SchoolTimetable *SchoolTimetableBlock `json:"school_timetable,omitempty"`
}

type StatsBlock struct {
	TotalUsers     int `json:"total_users"`
	ActiveSessions int `json:"active_sessions"`
}

type WeatherBlock struct {
	Changed  bool        `json:"changed"`
	Data     interface{} `json:"data,omitempty"`
	CachedAt *int64      `json:"cached_at,omitempty"`
}

type NotificationBlock struct {
	Changed     bool   `json:"changed"`
	LatestID    string `json:"latest_id"`
	HasNew      bool   `json:"has_new"`
	Count       int    `json:"count"`
	Title       string `json:"title,omitempty"`
	Icon        string `json:"icon,omitempty"`
	PublishedAt string `json:"published_at,omitempty"`
}

type HotUpdateBlock struct {
	Scripts map[string]ScriptVersion `json:"scripts"`
}

type Link struct {
	Href string `json:"href"`
}

type ScriptVersion struct {
	Changed       bool            `json:"changed"`
	LatestVersion int             `json:"latest_version"`
	Checksum      string          `json:"checksum"`
	Links         map[string]Link `json:"links,omitempty"`
}

type SchoolTimetableBlock struct {
	Changed       bool                    `json:"changed"`
	LatestVersion int64                   `json:"latest_version"`
	Checksum      string                  `json:"checksum"`
	SchemaVersion int                     `json:"schema_version"`
	Terms         []string                `json:"terms"`
	Changes       []SchoolTimetableChange `json:"changes"`
	PublishedAt   string                  `json:"published_at"`
}

type SchoolTimetableChange struct {
	Version    int64           `json:"version"`
	Sequence   int             `json:"sequence"`
	Operation  string          `json:"operation"`
	EntityType string          `json:"entity_type"`
	EntityID   string          `json:"entity_id"`
	TermKey    string          `json:"term_key"`
	Payload    json.RawMessage `json:"payload,omitempty"`
}

type SyncBlock struct {
	Enabled      bool   `json:"enabled"`
	HasChanges   bool   `json:"has_changes"`
	LatestCursor *int64 `json:"latest_cursor,omitempty"`
}
