package contract

import "net/url"

const (
	ClientBase       = "/hot-update/scripts"
	ContentRoute     = "/:name/content"
	clientAPIPrefix  = "/api/v1"
	contentPathStart = clientAPIPrefix + ClientBase + "/"
)

func ScriptContentPath(name string) string {
	return contentPathStart + url.PathEscape(name) + "/content"
}
