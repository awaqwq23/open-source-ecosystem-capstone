CREATE TABLE IF NOT EXISTS sync_schedule_item_details (
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  is_all_day BOOLEAN NOT NULL DEFAULT FALSE,
  countdown_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  auto_completed_once_at TIMESTAMPTZ,
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id, item_id) REFERENCES sync_agenda_items(user_id, id) ON DELETE CASCADE
);

ALTER TABLE sync_schedule_item_details
  ADD COLUMN IF NOT EXISTS countdown_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS auto_completed_once_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS sync_task_item_details (
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  deadline_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id, item_id) REFERENCES sync_agenda_items(user_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sync_course_item_details (
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  is_all_day BOOLEAN NOT NULL DEFAULT FALSE,
  timetable_id TEXT NOT NULL DEFAULT '',
  source_kind TEXT NOT NULL DEFAULT 'manual',
  source_course_id TEXT NOT NULL DEFAULT '',
  course_nature TEXT NOT NULL DEFAULT '',
  instructor TEXT NOT NULL DEFAULT '',
  week_meta TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id, item_id) REFERENCES sync_agenda_items(user_id, id) ON DELETE CASCADE
);

INSERT INTO sync_schedule_item_details (
  user_id, item_id, start_at, end_at, is_all_day, countdown_enabled,
  auto_completed_once_at
)
SELECT user_id, id, start_at, end_at, is_all_day, FALSE, NULL
FROM sync_agenda_items
WHERE type = 'schedule'
ON CONFLICT (user_id, item_id) DO NOTHING;

INSERT INTO sync_task_item_details (user_id, item_id, deadline_at)
SELECT user_id, id, COALESCE(deadline, end_at)
FROM sync_agenda_items
WHERE type = 'task'
ON CONFLICT (user_id, item_id) DO NOTHING;

INSERT INTO sync_course_item_details (
  user_id, item_id, start_at, end_at, is_all_day, timetable_id,
  source_kind, source_course_id, course_nature, instructor, week_meta
)
SELECT
  user_id, id, start_at, end_at, is_all_day, course_timetable_id,
  course_source_kind, course_source_course_id, course_nature, instructor, week_meta
FROM sync_agenda_items
WHERE type = 'course'
ON CONFLICT (user_id, item_id) DO NOTHING;

UPDATE sync_changes
SET payload = payload
  - 'start_at'
  - 'end_at'
  - 'is_all_day'
  - 'deadline'
  - 'estimated_duration_minutes'
  - 'course_timetable_id'
  - 'course_source_kind'
  - 'course_source_course_id'
  - 'course_nature'
  - 'instructor'
  - 'week_meta'
  || jsonb_build_object(
    'details',
    CASE payload->>'type'
      WHEN 'schedule' THEN jsonb_build_object(
        'start_at', payload->>'start_at',
        'end_at', payload->>'end_at',
        'is_all_day', COALESCE((payload->>'is_all_day')::boolean, false),
        'countdown_enabled', false,
        'auto_completed_once_at', NULL
      )
      WHEN 'task' THEN jsonb_build_object(
        'deadline_at', COALESCE(payload->>'deadline', payload->>'end_at')
      )
      WHEN 'course' THEN jsonb_build_object(
        'start_at', payload->>'start_at',
        'end_at', payload->>'end_at',
        'is_all_day', COALESCE((payload->>'is_all_day')::boolean, false),
        'timetable_id', COALESCE(payload->>'course_timetable_id', ''),
        'source_kind', COALESCE(payload->>'course_source_kind', 'manual'),
        'source_course_id', COALESCE(payload->>'course_source_course_id', ''),
        'course_nature', COALESCE(payload->>'course_nature', ''),
        'instructor', COALESCE(payload->>'instructor', ''),
        'week_meta', COALESCE(payload->>'week_meta', '')
      )
      ELSE '{}'::jsonb
    END
  )
WHERE entity_type = 'agenda_item'
  AND operation = 'upsert'
  AND payload IS NOT NULL
  AND payload ? 'start_at';

ALTER TABLE sync_agenda_items
  DROP COLUMN IF EXISTS start_at,
  DROP COLUMN IF EXISTS end_at,
  DROP COLUMN IF EXISTS is_all_day,
  DROP COLUMN IF EXISTS deadline,
  DROP COLUMN IF EXISTS estimated_duration_minutes,
  DROP COLUMN IF EXISTS course_timetable_id,
  DROP COLUMN IF EXISTS course_source_kind,
  DROP COLUMN IF EXISTS course_source_course_id,
  DROP COLUMN IF EXISTS course_nature,
  DROP COLUMN IF EXISTS instructor,
  DROP COLUMN IF EXISTS week_meta;

CREATE INDEX IF NOT EXISTS idx_sync_course_item_details_timetable
  ON sync_course_item_details(user_id, timetable_id);
