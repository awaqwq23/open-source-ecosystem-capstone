package audit

import (
	"context"
	"time"
)

type Event struct {
	ActorID   string
	Action    string
	Resource  string
	CreatedAt time.Time
	Metadata  map[string]string
}

type Recorder interface {
	Record(ctx context.Context, event Event) error
}
