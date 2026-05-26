package scheduler

import (
	"context"
	"errors"
	"sync"
	"time"
)

type jobEntry struct {
	job      Job
	interval time.Duration
}

type TickerScheduler struct {
	mu   sync.Mutex
	jobs []jobEntry
}

func NewTickerScheduler() *TickerScheduler {
	return &TickerScheduler{}
}

func (s *TickerScheduler) Register(job Job) error {
	return s.RegisterWithInterval(job, 0)
}

func (s *TickerScheduler) RegisterWithInterval(job Job, interval time.Duration) error {
	if job == nil {
		return errors.New("scheduler: job cannot be nil")
	}
	if interval <= 0 {
		interval = time.Hour
	}
	s.mu.Lock()
	s.jobs = append(s.jobs, jobEntry{job: job, interval: interval})
	s.mu.Unlock()
	return nil
}

func (s *TickerScheduler) Start(ctx context.Context) error {
	s.mu.Lock()
	entries := make([]jobEntry, len(s.jobs))
	copy(entries, s.jobs)
	s.mu.Unlock()

	for _, entry := range entries {
		j := entry.job
		interval := entry.interval
		go func() {
			ticker := time.NewTicker(interval)
			defer ticker.Stop()
			for {
				select {
				case <-ctx.Done():
					return
				case <-ticker.C:
					_ = j.Run(ctx)
				}
			}
		}()
	}
	<-ctx.Done()
	return nil
}
