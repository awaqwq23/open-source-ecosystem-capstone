ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS file_key TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS artifact_type TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS schema_version INT NOT NULL DEFAULT 0;

ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS artifact_size BIGINT NOT NULL DEFAULT 0;

ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS artifact_type TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS schema_version INT NOT NULL DEFAULT 0;

ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS artifact_size BIGINT NOT NULL DEFAULT 0;
