package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"os"
	"path/filepath"

	"github.com/openwhu/luotopia/server/internal/modules/sub_apps/school_timetable/app"
)

func main() {
	inputPath := flag.String("input", "", "path to school timetable ndjson.gz package")
	outputPath := flag.String("output", "", "path to write sqlite.gz artifact")
	version := flag.Int("version", 1, "artifact version")
	flag.Parse()

	if *inputPath == "" || *outputPath == "" {
		fmt.Fprintln(os.Stderr, "usage: school-timetable-artifact -input <package.ndjson.gz> -output <artifact.sqlite.gz> [-version 1]")
		os.Exit(2)
	}

	input, err := os.Open(*inputPath)
	if err != nil {
		fail(err)
	}
	defer input.Close()

	pkg, err := app.ParsePackage(context.Background(), input)
	if err != nil {
		fail(err)
	}
	records := app.BuildRecords(pkg)

	tempDir, err := os.MkdirTemp("", "school-timetable-artifact-*")
	if err != nil {
		fail(err)
	}
	defer os.RemoveAll(tempDir)

	artifact, err := app.BuildSQLiteArtifact(context.Background(), pkg, records, *version, tempDir)
	if err != nil {
		fail(err)
	}
	if err := os.MkdirAll(filepath.Dir(*outputPath), 0755); err != nil {
		fail(err)
	}
	if err := copyFile(artifact.Path, *outputPath); err != nil {
		fail(err)
	}

	fmt.Printf("term_key=%s\n", pkg.Manifest.TermKey)
	fmt.Printf("version=%d\n", *version)
	fmt.Printf("artifact_type=%s\n", artifact.ArtifactType)
	fmt.Printf("schema_version=%d\n", artifact.SchemaVersion)
	fmt.Printf("row_count=%d\n", len(pkg.Rows))
	fmt.Printf("checksum=%s\n", artifact.Checksum)
	fmt.Printf("size=%d\n", artifact.Size)
	fmt.Printf("output=%s\n", *outputPath)
}

func copyFile(srcPath string, dstPath string) error {
	src, err := os.Open(srcPath)
	if err != nil {
		return err
	}
	defer src.Close()
	dst, err := os.Create(dstPath)
	if err != nil {
		return err
	}
	defer dst.Close()
	_, err = io.Copy(dst, src)
	return err
}

func fail(err error) {
	fmt.Fprintln(os.Stderr, err)
	os.Exit(1)
}
