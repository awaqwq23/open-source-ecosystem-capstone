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
	"regexp"
	"sort"
	"strconv"
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
		RowCount: packageRowCount(pkg),
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
			RowCount: packageRowCount(pkg),
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
		"term": pkg.Manifest.Term, "first_week_monday": pkg.Manifest.FirstWeekMonday,
		"row_count": packageRowCount(pkg), "source": pkg.Manifest.Source,
		"source_checksum": pkg.Manifest.SourceChecksum,
	}
	if err := add("term", pkg.Manifest.TermKey, pkg.Manifest.TermKey, termPayload); err != nil {
		return nil, nil, err
	}
	for _, item := range records.Catalogs {
		if err := add("course", item.ID, "", item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.TermCourses {
		if err := add("term_course", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.InstructorCourses {
		if err := add("instructor_course", item.ID, "", item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.Offerings {
		if err := add("offering", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.Audiences {
		if err := add("audience", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	for _, item := range records.CourseInstances {
		if err := add("meeting_rule", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
		for _, week := range item.WeekIndexes {
			payload := map[string]any{"meeting_rule_id": item.ID, "week_index": week, "term_key": item.TermKey}
			if err := add("meeting_week", item.ID+":"+strconv.Itoa(week), item.TermKey, payload); err != nil {
				return nil, nil, err
			}
		}
	}
	for _, item := range records.SourceRows {
		if err := add("source_row", item.ID, item.TermKey, item); err != nil {
			return nil, nil, err
		}
	}
	return entities, counts, nil
}

func packageRowCount(pkg domain.Package) int {
	if pkg.Manifest.RowCount > 0 {
		return pkg.Manifest.RowCount
	}
	if len(pkg.SourceRows) > 0 {
		return len(pkg.SourceRows)
	}
	return len(pkg.Rows)
}

func entityKey(entityType, entityID string) string {
	return entityType + "\x1f" + entityID
}

func isSharedSchoolTimetableEntity(entityType string) bool {
	return entityType == "course" || entityType == "instructor_course"
}

type Records struct {
	Catalogs          []domain.CourseCatalog
	TermCourses       []domain.TermCourse
	InstructorCourses []domain.InstructorCourse
	Offerings         []domain.CourseOffering
	Audiences         []domain.CourseAudience
	SourceRows        []domain.SourceRow
	CourseInstances   []domain.CourseInstance
}

func BuildRecords(pkg domain.Package, version int) Records {
	if len(pkg.Catalogs)+len(pkg.TermCourses)+len(pkg.InstructorCourses)+len(pkg.Offerings)+len(pkg.Audiences)+len(pkg.SourceRows)+len(pkg.CourseInstances) > 0 {
		return Records{
			Catalogs:          pkg.Catalogs,
			TermCourses:       pkg.TermCourses,
			InstructorCourses: pkg.InstructorCourses,
			Offerings:         pkg.Offerings,
			Audiences:         pkg.Audiences,
			SourceRows:        pkg.SourceRows,
			CourseInstances:   pkg.CourseInstances,
		}
	}
	sourceRows := make([]domain.SourceRow, 0, len(pkg.Rows))
	instanceRecords := make([]domain.CourseInstance, 0, len(pkg.Rows))
	termCourseRows := make(map[string][]map[string]string)
	offeringRows := make(map[string][]map[string]string)
	offeringOrder := make([]string, 0, len(pkg.Rows))
	sourceOrdinals := make(map[string]int, len(pkg.Rows))

	for index, row := range pkg.Rows {
		canonical := canonicalSourceRow(row)
		sourceOrdinals[canonical]++
		sourceID := sourceRowID(pkg.Manifest.TermKey, canonical, sourceOrdinals[canonical])
		if !canBuildEntity(row) {
			sourceRows = append(sourceRows, domain.SourceRow{
				ID: sourceID, TermKey: pkg.Manifest.TermKey, SourceKey: row["key"],
				PackageIndex: index + 1, Status: "incomplete", Fields: row,
			})
			continue
		}
		catalogID := courseCatalogID(row)
		termCourseID := termCourseID(pkg.Manifest.TermKey, catalogID)
		offeringID := courseOfferingID(pkg.Manifest.TermKey, row)
		termCourseRows[termCourseID] = append(termCourseRows[termCourseID], row)
		if _, ok := offeringRows[offeringID]; !ok {
			offeringOrder = append(offeringOrder, offeringID)
		}
		offeringRows[offeringID] = append(offeringRows[offeringID], row)
		sourceRows = append(sourceRows, domain.SourceRow{
			ID: sourceID, TermKey: pkg.Manifest.TermKey, TermCourseID: termCourseID, OfferingID: offeringID,
			SourceKey: row["key"], PackageIndex: index + 1, Status: "active", Fields: row,
		})
	}

	offerings := make([]domain.CourseOffering, 0, len(offeringRows))
	audienceByID := make(map[string]domain.CourseAudience)
	instructorByID := make(map[string]domain.InstructorCourse)
	for _, id := range offeringOrder {
		rows := offeringRows[id]
		first := rows[0]
		catalogID := courseCatalogID(first)
		termCourseID := termCourseID(pkg.Manifest.TermKey, catalogID)
		instructorName := uniqueSummary(mapValues(rows, "jsxm"), 3, "位教师")
		instructorSetKey := teacherSetKey(mapValues(rows, "jsxm"))
		instructorID := instructorCourseID(catalogID, instructorSetKey)
		audienceSummary := audienceSummary(rows)
		gradeSummary := uniqueSummary(mapValues(rows, "nj"), 3, "个年级")
		majorSummary := uniqueSummary(mapValues(rows, "jszy"), 3, "个专业")
		planCollegeSummary := uniqueSummary(mapValues(rows, "jhxy"), 3, "个学院")
		capacity, selectedCount := parsePeopleCount(first["skrs"])
		scheduleKey := scheduleSignature(first)
		searchText := strings.Join(nonEmpty([]string{
			first["kcmc"], first["yskch"], first["jxbmc"], first["skxy"], instructorName, audienceSummary,
			first["xkbz"], first["qtjs"], first["jcmc"],
		}), " ")
		offerings = append(offerings, domain.CourseOffering{
			ID: id, TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			TermCourseID: termCourseID, CatalogID: catalogID, InstructorCourseID: instructorID,
			SourceKey: first["key"], TeachingClassName: first["jxbmc"], CourseNo: first["yskch"],
			CourseName: first["kcmc"], OpenCollege: first["skxy"], Credits: first["kcxf"],
			CourseNature: first["kcxzmc"], CourseCategory: first["kclbmc"], OpenType: first["kklxmc"],
			Instructor: instructorName, InstructorKey: normalizeKey(instructorName), InstructorSetKey: instructorSetKey,
			Title: first["jszc"], PeopleRaw: first["skrs"], Capacity: capacity, SelectedCount: selectedCount,
			TheoryHours: first["xsdm_01"], ComputerHours: first["xsdm_02"],
			ExperimentHours: first["xsdm_03"], PracticeHours: first["xsdm_04"], Remark: first["xkbz"],
			OtherTeachers: first["qtjs"], Textbook: first["jcmc"], Publisher: first["cbs"],
			ScheduleSignature: scheduleKey, ScheduleKey: scheduleKey, ScheduleSummary: scheduleSummary(first),
			WeekdaySummary:  strings.Join(weekdaySummaries([]map[string]string{first}), "、"),
			AudienceSummary: audienceSummary, GradeSummary: gradeSummary, MajorSummary: majorSummary,
			PlanCollegeSummary: planCollegeSummary, SourceRowCount: len(rows), SearchText: searchText, Fields: first,
		})
		instructorByID[instructorID] = domain.InstructorCourse{
			ID: instructorID, CatalogID: catalogID, CourseNo: first["yskch"], CourseName: first["kcmc"],
			Credits: first["kcxf"], InstructorName: instructorName, InstructorNameKey: normalizeKey(instructorName),
			LatestTermKey: pkg.Manifest.TermKey, LatestOpenCollege: first["skxy"], LatestTeachingTitle: first["jszc"],
			SearchText: strings.Join(nonEmpty([]string{first["kcmc"], first["yskch"], instructorName, first["skxy"]}), " "),
		}
		instances := courseInstancesForRow(pkg.Manifest.TermKey, termCourseID, catalogID, id, first)
		instanceRecords = append(instanceRecords, instances...)
		for _, row := range rows {
			audience := domain.CourseAudience{
				ID: courseAudienceID(id, row), TermKey: pkg.Manifest.TermKey,
				OfferingID: id, TermCourseID: termCourseID, CatalogID: catalogID, Grade: row["nj"], Major: row["jszy"],
				PlanCollege: row["jhxy"], CourseNature: row["kcxzmc"], CourseNatureCode: row["kcxzdm"],
				CourseCategory: row["kclbmc"], CourseCategoryCode: row["kclbdm"],
				OpenType: row["kklxmc"], OpenTypeCode: row["kklxdm"], ConditionCode: row["kkbm_id2"],
			}
			audienceByID[audience.ID] = audience
		}
	}

	termCourses := make([]domain.TermCourse, 0, len(termCourseRows))
	catalogByID := make(map[string]domain.CourseCatalog)
	for id, rows := range termCourseRows {
		first := rows[0]
		catalogID := courseCatalogID(first)
		catalogByID[catalogID] = domain.CourseCatalog{
			ID: catalogID, CatalogKey: catalogKey(first), CourseNo: first["yskch"],
			CourseName: first["kcmc"], Credits: first["kcxf"],
			SearchText: strings.Join(nonEmpty([]string{first["kcmc"], first["yskch"], first["kcxf"]}), " "),
		}
		teachers := uniqueSummary(mapValues(rows, "jsxm"), 3, "位教师")
		weekdays := uniqueSummary(weekdaySummaries(rows), 4, "组时间")
		searchText := strings.Join(nonEmpty([]string{
			first["kcmc"], first["yskch"], first["skxy"], first["kcxzmc"], first["kclbmc"], first["kklxmc"], teachers, weekdays,
		}), " ")
		termCourses = append(termCourses, domain.TermCourse{
			ID: id, TermKey: pkg.Manifest.TermKey, CatalogID: catalogID, CourseNo: first["yskch"],
			CourseName: first["kcmc"], OpenCollege: first["skxy"], Credits: first["kcxf"],
			CourseNature: first["kcxzmc"], CourseCategory: first["kclbmc"], OpenType: first["kklxmc"],
			TeachingClassCount: countOfferingsForTermCourse(offerings, id), TeacherSummary: teachers,
			WeekdaySummary: weekdays, SearchText: searchText,
		})
	}
	catalogs := sortedCatalogs(catalogByID)
	audiences := sortedAudiences(audienceByID)
	instructorCourses := sortedInstructorCourses(instructorByID)
	countInstructorOfferings(instructorCourses, offerings)
	sort.Slice(termCourses, func(i, j int) bool { return termCourses[i].ID < termCourses[j].ID })
	sort.Slice(offerings, func(i, j int) bool { return offerings[i].ID < offerings[j].ID })
	sort.Slice(instanceRecords, func(i, j int) bool { return instanceRecords[i].ID < instanceRecords[j].ID })
	records := Records{
		Catalogs: catalogs, TermCourses: termCourses, InstructorCourses: instructorCourses,
		Offerings: offerings, Audiences: audiences, SourceRows: sourceRows,
		CourseInstances: instanceRecords,
	}
	return records
}

var weekdayFields = []struct {
	index int
	code  string
	label string
}{
	{0, "sun", "周日"}, {1, "mon", "周一"}, {2, "tue", "周二"}, {3, "wen", "周三"},
	{4, "thu", "周四"}, {5, "fri", "周五"}, {6, "sat", "周六"},
}

func courseInstancesForRow(termKey, termCourseID, catalogID, offeringID string, row map[string]string) []domain.CourseInstance {
	result := make([]domain.CourseInstance, 0, 2)
	for _, field := range weekdayFields {
		raw := strings.TrimSpace(row[field.code])
		if raw == "" {
			continue
		}
		segments := splitScheduleSegments(raw)
		for segmentIndex, segment := range segments {
			weeks := parseWeekIndexes(segment)
			sectionStart, sectionEnd, sectionText := parseSectionRange(segment)
			weekText := extractFirst(segment, `\d+(?:-\d+)?周(?:\((?:单|双)\))?`)
			location := extractLocationText(segment)
			parseStatus := "parsed"
			if len(weeks) == 0 || sectionStart == 0 || sectionEnd == 0 {
				parseStatus = "partial"
			}
			instanceID := stableID(
				"course_instance",
				offeringID,
				fmt.Sprintf("%d", field.index),
				fmt.Sprintf("%d", segmentIndex),
				intListKey(weeks),
				fmt.Sprintf("%d", sectionStart),
				fmt.Sprintf("%d", sectionEnd),
				normalizeLocationKey(location),
			)
			result = append(result, domain.CourseInstance{
				ID: instanceID, OfferingID: offeringID, TermKey: termKey, TermCourseID: termCourseID, CatalogID: catalogID,
				Weekday: field.index, DayField: field.code, SegmentIndex: segmentIndex, WeekdayLabel: field.label,
				RawDayText: raw, RawSegmentText: segment, WeekText: weekText, SectionText: sectionText,
				SectionStart: sectionStart, SectionEnd: sectionEnd, LocationText: location, WeekIndexes: weeks,
				ParseStatus: parseStatus,
			})
		}
	}
	return result
}

type weekSpan struct {
	start  int
	end    int
	parity string
}

func splitScheduleSegments(raw string) []string {
	parts := regexp.MustCompile(`[，,;；]`).Split(raw, -1)
	result := make([]string, 0, len(parts))
	var current []string
	for index, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		current = append(current, part)
		segment := strings.Join(current, ",")
		if extractFirst(segment, `\d+(?:-\d+)?节`) == "" {
			continue
		}
		if index == len(parts)-1 || looksLikeWeekStart(parts[index+1]) {
			result = append(result, segment)
			current = nil
		}
	}
	if len(current) > 0 {
		result = append(result, strings.Join(current, ","))
	}
	if len(result) == 0 && strings.TrimSpace(raw) != "" {
		return []string{strings.TrimSpace(raw)}
	}
	return result
}

func looksLikeWeekStart(raw string) bool {
	return regexp.MustCompile(`^\s*\d+(?:-\d+)?周`).MatchString(raw)
}

func parseWeekSpans(raw string) []weekSpan {
	re := regexp.MustCompile(`(\d+)(?:-(\d+))?周(?:\((单|双)\))?`)
	matches := re.FindAllStringSubmatch(raw, -1)
	result := make([]weekSpan, 0, len(matches))
	for _, match := range matches {
		start, _ := strconv.Atoi(match[1])
		end := start
		if match[2] != "" {
			end, _ = strconv.Atoi(match[2])
		}
		if start <= 0 || end < start {
			continue
		}
		result = append(result, weekSpan{start: start, end: end, parity: match[3]})
	}
	return result
}

func parseWeekIndexes(raw string) []int {
	spans := parseWeekSpans(raw)
	seen := map[int]struct{}{}
	result := make([]int, 0, 16)
	for _, span := range spans {
		for index := span.start; index <= span.end; index++ {
			if span.parity == "单" && index%2 == 0 {
				continue
			}
			if span.parity == "双" && index%2 != 0 {
				continue
			}
			if _, ok := seen[index]; ok {
				continue
			}
			seen[index] = struct{}{}
			result = append(result, index)
		}
	}
	sort.Ints(result)
	return result
}

func parseSectionRange(raw string) (int, int, string) {
	match := regexp.MustCompile(`(\d+)(?:-(\d+))?节`).FindStringSubmatch(raw)
	if len(match) == 0 {
		return 0, 0, ""
	}
	start, _ := strconv.Atoi(match[1])
	end := start
	if match[2] != "" {
		end, _ = strconv.Atoi(match[2])
	}
	if start <= 0 || end < start {
		return 0, 0, ""
	}
	return start, end, match[0]
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

func sourceRowID(termKey, canonical string, ordinal int) string {
	return stableID("source", termKey, canonical, fmt.Sprintf("%d", ordinal))
}

func canonicalSourceRow(row map[string]string) string {
	keys := make([]string, 0, len(row))
	for key := range row {
		if strings.HasPrefix(key, "_source_") {
			continue
		}
		keys = append(keys, key)
	}
	sort.Strings(keys)
	ordered := make(map[string]string, len(row))
	for _, key := range keys {
		ordered[key] = row[key]
	}
	data, _ := json.Marshal(ordered)
	return string(data)
}

func canBuildEntity(row map[string]string) bool {
	for _, field := range []string{"xn", "xq", "jxbmc", "yskch", "kcmc", "skxy", "kcxf", "jsxm", "skrs"} {
		if strings.TrimSpace(row[field]) == "" {
			return false
		}
	}
	return true
}

func catalogKey(row map[string]string) string {
	return strings.Join([]string{normalizeKey(row["yskch"]), normalizeKey(row["kcmc"]), normalizeKey(row["kcxf"])}, "\x1f")
}

func courseCatalogID(row map[string]string) string {
	return stableID("catalog", row["yskch"], row["kcmc"], row["kcxf"])
}

func termCourseID(termKey, catalogID string) string {
	return stableID("term_course", termKey, catalogID)
}

func instructorCourseID(catalogID, instructorName string) string {
	return stableID("instructor_course", catalogID, instructorName)
}

func courseOfferingID(termKey string, row map[string]string) string {
	catalogID := courseCatalogID(row)
	return stableID("offering", termKey, catalogID, row["jxbmc"], teacherSetKey([]string{row["jsxm"]}), scheduleSignature(row))
}

func courseAudienceID(offeringID string, row map[string]string) string {
	return stableID("audience", offeringID, row["nj"], row["jszy"], row["jhxy"], row["kcxzdm"], row["kclbdm"], row["kklxdm"], row["kkbm_id2"])
}

func stableID(parts ...string) string {
	normalized := make([]string, len(parts))
	for i, part := range parts {
		normalized[i] = normalizeKey(part)
	}
	sum := sha256.Sum256([]byte(strings.Join(normalized, "\x1f")))
	return hex.EncodeToString(sum[:16])
}

func normalizeKey(value string) string {
	return strings.Join(strings.Fields(strings.TrimSpace(value)), " ")
}

func scheduleSignature(row map[string]string) string {
	values := make([]string, 0, len(weekdayFields))
	for _, field := range weekdayFields {
		raw := strings.TrimSpace(row[field.code])
		if raw == "" {
			continue
		}
		for index, segment := range splitScheduleSegments(raw) {
			sectionStart, sectionEnd, _ := parseSectionRange(segment)
			values = append(values, strings.Join([]string{
				field.code,
				strconv.Itoa(index),
				intListKey(parseWeekIndexes(segment)),
				strconv.Itoa(sectionStart),
				strconv.Itoa(sectionEnd),
				normalizeLocationKey(extractLocationText(segment)),
			}, "="))
		}
	}
	return strings.Join(values, "|")
}

func scheduleSummary(row map[string]string) string {
	parts := make([]string, 0, len(weekdayFields))
	for _, field := range weekdayFields {
		if value := strings.TrimSpace(row[field.code]); value != "" {
			parts = append(parts, field.label+value)
		}
	}
	return strings.Join(parts, "；")
}

func audienceSummary(rows []map[string]string) string {
	grades := uniqueSummary(mapValues(rows, "nj"), 3, "个年级")
	majors := uniqueSummary(mapValues(rows, "jszy"), 3, "个专业")
	return strings.Join(nonEmpty([]string{grades, majors}), " / ")
}

func countOfferingsForTermCourse(offerings []domain.CourseOffering, termCourseID string) int {
	count := 0
	for _, offering := range offerings {
		if offering.TermCourseID == termCourseID {
			count++
		}
	}
	return count
}

func countInstructorOfferings(instructors []domain.InstructorCourse, offerings []domain.CourseOffering) {
	counts := map[string]int{}
	for _, offering := range offerings {
		counts[offering.InstructorCourseID]++
	}
	for i := range instructors {
		instructors[i].OfferingCount = counts[instructors[i].ID]
	}
}

func weekdaySummaries(rows []map[string]string) []string {
	result := make([]string, 0, len(rows))
	for _, row := range rows {
		parts := make([]string, 0, len(weekdayFields))
		for _, field := range weekdayFields {
			if strings.TrimSpace(row[field.code]) != "" {
				parts = append(parts, field.label)
			}
		}
		result = append(result, strings.Join(parts, "、"))
	}
	return result
}

func mapValues(rows []map[string]string, key string) []string {
	values := make([]string, 0, len(rows))
	for _, row := range rows {
		values = append(values, row[key])
	}
	return values
}

func uniqueSummary(values []string, maxItems int, suffix string) string {
	unique := make([]string, 0, len(values))
	seen := map[string]struct{}{}
	for _, value := range values {
		value = strings.TrimSpace(value)
		if value == "" {
			continue
		}
		if _, ok := seen[value]; ok {
			continue
		}
		seen[value] = struct{}{}
		unique = append(unique, value)
	}
	if len(unique) <= maxItems {
		return strings.Join(unique, "、")
	}
	return fmt.Sprintf("%s等 %d %s", strings.Join(unique[:maxItems], "、"), len(unique), suffix)
}

func teacherSetKey(values []string) string {
	parts := make([]string, 0, len(values))
	seen := map[string]struct{}{}
	for _, value := range values {
		for _, name := range splitTeacherNames(value) {
			key := normalizeKey(name)
			if key == "" {
				continue
			}
			if _, ok := seen[key]; ok {
				continue
			}
			seen[key] = struct{}{}
			parts = append(parts, key)
		}
	}
	sort.Strings(parts)
	return strings.Join(parts, "|")
}

func splitTeacherNames(value string) []string {
	raw := regexp.MustCompile(`[,，;；、/\s]+`).Split(value, -1)
	result := make([]string, 0, len(raw))
	for _, part := range raw {
		part = strings.TrimSpace(part)
		if part != "" {
			result = append(result, part)
		}
	}
	return result
}

func parsePeopleCount(raw string) (int, int) {
	parts := regexp.MustCompile(`[\\/／]`).Split(raw, -1)
	capacity := 0
	selected := 0
	if len(parts) > 0 {
		capacity, _ = strconv.Atoi(strings.TrimSpace(parts[0]))
	}
	if len(parts) > 1 {
		selected, _ = strconv.Atoi(strings.TrimSpace(parts[1]))
	}
	return capacity, selected
}

func intListKey(values []int) string {
	if len(values) == 0 {
		return ""
	}
	parts := make([]string, len(values))
	for i, value := range values {
		parts[i] = strconv.Itoa(value)
	}
	return strings.Join(parts, ",")
}

func nonEmpty(values []string) []string {
	result := make([]string, 0, len(values))
	for _, value := range values {
		if strings.TrimSpace(value) != "" {
			result = append(result, value)
		}
	}
	return result
}

func extractFirst(raw string, pattern string) string {
	match := regexp.MustCompile(pattern).FindString(raw)
	return strings.TrimSpace(match)
}

func extractLocationText(raw string) string {
	match := regexp.MustCompile(`\d+(?:-\d+)?节(.*)$`).FindStringSubmatch(raw)
	if len(match) < 2 {
		return ""
	}
	return strings.TrimSpace(match[1])
}

func normalizeLocationKey(value string) string {
	return strings.ToLower(strings.ReplaceAll(normalizeKey(value), " ", ""))
}

func sanitizeFilePart(value string) string {
	value = regexp.MustCompile(`[^A-Za-z0-9._-]+`).ReplaceAllString(value, "_")
	return strings.Trim(value, "_")
}

func sortedCatalogs(input map[string]domain.CourseCatalog) []domain.CourseCatalog {
	result := make([]domain.CourseCatalog, 0, len(input))
	for _, item := range input {
		result = append(result, item)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].ID < result[j].ID })
	return result
}

func sortedAudiences(input map[string]domain.CourseAudience) []domain.CourseAudience {
	result := make([]domain.CourseAudience, 0, len(input))
	for _, item := range input {
		result = append(result, item)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].ID < result[j].ID })
	return result
}

func sortedInstructorCourses(input map[string]domain.InstructorCourse) []domain.InstructorCourse {
	result := make([]domain.InstructorCourse, 0, len(input))
	for _, item := range input {
		result = append(result, item)
	}
	sort.Slice(result, func(i, j int) bool { return result[i].ID < result[j].ID })
	return result
}
