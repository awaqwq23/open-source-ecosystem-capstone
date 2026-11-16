# API Resource Contracts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 收拢服务端资源链接契约，避免 pull 或客户端手写其它模块的下载路径。

**Architecture:** 由资源生产模块拥有 HTTP contract 包，transport 用同一份 route 模板注册，聚合模块用同一份 path builder 生成链接。pull 响应使用通用 `links` 对象表达二级资源，Flutter 只跟随服务端下发的链接。

**Tech Stack:** Go/Gin 服务端、Dart/Flutter 客户端、Go unit tests、Flutter test。

---

### Task 1: 服务端 contract 包与 pull links 契约

**Files:**
- Create: `src/Luotopia-server/internal/modules/sub_apps/school_timetable/contract/http.go`
- Create: `src/Luotopia-server/internal/modules/sub_apps/school_timetable/contract/http_test.go`
- Create: `src/Luotopia-server/internal/modules/push-and-pull/hot_update/contract/http.go`
- Create: `src/Luotopia-server/internal/modules/push-and-pull/hot_update/contract/http_test.go`
- Modify: `src/Luotopia-server/internal/modules/sub_apps/school_timetable/transport/http.go`
- Modify: `src/Luotopia-server/internal/modules/push-and-pull/hot_update/transport/http.go`
- Modify: `src/Luotopia-server/internal/modules/push-and-pull/pull/domain/types.go`
- Modify: `src/Luotopia-server/internal/modules/push-and-pull/pull/app/service.go`
- Test: `src/Luotopia-server/internal/modules/push-and-pull/pull/app/service_test.go`

- [ ] Write failing tests for contract path builders and pull response links.
- [ ] Run targeted Go tests and confirm they fail because contract/link code is missing.
- [ ] Add minimal contract packages, route registration usage, and `links` response fields.
- [ ] Run targeted Go tests and confirm they pass.

### Task 2: Flutter links parsing and download consumption

**Files:**
- Modify: `src/Luotopia-app/lib/features/unified_pull/data/pull_response.dart`
- Modify: `src/Luotopia-app/lib/features/unified_pull/domain/pull_service.dart`
- Modify: `src/Luotopia-app/test/features/unified_pull/pull_response_test.dart`

- [ ] Write failing Flutter test for `links.snapshot.href` and `links.content.href` parsing.
- [ ] Run targeted Flutter test and confirm it fails because links parsing is missing.
- [ ] Add minimal `ApiLink` parsing and switch download calls to link hrefs.
- [ ] Run targeted Flutter test and confirm it passes.

### Task 3: Contract documentation and verification

**Files:**
- Create: `src/Luotopia-server/api/openapi/client.v1.yaml`

- [ ] Document the pull response link shape and resource download endpoints.
- [ ] Run Go targeted tests, Flutter targeted test, and source searches for forbidden hard-coded resource paths.
- [ ] Commit only files touched for this task; do not include unrelated existing working tree changes.
