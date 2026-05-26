package domain

import (
	"time"

	notidomain "github.com/openwhu/luotopia/server/internal/modules/push-and-pull/notification/domain"
)

type Dashboard struct {
	Version string `json:"version"`
	Uptime  int64  `json:"uptime"`
}

type HealthStatus struct {
	Database bool `json:"database"`
	Redis    bool `json:"redis"`
}

type Notification struct {
	ID          string     `json:"id"`
	Title       string     `json:"title"`
	Content     string     `json:"content"`
	Priority    string     `json:"priority"`
	Status      string     `json:"status"`
	PublishedAt *time.Time `json:"published_at,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

type NotificationList struct {
	Total int64          `json:"total"`
	Items []Notification `json:"items"`
}

type CreateNotificationRequest struct {
	Title    string `json:"title" binding:"required"`
	Content  string `json:"content"`
	Priority string `json:"priority"`
}

func NewNotification(n notidomain.Notification) Notification {
	return Notification{
		ID:          n.ID,
		Title:       n.Title,
		Content:     n.Content,
		Priority:    string(n.Priority),
		Status:      string(n.Status),
		PublishedAt: n.PublishedAt,
		CreatedAt:   n.CreatedAt,
		UpdatedAt:   n.UpdatedAt,
	}
}

type HotUpdateScript struct {
	ID            string    `json:"id"`
	Name          string    `json:"name"`
	Description   string    `json:"description"`
	Channel       string    `json:"channel"`
	Enabled       bool      `json:"enabled"`
	LatestVersion int       `json:"latest_version"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type HotUpdateScriptList struct {
	Items []HotUpdateScript `json:"items"`
}

type CreateScriptRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Channel     string `json:"channel"`
}

type PublishReleaseRequest struct {
	FileKey      string `json:"file_key"`
	Content      string `json:"content"`
	Checksum     string `json:"checksum"`
	ReleaseNotes string `json:"release_notes"`
}

type UserInfo struct {
	ID         string    `json:"id"`
	Status     string    `json:"status"`
	Phone      string    `json:"phone,omitempty"`
	Email      string    `json:"email,omitempty"`
	SessionCnt int64     `json:"session_cnt"`
	CreatedAt  time.Time `json:"created_at"`
}

type UserList struct {
	Total int64      `json:"total"`
	Items []UserInfo `json:"items"`
}

type SyncAllowlistEntry struct {
	UserID    string    `json:"user_id"`
	Enabled   bool      `json:"enabled"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type SyncAllowlist struct {
	Items []SyncAllowlistEntry `json:"items"`
}

type AddAllowlistRequest struct {
	UserID string `json:"user_id" binding:"required"`
}
