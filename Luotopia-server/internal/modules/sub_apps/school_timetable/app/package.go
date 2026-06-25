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
			Type: "database", SchemaVersion: 2, TermKey: term.TermKey,
			SchoolYear: term.SchoolYear, Term: term.Term,
			SchoolYearCode: term.SchoolYearCode, TermCode: term.TermCode,
			FirstWeekMonday: term.FirstWeekMonday,
			RowCount:        term.RowCount, Source: "sqlite", SourceChecksum: "",
		},
	}
	pkg.Courses, err = readCourses(ctx, db)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.Teachers, err = readTeachers(ctx, db)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.Offerings, err = readOfferings(ctx, db, term.TermKey)
	if err != nil {
		return domain.Package{}, err
	}
	pkg.OfferingTeachers, err = readOfferingTeachers(ctx, db, term.TermKey)
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
	pkg.Meetings, err = readMeetings(ctx, db, term.TermKey)
	if err != nil {
		return domain.Package{}, err
	}
	if pkg.Manifest.RowCount == 0 {
		pkg.Manifest.RowCount = len(pkg.SourceRows)
	}
	return pkg, nil
}

func readTerms(ctx context.Context, db *sql.DB) ([]domain.Term, error) {
	rows, err := db.QueryContext(ctx, `SELECT term_key, school_year, term, school_year_code, term_code, first_week_monday, row_count FROM school_timetable_terms ORDER BY term_key`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_terms", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.Term
	for rows.Next() {
		var item domain.Term
		if err := rows.Scan(&item.TermKey, &item.SchoolYear, &item.Term, &item.SchoolYearCode, &item.TermCode, &item.FirstWeekMonday, &item.RowCount); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readCourses(ctx context.Context, db *sql.DB) ([]domain.Course, error) {
	rows, err := db.QueryContext(ctx, `SELECT id, course_no, course_name, credits FROM school_timetable_courses ORDER BY id`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_courses", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.Course
	for rows.Next() {
		var item domain.Course
		if err := rows.Scan(&item.ID, &item.CourseNo, &item.CourseName, &item.Credits); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readTeachers(ctx context.Context, db *sql.DB) ([]domain.Teacher, error) {
	rows, err := db.QueryContext(ctx, `SELECT id, name, name_key, seq FROM school_timetable_teachers ORDER BY id`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_teachers", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.Teacher
	for rows.Next() {
		var item domain.Teacher
		if err := rows.Scan(&item.ID, &item.Name, &item.NameKey, &item.Seq); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readOfferings(ctx context.Context, db *sql.DB, termKey string) ([]domain.CourseOffering, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, term_key, course_id, term_course_id, source_key, teaching_class_name,
		       open_college, college_id, open_dept_id, course_nature, course_category, open_type,
		       people_raw, capacity, selected_count, theory_hours, computer_hours,
		       experiment_hours, practice_hours, remark, note, other_teachers,
		       textbook, publisher, search_text
		FROM school_timetable_offerings
		WHERE term_key = ?
		ORDER BY id`, termKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_offerings", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.CourseOffering
	for rows.Next() {
		var item domain.CourseOffering
		if err := rows.Scan(&item.ID, &item.TermKey, &item.CourseID, &item.TermCourseID, &item.SourceKey, &item.TeachingClassName,
			&item.OpenCollege, &item.CollegeID, &item.OpenDeptID, &item.CourseNature, &item.CourseCategory, &item.OpenType,
			&item.PeopleRaw, &item.Capacity, &item.SelectedCount, &item.TheoryHours, &item.ComputerHours,
			&item.ExperimentHours, &item.PracticeHours, &item.Remark, &item.Note, &item.OtherTeachers,
			&item.Textbook, &item.Publisher, &item.SearchText); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readOfferingTeachers(ctx context.Context, db *sql.DB, termKey string) ([]domain.OfferingTeacher, error) {
	rows, err := db.QueryContext(ctx, `SELECT id, offering_id, teacher_id, role, title, ordinal FROM school_timetable_offering_teachers ORDER BY id`)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_offering_teachers", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.OfferingTeacher
	for rows.Next() {
		var item domain.OfferingTeacher
		if err := rows.Scan(&item.ID, &item.OfferingID, &item.TeacherID, &item.Role, &item.Title, &item.Ordinal); err != nil {
			return nil, err
		}
		item.TermKey = termKey
		result = append(result, item)
	}
	return result, rows.Err()
}

func readAudiences(ctx context.Context, db *sql.DB, termKey string) ([]domain.CourseAudience, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, term_key, offering_id, grade, grade_code, major, major_code, plan_college,
		       course_nature_code, course_category_code, open_type_code, condition_code
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
		if err := rows.Scan(&item.ID, &item.TermKey, &item.OfferingID, &item.Grade, &item.GradeCode, &item.Major, &item.MajorCode, &item.PlanCollege,
			&item.CourseNatureCode, &item.CourseCategoryCode, &item.OpenTypeCode, &item.ConditionCode); err != nil {
			return nil, err
		}
		result = append(result, item)
	}
	return result, rows.Err()
}

func readSourceRows(ctx context.Context, db *sql.DB, termKey string) ([]domain.SourceRow, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, term_key, COALESCE(term_course_id, ''), COALESCE(offering_id, ''), source_key,
		       package_index, status, raw_fields_json
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

func readMeetings(ctx context.Context, db *sql.DB, termKey string) ([]domain.Meeting, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, offering_id, term_key, weekday, day_field, segment_index, weekday_label,
		       raw_day_text, raw_segment_text, week_text, section_text, section_start,
		       section_end, location_text, week_indexes, parse_status
		FROM school_timetable_meetings
		WHERE term_key = ?
		ORDER BY id`, termKey)
	if err != nil {
		return nil, fmt.Errorf("%w: school_timetable_meetings", ErrInvalidPackage)
	}
	defer rows.Close()
	var result []domain.Meeting
	for rows.Next() {
		var item domain.Meeting
		var weeks string
		if err := rows.Scan(&item.ID, &item.OfferingID, &item.TermKey, &item.Weekday, &item.DayField, &item.SegmentIndex, &item.WeekdayLabel,
			&item.RawDayText, &item.RawSegmentText, &item.WeekText, &item.SectionText, &item.SectionStart,
			&item.SectionEnd, &item.LocationText, &weeks, &item.ParseStatus); err != nil {
			return nil, err
		}
		item.WeekIndexes = decodeIntList(weeks)
		result = append(result, item)
	}
	return result, rows.Err()
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

func decodeIntList(raw string) []int {
	if raw == "" {
		return nil
	}
	var decoded []int
	if err := json.Unmarshal([]byte(raw), &decoded); err != nil {
		return nil
	}
	return decoded
}
