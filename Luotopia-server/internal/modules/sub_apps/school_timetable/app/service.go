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
	version, err := s.repo.NextVersion(ctx, pkg.Manifest.TermKey)
	if err != nil {
		return domain.ImportResult{}, err
	}
	checksum := PackageChecksum(data)
	fileKey := fmt.Sprintf("%s-v%d.ndjson.gz", sanitizeFilePart(pkg.Manifest.TermKey), version)
	if err := os.MkdirAll(s.snapshotDir, 0755); err != nil {
		return domain.ImportResult{}, err
	}
	if err := os.WriteFile(filepath.Join(s.snapshotDir, fileKey), data, 0644); err != nil {
		return domain.ImportResult{}, err
	}
	now := time.Now().UTC()
	release := domain.Release{
		TermKey: pkg.Manifest.TermKey, Version: version, Checksum: checksum,
		FileKey: fileKey, RowCount: len(pkg.Rows), Active: true, PublishedAt: now,
	}
	records := BuildRecords(pkg)
	if err := s.repo.Publish(ctx, pkg, release, records); err != nil {
		return domain.ImportResult{}, err
	}
	return domain.ImportResult{
		Manifest: pkg.Manifest,
		Checksum: checksum,
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
	Heads     []domain.CourseHead
	Offerings []domain.CourseOffering
	Audiences []domain.CourseAudience
	RawRows   []domain.RawRow
	Meetings  []domain.Meeting
}

