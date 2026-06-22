package app

import (
	"bytes"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	"github.com/openwhu/luotopia/server/internal/platform/storage"
)

type Repository interface {
	Publish(ctx context.Context, pkg domain.Package, release domain.Release, records Records) error
	NextVersion(ctx context.Context, termKey string) (int, error)
	ListActiveTerms(ctx context.Context) ([]domain.Term, error)
	ListReleases(ctx context.Context, termKey string) ([]domain.Release, error)
	ActivateRelease(ctx context.Context, termKey string, version int) error
	GetRelease(ctx context.Context, termKey string, version int) (domain.Release, error)
}

type Service struct {
	repo          Repository
	snapshotDir   string
	objectStore   storage.Store
	publicBaseURL string
}

func NewService(repo Repository, snapshotDir string, objectStore storage.Store, publicBaseURL string) *Service {
	if strings.TrimSpace(snapshotDir) == "" {
		snapshotDir = "school_timetable_snapshots"
	}
	return &Service{
		repo:          repo,
		snapshotDir:   snapshotDir,
		objectStore:   objectStore,
		publicBaseURL: strings.TrimRight(publicBaseURL, "/"),
	}
}

func (s *Service) ValidatePackage(ctx context.Context, reader io.Reader) (domain.ImportResult, error) {
	data, err := io.ReadAll(reader)
	if err != nil {
		return domain.ImportResult{}, err
	}
	pkg, err := ParsePackage(ctx, bytes.NewReader(data))
	if err != nil {
		return domain.ImportResult{}, err
	}
	if err := validateFirstWeekMonday(pkg.Manifest.FirstWeekMonday); err != nil {
		return domain.ImportResult{}, err
	}
	return domain.ImportResult{
		Manifest: pkg.Manifest,
		Checksum: PackageChecksum(data),
		RowCount: len(pkg.Rows),
	}, nil
}

func (s *Service) ImportAndPublish(ctx context.Context, reader io.Reader) (domain.ImportResult, error) {
	data, err := io.ReadAll(reader)
	if err != nil {
		return domain.ImportResult{}, err
	}
	pkg, err := ParsePackage(ctx, bytes.NewReader(data))
	if err != nil {
		return domain.ImportResult{}, err
	}
	if err := validateFirstWeekMonday(pkg.Manifest.FirstWeekMonday); err != nil {
		return domain.ImportResult{}, err
	}
	version, err := s.repo.NextVersion(ctx, pkg.Manifest.TermKey)
	if err != nil {
		return domain.ImportResult{}, err
	}
	rawChecksum := PackageChecksum(data)
	records := BuildRecords(pkg, version)
	artifact, err := BuildSQLiteArtifact(ctx, pkg, records, version, s.snapshotDir)
	if err != nil {
		return domain.ImportResult{}, err
	}
	if s.objectStore == nil {
		return domain.ImportResult{}, fmt.Errorf("school timetable object store is not configured")
	}
	artifactFile, err := os.Open(artifact.Path)
	if err != nil {
		return domain.ImportResult{}, err
	}
	if err := s.objectStore.Put(ctx, storage.Object{
		Key:         artifact.Key,
		ContentType: SQLiteArtifactContent,
		Size:        artifact.Size,
		Body:        artifactFile,
	}); err != nil {
		return domain.ImportResult{}, err
	}
	now := time.Now().UTC()
	release := domain.Release{
		TermKey: pkg.Manifest.TermKey, Version: version, Checksum: artifact.Checksum,
		FileKey: artifact.Key, ArtifactType: artifact.ArtifactType, SchemaVersion: artifact.SchemaVersion,
		ArtifactSize: artifact.Size, RowCount: len(pkg.Rows), Active: true, PublishedAt: now,
	}
	if err := s.repo.Publish(ctx, pkg, release, records); err != nil {
		return domain.ImportResult{}, err
	}
	return domain.ImportResult{
		Manifest: pkg.Manifest,
		Checksum: rawChecksum,
		RowCount: len(pkg.Rows),
		Version:  version,
	}, nil
}

func (s *Service) ListActiveTerms(ctx context.Context) ([]domain.Term, error) {
	terms, err := s.repo.ListActiveTerms(ctx)
	if err != nil {
		return nil, err
	}
	for i := range terms {
		terms[i].ArtifactURL = s.objectURL(terms[i].FileKey)
	}
	return terms, nil
}

func (s *Service) ListReleases(ctx context.Context, termKey string) ([]domain.Release, error) {
	releases, err := s.repo.ListReleases(ctx, termKey)
	if err != nil {
		return nil, err
	}
	for i := range releases {
		releases[i].ArtifactURL = s.objectURL(releases[i].FileKey)
	}
	return releases, nil
}

