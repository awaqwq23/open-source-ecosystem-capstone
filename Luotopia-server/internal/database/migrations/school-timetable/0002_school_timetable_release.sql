-- 0002 重构全校课表元数据层：精简数据集头、新增学期发行版本表、移除旧 B 系统孤儿表。
-- 幂等：以 school_timetable_dataset_state 是否存在作为“首批迁移”守卫，旧 B 系统清理封于其内，
--       重放时不会误删已就位的新表 school_timetable_releases。

-- 1. 数据集全局头（替代 dataset_state，移除 term_keys_json 与 bundle_*）
CREATE TABLE IF NOT EXISTS school_timetable_dataset (
  id INTEGER PRIMARY KEY,
  version BIGINT NOT NULL DEFAULT 0,
  checksum TEXT NOT NULL DEFAULT '',
  schema_version INTEGER NOT NULL DEFAULT 1,
  published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. 学期发行版本表，临时名 releases_new（先避开旧 B 同名表，清理后 rename）
CREATE TABLE IF NOT EXISTS school_timetable_releases_new (
  term_key TEXT NOT NULL,
  version BIGINT NOT NULL,
  school_year TEXT NOT NULL DEFAULT '',
  term TEXT NOT NULL DEFAULT '',
  first_week_monday TEXT NOT NULL DEFAULT '',
  row_count INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT '',
  source_checksum TEXT NOT NULL DEFAULT '',
  package_checksum TEXT NOT NULL DEFAULT '',
  bundle_key TEXT NOT NULL DEFAULT '',
  bundle_href TEXT NOT NULL DEFAULT '',
  bundle_size BIGINT NOT NULL DEFAULT 0,
  bundle_checksum TEXT NOT NULL DEFAULT '',
  active BOOLEAN NOT NULL DEFAULT FALSE,
  published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (term_key, version)
);

CREATE INDEX IF NOT EXISTS idx_school_timetable_releases_active
  ON school_timetable_releases_new (term_key, active);

-- 3. 首批迁移：从旧 dataset_state 回填 dataset 与 releases_new，并清理旧 B 系统孤儿表
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'school_timetable_dataset_state') THEN
    INSERT INTO school_timetable_dataset (id, version, checksum, schema_version, published_at, updated_at)
    SELECT id, version, checksum, schema_version, published_at, updated_at
    FROM school_timetable_dataset_state
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO school_timetable_releases_new (
      term_key, version, school_year, term, first_week_monday,
      row_count, source, source_checksum, package_checksum,
      bundle_key, bundle_href, bundle_size, bundle_checksum, active, published_at
    )
    SELECT
      e.entity_id,
      s.version,
      e.payload_json ->> 'school_year',
      e.payload_json ->> 'term',
      e.payload_json ->> 'first_week_monday',
      COALESCE((SELECT COUNT(*) FROM school_timetable_entities se WHERE se.entity_type = 'source_row' AND se.term_key = e.entity_id), 0),
      COALESCE(e.payload_json ->> 'source', 'sqlite'),
      e.payload_json ->> 'source_checksum',
      '',
      s.bundle_key, s.bundle_href, COALESCE(s.bundle_size, 0), s.bundle_checksum,
      TRUE,
      s.published_at
    FROM school_timetable_entities e
    JOIN school_timetable_dataset_state s ON s.id = 1
    WHERE e.entity_type = 'term'
    ON CONFLICT (term_key, version) DO NOTHING;

    EXECUTE 'DROP TABLE school_timetable_dataset_state';

    -- 清理旧 B 系统孤儿表（无 Go 读写代码，迁移脚本已在 e23d52f 移除其定义）
    EXECUTE 'DROP TABLE IF EXISTS school_timetable_releases CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS school_timetable_terms CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_audiences CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_meeting_rules CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_occurrences CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_offerings CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_source_rows CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_term_courses CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_catalogs CASCADE';
    EXECUTE 'DROP TABLE IF EXISTS course_instructor_courses CASCADE';
  END IF;
END $$;

-- 4. 新表就位（仅当临时表仍存在，幂等）
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'school_timetable_releases_new') THEN
    ALTER TABLE school_timetable_releases_new RENAME TO school_timetable_releases;
  END IF;
END $$;
