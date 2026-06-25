package app

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	"github.com/openwhu/luotopia/server/internal/platform/storage"
)

type Repository interface {
	CurrentDataset(ctx context.Context) (domain.DatasetState, error)
	ListEntities(ctx context.Context) ([]domain.EntityRecord, error)
	ListEntitiesByTerm(ctx context.Context, termKey string) ([]domain.EntityRecord, error)
	ApplyImport(ctx context.Context, pkg domain.Package, preview domain.ImportPreview, progress ProgressFunc) error
	ChangesAfter(ctx context.Context, version int64, limit int) ([]domain.EntityChange, domain.DatasetState, error)
	ListTerms(ctx context.Context) ([]domain.Term, error)
	UpdateBundle(ctx context.Context, version int64, bundle domain.DatasetBundle) error
	PruneChanges(ctx context.Context) error
}

type BundleStore interface {
	Put(ctx context.Context, object storage.Object) error
	PublicURL(key string) string
}

type ProgressFunc func(current, total int, message string)

type jobManager struct {
	mu   sync.Mutex
	jobs map[string]*domain.ImportJob
	seq  int64
}

func newJobManager() *jobManager {
	return &jobManager{jobs: make(map[string]*domain.ImportJob)}
}

func (jm *jobManager) create(job domain.ImportJob) string {
	jm.mu.Lock()
	defer jm.mu.Unlock()
	jm.seq++
	id := fmt.Sprintf("job_%d", jm.seq)
	job.ID = id
	jm.jobs[id] = &job
	return id
}

func (jm *jobManager) get(id string) *domain.ImportJob {
	jm.mu.Lock()
	defer jm.mu.Unlock()
	job, ok := jm.jobs[id]
	if !ok {
		return nil
	}
	copy := *job
	return &copy
}

func (jm *jobManager) update(id string, fn func(job *domain.ImportJob)) {
	jm.mu.Lock()
	defer jm.mu.Unlock()
	if job, ok := jm.jobs[id]; ok {
		fn(job)
		job.UpdatedAt = time.Now().UnixMilli()
	}
}

type Service struct {
	repo        Repository
	bundleStore BundleStore
	jobs        *jobManager
	uploads     *uploadManager
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo, jobs: newJobManager(), uploads: newUploadManager("")}
}

func NewServiceWithBundleStore(repo Repository, store BundleStore) *Service {
	return &Service{repo: repo, bundleStore: store, jobs: newJobManager(), uploads: newUploadManager("")}
}

func (s *Service) CreateUpload(fileName string, size int64) (UploadSession, error) {
	return s.uploads.create(fileName, size)
}

func (s *Service) GetUpload(id string) (UploadSession, error) {
	session, ok := s.uploads.get(id)
	if !ok {
		return UploadSession{}, ErrNotFound
	}
	return session, nil
}

func (s *Service) SaveUploadChunk(id string, index int, reader io.Reader) (UploadSession, error) {
	return s.uploads.saveChunk(id, index, reader)
}

func (s *Service) CompleteUpload(id string) (UploadSession, error) {
	return s.uploads.complete(id)
}

func (s *Service) StartValidateUpload(uploadID string) (string, error) {
	if _, err := s.uploads.packagePath(uploadID); err != nil {
		return "", err
	}
	jobID := s.jobs.create(domain.ImportJob{
		Status:    domain.JobStatusPending,
		Progress:  "等待预检",
		CreatedAt: time.Now().UnixMilli(),
		UpdatedAt: time.Now().UnixMilli(),
	})
	go func() {
		ctx := context.Background()
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusRunning
			job.Progress = "读取数据包"
		})
		data, err := s.readUploadPackage(uploadID)
		if err != nil {
			s.jobs.update(jobID, func(job *domain.ImportJob) {
				job.Status = domain.JobStatusFailed
				job.Error = err.Error()
			})
			return
		}
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusRunning
			job.Progress = "解析并生成预览"
		})
		result, err := s.validatePackageBytes(ctx, data)
		if err != nil {
			s.jobs.update(jobID, func(job *domain.ImportJob) {
				job.Status = domain.JobStatusFailed
				job.Error = err.Error()
			})
			return
		}
		if result.Preview != nil {
			result.Preview.AllChanges = nil
		}
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusCompleted
			job.Progress = "预检完成"
			job.Result = &result
		})
	}()
	return jobID, nil
}

