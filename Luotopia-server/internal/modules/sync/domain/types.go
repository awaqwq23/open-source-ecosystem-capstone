package domain

import (
	"encoding/json"
	"time"
)

type EntityType string

const (
	EntityTypeAgendaItem        EntityType = "agenda_item"
	EntityTypeCourseTimetable   EntityType = "course_timetable"
	EntityTypeSelectedTimetable EntityType = "selected_course_timetable"
	EntityTypeSyncTombstone     EntityType = "sync_tombstone"
)

type Operation string

const (
	OperationUpsert Operation = "upsert"
	OperationDelete Operation = "delete"
)

type SyncChange struct {
	ChangeID   int64           `json:"change_id"`
	UserID     string          `json:"-"`
	DeviceID   string          `json:"-"`
	EntityType EntityType      `json:"entity_type"`
	EntityID   string          `json:"entity_id"`
	Operation  Operation       `json:"operation"`
	Revision   int64           `json:"revision"`
	Payload    json.RawMessage `json:"payload,omitempty"`
	CreatedAt  time.Time       `json:"created_at"`
}

type SyncChangeInput struct {
	EntityType EntityType      `json:"entity_type"`
	EntityID   string          `json:"entity_id"`
	Operation  Operation       `json:"operation"`
	Payload    json.RawMessage `json:"payload,omitempty"`
}

type SyncAppliedChange struct {
	ChangeID   int64      `json:"change_id"`
	EntityType EntityType `json:"entity_type"`
	EntityID   string     `json:"entity_id"`
	Operation  Operation  `json:"operation"`
	Revision   int64      `json:"revision"`
}

type SyncRejectedChange struct {
	EntityType EntityType `json:"entity_type"`
	EntityID   string     `json:"entity_id"`
	Operation  Operation  `json:"operation"`
	Reason     string     `json:"reason"`
}

type SyncPullResult struct {
	Cursor     int64        `json:"cursor"`
	NextCursor int64        `json:"next_cursor"`
	HasMore    bool         `json:"has_more"`
	Changes    []SyncChange `json:"changes"`
}

type SyncPushRequest struct {
	BaseCursor int64             `json:"base_cursor"`
	DeviceID   string            `json:"device_id"`
	Changes    []SyncChangeInput `json:"changes"`
}

type SyncPushResponse struct {
	Accepted      []SyncAppliedChange  `json:"accepted"`
	Rejected      []SyncRejectedChange `json:"rejected"`
	NextCursor    int64                `json:"next_cursor"`
	ServerChanges []SyncChange         `json:"server_changes"`
}

type AgendaItemPayload struct {
	ID                       string     `json:"id"`
	Type                     string     `json:"type"`
	Title                    string     `json:"title"`
	Notes                    string     `json:"notes"`
	Location                 string     `json:"location"`
	Color                    string     `json:"color"`
	Reminder                 string     `json:"reminder"`
	RepeatRule               string     `json:"repeat_rule"`
	StartAt                  time.Time  `json:"start_at"`
	EndAt                    time.Time  `json:"end_at"`
	IsAllDay                 bool       `json:"is_all_day"`
	Deadline                 *time.Time `json:"deadline,omitempty"`
	EstimatedDurationMinutes int        `json:"estimated_duration_minutes"`
	IsCompleted              bool       `json:"is_completed"`
	CompletedAt              *time.Time `json:"completed_at,omitempty"`
	SortOrder                float64    `json:"sort_order"`
	SourceKind               string     `json:"source_kind"`
	SourceRef                string     `json:"source_ref"`
	CourseTimetableID        string     `json:"course_timetable_id"`
	CourseSourceKind         string     `json:"course_source_kind"`
	CourseSourceCourseID     string     `json:"course_source_course_id"`
	CourseNature             string     `json:"course_nature"`
	Instructor               string     `json:"instructor"`
	WeekMeta                 string     `json:"week_meta"`
	CreatedAt                time.Time  `json:"created_at"`
	UpdatedAt                time.Time  `json:"updated_at"`
}

type CourseTimetablePayload struct {
	ID        string    `json:"id"`
	Name      string    `json:"name"`
	Source    string    `json:"source"`
	TermLabel string    `json:"term_label"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type SelectedTimetablePayload struct {
	TimetableID string    `json:"timetable_id"`
	SortOrder   float64   `json:"sort_order"`
	UpdatedAt   time.Time `json:"updated_at"`
}
