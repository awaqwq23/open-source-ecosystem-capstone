ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS raw_file_key TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS raw_checksum TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_terms
  ADD COLUMN IF NOT EXISTS raw_size BIGINT NOT NULL DEFAULT 0;

ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS raw_file_key TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS raw_checksum TEXT NOT NULL DEFAULT '';

ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS raw_size BIGINT NOT NULL DEFAULT 0;

DROP TABLE IF EXISTS course_instance_weeks;
DROP TABLE IF EXISTS course_instances;
DROP TABLE IF EXISTS course_source_rows;
DROP TABLE IF EXISTS course_audiences;
DROP TABLE IF EXISTS course_offerings;
DROP TABLE IF EXISTS course_instructor_courses;
DROP TABLE IF EXISTS course_term_courses;
DROP TABLE IF EXISTS course_catalogs;