func (s *Service) StartUploadImport(uploadID string) (string, error) {
	if _, err := s.uploads.packagePath(uploadID); err != nil {
		return "", err
	}
	jobID := s.createImportJob()
	go func() {
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusRunning
			job.Progress = "读取数据包"
		})
		data, err := s.readUploadPackage(uploadID)
		if err != nil {
			s.jobs.update(jobID, func(job *domain.ImportJob) {
				job.Status = domain.JobStatusFailed
				job.Error = err.Error()
			})
			return
		}
		s.runImportJob(jobID, data)
	}()
	return jobID, nil
}

func (s *Service) readUploadPackage(uploadID string) ([]byte, error) {
	path, err := s.uploads.packagePath(uploadID)
	if err != nil {
		return nil, err
	}
	cleanPath := filepath.Clean(path)
	return os.ReadFile(cleanPath)
}

func (s *Service) validatePackageBytes(ctx context.Context, data []byte) (domain.ImportResult, error) {
	pkg, err := ParsePackage(ctx, bytes.NewReader(data))
	if err != nil {
		return domain.ImportResult{}, err
	}
	if err := validateFirstWeekMonday(pkg.Manifest.FirstWeekMonday); err != nil {
		return domain.ImportResult{}, err
	}
	preview, err := s.previewImport(ctx, pkg, PackageChecksum(data), 100)
	if err != nil {
		return domain.ImportResult{}, err
	}
	return domain.ImportResult{
		Manifest: pkg.Manifest,
		Checksum: PackageChecksum(data),
		RowCount: pkg.Manifest.RowCount,
		Version:  preview.NextVersion,
		Preview:  &preview,
	}, nil
}

func (s *Service) createImportJob() string {
	return s.jobs.create(domain.ImportJob{
		Status:    domain.JobStatusPending,
		Progress:  "等待处理",
		CreatedAt: time.Now().UnixMilli(),
		UpdatedAt: time.Now().UnixMilli(),
	})
}

func (s *Service) runImportJob(jobID string, data []byte) {
	ctx := context.Background()
	report := func(progress string) {
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusRunning
			job.Progress = progress
		})
	}
	fail := func(err error) {
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusFailed
			job.Error = err.Error()
		})
	}
	report("解析数据包")
	pkg, err := ParsePackage(ctx, bytes.NewReader(data))
	if err != nil {
		fail(fmt.Errorf("解析数据包失败: %w", err))
		return
	}
	if err := validateFirstWeekMonday(pkg.Manifest.FirstWeekMonday); err != nil {
		fail(fmt.Errorf("数据包校验失败: %w", err))
		return
	}
	report("生成变更集")
	rawChecksum := PackageChecksum(data)
	preview, err := s.previewImport(ctx, pkg, rawChecksum, 0)
	if err != nil {
		fail(fmt.Errorf("变更集生成失败: %w", err))
		return
	}
	// 无变更：不推进版本、不写库（同包重复发布为 no-op）。
	// 但若当前激活发行缺离线包，补算一次（用当前版本），保证客户端降级整包可用。
	emptyChanges := len(preview.AllChanges) == 0 && len(preview.Changes) == 0
	if emptyChanges {
		current, _ := s.CurrentBundle(ctx)
		if current == nil || current.Href == "" {
			report("补算离线包")
			bundleProgress := func(current2, total int, message string) {
				pct := 0
				if total > 0 {
					pct = current2 * 100 / total
				}
				s.jobs.update(jobID, func(job *domain.ImportJob) {
					job.Status = domain.JobStatusRunning
					job.Progress = fmt.Sprintf("构建离线包 %d%%（%s）", pct, message)
				})
			}
			curState, err := s.repo.CurrentDataset(ctx)
			if err == nil && curState.Version > 0 {
				if err := s.publishBundle(ctx, curState.Version, bundleProgress); err != nil {
					fail(fmt.Errorf("补算离线包失败: %w", err))
					return
				}
			}
		}
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusCompleted
			job.Progress = "完成（无变更）"
			job.Result = &domain.ImportResult{
				Manifest: pkg.Manifest, Checksum: rawChecksum,
				RowCount: pkg.Manifest.RowCount, Version: preview.BaseVersion,
				Preview: &preview,
			}
		})
		return
	}
	report("写入数据库")
	progress := func(current, total int, message string) {
		pct := 0
		if total > 0 {
			pct = current * 100 / total
		}
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusRunning
			job.Progress = fmt.Sprintf("写入数据库 %d%%（%d/%d）", pct, current, total)
		})
	}
	if err := s.repo.ApplyImport(ctx, pkg, preview, progress); err != nil {
		fail(fmt.Errorf("写入数据库失败: %w", err))
		return
	}
	report("构建并上传离线包")
	bundleProgress := func(current, total int, message string) {
		pct := 0
		if total > 0 {
			pct = current * 100 / total
		}
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Status = domain.JobStatusRunning
			job.Progress = fmt.Sprintf("构建离线包 %d%%（%s）", pct, message)
		})
	}
	if err := s.publishBundle(ctx, preview.NextVersion, bundleProgress); err != nil {
		fail(fmt.Errorf("发布离线包失败: %w", err))
		return
	}
	// 归档清理：按学期分组锚定激活基底，删除可安全裁去的旧版 changes。
	// 失败不影响导入结果（数据已落库），仅记录以便后续补偿。
	if err := s.repo.PruneChanges(ctx); err != nil {
		s.jobs.update(jobID, func(job *domain.ImportJob) {
			job.Progress = "完成（归档清理失败）"
		})
	}
	if len(preview.Changes) > 100 {
		preview.Changes = preview.Changes[:100]
	}
	preview.AllChanges = nil
	s.jobs.update(jobID, func(job *domain.ImportJob) {
		job.Status = domain.JobStatusCompleted
		job.Progress = "完成"
		job.Result = &domain.ImportResult{
			Manifest: pkg.Manifest,
			Checksum: rawChecksum,
			RowCount: pkg.Manifest.RowCount,
			Version:  preview.NextVersion,
			Preview:  &preview,
		}
	})
}

