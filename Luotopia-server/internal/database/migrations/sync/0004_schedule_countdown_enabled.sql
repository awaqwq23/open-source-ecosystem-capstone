ALTER TABLE sync_schedule_item_details
  ADD COLUMN IF NOT EXISTS countdown_enabled BOOLEAN NOT NULL DEFAULT FALSE;
