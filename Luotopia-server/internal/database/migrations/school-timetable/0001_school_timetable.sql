CREATE TABLE IF NOT EXISTS school_timetable_terms (
  term_key TEXT PRIMARY KEY,
  school_year TEXT NOT NULL,
  term TEXT NOT NULL,
  active_version INT NOT NULL DEFAULT 0,
  checksum TEXT NOT NULL DEFAULT '',
  row_count INT NOT NULL DEFAULT 0,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE IF NOT EXISTS school_timetable_releases (
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  version INT NOT NULL,
  checksum TEXT NOT NULL,
  file_key TEXT NOT NULL,
  row_count INT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT FALSE,
  published_at TIMESTAMPTZ NOT NULL,
  PRIMARY KEY (term_key, version)
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_releases_active
  ON school_timetable_releases(term_key, active);

CREATE TABLE IF NOT EXISTS school_timetable_course_heads (
  id TEXT PRIMARY KEY,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  course_head_key TEXT NOT NULL,
  course_no TEXT NOT NULL,
  course_name TEXT NOT NULL,
  open_college TEXT NOT NULL DEFAULT '',
  credits TEXT NOT NULL DEFAULT '',
  course_nature TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '',
  teaching_class_count INT NOT NULL DEFAULT 0,
  teacher_summary TEXT NOT NULL DEFAULT '',
  weekday_summary TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_course_heads_term
  ON school_timetable_course_heads(term_key);

CREATE INDEX IF NOT EXISTS idx_school_timetable_course_heads_course_no
  ON school_timetable_course_heads(course_no);

CREATE TABLE IF NOT EXISTS school_timetable_raw_rows (
  id TEXT PRIMARY KEY,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  course_head_id TEXT NOT NULL REFERENCES school_timetable_course_heads(id) ON DELETE CASCADE,
  source_key TEXT NOT NULL,
  school_year TEXT NOT NULL,
  term TEXT NOT NULL,
  teaching_class_name TEXT NOT NULL,
  course_no TEXT NOT NULL,
  course_name TEXT NOT NULL,
  open_college TEXT NOT NULL DEFAULT '',
  plan_college TEXT NOT NULL DEFAULT '',
  credits TEXT NOT NULL DEFAULT '',
  course_nature TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '',
  grade TEXT NOT NULL DEFAULT '',
  major TEXT NOT NULL DEFAULT '',
  instructor TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  people_raw TEXT NOT NULL DEFAULT '',
  fields_json JSONB NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE (term_key, source_key)
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_raw_rows_head
  ON school_timetable_raw_rows(course_head_id);

CREATE INDEX IF NOT EXISTS idx_school_timetable_raw_rows_instructor
  ON school_timetable_raw_rows(instructor);

CREATE TABLE IF NOT EXISTS school_timetable_meetings (
  id TEXT PRIMARY KEY,
  raw_row_id TEXT NOT NULL REFERENCES school_timetable_raw_rows(id) ON DELETE CASCADE,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  course_head_id TEXT NOT NULL REFERENCES school_timetable_course_heads(id) ON DELETE CASCADE,
  weekday INT NOT NULL,
  segment_index INT NOT NULL,
  weekday_label TEXT NOT NULL DEFAULT '',
  raw_text TEXT NOT NULL DEFAULT '',
  location_text TEXT NOT NULL DEFAULT '',
  building TEXT NOT NULL DEFAULT '',
  room TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_meetings_raw_row
  ON school_timetable_meetings(raw_row_id);

CREATE INDEX IF NOT EXISTS idx_school_timetable_meetings_weekday
  ON school_timetable_meetings(weekday);
