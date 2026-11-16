CREATE TABLE IF NOT EXISTS hot_update_scripts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  channel TEXT NOT NULL DEFAULT 'stable',
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_hot_update_scripts_name
  ON hot_update_scripts(name);

CREATE TABLE IF NOT EXISTS hot_update_releases (
  id TEXT PRIMARY KEY,
  script_id TEXT NOT NULL REFERENCES hot_update_scripts(id) ON DELETE CASCADE,
  version INT NOT NULL,
  file_key TEXT NOT NULL,
  checksum TEXT NOT NULL DEFAULT '',
  release_notes TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL,
  UNIQUE (script_id, version)
);

CREATE INDEX IF NOT EXISTS idx_hot_update_releases_script_id
  ON hot_update_releases(script_id, version DESC);
