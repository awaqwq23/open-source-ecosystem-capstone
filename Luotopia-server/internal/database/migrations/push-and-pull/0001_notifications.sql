CREATE TABLE IF NOT EXISTS push_notifications (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL DEFAULT '',
  priority TEXT NOT NULL DEFAULT 'normal',
  status TEXT NOT NULL DEFAULT 'draft',
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_push_notifications_status
  ON push_notifications(status);
CREATE INDEX IF NOT EXISTS idx_push_notifications_published_at
  ON push_notifications(published_at DESC)
  WHERE status = 'published';
