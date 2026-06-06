CREATE TABLE IF NOT EXISTS sync_agenda_items (
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  id TEXT NOT NULL,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  location TEXT NOT NULL DEFAULT '',
  color TEXT NOT NULL,
  reminder TEXT NOT NULL,
  repeat_rule TEXT NOT NULL,
  is_completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  sort_order DOUBLE PRECISION NOT NULL DEFAULT 0,
  source_kind TEXT NOT NULL DEFAULT 'manual',
  source_ref TEXT NOT NULL DEFAULT '',
  revision BIGINT NOT NULL DEFAULT 0,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, id)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_agenda_items_source
  ON sync_agenda_items(user_id, source_kind, source_ref)
  WHERE source_ref <> '' AND deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_sync_agenda_items_user_updated
  ON sync_agenda_items(user_id, updated_at);
CREATE INDEX IF NOT EXISTS idx_sync_agenda_items_timetable
  ON sync_agenda_items(user_id, type);

CREATE TABLE IF NOT EXISTS sync_schedule_item_details (
  user_id TEXT NOT NULL,
  item_id TEXT NOT NULL,
  start_at TIMESTAMPTZ NOT NULL,
  end_at TIMESTAMPTZ NOT NULL,
  is_all_day BOOLEAN NOT NULL DEFAULT FALSE,
  auto_completed_once_at TIMESTAMPTZ,
  PRIMARY KEY (user_id, item_id),
  FOREIGN KEY (user_id, item_id) REFERENCES sync_agenda_items(user_id, id) ON DELETE CASCADE
);

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

CREATE INDEX IF NOT EXISTS idx_sync_course_item_details_timetable
  ON sync_course_item_details(user_id, timetable_id);

CREATE TABLE IF NOT EXISTS sync_course_timetables (
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  source TEXT NOT NULL,
  term_label TEXT NOT NULL DEFAULT '',
  revision BIGINT NOT NULL DEFAULT 0,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, id)
);

CREATE INDEX IF NOT EXISTS idx_sync_course_timetables_user_updated
  ON sync_course_timetables(user_id, updated_at);

CREATE TABLE IF NOT EXISTS sync_selected_course_timetables (
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  timetable_id TEXT NOT NULL,
  sort_order DOUBLE PRECISION NOT NULL DEFAULT 0,
  revision BIGINT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, timetable_id)
);

CREATE TABLE IF NOT EXISTS sync_tombstones (
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  revision BIGINT NOT NULL DEFAULT 0,
  deleted_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (user_id, entity_type, entity_id)
);

CREATE TABLE IF NOT EXISTS sync_changes (
  id BIGSERIAL PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL DEFAULT '',
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  revision BIGINT NOT NULL,
  payload JSONB,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_sync_changes_user_id
  ON sync_changes(user_id, id);
CREATE INDEX IF NOT EXISTS idx_sync_changes_entity
  ON sync_changes(user_id, entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_sync_changes_created_at
  ON sync_changes(user_id, created_at);
