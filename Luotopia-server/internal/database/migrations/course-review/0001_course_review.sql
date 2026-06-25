-- 课程评价系统 v1 数据模型。
-- 评价对象 = 全校课表 course_id + teacher_id，直接复用 school_timetable 实体 ID，
-- 不建独立教师体系。course_id / teacher_id 不加外键（全校课表为实体 KV 存储，
-- 由业务层校验目标实体存在），与全校课表跨模块无 FK 的做法一致。
-- 评分语义：difficulty/workload 越高越难/越重，quality/interest 越高越好/越有趣。

-- 评价对象聚合
CREATE TABLE IF NOT EXISTS course_review_subjects (
  id TEXT PRIMARY KEY,                       -- 确定性 id = sha256(course_id || ':' || teacher_id) 的十六进制
  course_id TEXT NOT NULL,
  teacher_id TEXT NOT NULL,
  review_count INTEGER NOT NULL DEFAULT 0,
  avg_difficulty NUMERIC(4, 2),
  avg_workload NUMERIC(4, 2),
  avg_quality NUMERIC(4, 2),
  avg_interest NUMERIC(4, 2),
  grade_sample_count INTEGER NOT NULL DEFAULT 0,
  avg_grade NUMERIC(5, 2),
  latest_review_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL,
  UNIQUE (course_id, teacher_id)
);

-- 单条评价
CREATE TABLE IF NOT EXISTS course_reviews (
  id TEXT PRIMARY KEY,
  subject_id TEXT NOT NULL REFERENCES course_review_subjects(id) ON DELETE CASCADE,
  author_user_id TEXT REFERENCES auth_users(id) ON DELETE SET NULL,
  source TEXT NOT NULL,                     -- user / legacy（v1 仅 user）
  status TEXT NOT NULL,                     -- pending / published / hidden / deleted
  difficulty INTEGER NOT NULL,
  workload INTEGER NOT NULL,
  quality INTEGER NOT NULL,
  interest INTEGER NOT NULL,
  raw_grade_text TEXT,
  grade_value NUMERIC(5, 2),
  final_assessment_text TEXT,
  attendance_text TEXT,
  homework_text TEXT,
  content_text TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL
);

-- 同一用户对同一评价对象仅一条有效（source=user 且未删除）；允许删除后重投，避免重复刷积分
CREATE UNIQUE INDEX IF NOT EXISTS uq_course_reviews_user_subject
  ON course_reviews (author_user_id, subject_id) WHERE source = 'user' AND status <> 'deleted';

CREATE INDEX IF NOT EXISTS idx_reviews_subject_status_created
  ON course_reviews (subject_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reviews_author_created
  ON course_reviews (author_user_id, created_at DESC);

-- 积分钱包
CREATE TABLE IF NOT EXISTS course_review_user_wallets (
  user_id TEXT PRIMARY KEY REFERENCES auth_users(id) ON DELETE CASCADE,
  balance INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ NOT NULL
);

-- 积分流水
CREATE TABLE IF NOT EXISTS course_review_point_ledger (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  delta INTEGER NOT NULL,
  reason TEXT NOT NULL,                     -- review_published / redeem_access / admin_adjust
  review_id TEXT REFERENCES course_reviews(id) ON DELETE SET NULL,
  access_grant_id TEXT,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_ledger_user_created
  ON course_review_point_ledger (user_id, created_at DESC);

-- 查询权限授权
CREATE TABLE IF NOT EXISTS course_review_access_grants (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
  starts_at TIMESTAMPTZ NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  source_ledger_id TEXT REFERENCES course_review_point_ledger(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_access_grants_user_window
  ON course_review_access_grants (user_id, starts_at, expires_at);