func (s *Service) GetImportJob(ctx context.Context, id string) (*domain.ImportJob, error) {
	job := s.jobs.get(id)
	if job == nil {
		return nil, ErrNotFound
	}
	return job, nil
}

func (s *Service) CurrentDataset(ctx context.Context) (domain.DatasetState, error) {
	return s.repo.CurrentDataset(ctx)
}

func (s *Service) ChangesAfter(ctx context.Context, version int64, limit int) ([]domain.EntityChange, domain.DatasetState, error) {
	return s.repo.ChangesAfter(ctx, version, limit)
}

func (s *Service) CurrentBundle(ctx context.Context) (*domain.DatasetBundle, error) {
	state, err := s.repo.CurrentDataset(ctx)
	if err != nil {
		return nil, err
	}
	if state.Bundle == nil || state.Bundle.Href == "" {
		return nil, ErrNotFound
	}
	return state.Bundle, nil
}

func (s *Service) ListTerms(ctx context.Context) ([]domain.Term, error) {
	return s.repo.ListTerms(ctx)
}

func (s *Service) previewImport(ctx context.Context, pkg domain.Package, packageChecksum string, limit int) (domain.ImportPreview, error) {
	state, err := s.repo.CurrentDataset(ctx)
	if err != nil {
		return domain.ImportPreview{}, err
	}
	existing, err := s.repo.ListEntitiesByTerm(ctx, pkg.Manifest.TermKey)
	if err != nil {
		return domain.ImportPreview{}, err
	}
	nextVersion := state.Version + 1
	records := BuildRecords(pkg, int(nextVersion))
	incoming, counts, err := flattenRecords(pkg, records)
	if err != nil {
		return domain.ImportPreview{}, err
	}
	previous := make(map[string]domain.EntityRecord, len(existing))
	for _, entity := range existing {
		previous[entityKey(entity.EntityType, entity.EntityID)] = entity
	}
	changes := make([]domain.EntityChange, 0)
	keys := make([]string, 0, len(incoming))
	for key := range incoming {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		entity := incoming[key]
		old, ok := previous[key]
		if ok && old.PayloadChecksum == entity.PayloadChecksum {
			delete(previous, key)
			continue
		}
		changes = append(changes, domain.EntityChange{
			Version: nextVersion, Operation: "upsert", EntityType: entity.EntityType,
			EntityID: entity.EntityID, TermKey: entity.TermKey, Payload: entity.Payload,
			BaseVersion: state.Version,
		})
		delete(previous, key)
	}
	deleteKeys := make([]string, 0, len(previous))
	for key := range previous {
		deleteKeys = append(deleteKeys, key)
	}
	sort.Strings(deleteKeys)
	for _, key := range deleteKeys {
		entity := previous[key]
		if isSharedSchoolTimetableEntity(entity.EntityType) {
			continue
		}
		changes = append(changes, domain.EntityChange{
			Version: nextVersion, Operation: "delete", EntityType: entity.EntityType,
			EntityID: entity.EntityID, TermKey: entity.TermKey,
			BaseVersion: state.Version,
		})
	}
	upserts := 0
	deletes := 0
	for i := range changes {
		changes[i].Sequence = i + 1
		if changes[i].Operation == "delete" {
			deletes++
		} else {
			upserts++
		}
	}
	previewChanges := changes
	if limit > 0 && len(previewChanges) > limit {
		previewChanges = previewChanges[:limit]
	}
	return domain.ImportPreview{
		BaseVersion: state.Version, NextVersion: nextVersion, TermKey: pkg.Manifest.TermKey,
		Checksum: packageChecksum, Upserts: upserts, Deletes: deletes,
		EntityCounts: counts, Changes: previewChanges, AllChanges: changes,
	}, nil
}

