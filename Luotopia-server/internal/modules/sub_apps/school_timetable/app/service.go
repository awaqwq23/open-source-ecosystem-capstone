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
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
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
	repo        Repository
	snapshotDir string
}

func NewService(repo Repository, snapshotDir string) *Service {
	if strings.TrimSpace(snapshotDir) == "" {
		snapshotDir = "school_timetable_snapshots"
	}
	return &Service{repo: repo, snapshotDir: snapshotDir}
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
	records := BuildRecords(pkg)
	snapshotData, err := GzipSnapshot(pkg, records)
	if err != nil {
		return domain.ImportResult{}, err
	}
	snapshotChecksum := PackageChecksum(snapshotData)
	fileKey := fmt.Sprintf("%s-v%d-unified.json.gz", sanitizeFilePart(pkg.Manifest.TermKey), version)
	if err := os.MkdirAll(s.snapshotDir, 0755); err != nil {
		return domain.ImportResult{}, err
	}
	if err := os.WriteFile(filepath.Join(s.snapshotDir, fileKey), snapshotData, 0644); err != nil {
		return domain.ImportResult{}, err
	}
	now := time.Now().UTC()
	release := domain.Release{
		TermKey: pkg.Manifest.TermKey, Version: version, Checksum: snapshotChecksum,
		FileKey: fileKey, RowCount: len(pkg.Rows), Active: true, PublishedAt: now,
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
	return s.repo.ListActiveTerms(ctx)
}

func (s *Service) ListReleases(ctx context.Context, termKey string) ([]domain.Release, error) {
	return s.repo.ListReleases(ctx, termKey)
}

func (s *Service) ActivateRelease(ctx context.Context, termKey string, version int) error {
	return s.repo.ActivateRelease(ctx, termKey, version)
}

func (s *Service) SnapshotPath(ctx context.Context, termKey string, version int) (string, domain.Release, error) {
	release, err := s.repo.GetRelease(ctx, termKey, version)
	if err != nil {
		return "", domain.Release{}, err
	}
	return filepath.Join(s.snapshotDir, release.FileKey), release, nil
}

type Records struct {
	Catalogs          []domain.CourseCatalog
	TermCourses       []domain.TermCourse
	InstructorCourses []domain.InstructorCourse
	Offerings         []domain.CourseOffering
	Audiences         []domain.CourseAudience
	SourceRows        []domain.SourceRow
	MeetingRules      []domain.CourseMeetingRule
	Occurrences       []domain.CourseOccurrence
}

func BuildRecords(pkg domain.Package) Records {
	weekOneMonday, _ := time.Parse("2006-01-02", pkg.Manifest.FirstWeekMonday)
	sourceRows := make([]domain.SourceRow, 0, len(pkg.Rows))
	ruleRecords := make([]domain.CourseMeetingRule, 0, len(pkg.Rows))
	occurrenceRecords := make([]domain.CourseOccurrence, 0, len(pkg.Rows)*8)
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
		instructorID := instructorCourseID(catalogID, instructorName)
		audienceSummary := audienceSummary(rows)
		searchText := strings.Join(nonEmpty([]string{
			first["kcmc"], first["yskch"], first["jxbmc"], first["skxy"], instructorName, audienceSummary,
			first["xkbz"], first["qtjs"], first["jcmc"],
		}), " ")
		offerings = append(offerings, domain.CourseOffering{
			ID: id, TermKey: pkg.Manifest.TermKey, SchoolYear: pkg.Manifest.SchoolYear, Term: pkg.Manifest.Term,
			TermCourseID: termCourseID, CatalogID: catalogID, InstructorCourseID: instructorID,
			SourceKey: first["key"], TeachingClassName: first["jxbmc"], CourseNo: first["yskch"],
			CourseName: first["kcmc"], OpenCollege: first["skxy"], Credits: first["kcxf"],
			Instructor: instructorName, InstructorKey: normalizeKey(instructorName), Title: first["jszc"],
			PeopleRaw: first["skrs"], TheoryHours: first["xsdm_01"], ComputerHours: first["xsdm_02"],
			ExperimentHours: first["xsdm_03"], PracticeHours: first["xsdm_04"], Remark: first["xkbz"],
			OtherTeachers: first["qtjs"], Textbook: first["jcmc"], Publisher: first["cbs"],
			ScheduleSignature: scheduleSignature(first), ScheduleSummary: scheduleSummary(first),
			WeekdaySummary:  strings.Join(weekdaySummaries([]map[string]string{first}), "、"),
			AudienceSummary: audienceSummary, SourceRowCount: len(rows), SearchText: searchText, Fields: first,
		})
		instructorByID[instructorID] = domain.InstructorCourse{
			ID: instructorID, CatalogID: catalogID, CourseNo: first["yskch"], CourseName: first["kcmc"],
			Credits: first["kcxf"], InstructorName: instructorName, InstructorNameKey: normalizeKey(instructorName),
			LatestTermKey: pkg.Manifest.TermKey, LatestOpenCollege: first["skxy"], LatestTeachingTitle: first["jszc"],
			SearchText: strings.Join(nonEmpty([]string{first["kcmc"], first["yskch"], instructorName, first["skxy"]}), " "),
		}
		rules := meetingRulesForRow(pkg.Manifest.TermKey, termCourseID, catalogID, id, first)
		ruleRecords = append(ruleRecords, rules...)
		for _, rule := range rules {
			occurrenceRecords = append(occurrenceRecords, occurrencesForRule(weekOneMonday, rule)...)
		}
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
	sort.Slice(ruleRecords, func(i, j int) bool { return ruleRecords[i].ID < ruleRecords[j].ID })
	sort.Slice(occurrenceRecords, func(i, j int) bool { return occurrenceRecords[i].ID < occurrenceRecords[j].ID })
	return Records{
		Catalogs: catalogs, TermCourses: termCourses, InstructorCourses: instructorCourses,
		Offerings: offerings, Audiences: audiences, SourceRows: sourceRows,
		MeetingRules: ruleRecords, Occurrences: occurrenceRecords,
	}
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
		Audiences: records.Audiences, MeetingRules: records.MeetingRules,
		Occurrences: records.Occurrences, SourceRows: records.SourceRows,
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

func meetingRulesForRow(termKey, termCourseID, catalogID, offeringID string, row map[string]string) []domain.CourseMeetingRule {
	result := make([]domain.CourseMeetingRule, 0, 2)
	for _, field := range weekdayFields {
		raw := strings.TrimSpace(row[field.code])
		if raw == "" {
			continue
		}
		location, building, room := extractLocation(raw)
		weekText := extractFirst(raw, `\d+(?:-\d+)?周(?:\((?:单|双)\))?`)
		sectionText := extractFirst(raw, `\d+(?:-\d+)?节`)
		ruleID := stableID("meeting_rule", offeringID, fmt.Sprintf("%d", field.index), raw)
		result = append(result, domain.CourseMeetingRule{
			ID: ruleID, OfferingID: offeringID, TermKey: termKey, TermCourseID: termCourseID, CatalogID: catalogID,
			Weekday: field.index, SegmentIndex: len(result), WeekdayLabel: field.label, RawText: raw,
			WeekText: weekText, SectionText: sectionText, LocationText: location, Building: building, Room: room,
		})
	}
	return result
}

func occurrencesForRule(firstMonday time.Time, rule domain.CourseMeetingRule) []domain.CourseOccurrence {
	if firstMonday.IsZero() {
		return nil
	}
	weeks := parseWeekSpans(rule.RawText)
	if len(weeks) == 0 {
		return nil
	}
	offset := rule.Weekday - 1
	if rule.Weekday == 0 {
		offset = 6
	}
	result := make([]domain.CourseOccurrence, 0, 16)
	occurrenceIndex := 0
	for _, week := range weeks {
		for index := week.start; index <= week.end; index++ {
			if week.parity == "单" && index%2 == 0 {
				continue
			}
			if week.parity == "双" && index%2 != 0 {
				continue
			}
			date := firstMonday.AddDate(0, 0, (index-1)*7+offset)
			id := stableID("occurrence", rule.ID, fmt.Sprintf("%d", occurrenceIndex), date.Format("2006-01-02"), rule.SectionText, rule.LocationText)
			result = append(result, domain.CourseOccurrence{
				ID: id, RuleID: rule.ID, OfferingID: rule.OfferingID, TermKey: rule.TermKey,
				TermCourseID: rule.TermCourseID, CatalogID: rule.CatalogID, Date: date.Format("2006-01-02"),
				WeekIndex: index, Weekday: rule.Weekday, SectionText: rule.SectionText,
				LocationText: rule.LocationText, Building: rule.Building, Room: rule.Room,
			})
			occurrenceIndex++
		}
	}
	return result
}

type weekSpan struct {
	start  int
	end    int
	parity string
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
	return stableID("offering", termKey, row["jxbmc"], row["jsxm"], scheduleSignature(row))
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
		values = append(values, fmt.Sprintf("%s=%s", field.code, normalizeKey(row[field.code])))
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

func extractLocation(raw string) (string, string, string) {
	matches := regexp.MustCompile(`((?:\d区|虚拟教室)[^,，;；)]*)`).FindAllStringSubmatch(raw, -1)
	if len(matches) == 0 {
		return "", "", ""
	}
	location := strings.TrimSpace(matches[len(matches)-1][1])
	if location == "" || location == "虚拟教室" {
		return location, location, ""
	}
	parts := regexp.MustCompile(`^(\d区[^-－]*)[-－]?(.*)$`).FindStringSubmatch(location)
	if len(parts) == 0 {
		return location, location, ""
	}
	return location, strings.TrimSpace(parts[1]), strings.TrimSpace(parts[2])
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
