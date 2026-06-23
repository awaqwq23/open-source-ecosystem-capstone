package app

import (
	"compress/gzip"
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/domain"
	_ "modernc.org/sqlite"
)

var (
	ErrInvalidPackage = errors.New("school timetable: invalid package")
	ErrNotFound       = errors.New("school timetable: not found")
)

func ParsePackage(ctx context.Context, reader io.Reader) (domain.Package, error) {
	tempDir, err := os.MkdirTemp("", "school-timetable-import-*")
	if err != nil {
		return domain.Package{}, err
	}
	defer os.RemoveAll(tempDir)

	dbPath := filepath.Join(tempDir, "package.sqlite")
	if err := ungzipToFile(reader, dbPath); err != nil {
		return domain.Package{}, err
	}
	db, err := sql.Open("sqlite", dbPath)
	if err != nil {
		return domain.Package{}, err
	}
	defer db.Close()
	if err := ctx.Err(); err != nil {
		return domain.Package{}, err
	}
	return readDatabasePackage(ctx, db)
}

func PackageChecksum(data []byte) string {
	sum := sha256.Sum256(data)
	return "sha256:" + hex.EncodeToString(sum[:])
}

func ungzipToFile(reader io.Reader, path string) error {
	gzipReader, err := gzip.NewReader(reader)
	if err != nil {
		return fmt.Errorf("%w: gzip", ErrInvalidPackage)
	}
	defer gzipReader.Close()
	out, err := os.Create(path)
	if err != nil {
		return err
	}
	defer out.Close()
	if _, err := io.Copy(out, gzipReader); err != nil {
		return err
	}
	return nil
}

func readDatabasePackage(ctx context.Context, db *sql.DB) (domain.Package, error) {
	terms, err := readTerms(ctx, db)
	if err != nil {
		return domain.Package{}, err
	}
	if len(terms) != 1 {
		return domain.Package{}, fmt.Errorf("%w: package must contain exactly one term", ErrInvalidPackage)
	}
	term := terms[0]
	pkg := domain.Package{
		Manifest: domain.Manifest{
			Type: "database", SchemaVersion: 1, TermKey: term.TermKey,
			SchoolYear: term.SchoolYear, Term: term.Term, FirstWeekMonday: term.FirstWeekMonday,
			RowCount: term.RowCount, Source: "sqlite", SourceChecksum: "",
		},
	}
	pkg.Catalogs, err = readCatalogs(ctx, db)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.TermCourses, err = readTermCourses(ctx, db, term.TermKey)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.InstructorCourses, err = readInstructorCourses(ctx, db)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.Offerings, err = readOfferings(ctx, db, term)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.Audiences, err = readAudiences(ctx, db, term.TermKey)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.SourceRows, err = readSourceRows(ctx, db, term.TermKey)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.CourseInstances, err = readMeetingRules(ctx, db, term.TermKey)
	if err != nil {
		return domain.Package{}, err
	}
	if pkg.Manifest.RowCount == 0 {
		pkg.Manifest.RowCount = len(pkg.SourceRows)
	}
	return pkg, nil
}