func flattenRecords(pkg domain.Package, records Records) (map[string]domain.EntityRecord, map[string]int, error) {
	entities := make(map[string]domain.EntityRecord)
	counts := make(map[string]int)
	add := func(entityType, entityID, termKey string, payload any) error {
		data, err := json.Marshal(payload)
		if err != nil {
			return err
		}
		sum := sha256.Sum256(data)
		record := domain.EntityRecord{
			EntityType: entityType, EntityID: entityID, TermKey: termKey,
			Payload: data, PayloadChecksum: "sha256:" + hex.EncodeToString(sum[:]),
		}
		entities[entityKey(entityType, entityID)] = record
		counts[entityType]++
		return nil
	}
	termPayload := map[string]any{
		"term_key": pkg.Manifest.TermKey, "school_year": pkg.Manifest.SchoolYear,
		"term": pkg.Manifest.Term, "school_year_code": pkg.Manifest.SchoolYearCode,
		"term_code": pkg.Manifest.TermCode, "first_week_monday": pkg.Manifest.FirstWeekMonday,
		"row_count": pkg.Manifest.RowCount, "source": pkg.Manifest.Source,
		"source_checksum": pkg.Manifest.SourceChecksum,
	}
	if err := add("term", pkg.Manifest.TermKey, pkg.Manifest.TermKey, termPayload); err != nil {
		return nil, nil, err
	}
	for _, item := range records.Courses {
		if err := add("course", item.ID, "", item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.Teachers {
		if err := add("teacher", item.ID, "", item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.Offerings {
		if err := add("offering", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.OfferingTeachers {
		if err := add("offering_teacher", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.Audiences {
		if err := add("audience", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.Meetings {
		if err := add("meeting", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.SourceRows {
		if err := add("source_row", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	// 用实际源行数回填 term 元数据，避免依赖源包自报的 RowCount（可能为 0），与 release.row_count 同源。
	if termEnt, ok := entities[entityKey("term", pkg.Manifest.TermKey)]; ok {
		var tp map[string]any
		if err := json.Unmarshal(termEnt.Payload, &tp); err == nil {
			tp["row_count"] = counts["source_row"]
			if data, err := json.Marshal(tp); err == nil {
				sum := sha256.Sum256(data)
				entities[entityKey("term", pkg.Manifest.TermKey)] = domain.EntityRecord{
					EntityType: "term", EntityID: pkg.Manifest.TermKey, TermKey: pkg.Manifest.TermKey,
					Payload: data, PayloadChecksum: "sha256:" + hex.EncodeToString(sum[:]),
				}
			}
		}
	}
	return entities, counts, nil
}

func entityKey(entityType, entityID string) string {
	return entityType + "\x1f" + entityID
}

func isSharedSchoolTimetableEntity(entityType string) bool {
	return entityType == "course" || entityType == "teacher"
}

// isNonSyncSchoolTimetableEntity 标记仅服务端留档、不下发客户端的实体（目前为 source_row）：
// 不进客户端 bundle，也不出现在下发给客户端的 changes 流里。
func isNonSyncSchoolTimetableEntity(entityType string) bool {
	return entityType == "source_row"
}

type Records struct {
	Courses          []domain.Course
	Teachers         []domain.Teacher
	Offerings        []domain.CourseOffering
	OfferingTeachers []domain.OfferingTeacher
	Audiences        []domain.CourseAudience
	Meetings         []domain.Meeting
	SourceRows       []domain.SourceRow
}

func BuildRecords(pkg domain.Package, version int) Records {
	return Records{
		Courses:          pkg.Courses,
		Teachers:         pkg.Teachers,
		Offerings:        pkg.Offerings,
		OfferingTeachers: pkg.OfferingTeachers,
		Audiences:        pkg.Audiences,
		Meetings:         pkg.Meetings,
		SourceRows:       pkg.SourceRows,
	}
}

func validateFirstWeekMonday(value string) error {
	parsed, err := time.Parse("2006-01-02", strings.TrimSpace(value))
	if err != nil {
		return fmt.Errorf("%w: first_week_monday", ErrInvalidPackage)
	}
	if parsed.Weekday() != time.Monday {
		return fmt.Errorf("%w: first_week_monday is not monday", ErrInvalidPackage)
	}
	return nil
}
