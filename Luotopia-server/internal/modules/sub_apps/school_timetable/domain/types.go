package domain

import "time"

type Manifest struct {
	Type           string   `json:"type"`
	SchemaVersion  int      `json:"schema_version"`
	TermKey        string   `json:"term_key"`
	SchoolYear     string   `json:"school_year"`
	Term           string   `json:"term"`
	FieldCodes     []string `json:"field_codes"`
	RowCount       int      `json:"row_count"`
	GeneratedAt    string   `json:"generated_at"`
	Source         string   `json:"source"`
	SourceChecksum string   `json:"source_checksum"`
}

type Package struct {
	Manifest Manifest
	Rows     []map[string]string
}

type Term struct {
	TermKey     string    `json:"term_key"`
	SchoolYear  string    `json:"school_year"`
	Term        string    `json:"term"`
	Version     int       `json:"version"`
	Checksum    string    `json:"checksum"`
	RowCount    int       `json:"row_count"`
	PublishedAt time.Time `json:"published_at"`
}

type Release struct {
	TermKey     string    `json:"term_key"`
	Version     int       `json:"version"`
	Checksum    string    `json:"checksum"`
	FileKey     string    `json:"file_key"`
	RowCount    int       `json:"row_count"`
	Active      bool      `json:"active"`
	PublishedAt time.Time `json:"published_at"`
}

type RawRow struct {
	ID                string
	TermKey           string
	CourseHeadID      string
	SourceKey         string
	SchoolYear        string
	Term              string
	TeachingClassName string
	CourseNo          string
	CourseName        string
	OpenCollege       string
	PlanCollege       string
	Credits           string
	CourseNature      string
	CourseCategory    string
	OpenType          string
	Grade             string
	Major             string
	Instructor        string
	Title             string
	PeopleRaw         string
	Fields            map[string]string
}

type CourseHead struct {
	ID                 string
	TermKey            string
	CourseHeadKey      string
	CourseNo           string
	CourseName         string
	OpenCollege        string
	Credits            string
	CourseNature       string
	CourseCategory     string
	OpenType           string
	TeachingClassCount int
	TeacherSummary     string
	WeekdaySummary     string
	SearchText         string
}

type Meeting struct {
	ID           string
	RawRowID     string
	TermKey      string
	CourseHeadID string
	Weekday      int
	SegmentIndex int
	WeekdayLabel string
	RawText      string
	LocationText string
	Building     string
	Room         string
}

type ImportResult struct {
	Manifest Manifest `json:"manifest"`
	Checksum string   `json:"checksum"`
	RowCount int      `json:"row_count"`
	Version  int      `json:"version,omitempty"`
}