func BuildRecords(pkg domain.Package) Records {
	rowRecords := make([]domain.RawRow, 0, len(pkg.Rows))
	meetingRecords := make([]domain.Meeting, 0, len(pkg.Rows))
	headRows := make(map[string][]map[string]string)
	offeringRows := make(map[string][]map[string]string)
	offeringOrder := make([]string, 0, len(pkg.Rows))
	sourceOrdinals := make(map[string]int, len(pkg.Rows))
	for index, row := range pkg.Rows {
		canonical := canonicalSourceRow(row)
		sourceOrdinals[canonical]++
		rawID := sourceRowID(pkg.Manifest.TermKey, canonical, sourceOrdinals[canonical])
		if !canBuildEntity(row) {
			rowRecords = append(rowRecords, domain.RawRow{
				ID: rawID, TermKey: pkg.Manifest.TermKey, SourceKey: row["key"],
				PackageIndex: index + 1, Status: "incomplete",
				SchoolYear: row["xn"], Term: row["xq"], TeachingClassName: row["jxbmc"],
				CourseNo: row["yskch"], CourseName: row["kcmc"], OpenCollege: row["skxy"],
				PlanCollege: row["jhxy"], Credits: row["kcxf"], CourseNature: row["kcxzmc"],
				CourseCategory: row["kclbmc"], OpenType: row["kklxmc"], Grade: row["nj"],
				Major: row["jszy"], Instructor: row["jsxm"], Title: row["jszc"], PeopleRaw: row["skrs"],
				Fields: row,
			})
			continue
		}
		headID := courseHeadID(pkg.Manifest.TermKey, row)
		offeringID := courseOfferingID(pkg.Manifest.TermKey, row)
		headRows[headID] = append(headRows[headID], row)
		if _, ok := offeringRows[offeringID]; !ok {
			offeringOrder = append(offeringOrder, offeringID)
		}
		offeringRows[offeringID] = append(offeringRows[offeringID], row)
		rowRecords = append(rowRecords, domain.RawRow{
			ID: rawID, TermKey: pkg.Manifest.TermKey, CourseHeadID: headID, OfferingID: offeringID, SourceKey: row["key"],
			PackageIndex: index + 1, Status: "active",
			SchoolYear: row["xn"], Term: row["xq"], TeachingClassName: row["jxbmc"],
			CourseNo: row["yskch"], CourseName: row["kcmc"], OpenCollege: row["skxy"],
			PlanCollege: row["jhxy"], Credits: row["kcxf"], CourseNature: row["kcxzmc"],
			CourseCategory: row["kclbmc"], OpenType: row["kklxmc"], Grade: row["nj"],
			Major: row["jszy"], Instructor: row["jsxm"], Title: row["jszc"], PeopleRaw: row["skrs"],
			Fields: row,
		})
	}
	offerings := make([]domain.CourseOffering, 0, len(offeringRows))
	audienceByID := make(map[string]domain.CourseAudience)
	for _, id := range offeringOrder {
		rows := offeringRows[id]
		first := rows[0]
		headID := courseHeadID(pkg.Manifest.TermKey, first)
		teachers := uniqueSummary(mapValues(rows, "jsxm"), 3, "位教师")
		audienceSummary := audienceSummary(rows)
		searchText := strings.Join(nonEmpty([]string{
			first["kcmc"], first["yskch"], first["jxbmc"], first["skxy"], teachers, audienceSummary,
			first["xkbz"], first["qtjs"], first["jcmc"],
		}), " ")
		offerings = append(offerings, domain.CourseOffering{
			ID: id, TermKey: pkg.Manifest.TermKey, CourseHeadID: headID,
			TeachingClassName: first["jxbmc"], CourseNo: first["yskch"], CourseName: first["kcmc"],
			OpenCollege: first["skxy"], Credits: first["kcxf"], Instructor: teachers,
			TeacherKey: normalizeKey(first["jsxm"]), Title: first["jszc"], PeopleRaw: first["skrs"],
			TheoryHours: first["xsdm_01"], ComputerHours: first["xsdm_02"], ExperimentHours: first["xsdm_03"], PracticeHours: first["xsdm_04"],
			Remark: first["xkbz"], OtherTeachers: first["qtjs"], Textbook: first["jcmc"], Publisher: first["cbs"],
			ScheduleSignature: scheduleSignature(first), ScheduleSummary: scheduleSummary(first),
			WeekdaySummary:  strings.Join(weekdaySummaries([]map[string]string{first}), "、"),
			AudienceSummary: audienceSummary, SourceRowCount: len(rows), SearchText: searchText, Fields: first,
		})
		meetingRecords = append(meetingRecords, meetingsForRow(pkg.Manifest.TermKey, headID, id, first)...)
		for _, row := range rows {
			audience := domain.CourseAudience{
				ID: courseAudienceID(pkg.Manifest.TermKey, id, row), TermKey: pkg.Manifest.TermKey,
				OfferingID: id, CourseHeadID: headID, Grade: row["nj"], Major: row["jszy"],
				PlanCollege: row["jhxy"], CourseNature: row["kcxzmc"], CourseNatureCode: row["kcxzdm"],
				CourseCategory: row["kclbmc"], CourseCategoryCode: row["kclbdm"],
				OpenType: row["kklxmc"], OpenTypeCode: row["kklxdm"], ConditionCode: row["kkbm_id2"],
			}
			audienceByID[audience.ID] = audience
		}
	}
	audiences := make([]domain.CourseAudience, 0, len(audienceByID))
	for _, item := range audienceByID {
		audiences = append(audiences, item)
	}
	sort.Slice(audiences, func(i, j int) bool { return audiences[i].ID < audiences[j].ID })

	heads := make([]domain.CourseHead, 0, len(headRows))
	for id, rows := range headRows {
		first := rows[0]
		teachers := uniqueSummary(mapValues(rows, "jsxm"), 3, "位教师")
		weekdays := uniqueSummary(weekdaySummaries(rows), 4, "组时间")
		searchText := strings.Join(nonEmpty([]string{
			first["kcmc"], first["yskch"], first["skxy"], first["kcxzmc"], first["kclbmc"], first["kklxmc"], teachers, weekdays,
		}), " ")
		heads = append(heads, domain.CourseHead{
			ID: id, TermKey: pkg.Manifest.TermKey, CourseHeadKey: first["yskch"], CourseNo: first["yskch"],
			CourseName: first["kcmc"], OpenCollege: first["skxy"], Credits: first["kcxf"],
			CourseNature: first["kcxzmc"], CourseCategory: first["kclbmc"], OpenType: first["kklxmc"],
			TeachingClassCount: countOfferingsForHead(offerings, id), TeacherSummary: teachers, WeekdaySummary: weekdays, SearchText: searchText,
		})
	}
	sort.Slice(heads, func(i, j int) bool { return heads[i].ID < heads[j].ID })
	return Records{Heads: heads, Offerings: offerings, Audiences: audiences, RawRows: rowRecords, Meetings: meetingRecords}
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

var weekdayFields = []struct {
	index int
	code  string
	label string
}{
	{0, "sun", "周日"}, {1, "mon", "周一"}, {2, "tue", "周二"}, {3, "wen", "周三"},
	{4, "thu", "周四"}, {5, "fri", "周五"}, {6, "sat", "周六"},
}

func meetingsForRow(termKey, headID, offeringID string, row map[string]string) []domain.Meeting {
	result := make([]domain.Meeting, 0, 2)
	for _, field := range weekdayFields {
		raw := strings.TrimSpace(row[field.code])
		if raw == "" {
			continue
		}
		location, building, room := extractLocation(raw)
		result = append(result, domain.Meeting{
			ID: fmt.Sprintf("%s:%d:0", offeringID, field.index), OfferingID: offeringID, TermKey: termKey, CourseHeadID: headID,
			Weekday: field.index, SegmentIndex: 0, WeekdayLabel: field.label, RawText: raw,
			LocationText: location, Building: building, Room: room,
		})
	}
	return result
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

func courseHeadID(termKey string, row map[string]string) string {
	return stableID("head", termKey, row["yskch"])
}

func courseOfferingID(termKey string, row map[string]string) string {
	return stableID("offering", termKey, row["jxbmc"], row["jsxm"], scheduleSignature(row))
}

func courseAudienceID(termKey, offeringID string, row map[string]string) string {
	return stableID("audience", termKey, offeringID, row["nj"], row["jszy"], row["jhxy"], row["kcxzdm"], row["kclbdm"], row["kklxdm"], row["kkbm_id2"])
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

func countOfferingsForHead(offerings []domain.CourseOffering, headID string) int {
	count := 0
	for _, offering := range offerings {
		if offering.CourseHeadID == headID {
			count++
		}
	}
	return count
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
