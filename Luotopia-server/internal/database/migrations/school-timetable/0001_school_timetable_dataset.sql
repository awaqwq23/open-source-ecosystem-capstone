CREATE TABLE IF NOT EXISTS school_timetable_dataset_state (
  id INTEGER PRIMARY KEY,
  version BIGINT NOT NULL DEFAULT 0,
  checksum TEXT NOT NULL DEFAULT '',
  schema_version INTEGER NOT NULL DEFAULT 1,
  term_keys_json TEXT NOT NULL DEFAULT '[]',
  published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS school_timetable_entities (
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  term_key TEXT NOT NULL DEFAULT '',
  payload_json JSONB NOT NULL,
  payload_checksum TEXT NOT NULL,
  updated_version BIGINT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_entities_term
  ON school_timetable_entities(term_key, entity_type);

CREATE TABLE IF NOT EXISTS school_timetable_changes (
  version BIGINT NOT NULL,
  sequence INTEGER NOT NULL,
  operation TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  term_key TEXT NOT NULL DEFAULT '',
  payload_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (version, sequence)
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_changes_entity
  ON school_timetable_changes(entity_type, entity_id);
