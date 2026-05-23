package scheduler

import "context"

type Job interface {
	Name() string
	Run(ctx context.Context) error
}

type Scheduler interface {
	Register(job Job) error
	Start(ctx context.Context) error
}

type NoopScheduler struct{}

func (NoopScheduler) Register(Job) error {
	return nil
}

func (NoopScheduler) Start(context.Context) error {
	return nil
}
