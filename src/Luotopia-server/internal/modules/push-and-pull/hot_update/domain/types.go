package domain

import "time"

type Channel string

const (
	ChannelStable Channel = "stable"
	ChannelBeta   Channel = "beta"
)

type Script struct {
	ID          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Channel     Channel   `json:"channel"`
	Enabled     bool      `json:"enabled"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type ScriptRelease struct {
	ID           string    `json:"id"`
	ScriptID     string    `json:"script_id"`
	Version      int       `json:"version"`
	FileKey      string    `json:"file_key"`
	Checksum     string    `json:"checksum"`
	ReleaseNotes string    `json:"release_notes"`
	CreatedAt    time.Time `json:"created_at"`
}

type ScriptWithLatestVersion struct {
	Script
	LatestVersion int    `json:"latest_version"`
	FileKey       string `json:"file_key,omitempty"`
	Checksum      string `json:"checksum,omitempty"`
}
