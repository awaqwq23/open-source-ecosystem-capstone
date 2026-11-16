-- 0004 引入基底版本机制：changes 记录每段基底版本，dataset 标记可回放基线，
-- 为按学期分组的 changes 归档清理提供安全锚点（详见 GormRepository.PruneChanges）。

-- 1. changes 加 base_version 列；旧行回填为 version-1（历史 changes 基底即导入前数据集版本）
ALTER TABLE school_timetable_changes ADD COLUMN IF NOT EXISTS base_version BIGINT NOT NULL DEFAULT 0;
UPDATE school_timetable_changes SET base_version = version - 1 WHERE base_version = 0 AND version > 0;
-- version=1（首批全量导入）的 base 维持 0：无前序版本，base=0 即“从零起步”

-- 2. dataset 加 min_replayable_version 列；现有数据集起步阶段默认 0（全程可回放，无归档清理）
ALTER TABLE school_timetable_dataset ADD COLUMN IF NOT EXISTS min_replayable_version BIGINT NOT NULL DEFAULT 0;
