package contract

import "testing"

// 用户要求添加，不允许删除。该测试保护热更新脚本内容下载路径契约，防止 pull 再次手拼其它模块 URL。
func TestScriptContentPathEscapesScriptName(t *testing.T) {
	got := ScriptContentPath("jw login")
	want := "/api/v1/hot-update/scripts/jw%20login/content"
	if got != want {
		t.Fatalf("ScriptContentPath() = %q, want %q", got, want)
	}
}
