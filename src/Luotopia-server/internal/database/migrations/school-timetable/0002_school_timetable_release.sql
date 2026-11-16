-- 0002 重构全校课表元数据层：精简数据集头、新增学期发行版本表、移除旧 B 系统孤儿表。
-- 幂等性（彻底）：以“目标新表 school_timetable_releases 是否已就位”为总守卫——
--   首批迁移（建表/回填/清理旧表/RENAME）整体封于“目标表不存在”分支内，重放时整块跳过，
--   已就位且非空的 releases 不会被空临时表 RENAME 覆盖（此前版本的缺陷）。
--   回填源使用 entities(term)+dataset（长期存在），不依赖首跑后即 DROP 的 dataset_state。

-- 1. 数据集全局头（替代 dataset_state，移除 term_keys_json 与 bundle_*）
CREATE TABLE IF NOT EXISTS school_timetable_dataset (
  id INTEGER PRIMARY KEY,
  version BIGINT NOT NULL DEFAULT 0,
  checksum TEXT NOT NULL DEFAULT '',
  schema_version INTEGER NOT NULL DEFAULT 1,
  published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DO $$
DECLARE
  legacy_state_exists boolean := EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'school_timetable_dataset_state');
  legacy_releases_exists boolean := EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'school_timetable_releases');
  releases_ready boolean := EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'school_timetable_releases' AND column_name = 'row_count');
BEGIN
  IF releases_ready THEN
    -- 已就位：重放。仅做幂等自愈回填（行缺失才补，已有不动），不重建表、不清理旧表。
    INSERT INTO school_timetable_releases (
      term_key, version, school_year, term, first_week_monday,
      row_count, source, source_checksum, package_checksum,
      bundle_key, bundle_href, bundle_size, bundle_checksum, active, published_at
    )
    SELECT
      e.entity_id, d.version,
      e.payload_json ->> 'school_year', e.payload_json ->> 'term', e.payload_json ->> 'first_week_monday',
      COALESCE((SELECT COUNT(*) FROM school_timetable_entities se WHERE se.entity_type = 'source_row' AND se.term_key = e.entity_id), 0),
      COALESCE(e.payload_json ->> 'source', 'sqlite'), e.payload_json ->> 'source_checksum', '',
      '', '', 0, '', TRUE, d.published_at
    FROM school_timetable_entities e
    JOIN school_timetable_dataset d ON d.id = 1
    WHERE e.entity_type = 'term'
    ON CONFLICT (term_key, version) DO NOTHING;
    RETURN;
  END IF;

  -- —— 首次迁移：用临时名建发行表，避开同名旧表 ——
  CREATE TABLE school_timetable_releases_new (
    term_key TEXT NOT NULL, version BIGINT NOT NULL,
    school_year TEXT NOT NULL DEFAULT '', term TEXT NOT NULL DEFAULT '',
    first_week_monday TEXT NOT NULL DEFAULT '', row_count INTEGER NOT NULL DEFAULT 0,
    source TEXT NOT NULL DEFAULT '', source_checksum TEXT NOT NULL DEFAULT '',
    package_checksum TEXT NOT NULL DEFAULT '',
    bundle_key TEXT NOT NULL DEFAULT '', bundle_href TEXT NOT NULL DEFAULT '',
    bundle_size BIGINT NOT NULL DEFAULT 0, bundle_checksum TEXT NOT NULL DEFAULT '',
    active BOOLEAN NOT NULL DEFAULT FALSE, published_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (term_key, version)
  );
  CREATE INDEX idx_school_timetable_releases_active ON school_timetable_releases_new (term_key, active);

  -- 回填数据集头（优先用旧 dataset_state 的语义化副本，首跑时它存在）
  IF legacy_state_exists THEN
    INSERT INTO school_timetable_dataset (id, version, checksum, schema_version, published_at, updated_at)
    SELECT id, version, checksum, schema_version, published_at, updated_at
    FROM school_timetable_dataset_state ON CONFLICT (id) DO NOTHING;

    INSERT INTO school_timetable_releases_new (
      term_key, version, school_year, term, first_week_monday,
      row_count, source, source_checksum, package_checksum,
      bundle_key, bundle_href, bundle_size, bundle_checksum, active, published_at
    )
    SELECT
      e.entity_id, s.version,
      e.payload_json ->> 'school_year', e.payload_json ->> 'term', e.payload_json ->> 'first_week_monday',
      COALESCE((SELECT COUNT(*) FROM school_timetable_entities se WHERE se.entity_type = 'source_row' AND se.term_key = e.entity_id), 0),
      COALESCE(e.payload_json ->> 'source', 'sqlite'), e.payload_json ->> 'source_checksum', '',
      s.bundle_key, s.bundle_href, COALESCE(s.bundle_size, 0), s.bundle_checksum, TRUE, s.published_at
    FROM school_timetable_entities e JOIN school_timetable_dataset_state s ON s.id = 1
    WHERE e.entity_type = 'term' ON CONFLICT (term_key, version) DO NOTHING;
  END IF;

  -- 旧表清理：旧 B 系统孤儿表（Go 无引用，迁移脚本已在 e23d52f 移除其定义）
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
  IF legacy_state_exists THEN
    EXECUTE 'DROP TABLE IF EXISTS school_timetable_dataset_state';
  END IF;

  -- 临时表就位（旧名已清空，RENAME 必然成功）
  ALTER TABLE school_timetable_releases_new RENAME TO school_timetable_releases;
END $$;