func readTerms(ctx context.Context, db *sql.DB) ([]domain.Term, error) {
	rows, err := db.QueryContext(ctx, `SELECT term_key, school_year, term, first_week_monday, row_count FROM school_timetable_term_rows ORDER BY term_key`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_term_rows", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.Term
	for rows.Next() {
		var item domain.Term
		if err := rows.Scan(&item.TermKey, &item.SchoolYear, &item.Term, &item.FirstWeekMonday, &item.RowCount); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readCatalogs(ctx context.Context, db *sql.DB) ([]domain.CourseCatalog, error) {
	rows, err := db.QueryContext(ctx, `SELECT id, catalog_key, course_no, course_name, credits, search_text FROM school_timetable_courses ORDER BY id`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_courses", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.CourseCatalog
	for rows.Next() {
		var item domain.CourseCatalog
		if err := rows.Scan(&item.ID, &item.CatalogKey, &item.CourseNo, &item.CourseName, &item.Credits, &item.SearchText); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readTermCourses(ctx context.Context, db *sql.DB, termKey string) ([]domain.TermCourse, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT ct.id, ct.term_key, ct.course_id, c.course_no, c.course_name, ct.open_college, c.credits,
		       ct.course_nature, ct.course_category, ct.open_type, ct.teaching_class_count,
		       ct.teacher_summary, ct.weekday_summary, ct.search_text
		FROM school_timetable_course_terms ct
		JOIN school_timetable_courses c ON c.id = ct.course_id
		WHERE ct.term_key = ?
		ORDER BY ct.id`, termKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_course_terms", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.TermCourse
	for rows.Next() {
		var item domain.TermCourse
		if err := rows.Scan(&item.ID, &item.TermKey, &item.CatalogID, &item.CourseNo, &item.CourseName, &item.OpenCollege, &item.Credits, &item.CourseNature, &item.CourseCategory, &item.OpenType, &item.TeachingClassCount, &item.TeacherSummary, &item.WeekdaySummary, &item.SearchText); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readInstructorCourses(ctx context.Context, db *sql.DB) ([]domain.InstructorCourse, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT i.id, i.course_id, c.course_no, c.course_name, c.credits, i.instructor_name, i.instructor_name_key,
		       i.offering_count, i.latest_term_key, i.latest_open_college, i.latest_teaching_title, i.search_text
		FROM school_timetable_instructors i
		JOIN school_timetable_courses c ON c.id = i.course_id
		ORDER BY i.id`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_instructors", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.InstructorCourse
	for rows.Next() {
		var item domain.InstructorCourse
		if err := rows.Scan(&item.ID, &item.CatalogID, &item.CourseNo, &item.CourseName, &item.Credits, &item.InstructorName, &item.InstructorNameKey, &item.OfferingCount, &item.LatestTermKey, &item.LatestOpenCollege, &item.LatestTeachingTitle, &item.SearchText); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readOfferings(ctx context.Context, db *sql.DB, term domain.Term) ([]domain.CourseOffering, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, term_key, term_course_id, course_id, instructor_id, source_key, teaching_class_name,
		       instructor, title, people_raw, capacity, selected_count, theory_hours, computer_hours,
		       experiment_hours, practice_hours, remark, other_teachers, textbook, publisher,
		       schedule_summary, weekday_summary, detail_fields_json, search_text
		FROM school_timetable_offerings
		WHERE term_key = ?
		ORDER BY id`, term.TermKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_offerings", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.CourseOffering
	for rows.Next() {
		var item domain.CourseOffering
		var fields string
		if err := rows.Scan(&item.ID, &item.TermKey, &item.TermCourseID, &item.CatalogID, &item.InstructorCourseID, &item.SourceKey, &item.TeachingClassName, &item.Instructor, &item.Title, &item.PeopleRaw, &item.Capacity, &item.SelectedCount, &item.TheoryHours, &item.ComputerHours, &item.ExperimentHours, &item.PracticeHours, &item.Remark, &item.OtherTeachers, &item.Textbook, &item.Publisher, &item.ScheduleSummary, &item.WeekdaySummary, &fields, &item.SearchText); err != nil {
			return nil, err
		}
		item.SchoolYear = term.SchoolYear
		item.Term = term.Term
		item.Fields = decodeStringMap(fields)
		result = append(result, item)
	}
	return result, rows.Err()
}

func readAudiences(ctx context.Context, db *sql.DB, termKey string) ([]domain.CourseAudience, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, term_key, offering_id, grade, major, plan_college, course_nature, course_nature_code,
		       course_category, course_category_code, open_type, open_type_code, condition_code
		FROM school_timetable_audiences
		WHERE term_key = ?
		ORDER BY id`, termKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_audiences", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.CourseAudience
	for rows.Next() {
		var item domain.CourseAudience
		if err := rows.Scan(&item.ID, &item.TermKey, &item.OfferingID, &item.Grade, &item.Major, &item.PlanCollege, &item.CourseNature, &item.CourseNatureCode, &item.CourseCategory, &item.CourseCategoryCode, &item.OpenType, &item.OpenTypeCode, &item.ConditionCode); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readSourceRows(ctx context.Context, db *sql.DB, termKey string) ([]domain.SourceRow, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, term_key, COALESCE(term_course_id, ''), COALESCE(offering_id, ''), source_key,
		       package_index, source_status, raw_fields_json
		FROM school_timetable_source_rows
		WHERE term_key = ?
		ORDER BY package_index, id`, termKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_source_rows", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.SourceRow
	for rows.Next() {
		var item domain.SourceRow
		var fields string
		if err := rows.Scan(&item.ID, &item.TermKey, &item.TermCourseID, &item.OfferingID, &item.SourceKey, &item.PackageIndex, &item.Status, &fields); err != nil {
			return nil, err
		}
		item.Fields = decodeStringMap(fields)
		result = append(result, item)
	}
	return result, rows.Err()
}

func readMeetingRules(ctx context.Context, db *sql.DB, termKey string) ([]domain.CourseInstance, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, offering_id, term_key, weekday, day_field, segment_index, weekday_label,
		       raw_day_text, raw_segment_text, week_text, section_text, section_start,
		       section_end, location_text, parse_status
		FROM school_timetable_meeting_rules
		WHERE term_key = ?
		ORDER BY id`, termKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_meeting_rules", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.CourseInstance
	for rows.Next() {
		var item domain.CourseInstance
		if err := rows.Scan(&item.ID, &item.OfferingID, &item.TermKey, &item.Weekday, &item.DayField, &item.SegmentIndex, &item.WeekdayLabel, &item.RawDayText, &item.RawSegmentText, &item.WeekText, &item.SectionText, &item.SectionStart, &item.SectionEnd, &item.LocationText, &item.ParseStatus); err != nil {
			return nil, err
		}
		item.WeekIndexes = readWeeks(ctx, db, item.ID)
		result = append(result, item)
	}
	return result, rows.Err()
}

func readWeeks(ctx context.Context, db *sql.DB, ruleID string) []int {
	rows, err := db.QueryContext(ctx, `SELECT week_index FROM school_timetable_meeting_weeks WHERE meeting_rule_id = ? ORDER BY week_index`, ruleID)
	if err != nil {
		return nil
	}
	defer rows.Close()
	var result []int
	for rows.Next() {
		var value int
		if rows.Scan(&value) == nil {
			result = append(result, value)
		}
	}
	return result
}

func decodeStringMap(raw string) map[string]string {
	var decoded map[string]any
	if err := json.Unmarshal([]byte(raw), &decoded); err != nil {
		return map[string]string{}
	}
	result := make(map[string]string, len(decoded))
	for key, value := range decoded {
		result[key] = fmt.Sprint(value)
	}
	return result
}