func (s *Service) ActivateRelease(ctx context.Context, termKey string, version int) error {
	return s.repo.ActivateRelease(ctx, termKey, version)
}

func (s *Service) objectURL(key string) string {
	if key == "" || s.publicBaseURL == "" {
		return ""
	}
	return s.publicBaseURL + "/" + strings.TrimLeft(key, "/")
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
				ID: sourceID, StableID: sourceID, TermKey: pkg.Manifest.TermKey, SourceKey: row["key"],
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
			ID: sourceID, StableID: sourceID, TermKey: pkg.Manifest.TermKey, TermCourseID: termCourseID, OfferingID: offeringID,
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
			ID: id, StableID: id, TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
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
			ID: instructorID, StableID: instructorID, CatalogID: catalogID, CourseNo: first["yskch"], CourseName: first["kcmc"],
			Credits: first["kcxf"], InstructorName: instructorName, InstructorNameKey: normalizeKey(instructorName),
			LatestTermKey: pkg.Manifest.TermKey, LatestOpenCollege: first["skxy"], LatestTeachingTitle: first["jszc"],
			SearchText: strings.Join(nonEmpty([]string{first["kcmc"], first["yskch"], instructorName, first["skxy"]}), " "),
		}
		instances := courseInstancesForRow(pkg.Manifest.TermKey, termCourseID, catalogID, id, first)
		instanceRecords = append(instanceRecords, instances...)
		for _, row := range rows {
			audience := domain.CourseAudience{
				ID: courseAudienceID(id, row), StableID: courseAudienceID(id, row), TermKey: pkg.Manifest.TermKey,
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
			ID: catalogID, StableID: catalogID, CatalogKey: catalogKey(first), CourseNo: first["yskch"],
			CourseName: first["kcmc"], Credits: first["kcxf"],
			SearchText: strings.Join(nonEmpty([]string{first["kcmc"], first["yskch"], first["kcxf"]}), " "),
		}
		teachers := uniqueSummary(mapValues(rows, "jsxm"), 3, "位教师")
		weekdays := uniqueSummary(weekdaySummaries(rows), 4, "组时间")
		searchText := strings.Join(nonEmpty([]string{
			first["kcmc"], first["yskch"], first["skxy"], first["kcxzmc"], first["kclbmc"], first["kklxmc"], teachers, weekdays,
		}), " ")
		termCourses = append(termCourses, domain.TermCourse{
			ID: id, StableID: id, TermKey: pkg.Manifest.TermKey, CatalogID: catalogID, CourseNo: first["yskch"],
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
	return scopeRecordsToRelease(records, releaseID(pkg.Manifest.TermKey, version))
}

func releaseID(termKey string, version int) string {
	return termKey + "@" + strconv.Itoa(version)
}

func scopeRecordsToRelease(records Records, releaseID string) Records {
	termCourseIDs := make(map[string]string, len(records.TermCourses))
	instructorCourseIDs := make(map[string]string, len(records.InstructorCourses))
	offeringIDs := make(map[string]string, len(records.Offerings))
	audienceIDs := make(map[string]string, len(records.Audiences))
	instanceIDs := make(map[string]string, len(records.CourseInstances))
	sourceIDs := make(map[string]string, len(records.SourceRows))

	for i := range records.TermCourses {
		stable := records.TermCourses[i].StableID
		if stable == "" {
			stable = records.TermCourses[i].ID
		}
		termCourseIDs[records.TermCourses[i].ID] = scopedEntityID(releaseID, stable)
		records.TermCourses[i].StableID = stable
		records.TermCourses[i].ReleaseID = releaseID
		records.TermCourses[i].ID = termCourseIDs[records.TermCourses[i].ID]
	}
	for i := range records.InstructorCourses {
		stable := records.InstructorCourses[i].StableID
		if stable == "" {
			stable = records.InstructorCourses[i].ID
		}
		instructorCourseIDs[records.InstructorCourses[i].ID] = scopedEntityID(releaseID, stable)
		records.InstructorCourses[i].StableID = stable
		records.InstructorCourses[i].ReleaseID = releaseID
		records.InstructorCourses[i].ID = instructorCourseIDs[records.InstructorCourses[i].ID]
	}
	for i := range records.Offerings {
		stable := records.Offerings[i].StableID
		if stable == "" {
			stable = records.Offerings[i].ID
		}
		offeringIDs[records.Offerings[i].ID] = scopedEntityID(releaseID, stable)
		records.Offerings[i].StableID = stable
		records.Offerings[i].ReleaseID = releaseID
		records.Offerings[i].ID = offeringIDs[records.Offerings[i].ID]
		records.Offerings[i].TermCourseID = termCourseIDs[records.Offerings[i].TermCourseID]
		records.Offerings[i].InstructorCourseID = instructorCourseIDs[records.Offerings[i].InstructorCourseID]
	}
	for i := range records.Audiences {
		stable := records.Audiences[i].StableID
		if stable == "" {
			stable = records.Audiences[i].ID
		}
		audienceIDs[records.Audiences[i].ID] = scopedEntityID(releaseID, stable)
		records.Audiences[i].StableID = stable
		records.Audiences[i].ReleaseID = releaseID
		records.Audiences[i].ID = audienceIDs[records.Audiences[i].ID]
		records.Audiences[i].OfferingID = offeringIDs[records.Audiences[i].OfferingID]
		records.Audiences[i].TermCourseID = termCourseIDs[records.Audiences[i].TermCourseID]
	}
	for i := range records.CourseInstances {
		stable := records.CourseInstances[i].StableID
		if stable == "" {
			stable = records.CourseInstances[i].ID
		}
		instanceIDs[records.CourseInstances[i].ID] = scopedEntityID(releaseID, stable)
		records.CourseInstances[i].StableID = stable
		records.CourseInstances[i].ReleaseID = releaseID
		records.CourseInstances[i].ID = instanceIDs[records.CourseInstances[i].ID]
		records.CourseInstances[i].OfferingID = offeringIDs[records.CourseInstances[i].OfferingID]
		records.CourseInstances[i].TermCourseID = termCourseIDs[records.CourseInstances[i].TermCourseID]
	}
	for i := range records.SourceRows {
		stable := records.SourceRows[i].StableID
		if stable == "" {
			stable = records.SourceRows[i].ID
		}
		sourceIDs[records.SourceRows[i].ID] = scopedEntityID(releaseID, stable)
		records.SourceRows[i].StableID = stable
		records.SourceRows[i].ReleaseID = releaseID
		records.SourceRows[i].ID = sourceIDs[records.SourceRows[i].ID]
		records.SourceRows[i].TermCourseID = termCourseIDs[records.SourceRows[i].TermCourseID]
		records.SourceRows[i].OfferingID = offeringIDs[records.SourceRows[i].OfferingID]
	}
	return records
}

func scopedEntityID(releaseID, entityStableID string) string {
	return stableID("release_entity", releaseID, entityStableID)
}

func GzipPackage(pkg domain.Package) ([]byte, error) {
	fieldCodes := append([]string(nil), pkg.Manifest.FieldCodes...)
	sort.Strings(fieldCodes)
	var raw bytes.Buffer
	manifest := pkg.Manifest
	manifest.FieldCodes = fieldCodes
	manifest.RowCount = len(pkg.Rows)
	if manifest.Type == "" {
		manifest.Type = "manifest"
	}
	if manifest.SchemaVersion == 0 {
		manifest.SchemaVersion = 1
	}
	rowsPayload := StableRowsPayload(pkg.Rows)
	sum := sha256.Sum256(rowsPayload)
	manifest.SourceChecksum = "sha256:" + hex.EncodeToString(sum[:])
	data, err := json.Marshal(manifest)
	if err != nil {
		return nil, err
	}
	raw.Write(data)
	raw.WriteByte('\n')
	raw.Write(rowsPayload)
	raw.WriteByte('\n')
	var compressed bytes.Buffer
	writer := gzip.NewWriter(&compressed)
	if _, err := writer.Write(raw.Bytes()); err != nil {
		return nil, err
	}
	if err := writer.Close(); err != nil {
		return nil, err
	}
	return compressed.Bytes(), nil
}

func GzipSnapshot(pkg domain.Package, records Records) ([]byte, error) {
	manifest := pkg.Manifest
	manifest.SchemaVersion = 2
	manifest.RowCount = len(pkg.Rows)
	snapshot := domain.Snapshot{
		Manifest: manifest, Catalogs: records.Catalogs, TermCourses: records.TermCourses,
		InstructorCourses: records.InstructorCourses, Offerings: records.Offerings,
		Audiences: records.Audiences, CourseInstances: records.CourseInstances,
		SourceRows: records.SourceRows,
	}
	data, err := json.Marshal(snapshot)
	if err != nil {
		return nil, err
	}
	var compressed bytes.Buffer
	writer := gzip.NewWriter(&compressed)
	if _, err := writer.Write(data); err != nil {
		return nil, err
	}
	if err := writer.Close(); err != nil {
		return nil, err
	}
	return compressed.Bytes(), nil
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
				ID: instanceID, StableID: instanceID, OfferingID: offeringID, TermKey: termKey, TermCourseID: termCourseID, CatalogID: catalogID,
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
