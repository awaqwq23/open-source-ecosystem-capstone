package contract

import (
	"strconv"
	"strings"
)

const (
	ClientBase = "/school-timetable"
)

func ArtifactKey(termKey string, version int) string {
	return "school-timetable/" + sanitizeObjectPart(termKey) + "/v" + strconv.Itoa(version) + ".sqlite.gz"
}

func sanitizeObjectPart(value string) string {
	replacer := strings.NewReplacer("/", "_", "\\", "_", " ", "_")
	value = replacer.Replace(strings.TrimSpace(value))
	value = strings.Trim(value, "_")
	if value == "" {
		return "unknown"
	}
	return value
}
