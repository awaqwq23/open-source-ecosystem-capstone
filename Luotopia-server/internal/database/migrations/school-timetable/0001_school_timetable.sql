CREATE TABLE IF NOT EXISTS school_timetable_terms (
  term_key TEXT PRIMARY KEY,
  school_year TEXT NOT NULL,
  term TEXT NOT NULL,
  first_week_monday TEXT NOT NULL,
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

CREATE TABLE IF NOT EXISTS course_catalogs (
  id TEXT PRIMARY KEY,
  catalog_key TEXT NOT NULL,
  course_no TEXT NOT NULL,
  course_name TEXT NOT NULL,
  credits TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_course_catalogs_course_no
  ON course_catalogs(course_no);

CREATE TABLE IF NOT EXISTS course_term_courses (
  id TEXT PRIMARY KEY,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  catalog_id TEXT NOT NULL REFERENCES course_catalogs(id) ON DELETE CASCADE,
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

CREATE INDEX IF NOT EXISTS idx_course_term_courses_term
  ON course_term_courses(term_key);

CREATE INDEX IF NOT EXISTS idx_course_term_courses_catalog
  ON course_term_courses(catalog_id);

CREATE TABLE IF NOT EXISTS course_instructor_courses (
  id TEXT PRIMARY KEY,
  catalog_id TEXT NOT NULL REFERENCES course_catalogs(id) ON DELETE CASCADE,
  course_no TEXT NOT NULL,
  course_name TEXT NOT NULL,
  credits TEXT NOT NULL DEFAULT '',
  instructor_name TEXT NOT NULL DEFAULT '',
  instructor_name_key TEXT NOT NULL DEFAULT '',
  offering_count INT NOT NULL DEFAULT 0,
  latest_term_key TEXT NOT NULL DEFAULT '',
  latest_open_college TEXT NOT NULL DEFAULT '',
  latest_teaching_title TEXT NOT NULL DEFAULT '',
  search_text TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_course_instructor_courses_instructor
  ON course_instructor_courses(instructor_name_key);

CREATE TABLE IF NOT EXISTS course_offerings (
  id TEXT PRIMARY KEY,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  term_course_id TEXT NOT NULL REFERENCES course_term_courses(id) ON DELETE CASCADE,
  catalog_id TEXT NOT NULL REFERENCES course_catalogs(id) ON DELETE CASCADE,
  instructor_course_id TEXT NOT NULL REFERENCES course_instructor_courses(id) ON DELETE CASCADE,
  teaching_class_name TEXT NOT NULL,
  course_no TEXT NOT NULL,
  course_name TEXT NOT NULL,
  open_college TEXT NOT NULL DEFAULT '',
  credits TEXT NOT NULL DEFAULT '',
  instructor TEXT NOT NULL DEFAULT '',
  instructor_key TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  people_raw TEXT NOT NULL DEFAULT '',
  theory_hours TEXT NOT NULL DEFAULT '',
  computer_hours TEXT NOT NULL DEFAULT '',
  experiment_hours TEXT NOT NULL DEFAULT '',
  practice_hours TEXT NOT NULL DEFAULT '',
  remark TEXT NOT NULL DEFAULT '',
  other_teachers TEXT NOT NULL DEFAULT '',
  textbook TEXT NOT NULL DEFAULT '',
  publisher TEXT NOT NULL DEFAULT '',
  schedule_signature TEXT NOT NULL DEFAULT '',
  schedule_summary TEXT NOT NULL DEFAULT '',
  weekday_summary TEXT NOT NULL DEFAULT '',
  audience_summary TEXT NOT NULL DEFAULT '',
  source_row_count INT NOT NULL DEFAULT 0,
  search_text TEXT NOT NULL DEFAULT '',
  fields_json JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_course_offerings_term_course
  ON course_offerings(term_course_id);

CREATE INDEX IF NOT EXISTS idx_course_offerings_instructor
  ON course_offerings(instructor_course_id);

CREATE TABLE IF NOT EXISTS course_audiences (
  id TEXT PRIMARY KEY,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  offering_id TEXT NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
  term_course_id TEXT NOT NULL REFERENCES course_term_courses(id) ON DELETE CASCADE,
  catalog_id TEXT NOT NULL REFERENCES course_catalogs(id) ON DELETE CASCADE,
  grade TEXT NOT NULL DEFAULT '',
  major TEXT NOT NULL DEFAULT '',
  plan_college TEXT NOT NULL DEFAULT '',
  course_nature TEXT NOT NULL DEFAULT '',
  course_nature_code TEXT NOT NULL DEFAULT '',
  course_category TEXT NOT NULL DEFAULT '',
  course_category_code TEXT NOT NULL DEFAULT '',
  open_type TEXT NOT NULL DEFAULT '',
  open_type_code TEXT NOT NULL DEFAULT '',
  condition_code TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_course_audiences_offering
  ON course_audiences(offering_id);

CREATE INDEX IF NOT EXISTS idx_course_audiences_filter
  ON course_audiences(term_key, grade, major, plan_college);

CREATE TABLE IF NOT EXISTS course_source_rows (
  id TEXT PRIMARY KEY,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  term_course_id TEXT NOT NULL DEFAULT '',
  offering_id TEXT NOT NULL DEFAULT '',
  source_key TEXT NOT NULL DEFAULT '',
  package_index INT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'active',
  fields_json JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_course_source_rows_term_status
  ON course_source_rows(term_key, status);

CREATE TABLE IF NOT EXISTS course_meeting_rules (
  id TEXT PRIMARY KEY,
  offering_id TEXT NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  term_course_id TEXT NOT NULL REFERENCES course_term_courses(id) ON DELETE CASCADE,
  catalog_id TEXT NOT NULL REFERENCES course_catalogs(id) ON DELETE CASCADE,
  weekday INT NOT NULL,
  segment_index INT NOT NULL,
  weekday_label TEXT NOT NULL DEFAULT '',
  raw_text TEXT NOT NULL DEFAULT '',
  week_text TEXT NOT NULL DEFAULT '',
  section_text TEXT NOT NULL DEFAULT '',
  location_text TEXT NOT NULL DEFAULT '',
  building TEXT NOT NULL DEFAULT '',
  room TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_course_meeting_rules_offering
  ON course_meeting_rules(offering_id);

CREATE INDEX IF NOT EXISTS idx_course_meeting_rules_weekday
  ON course_meeting_rules(weekday);

CREATE TABLE IF NOT EXISTS course_occurrences (
  id TEXT PRIMARY KEY,
  rule_id TEXT NOT NULL REFERENCES course_meeting_rules(id) ON DELETE CASCADE,
  offering_id TEXT NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
  term_key TEXT NOT NULL REFERENCES school_timetable_terms(term_key) ON DELETE CASCADE,
  term_course_id TEXT NOT NULL REFERENCES course_term_courses(id) ON DELETE CASCADE,
  catalog_id TEXT NOT NULL REFERENCES course_catalogs(id) ON DELETE CASCADE,
  date TEXT NOT NULL,
  week_index INT NOT NULL,
  weekday INT NOT NULL,
  section_text TEXT NOT NULL DEFAULT '',
  location_text TEXT NOT NULL DEFAULT '',
  building TEXT NOT NULL DEFAULT '',
  room TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS idx_course_occurrences_offering
  ON course_occurrences(offering_id);

CREATE INDEX IF NOT EXISTS idx_course_occurrences_date
  ON course_occurrences(date);
