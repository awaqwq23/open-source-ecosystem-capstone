package contract

import (
	"net/url"
	"strconv"
)

const (
	ClientBase         = "/school-timetable"
	SnapshotRoute      = "/terms/:termKey/releases/:version/snapshot"
	clientAPIPrefix    = "/api/v1"
	snapshotPathPrefix = clientAPIPrefix + ClientBase + "/terms/"
)

func SnapshotPath(termKey string, version int) string {
	return snapshotPathPrefix + url.PathEscape(termKey) + "/releases/" + strconv.Itoa(version) + "/snapshot"
}
