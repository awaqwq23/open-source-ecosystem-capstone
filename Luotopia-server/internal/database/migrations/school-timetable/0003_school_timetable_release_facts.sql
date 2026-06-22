ALTER TABLE school_timetable_releases
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '';

UPDATE school_timetable_releases
SET release_id = term_key || '@' || version::TEXT
WHERE release_id = '';

CREATE UNIQUE INDEX IF NOT EXISTS idx_school_timetable_releases_release_id
  ON school_timetable_releases(release_id)
  WHERE release_id <> '';

ALTER TABLE course_term_courses
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stable_id TEXT NOT NULL DEFAULT '';

UPDATE course_term_courses c
SET release_id = c.term_key || '@' || t.active_version::TEXT,
    stable_id = c.id
FROM school_timetable_terms t
WHERE c.term_key = t.term_key
  AND c.release_id = '';

ALTER TABLE course_instructor_courses
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stable_id TEXT NOT NULL DEFAULT '';

UPDATE course_instructor_courses c
SET release_id = c.latest_term_key || '@' || t.active_version::TEXT,
    stable_id = c.id
FROM school_timetable_terms t
WHERE c.latest_term_key = t.term_key
  AND c.release_id = '';

ALTER TABLE course_offerings
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stable_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS grade_summary TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS major_summary TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS plan_college_summary TEXT NOT NULL DEFAULT '';

UPDATE course_offerings c
SET release_id = c.term_key || '@' || t.active_version::TEXT,
    stable_id = c.id,
    plan_college_summary = c.audience_summary
FROM school_timetable_terms t
WHERE c.term_key = t.term_key
  AND c.release_id = '';

ALTER TABLE course_audiences
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stable_id TEXT NOT NULL DEFAULT '';

UPDATE course_audiences c
SET release_id = c.term_key || '@' || t.active_version::TEXT,
    stable_id = c.id
FROM school_timetable_terms t
WHERE c.term_key = t.term_key
  AND c.release_id = '';

ALTER TABLE course_source_rows
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stable_id TEXT NOT NULL DEFAULT '';

UPDATE course_source_rows c
SET release_id = c.term_key || '@' || t.active_version::TEXT,
    stable_id = c.id
FROM school_timetable_terms t
WHERE c.term_key = t.term_key
  AND c.release_id = '';

ALTER TABLE course_instances
  ADD COLUMN IF NOT EXISTS release_id TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS stable_id TEXT NOT NULL DEFAULT '';

UPDATE course_instances c
SET release_id = c.term_key || '@' || t.active_version::TEXT,
    stable_id = c.id
FROM school_timetable_terms t
WHERE c.term_key = t.term_key
  AND c.release_id = '';

CREATE TABLE IF NOT EXISTS course_instance_weeks (
  release_id TEXT NOT NULL,
  instance_id TEXT NOT NULL,
  week_index INT NOT NULL,
  PRIMARY KEY (release_id, instance_id, week_index)
);

INSERT INTO course_instance_weeks (release_id, instance_id, week_index)
SELECT c.release_id, c.id, value::INT
FROM course_instances c,
     jsonb_array_elements_text(c.week_indexes) AS value
WHERE c.release_id <> ''
ON CONFLICT DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_course_term_courses_release
  ON course_term_courses(release_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_term_courses_release_stable
  ON course_term_courses(release_id, stable_id)
  WHERE release_id <> '' AND stable_id <> '';

CREATE INDEX IF NOT EXISTS idx_course_instructor_courses_release
  ON course_instructor_courses(release_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_instructor_courses_release_stable
  ON course_instructor_courses(release_id, stable_id)
  WHERE release_id <> '' AND stable_id <> '';

CREATE INDEX IF NOT EXISTS idx_course_offerings_release
  ON course_offerings(release_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_offerings_release_stable
  ON course_offerings(release_id, stable_id)
  WHERE release_id <> '' AND stable_id <> '';

CREATE INDEX IF NOT EXISTS idx_course_audiences_release
  ON course_audiences(release_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_audiences_release_stable
  ON course_audiences(release_id, stable_id)
  WHERE release_id <> '' AND stable_id <> '';

CREATE INDEX IF NOT EXISTS idx_course_source_rows_release
  ON course_source_rows(release_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_source_rows_release_stable
  ON course_source_rows(release_id, stable_id)
  WHERE release_id <> '' AND stable_id <> '';

CREATE INDEX IF NOT EXISTS idx_course_instances_release
  ON course_instances(release_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_course_instances_release_stable
  ON course_instances(release_id, stable_id)
  WHERE release_id <> '' AND stable_id <> '';

CREATE INDEX IF NOT EXISTS idx_course_instance_weeks_week
  ON course_instance_weeks(release_id, week_index, instance_id);
