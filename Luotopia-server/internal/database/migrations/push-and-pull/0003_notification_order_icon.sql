ALTER TABLE push_notifications
  ADD COLUMN IF NOT EXISTS icon TEXT NOT NULL DEFAULT 'campaign';

ALTER TABLE push_notifications
  ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_push_notifications_display_order
  ON push_notifications(display_order ASC, published_at DESC, created_at DESC)
  WHERE status = 'published';
